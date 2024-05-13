import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import 'kanna_rotate/kanna_rotate_result.dart';
import 'yolo_result.dart';

part 'detect_result.freezed.dart';

@freezed
class DetectResult with _$DetectResult {
  const factory DetectResult({
    @Default(<YoloResult>[]) List<YoloResult> result,
    KannaRotateResult? image,
  }) = _DetectResult;
}
