import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'yolo_result.freezed.dart';

@freezed
class YoloResult with _$YoloResult {
  const factory YoloResult({
    @Default(0) double x,
    @Default(0) double y,
    @Default(0) double width,
    @Default(0) double height,
    @Default(0) int label,
    @Default(0) double prob,
  }) = _YoloResult;

  static List<YoloResult> create(String response) => response
          .split('\n')
          .where(
            (element) => element.isNotEmpty,
          )
          .map(
        (e) {
          final values = e.split(',');
          return YoloResult(
            x: double.parse(values[0]),
            y: double.parse(values[1]),
            width: double.parse(values[2]),
            height: double.parse(values[3]),
            label: int.parse(values[4]),
            prob: double.parse(values[5]),
          );
        },
      ).toList();
}
