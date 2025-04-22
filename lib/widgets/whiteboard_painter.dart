import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

/// Custom painter that handles rendering of the whiteboard content
class WhiteboardPainter extends CustomPainter {
  /// List of drawing points to render
  final List<DrawingPoint> points;
  
  /// Optional background image
  final ui.Image? backgroundImage;
  
  /// Optional selection rectangle when in selection mode
  final Rect? selectionRect;
  
  /// Whether the whiteboard is in selection mode
  final bool isSelectionMode;
  
  /// Creates a new whiteboard painter
  WhiteboardPainter({
    required this.points,
    this.backgroundImage,
    this.selectionRect,
    this.isSelectionMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background image if available
    if (backgroundImage != null) {
      canvas.drawImage(backgroundImage!, Offset.zero, Paint());
    }
    
    // Draw strokes
    for (int i = 0; i < points.length - 1; i++) {
      // Skip the "invisible" points (used as stroke separators)
      if (points[i].isEndOfStroke || points[i + 1].isEndOfStroke) {
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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}