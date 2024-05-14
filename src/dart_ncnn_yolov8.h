#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif

// YOLO
FFI_PLUGIN_EXPORT void yoloLoad(const char *model_path, const char *param_path, int target_size, int num_class, int use_gpu);

FFI_PLUGIN_EXPORT void yoloUnload();

FFI_PLUGIN_EXPORT char *detectWithImagePath(const char *image_path, float prob_threshold, float nms_threshold, int target_size);

FFI_PLUGIN_EXPORT char *detectWithPixels(const unsigned char *pixels, int pixelType, int width, int height,
                                         float prob_threshold, float nms_threshold, int target_size);

FFI_PLUGIN_EXPORT void yuv420sp2rgb(const unsigned char *yuv420sp, int width, int height, unsigned char *rgb);

FFI_PLUGIN_EXPORT void rgb2rgba(const unsigned char *rgb, int width, int height, unsigned char *rgba);

FFI_PLUGIN_EXPORT void kannaRotate(const unsigned char *src, int channel, int srcw, int srch, unsigned char *dst,
                                   int dsw, int dsh, int type);

#ifdef __cplusplus
}
#endif
