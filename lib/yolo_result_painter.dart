import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'models/yolo_result.dart';

class YoloResultPainter extends CustomPainter {
  YoloResultPainter({
    required this.image,
    required this.results,
    required this.labels,
    Paint? drawRectPaint,
    TextStyle? labelTextStyle,
  }) {
    final defaultDrawRectPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = min(image.width, image.height) * 0.01;
    this.drawRectPaint = drawRectPaint ?? defaultDrawRectPaint;

    this.labelTextStyle = labelTextStyle ??
        TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: min(image.width, image.height) * 0.05,
        );
  }

  final List<String> labels;

  final ui.Image image;

  final List<YoloResult> results;

  late Paint drawRectPaint;

  late TextStyle labelTextStyle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());

    for (final e in results) {
      final rect = ui.Rect.fromLTWH(
        e.x,
        e.y,
        e.width,
        e.height,
      );
      canvas.drawRect(
        rect,
        drawRectPaint,
      );

      TextPainter(
        text: TextSpan(
          text: ' ${labels[e.label]}: ${(e.prob * 100).toStringAsFixed(2)}%',
          style: labelTextStyle,
        ),
        textDirection: ui.TextDirection.ltr,
      )
        ..layout()
        ..paint(
          canvas,
          Offset(
            rect.left,
            rect.top,
          ),
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
