import 'package:dart_ncnn_yolov8/dart_ncnn_yolov8.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'ncnn_yolo_options.freezed.dart';

@freezed
class NcnnYoloOptions with _$NcnnYoloOptions {
  const factory NcnnYoloOptions({
    @Default(true) bool autoDispose,
    @Default(yoloProbThresholdDefault) double probThreshold,
    @Default(yoloNmsThresholdDefault) double nmsThreshold,
    @Default(yoloTargetSizeDefault) int targetSize,
  }) = _NcnnYoloOptions;
}

final ncnnYoloOptions = StateProvider(
  (ref) => const NcnnYoloOptions(),
  name: 'ncnnYoloxOptions',
);
