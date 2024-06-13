#include "dart_ncnn_yolov8.h"

#include <stdbool.h>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include "cpu.h"
#include "net.h"

struct Object {
    int label;
    float prob;
    cv::Rect_<float> rect;
};

class Yolo {
  public:
    Yolo();

    bool load(const char *model_path, const char *param_path, int _target_size, int _num_class, bool use_gpu = false);

    bool detect(const unsigned char *pixels, int type, int width, int height, std::vector<Object> &objects,
                float prob_threshold = 0.6f, float nms_threshold = 0.5f);

  private:
    ncnn::Net yolo;
    int num_class;
    int target_size;
    float norm_value[3];
    ncnn::UnlockedPoolAllocator blob_pool_allocator;
    ncnn::PoolAllocator workspace_pool_allocator;
};

static void transpose(const ncnn::Mat &in, ncnn::Mat &out) {
    // transpose Mat, chw to cwh

    ncnn::Option opt;
    opt.num_threads = 2;
    opt.use_fp16_storage = false;
    opt.use_packing_layout = true;

    ncnn::Layer *op = ncnn::create_layer("Permute");

    // set param
    ncnn::ParamDict pd;
    pd.set(0, 1); // order_type

    op->load_param(pd);

    op->create_pipeline(opt);

    ncnn::Mat in_packed = in;
    {
        // resolve dst_elempack
        int dims = in.dims;
        int elemcount = 0;
        if (dims == 1)
            elemcount = in.elempack * in.w;
        if (dims == 2)
            elemcount = in.elempack * in.h;
        if (dims == 3)
            elemcount = in.elempack * in.c;

        int dst_elempack = 1;
        if (op->support_packing) {
            if (elemcount % 8 == 0 && (ncnn::cpu_support_x86_avx2() || ncnn::cpu_support_x86_avx()))
                dst_elempack = 8;
            else if (elemcount % 4 == 0)
                dst_elempack = 4;
        }

        if (in.elempack != dst_elempack) {
            convert_packing(in, in_packed, dst_elempack, opt);
        }
    }

    // forward
    op->forward(in_packed, out, opt);

    op->destroy_pipeline(opt);

    delete op;
}

static float intersection_area(const Object &a, const Object &b) {
    cv::Rect_<float> inter = a.rect & b.rect;
    return inter.area();
}

static void qsort_descent_inplace(std::vector<Object> &face_objects, int left, int right) {
    int i = left;
    int j = right;
    float p = face_objects[(left + right) / 2].prob;

    while (i <= j) {
        while (face_objects[i].prob > p)
            i++;

        while (face_objects[j].prob < p)
            j--;

        if (i <= j) {
            // swap
            std::swap(face_objects[i], face_objects[j]);

            i++;
            j--;
        }
    }

    //     #pragma omp parallel sections
    {
        //         #pragma omp section
        {
            if (left < j)
                qsort_descent_inplace(face_objects, left, j);
        }
        //         #pragma omp section
        {
            if (i < right)
                qsort_descent_inplace(face_objects, i, right);
        }
    }
}

static void qsort_descent_inplace(std::vector<Object> &face_objects) {
    if (face_objects.empty())
        return;

    qsort_descent_inplace(face_objects, 0, face_objects.size() - 1);
}

static void nms_sorted_bboxes(const std::vector<Object> &face_objects, std::vector<int> &picked, float nms_threshold) {
    picked.clear();

    const int n = face_objects.size();

    std::vector<float> areas(n);
    for (int i = 0; i < n; i++) {
        areas[i] = face_objects[i].rect.width * face_objects[i].rect.height;
    }

    for (int i = 0; i < n; i++) {
        const Object &a = face_objects[i];

        int keep = 1;
        for (int j = 0; j < (int)picked.size(); j++) {
            const Object &b = face_objects[picked[j]];

            // intersection over union
            float inter_area = intersection_area(a, b);
            float union_area = areas[i] + areas[picked[j]] - inter_area;
            // float IoU = inter_area / union_area
            if (inter_area / union_area > nms_threshold)
                keep = 0;
        }

        if (keep)
            picked.push_back(i);
    }
}

