# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(dart_ncnn_yolov8_library VERSION 0.0.1 LANGUAGES CXX)

get_filename_component(PROJECT_FOLDER ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(ncnn_DIR ${PROJECT_FOLDER}/linux/ncnn/lib/cmake)
  set(OpenCV_DIR ${PROJECT_FOLDER}/linux/opencv-mobile/lib/cmake)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Android")
  set(ncnn_DIR ${PROJECT_FOLDER}/android/src/main/cpp/ncnn/${ANDROID_ABI}/lib/cmake/ncnn)
  set(OpenCV_DIR ${PROJECT_FOLDER}/android/src/main/cpp/opencv-mobile/sdk/native/jni)
else()
  message(FATAL_ERROR "system not support: ${CMAKE_SYSTEM_NAME}")
endif()

find_package(OpenCV 4 REQUIRED)

find_package(ncnn REQUIRED)

include_directories(
  ${PROJECT_FOLDER}/src
  ${OpenCV_INCLUDE_DIRS}
)

add_library(dart_ncnn_yolov8 SHARED
  "dart_ncnn_yolov8.cpp"
)

set_target_properties(dart_ncnn_yolov8 PROPERTIES
  PUBLIC_HEADER dart_ncnn_yolov8.h
  OUTPUT_NAME "dart_ncnn_yolov8"
)

target_link_libraries(dart_ncnn_yolov8
    ncnn
    ${OpenCV_LIBS}
)

target_compile_definitions(dart_ncnn_yolov8 PUBLIC DART_SHARED_LIB)
