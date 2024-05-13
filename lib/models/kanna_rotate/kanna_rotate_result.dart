import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import '../pixel_channel.dart';

part 'kanna_rotate_result.freezed.dart';

@freezed
class KannaRotateResult with _$KannaRotateResult {
  const factory KannaRotateResult({
    Uint8List? pixels,
    @Default(0) int width,
    @Default(0) int height,
    @Default(PixelChannel.c1) PixelChannel pixelChannel,
  }) = _KannaRotateResult;
}