static void generate_proposals(const ncnn::Mat &pred, int num_class, float prob_threshold,
                               std::vector<Object> &objects) {
    ncnn::Mat output;
    transpose(pred, output);

    for (int i = 0; i < output.h; i++) {
        float *data = output.row(i);
        float *classes_scores = data + 4;

        // find label with max score
        int label = -1;
        float max_class_score = -FLT_MAX;
        for (int k = 0; k < num_class; k++) {
            float confidence = classes_scores[k];
            if (confidence > max_class_score) {
                label = k;
                max_class_score = confidence;
            }
        }

        if (max_class_score > prob_threshold) {
            float x = data[0];
            float y = data[1];
            float w = data[2];
            float h = data[3];

            int left = int(x - 0.5 * w);
            int top = int(y - 0.5 * h);

            int width = int(w);
            int height = int(h);

            Object obj;
            obj.rect = cv::Rect(left, top, width, height);
            obj.label = label;
            obj.prob = max_class_score;
            objects.push_back(obj);
        }
    }
}

Yolo::Yolo() {
    blob_pool_allocator.set_size_compare_ratio(0.f);
    workspace_pool_allocator.set_size_compare_ratio(0.f);
}

bool Yolo::load(const char *model_path, const char *param_path, int _target_size, int _num_class, bool use_gpu) {
    const float _norm_value[3] = {1 / 255.f, 1 / 255.f, 1 / 255.f};
    yolo.clear();
    blob_pool_allocator.clear();
    workspace_pool_allocator.clear();

    ncnn::set_cpu_powersave(2);
    ncnn::set_omp_num_threads(ncnn::get_big_cpu_count());

    yolo.opt = ncnn::Option();

#if NCNN_VULKAN
    yolo.opt.use_vulkan_compute = use_gpu;
#endif

    yolo.opt.num_threads = ncnn::get_big_cpu_count();
    yolo.opt.blob_allocator = &blob_pool_allocator;
    yolo.opt.workspace_allocator = &workspace_pool_allocator;

    yolo.load_param(param_path);
    yolo.load_model(model_path);

    num_class = _num_class;
    target_size = _target_size;
    norm_value[0] = _norm_value[0];
    norm_value[1] = _norm_value[1];
    norm_value[2] = _norm_value[2];

    return true;
}

bool Yolo::detect(const unsigned char *pixels, int type, int width, int height, std::vector<Object> &objects,
                  float prob_threshold, float nms_threshold) {
    // pad to multiple of 32
    int w = width;
    int h = height;
    // pad to target_size rectangle
    int w_pad, h_pad;
    float scale;
    if (w > h) {
        scale = (float)target_size / w;
        w = target_size;
        h = h * scale;
        w_pad = 0;
        h_pad = w - h;
    } else {
        scale = (float)target_size / h;
        h = target_size;
        w = w * scale;
        h_pad = 0;
        w_pad = h - w;
    }

    ncnn::Mat in = ncnn::Mat::from_pixels_resize(pixels, type, width, height, w, h);

    ncnn::Mat in_pad;
    ncnn::copy_make_border(in, in_pad, h_pad / 2, h_pad - h_pad / 2, w_pad / 2, w_pad - w_pad / 2,
                           ncnn::BORDER_CONSTANT, 0.f);

    in_pad.substract_mean_normalize(0, norm_value);

    ncnn::Extractor ex = yolo.create_extractor();

    ex.input("in0", in_pad);

    std::vector<Object> proposals;

    ncnn::Mat out;
    ex.extract("out0", out);

    generate_proposals(out, num_class, prob_threshold, proposals);

    // sort all proposals by score from highest to lowest
    qsort_descent_inplace(proposals);

    // apply nms with nms_threshold
    std::vector<int> picked;
    nms_sorted_bboxes(proposals, picked, nms_threshold);

    int count = picked.size();

    objects.resize(count);
    for (int i = 0; i < count; i++) {
        objects[i] = proposals[picked[i]];

        // adjust offset to original unpadded
        float x0 = (objects[i].rect.x - (w_pad / 2)) / scale;
        float y0 = (objects[i].rect.y - (h_pad / 2)) / scale;
        float x1 = (objects[i].rect.x + objects[i].rect.width - (w_pad / 2)) / scale;
        float y1 = (objects[i].rect.y + objects[i].rect.height - (h_pad / 2)) / scale;

        // clip
        x0 = std::max(std::min(x0, (float)(width - 1)), 0.f);
        y0 = std::max(std::min(y0, (float)(height - 1)), 0.f);
        x1 = std::max(std::min(x1, (float)(width - 1)), 0.f);
        y1 = std::max(std::min(y1, (float)(height - 1)), 0.f);

        objects[i].rect.x = x0;
        objects[i].rect.y = y0;
        objects[i].rect.width = x1 - x0;
        objects[i].rect.height = y1 - y0;
    }

    // sort objects by area
    struct {
        bool operator()(const Object &a, const Object &b) const {
            return a.rect.area() > b.rect.area();
        }
    } objects_area_greater;
    std::sort(objects.begin(), objects.end(), objects_area_greater);
    return true;
}

