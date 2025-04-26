import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/drawing_point.dart';
import '../screens/shape_utils.dart';

class WhiteboardPainter extends CustomPainter {
  final List<DrawingPoint> points;
  final ui.Image? backgroundImage;
  final Color canvasColor;
  final Rect? selectionRect;
  final bool isSelectionMode;
  final List<ShapeItem> shapes;
  final ShapeItem? currentShape;
  final bool showMeasurements;

  WhiteboardPainter({
    required this.points,
    this.backgroundImage,
    this.canvasColor = Colors.white,
    this.selectionRect,
    this.isSelectionMode = false,
    this.shapes = const [],
    this.currentShape,
    this.showMeasurements = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background color
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = canvasColor,
    );

    // Draw background image if available
    if (backgroundImage != null) {
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(
        backgroundImage!, 
        Rect.fromLTWH(0, 0, backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble()),
        dstRect,
        Paint()
      );
    }

    // Clip canvas to size
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw strokes
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].offset != Offset.zero &&
          points[i + 1].offset != Offset.zero &&
          points[i].color != Colors.transparent &&
          points[i + 1].color != Colors.transparent) {
        Paint paint = Paint()
          ..color = points[i].color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = points[i].strokeWidth;
        canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
      }
    }

    // Draw completed shapes
    for (final shape in shapes) {
      ShapeUtils.drawShape(canvas, size, shape, showMeasurements);
    }

    // Draw current shape being created
    if (currentShape != null) {
      ShapeUtils.drawShape(canvas, size, currentShape!, showMeasurements);
    }

    // Draw selection rectangle if in selection mode
    if (isSelectionMode && selectionRect != null) {
      final selectionPaint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.fill;
      
      final borderPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawRect(selectionRect!, selectionPaint);
      canvas.drawRect(selectionRect!, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}