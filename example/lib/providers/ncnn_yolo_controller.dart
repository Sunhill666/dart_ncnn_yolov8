import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:dart_ncnn_yolov8/dart_ncnn_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'my_camera_controller.dart';
import 'ncnn_yolo_options.dart';

final ncnnYoloController =
    StateNotifierProvider<NcnnYoloController, List<YoloResult>>(
  NcnnYoloController.new,
);

class NcnnYoloController extends StateNotifier<List<YoloResult>> {
  NcnnYoloController(this.ref) : super([]);

  final Ref ref;

  final _ncnnYolo = DartNcnnYolo();

  static final previewImage = StateProvider<ui.Image?>(
    (_) => null,
  );

  Future<void> initialize() async {
    await _ncnnYolo.yoloLoad(
      modelPath: 'assets/yolo/yolov8n.bin',
      paramPath: 'assets/yolo/yolov8n.param',
      autoDispose: ref.read(ncnnYoloOptions).autoDispose,
      probThreshold: ref.read(ncnnYoloOptions).probThreshold,
      nmsThreshold: ref.read(ncnnYoloOptions).nmsThreshold,
      targetSize: ref.read(ncnnYoloOptions).targetSize,
      numClass: ref.read(ncnnYoloOptions).numClass,
      useGPU: ref.read(ncnnYoloOptions).useGPU,
    );
  }

  Future<void> detectFromImageFile(XFile file) async {
    state = _ncnnYolo.detectImageFile(file.path);
    log(state.toString());

    final decodedImage = await decodeImageFromList(
      File(
        file.path,
      ).readAsBytesSync(),
    );
    ref.read(previewImage.notifier).state = decodedImage;
  }

  Future<void> detectFromCameraImage(CameraImage cameraImage) async {
    final completer = Completer<void>();
    final stopwatch = Stopwatch()..start();

    switch (cameraImage.format.group) {
      case ImageFormatGroup.unknown:
      case ImageFormatGroup.jpeg:
        log('not support format');
        return;
      case ImageFormatGroup.yuv420:
        state = _ncnnYolo
            .detectYUV420(
              y: cameraImage.planes[0].bytes,
              u: cameraImage.planes[1].bytes,
              v: cameraImage.planes[2].bytes,
              height: cameraImage.height,
              deviceOrientationType:
                  ref.read(myCameraController).deviceOrientationType,
              sensorOrientation: ref.read(myCameraController).sensorOrientation,
              onDecodeImage: (image) {
                ref.read(previewImage.notifier).state = image;
                completer.complete();
              },
            )
            .result;
        break;
      case ImageFormatGroup.bgra8888:
        state = _ncnnYolo
            .detectBGRA8888(
              pixels: cameraImage.planes[0].bytes,
              height: cameraImage.height,
              deviceOrientationType:
                  ref.read(myCameraController).deviceOrientationType,
              sensorOrientation: ref.read(myCameraController).sensorOrientation,
              onDecodeImage: (image) {
                ref.read(previewImage.notifier).state = image;
                completer.complete();
              },
            )
            .result;
        break;
      case ImageFormatGroup.nv21:
        break;
    }

    stopwatch.stop();
    log('detect fps: ${1000 / stopwatch.elapsedMilliseconds}');

    return completer.future;
  }
}