char *parseResultsObjects(std::vector<Object> &objects) {
    if (objects.size() == 0) {
        NCNN_LOGE("No object detected");
        return (char *)"";
    }

    std::string result = "";
    for (int i = 0; i < (int)objects.size(); i++) {
        Object obj = objects[i];
        result += std::to_string(obj.rect.x) + "," + std::to_string(obj.rect.y) + "," + std::to_string(obj.rect.width) +
                  "," + std::to_string(obj.rect.height) + "," + std::to_string(obj.label) + "," +
                  std::to_string(obj.prob) + "\n";
    }

    char *result_c = new char[result.length() + 1];
    strcpy(result_c, result.c_str());
    return result_c;
}

static Yolo *g_yolo = 0;
static ncnn::Mutex lock;

FFI_PLUGIN_EXPORT void yoloLoad(const char *model_path, const char *param_path, int target_size, int num_class,
                                int use_gpu) {
    {
        ncnn::MutexLockGuard g(lock);

        if (use_gpu && ncnn::get_gpu_count() == 0) {
            // no gpu
            delete g_yolo;
            g_yolo = 0;
        } else {
            if (!g_yolo)
                g_yolo = new Yolo;
            g_yolo->load(model_path, param_path, target_size, num_class, use_gpu);
        }
    }
}

FFI_PLUGIN_EXPORT void yoloUnload() {
    {
        ncnn::MutexLockGuard g(lock);

        delete g_yolo;
        g_yolo = 0;
    }
}

FFI_PLUGIN_EXPORT char *detectWithImagePath(const char *image_path, float prob_threshold, float nms_threshold,
                                            int target_size) {
    cv::Mat bgr = cv::imread(image_path, 1);
    if (bgr.empty()) {
        fprintf(stderr, "cv::imread %s failed\n", image_path);
    }
    std::vector<Object> objects;
    int img_w = bgr.cols;
    int img_h = bgr.rows;
    {
        ncnn::MutexLockGuard g(lock);

        if (g_yolo) {
            g_yolo->detect(bgr.data, ncnn::Mat::PIXEL_BGR2RGB, img_w, img_h, objects, prob_threshold, nms_threshold);
        }
    }
    return parseResultsObjects(objects);
}

FFI_PLUGIN_EXPORT char *detectWithPixels(const unsigned char *pixels, int pixelType, int width, int height,
                                         float prob_threshold, float nms_threshold, int target_size) {
    std::vector<Object> objects;
    {
        ncnn::MutexLockGuard g(lock);

        if (g_yolo) {
            g_yolo->detect(pixels, pixelType, width, height, objects, prob_threshold, nms_threshold);
        }
    }
    return parseResultsObjects(objects);
}

FFI_PLUGIN_EXPORT void yuv420sp2rgb(const unsigned char *yuv420sp, int width, int height, unsigned char *rgb) {
    ncnn::yuv420sp2rgb(yuv420sp, width, height, rgb);
    return;
}

FFI_PLUGIN_EXPORT void rgb2rgba(const unsigned char *rgb, int width, int height, unsigned char *rgba) {
    ncnn::Mat m = ncnn::Mat::from_pixels(rgb, ncnn::Mat::PIXEL_RGB2BGRA, width, height);
    m.to_pixels(rgba, ncnn::Mat::PIXEL_RGBA);
    return;
}

FFI_PLUGIN_EXPORT void kannaRotate(const unsigned char *src, int channel, int srcw, int srch, unsigned char *dst,
                                   int dsw, int dsh, int type) {
    switch (channel) {
    case 1:
        ncnn::kanna_rotate_c1(src, srcw, srch, dst, dsw, dsh, type);
        break;
    case 2:
        ncnn::kanna_rotate_c2(src, srcw, srch, dst, dsw, dsh, type);
        break;
    case 3:
        ncnn::kanna_rotate_c3(src, srcw, srch, dst, dsw, dsh, type);
        break;
    case 4:
        ncnn::kanna_rotate_c4(src, srcw, srch, dst, dsw, dsh, type);
        break;
    }
    return;
}
