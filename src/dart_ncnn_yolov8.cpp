#include "dart_ncnn_yolov8.h"

#include <stdbool.h>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include "cpu.h"
#include "net.h"

ncnn::Net yolo;
ncnn::UnlockedPoolAllocator blob_pool_allocator;
ncnn::PoolAllocator workspace_pool_allocator;

struct Object {
    int label;
    float prob;
    cv::Rect_<float> rect;
};

struct GridAndStride {
    int grid0;
    int grid1;
    int stride;
};

static float fast_exp(float x) {
    union {
        uint32_t i;
        float f;
    } v{};
    v.i = (1 << 23) * (1.4426950409 * x + 126.93490512f);
    return v.f;
}

static float sigmoid(float x) {
    return 1.0f / (1.0f + fast_exp(-x));
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

static void generate_grids_and_stride(const int target_w, const int target_h, std::vector<int> &strides,
                                      std::vector<GridAndStride> &grid_strides) {
    for (int i = 0; i < (int)strides.size(); i++) {
        int stride = strides[i];
        int num_grid_w = target_w / stride;
        int num_grid_h = target_h / stride;
        for (int g1 = 0; g1 < num_grid_h; g1++) {
            for (int g0 = 0; g0 < num_grid_w; g0++) {
                GridAndStride gs;
                gs.grid0 = g0;
                gs.grid1 = g1;
                gs.stride = stride;
                grid_strides.push_back(gs);
            }
        }
    }
}

static void generate_proposals(std::vector<GridAndStride> grid_strides, const ncnn::Mat &pred, float prob_threshold,
                               std::vector<Object> &objects) {
    const int num_points = grid_strides.size();
    const int num_class = 80;
    const int reg_max_1 = 16;

    for (int i = 0; i < num_points; i++) {
        const float *scores = pred.row(i) + 4 * reg_max_1;

        // find label with max score
        int label = -1;
        float score = -FLT_MAX;
        for (int k = 0; k < num_class; k++) {
            float confidence = scores[k];
            if (confidence > score) {
                label = k;
                score = confidence;
            }
        }
        float box_prob = sigmoid(score);
        if (box_prob >= prob_threshold) {
            ncnn::Mat bbox_pred(reg_max_1, 4, (void *)pred.row(i));
            {
                ncnn::Layer *softmax = ncnn::create_layer("Softmax");

                ncnn::ParamDict pd;
                pd.set(0, 1); // axis
                pd.set(1, 1);
                softmax->load_param(pd);

                ncnn::Option opt;
                opt.num_threads = 1;
                opt.use_packing_layout = false;

                softmax->create_pipeline(opt);

                softmax->forward_inplace(bbox_pred, opt);

                softmax->destroy_pipeline(opt);

                delete softmax;
            }

            float pred_ltrb[4];
            for (int k = 0; k < 4; k++) {
                float dis = 0.f;
                const float *dis_after_sm = bbox_pred.row(k);
                for (int l = 0; l < reg_max_1; l++) {
                    dis += l * dis_after_sm[l];
                }

                pred_ltrb[k] = dis * grid_strides[i].stride;
            }

            float pb_cx = (grid_strides[i].grid0 + 0.5f) * grid_strides[i].stride;
            float pb_cy = (grid_strides[i].grid1 + 0.5f) * grid_strides[i].stride;

            float x0 = pb_cx - pred_ltrb[0];
            float y0 = pb_cy - pred_ltrb[1];
            float x1 = pb_cx + pred_ltrb[2];
            float y1 = pb_cy + pred_ltrb[3];

            Object obj;
            obj.rect.x = x0;
            obj.rect.y = y0;
            obj.rect.width = x1 - x0;
            obj.rect.height = y1 - y0;
            obj.label = label;
            obj.prob = box_prob;

            objects.push_back(obj);
        }
    }
}


static bool detect(const unsigned char *pixels, int type, int width, int height, std::vector<Object> &objects,
                   float prob_threshold, float nms_threshold, int target_size) {
    const float mean_value[3] = {103.53f, 116.28f, 123.675f};
    const float norm_value[3] = {1 / 255.f, 1 / 255.f, 1 / 255.f};
    // pad to multiple of 32
    int w = width;
    int h = height;
    float scale;
    if (w > h) {
        scale = (float)target_size / w;
        w = target_size;
        h = h * scale;
    } else {
        scale = (float)target_size / h;
        h = target_size;
        w = w * scale;
    }

    ncnn::Mat in = ncnn::Mat::from_pixels_resize(pixels, type, width, height, w, h);

    // pad to target_size rectangle
    int w_pad = (w + 31) / 32 * 32 - w;
    int h_pad = (h + 31) / 32 * 32 - h;
    ncnn::Mat in_pad;
    ncnn::copy_make_border(in, in_pad, h_pad / 2, h_pad - h_pad / 2, w_pad / 2, w_pad - w_pad / 2,
                           ncnn::BORDER_CONSTANT, 0.f);

    in_pad.substract_mean_normalize(0, norm_value);

    ncnn::Extractor ex = yolo.create_extractor();

    ex.input("images", in_pad);

    std::vector<Object> proposals;

    ncnn::Mat out;
    ex.extract("output", out);

    std::vector<int> strides = {8, 16, 32}; // might have stride=64
    std::vector<GridAndStride> grid_strides;
    generate_grids_and_stride(in_pad.w, in_pad.h, strides, grid_strides);
    generate_proposals(grid_strides, out, prob_threshold, proposals);

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

static bool detect_yolo_cv_mat(const cv::Mat &bgr, float prob_threshold, float nms_threshold, int target_size,
                                std::vector<Object> &objects) {
    int img_w = bgr.cols;
    int img_h = bgr.rows;
    return detect(bgr.data, ncnn::Mat::PIXEL_BGR, img_w, img_h, objects, prob_threshold, nms_threshold, target_size);
}

static bool detect_yolo_pixels(const unsigned char *pixels, int pixelType, int width, int height, float prob_threshold,
                                float nms_threshold, int target_size, std::vector<Object> &objects) {
    return detect(pixels, pixelType, width, height, objects, prob_threshold, nms_threshold, target_size);
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

FFI_PLUGIN_EXPORT void yoloLoad(const char *model_path, const char *param_path, int target_size, int use_gpu) {
    blob_pool_allocator.set_size_compare_ratio(0.f);
    workspace_pool_allocator.set_size_compare_ratio(0.f);

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
}

FFI_PLUGIN_EXPORT void yoloUnload() {
    yolo.clear();
    blob_pool_allocator.clear();
    workspace_pool_allocator.clear();
}

FFI_PLUGIN_EXPORT char *detectWithImagePath(const char *image_path, float prob_threshold, float nms_threshold, int target_size) {
    cv::Mat bgr = cv::imread(image_path, 1);
    if (bgr.empty()) {
        fprintf(stderr, "cv::imread %s failed\n", image_path);
    }
    std::vector<Object> objects;
    detect_yolo_cv_mat(bgr, prob_threshold, nms_threshold, target_size, objects);
    return parseResultsObjects(objects);
}

FFI_PLUGIN_EXPORT char *detectWithPixels(const unsigned char *pixels, int pixelType, int width, int height,
                                         float prob_threshold, float nms_threshold, int target_size) {
    std::vector<Object> objects;
    detect_yolo_pixels(pixels, pixelType, width, height, prob_threshold, nms_threshold, target_size, objects);
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
