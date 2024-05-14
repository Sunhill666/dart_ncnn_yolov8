import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'dart_ncnn_yolov8_bindings_generated.dart';
import 'models/detect_result.dart';
import 'models/kanna_rotate/kanna_rotate_device_orientation_type.dart';
import 'models/kanna_rotate/kanna_rotate_result.dart';
import 'models/kanna_rotate/kanna_rotate_type.dart';
import 'models/pixel_channel.dart';
import 'models/pixel_format.dart';
import 'models/yolo_result.dart';

const yoloProbThresholdDefault = 0.6;

const yoloNmsThresholdDefault = 0.5;

const yoloTargetSizeDefault = 320;

const String _libName = 'dart_ncnn_yolov8';

class DartNcnnYolo {

  DartNcnnYolo() {
    _bindings = DartNcnnYolov8Bindings(_dylib);
  }

  /// The dynamic library in which the symbols for [DartNcnnYolov8Bindings] can be found.
  final DynamicLibrary _dylib = () {
    if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.open('$_libName.framework/$_libName');
    }
    if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open('lib$_libName.so');
    }
    if (Platform.isWindows) {
      return DynamicLibrary.open('$_libName.dll');
    }
    throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }();

  /// The bindings to the native functions in [_dylib].
  late DartNcnnYolov8Bindings _bindings;

  /// Threshold of bounding box prob.
  double _probThreshold = yoloProbThresholdDefault;
  double get probThreshold => _probThreshold;

  /// NMS threshold.
  double _nmsThreshold = yoloNmsThresholdDefault;
  double get nmsThreshold => _nmsThreshold;

  /// Target image size after resize.
  int _targetSize = yoloTargetSizeDefault;
  int get targetSize => _targetSize;

  /// Initialize YOLO
  /// Run it for the first time
  ///
  /// - [modelPath] - path to model file. like "assets/yolo.bin"
  /// - [paramPath] - path to parameter file. like "assets/yolo.param"
  /// - [autoDispose] - If true, multiple calls to initYolo will automatically dispose of recently loaded model.
  /// - [probThreshold] Threshold of bounding box prob.
  /// - [nmsThreshold] NMS threshold.
  /// - [targetSize] Target image size after resize, might use 416 for small model.
  Future<void> yoloLoad({
    required String modelPath,
    required String paramPath,
    bool autoDispose = true,
    double probThreshold = yoloProbThresholdDefault,
    double nmsThreshold = yoloNmsThresholdDefault,
    int targetSize = yoloTargetSizeDefault,
  }) async {
    assert(probThreshold > 0);
    assert(nmsThreshold > 0);
    assert(targetSize > 0);

    if (autoDispose) {
      yoloUnload();
    }

    _probThreshold = probThreshold;
    _nmsThreshold = nmsThreshold;
    _targetSize = targetSize;

    final tempModelPath = (await _copy(modelPath)).toNativeUtf8();
    final tempParamPath = (await _copy(paramPath)).toNativeUtf8();

    _bindings.yoloLoad(
      tempModelPath as Pointer<Char>,
      tempParamPath as Pointer<Char>,
      targetSize,
      1,
    );
    
    calloc
      ..free(tempModelPath)
      ..free(tempParamPath);
  }

  /// Dispose of the recently loaded YOLO model.
  void yoloUnload() {
    _bindings.yoloUnload();
  }

  Future<String> _copy(String assetsPath) async {
    final documentDir = await getApplicationDocumentsDirectory();

    final data = await rootBundle.load(assetsPath);

    final file = File('${documentDir.path}/$assetsPath')
      ..createSync(recursive: true)
      ..writeAsBytesSync(
        data.buffer.asUint8List(),
        flush: true,
      );
    return file.path;
  }

  /// Detect with YOLO
  /// Run it after yoloLoad
  ///
  /// When detecting from an image byte array, specify [y], [u] and [v].
  /// [y] and [u] and [v] are the YUV420 data of the image.
  /// [height] is the height of the image.
  /// The width of the image is calculated from [y] length.
  ///
  /// [deviceOrientationType] is the device orientation.
  /// It can be obtained from CameraController of the camera package.
  /// https://github.com/flutter/plugins/blob/main/packages/camera/camera/lib/src/camera_controller.dart#L134
  ///
  /// [sensorOrientation] is the orientation of the camera sensor.
  /// It can be obtained from CameraController of the camera package.
  /// https://github.com/flutter/plugins/blob/main/packages/camera/camera_platform_interface/lib/src/types/camera_description.dart#L42
  ///
  /// [onDecodeImage] and [onYuv420sp2rgbImage] are callback functions for decoding images.
  /// The process of converting to a [ui.Image] object is heavy and affects performance.
  /// If [ui.Image] is not needed, it is recommended to set null.
  ///
  DetectResult detectYUV420({
    required Uint8List y,
    required Uint8List u,
    required Uint8List v,
    required int height,
    @Deprecated("width is automatically calculated from the length of the y.")
        int width = 0,
    required KannaRotateDeviceOrientationType deviceOrientationType,
    required int sensorOrientation,
    void Function(ui.Image image)? onDecodeImage,
    void Function(ui.Image image)? onYuv420sp2rgbImage,
  }) {
    final yuv420sp = yuv420sp2Uint8List(
      y: y,
      u: u,
      v: v,
    );

    final width = y.length ~/ height;

    final pixels = yuv420sp2rgb(
      yuv420sp: yuv420sp,
      width: width,
      height: height,
    );
    if (onYuv420sp2rgbImage != null) {
      final rgba = rgb2rgba(
        rgb: pixels,
        width: width,
        height: height,
      );

      ui.decodeImageFromPixels(
        rgba,
        width,
        height,
        ui.PixelFormat.rgba8888,
        onYuv420sp2rgbImage,
      );
    }

    final rotated = kannaRotate(
      pixels: pixels,
      width: width,
      height: height,
      deviceOrientationType: deviceOrientationType,
      sensorOrientation: sensorOrientation,
    );

    if (onDecodeImage != null) {
      final rgba = rgb2rgba(
        rgb: rotated.pixels ?? Uint8List(0),
        width: rotated.width,
        height: rotated.height,
      );

      ui.decodeImageFromPixels(
        rgba,
        rotated.width,
        rotated.height,
        ui.PixelFormat.rgba8888,
        onDecodeImage,
      );
    }

    return DetectResult(
      result: detectPixels(
        pixels: rotated.pixels ?? Uint8List(0),
        width: rotated.width,
        height: rotated.height,
      ),
      image: rotated,
    );
  }

  /// Detect with YOLO
  /// Run it after yoloLoad
  ///
  /// When detecting from an image byte array, specify [pixels].
  /// [height] is the height of the image.
  /// The width of the image is calculated from [pixels] length.
  ///
  /// [deviceOrientationType] is the device orientation.
  /// It can be obtained from CameraController of the camera package.
  /// https://github.com/flutter/plugins/blob/main/packages/camera/camera/lib/src/camera_controller.dart#L134
  ///
  /// [sensorOrientation] is the orientation of the camera sensor.
  /// It can be obtained from CameraController of the camera package.
  /// https://github.com/flutter/plugins/blob/main/packages/camera/camera_platform_interface/lib/src/types/camera_description.dart#L42
  ///
  /// [onDecodeImage] is a callback function to decode the image.
  /// The process of converting to a [ui.Image] object is heavy and affects performance.
  /// If [ui.Image] is not needed, it is recommended to set null.
  ///
  DetectResult detectBGRA8888({
    required Uint8List pixels,
    required int height,
    @Deprecated("width is automatically calculated from the length of the pixels.")
        int width = 0,
    required KannaRotateDeviceOrientationType deviceOrientationType,
    required int sensorOrientation,
    void Function(ui.Image image)? onDecodeImage,
  }) {
    final width = pixels.length ~/ height ~/ 4;

    final rotated = kannaRotate(
      pixels: pixels,
      pixelChannel: PixelChannel.c4,
      width: width,
      height: height,
      deviceOrientationType: deviceOrientationType,
      sensorOrientation: sensorOrientation,
    );

    if (onDecodeImage != null) {
      ui.decodeImageFromPixels(
        pixels,
        width,
        height,
        ui.PixelFormat.bgra8888,
        onDecodeImage,
      );
    }

    return DetectResult(
      result: detectPixels(
        pixels: rotated.pixels ?? Uint8List(0),
        pixelFormat: PixelFormat.bgra,
        width: rotated.width,
        height: rotated.height,
      ),
      image: rotated,
    );
  }

  /// Detect with YOLO
  /// Run it after yoloLoad
  ///
  /// Reads an image from pixel data and executes Detect.
  ///
  /// [pixels] is pixel data of the image. [pixelFormat] is the pixel format.
  /// [width] and [height] are the width and height of the image.
  ///
  /// Returns a list of [YoloResult]
  ///
  List<YoloResult> detectPixels({
    required Uint8List pixels,
    PixelFormat pixelFormat = PixelFormat.rgb,
    required int width,
    required int height,
  }) {
    final pixelsNative = calloc.allocate<UnsignedChar>(pixels.length);

    for (var i = 0; i < pixels.length; i++) {
      pixelsNative[i] = pixels[i];
    }

    final results = YoloResult.create(
      _bindings.detectWithPixels(
        pixelsNative,
        pixelFormat.type,
        width,
        height,
        probThreshold,
        nmsThreshold,
        targetSize,
      ).cast<Utf8>().toDartString(),
    );
    calloc.free(pixelsNative);
    return results;
  }

  /// Detect with YOLO
  /// Run it after yoloLoad
  ///
  /// Read the image from the file path and execute Detect.
  ///
  /// The [imagePath] should be the path to the image, such as "assets/image.jpg".
  /// Returns the results of a YOLOX run as a List of [YoloResult].
  ///
  List<YoloResult> detectImageFile(
    String imagePath,
  ) {
    assert(imagePath.isNotEmpty, 'imagePath is empty');

    if (imagePath.isEmpty) {
      return [];
    }

    final imagePathNative = imagePath.toNativeUtf8();

    final results = YoloResult.create(
      _bindings.detectWithImagePath(
        imagePathNative as Pointer<Char>,
        probThreshold,
        nmsThreshold,
        targetSize,
      ).cast<Utf8>().toDartString(),
    );
    calloc.free(imagePathNative);
    return results;
  }

  /// Rotate the pixel to match the orientation of the device.
  ///
  /// [pixels] is Image pixel data.
  /// [pixelChannel] is the number of channels of the image. For example, [PixelChannel.c3] for RGB or [PixelChannel.c4] for RGBA.
  /// [width] and [height] specify the width and height of the Image.
  /// [deviceOrientationType] is the orientation of the device.
  /// [sensorOrientation] is the orientation of the sensor.
  ///
  /// Returns [KannaRotateResult] with the rotated pixels data.
  ///
  KannaRotateResult kannaRotate({
    required Uint8List pixels,
    PixelChannel pixelChannel = PixelChannel.c3,
    required int width,
    required int height,
    KannaRotateDeviceOrientationType deviceOrientationType =
        KannaRotateDeviceOrientationType.portraitUp,
    int sensorOrientation = 90,
  }) {
    assert(width > 0, 'width is too small');
    assert(height > 0, 'height is too small');
    assert(pixels.isNotEmpty, 'pixels is empty');
    assert(sensorOrientation >= 0, 'sensorOrientation is too small');
    assert(sensorOrientation <= 360, 'sensorOrientation is too big');
    assert(sensorOrientation % 90 == 0, 'Only 0, 90, 180 or 270');

    if (width <= 0 ||
        height <= 0 ||
        pixels.isEmpty ||
        sensorOrientation < 0 ||
        sensorOrientation > 360 ||
        sensorOrientation % 90 != 0) {
      return const KannaRotateResult();
    }

    var rotateType = KannaRotateType.deg0;

    ///
    /// I don't know why you only need iOS but it works.
    /// Maybe related issue https://github.com/flutter/flutter/issues/94045
    ///
    switch (deviceOrientationType) {
      case KannaRotateDeviceOrientationType.portraitUp:
        rotateType = KannaRotateType.fromDegree(
          Platform.isIOS
              ? (-90 + sensorOrientation) % 360
              : (0 + sensorOrientation) % 360,
        );
        break;
      case KannaRotateDeviceOrientationType.landscapeRight:
        rotateType = KannaRotateType.fromDegree(
          Platform.isIOS
              ? (-90 + sensorOrientation) % 360
              : (90 + sensorOrientation) % 360,
        );
        break;
      case KannaRotateDeviceOrientationType.portraitDown:
        rotateType = KannaRotateType.fromDegree(
          Platform.isIOS
              ? (-90 + sensorOrientation) % 360
              : (180 + sensorOrientation) % 360,
        );
        break;
      case KannaRotateDeviceOrientationType.landscapeLeft:
        rotateType = KannaRotateType.fromDegree(
          Platform.isIOS
              ? (-90 + sensorOrientation) % 360
              : (270 + sensorOrientation) % 360,
        );
        break;
    }

    if (rotateType == KannaRotateType.deg0) {
      return KannaRotateResult(
        pixels: pixels,
        width: width,
        height: height,
        pixelChannel: pixelChannel,
      );
    }

    final src = calloc.allocate<Uint8>(pixels.length);
    for (var i = 0; i < pixels.length; i++) {
      src[i] = pixels[i];
    }
    final srcw = width;
    final srch = height;

    final dst = calloc.allocate<Uint8>(pixels.length);
    var dstw = width;
    var dsth = height;

    switch (rotateType) {
      case KannaRotateType.deg0:
      case KannaRotateType.deg180:
        break;
      case KannaRotateType.deg90:
      case KannaRotateType.deg270:
        dstw = height;
        dsth = width;
        break;
    }

    final type = rotateType.type;

    _bindings.kannaRotate(
      src as Pointer<UnsignedChar>,
      pixelChannel.channelNum,
      srcw,
      srch,
      dst as Pointer<UnsignedChar>,
      dstw,
      dsth,
      type,
    );

    final results = _copyUint8PointerToUint8List(dst, pixels.length);
    calloc
      ..free(src)
      ..free(dst);

    return KannaRotateResult(
      pixels: results,
      width: dstw,
      height: dsth,
      pixelChannel: pixelChannel,
    );
  }

  /// Converts YUV bytes to a Uint8List of YUV420sp(NV12).
  ///
  /// The use case for this method is when using the camera plugin. https://pub.dev/packages/camera
  /// See example.
  ///
  Uint8List yuv420sp2Uint8List({
    required Uint8List y,
    required Uint8List u,
    required Uint8List v,
  }) {
    assert(y.isNotEmpty, 'y is empty');
    assert(u.isNotEmpty, 'u is empty');
    assert(v.isNotEmpty, 'v is empty');

    final yuv420sp = Uint8List(
      y.length + u.length + v.length,
    );

    /// https://wiki.videolan.org/YUV#Semi-planar
    for (var i = 0; i < y.length; i++) {
      yuv420sp[i] = y[i];
    }

    for (var i = 0; i < u.length; i += 2) {
      yuv420sp[y.length + i] = u[i];
      yuv420sp[y.length + i + 1] = v[i];
    }
    return yuv420sp;
  }

  /// Convert YUV420SP to RGB
  ///
  /// [yuv420sp] is Image data in YUV420SP(NV12) format. [width] and [height] specify the width and height of the Image.
  /// Returns RGB bytes.
  ///
  Uint8List yuv420sp2rgb({
    required Uint8List yuv420sp,
    required int width,
    required int height,
  }) {
    assert(width > 0, 'width is too small');
    assert(height > 0, 'height is too small');
    assert(yuv420sp.isNotEmpty, 'yuv420sp is empty');

    if (width <= 0 || height <= 0 || yuv420sp.isEmpty) {
      return Uint8List(0);
    }

    final pixels = calloc.allocate<Uint8>(yuv420sp.length);
    for (var i = 0; i < yuv420sp.length; i++) {
      pixels[i] = yuv420sp[i];
    }

    final rgb = calloc.allocate<Uint8>(width * height * 3);

    _bindings.yuv420sp2rgb(
      pixels as Pointer<UnsignedChar>,
      width,
      height,
      rgb as Pointer<UnsignedChar>,
    );

    final results = _copyUint8PointerToUint8List(rgb, width * height * 3);
    calloc
      ..free(pixels)
      ..free(rgb);
    return results;
  }

  /// Convert RGB to RGBA
  ///
  /// [rgb] is Image data in RGB format. [width] and [height] specify the width and height of the Image.
  /// Returns RGBA bytes.
  ///
  Uint8List rgb2rgba({
    required Uint8List rgb,
    required int width,
    required int height,
  }) {
    assert(width > 0, 'width is too small');
    assert(height > 0, 'height is too small');
    assert(rgb.isNotEmpty, 'pixels is empty');

    if (width <= 0 || height <= 0 || rgb.isEmpty) {
      return Uint8List(0);
    }

    final pixels = calloc.allocate<Uint8>(rgb.length);
    for (var i = 0; i < rgb.length; i++) {
      pixels[i] = rgb[i];
    }

    final rgba = calloc.allocate<Uint8>(width * height * 4);

    _bindings.rgb2rgba(
      pixels as Pointer<UnsignedChar>,
      width,
      height,
      rgba as Pointer<UnsignedChar>,
    );

    final results = _copyUint8PointerToUint8List(rgba, width * height * 4);
    calloc
      ..free(pixels)
      ..free(rgba);
    return results;
  }

  /// Copy to Uint8List
  ///
  /// asTypedList is not used because pointer object cannot be free.
  /// https://api.flutter.dev/flutter/dart-ffi/Int8Pointer/asTypedList.html
  ///
  Uint8List _copyUint8PointerToUint8List(Pointer<Uint8> pointer, int length) {
    final result = Uint8List(length);
    for (var i = 0; i < length; i++) {
      result[i] = pointer[i];
    }
    return result;
  }
}
