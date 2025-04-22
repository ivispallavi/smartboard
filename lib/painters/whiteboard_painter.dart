import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/drawing_point.dart';

enum DrawingMode {
  pen,
  eraser,
  // Add other modes as needed
}

class WhiteboardPainter extends CustomPainter {
  final List<DrawingPoint> points;
  final ui.Image? backgroundImage;
  final Rect? selectionRect;
  final bool isSelectionMode;
  final DrawingMode drawingMode;

  WhiteboardPainter({
    required this.points,
    this.backgroundImage,
    this.selectionRect,
    this.isSelectionMode = false,
    this.drawingMode = DrawingMode.pen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      canvas.drawImage(backgroundImage!, Offset.zero, Paint());
    }

    // Paint all stroke points
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].isDeleted || points[i + 1].isDeleted) {
        continue;
      }

      if (points[i].offset != Offset.zero && points[i + 1].offset != Offset.zero) {
        Paint paint = Paint()
          ..color = points[i].color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = points[i].strokeWidth;
        
        canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
      }
    }

    // Draw selection rectangle if in selection mode
    if (isSelectionMode && selectionRect != null) {
      Paint selectionPaint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      Paint borderPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(selectionRect!, selectionPaint);
      canvas.drawRect(selectionRect!, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}