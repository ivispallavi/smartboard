import 'package:flutter/material.dart';
import 'dart:math' as math;

// Define the necessary enum and classes
enum ShapeType { rectangle, circle, triangle, square }

class ShapeItem {
  final ShapeType type;
  final Offset startPoint;
  final Offset endPoint;
  final Color color;
  final double strokeWidth;

  ShapeItem({
    required this.type,
    required this.startPoint,
    required this.endPoint,
    this.color = Colors.blue,
    this.strokeWidth = 2.0,
  });
}

/// Custom painter for drawing shapes
class ShapePainter extends CustomPainter {
  final ShapeItem? currentShape;
  final List<ShapeItem> shapes;
  final bool showMeasurements;

  ShapePainter({
    this.currentShape,
    required this.shapes,
    this.showMeasurements = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all saved shapes
    for (var shape in shapes) {
      ShapeUtils.drawShape(canvas, size, shape, showMeasurements);
    }

    // Draw current shape being created
    if (currentShape != null) {
      ShapeUtils.drawShape(canvas, size, currentShape!, showMeasurements);
    }
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    return oldDelegate.currentShape != currentShape ||
        oldDelegate.shapes.length != shapes.length ||
        oldDelegate.showMeasurements != showMeasurements;
  }
}

/// Utility class for shape operations
class ShapeUtils {
  // Pixel to cm conversion factor
  static const double pixelToCm = 0.026458333;
  
  // Main function to handle shape creation start
  static void handleShapeStart(
    DragStartDetails details,
    GlobalKey canvasKey,
    ScrollController scrollController,
    ShapeType selectedShape,
    Function(Offset startPoint) onStartPointCreated,
  ) {
    try {
      // Get the render box for coordinate calculation
      final RenderBox renderBox =
          canvasKey.currentContext!.findRenderObject() as RenderBox;

      // Get the position relative to the canvas
      final Offset localPosition = renderBox.globalToLocal(
        details.globalPosition,
      );

      // Adjust for scroll offset
      double scrollOffset =
          scrollController.hasClients ? scrollController.offset : 0.0;
      Offset adjustedPosition = Offset(
        localPosition.dx,
        localPosition.dy + scrollOffset,
      );

      // Call the callback with the start point
      onStartPointCreated(adjustedPosition);
    } catch (e) {
      print("Error in handleShapeStart: $e");
    }
  }

  // Function to handle shape creation update
  static void handleShapeUpdate(
    DragUpdateDetails details,
    GlobalKey canvasKey,
    ScrollController scrollController,
    Offset startPoint,
    ShapeType selectedShape,
    Function(Offset endPoint, ShapeItem shape) onShapeUpdated,
  ) {
    try {
      // Get the render box for coordinate calculation
      final RenderBox renderBox =
          canvasKey.currentContext!.findRenderObject() as RenderBox;

      // Get the position relative to the canvas
      final Offset localPosition = renderBox.globalToLocal(
        details.globalPosition,
      );

      // Adjust for scroll offset
      double scrollOffset =
          scrollController.hasClients ? scrollController.offset : 0.0;
      Offset adjustedPosition = Offset(
        localPosition.dx,
        localPosition.dy + scrollOffset,
      );

      // Create shape with updated end point
      ShapeItem currentShape = ShapeItem(
        type: selectedShape,
        startPoint: startPoint,
        endPoint: adjustedPosition,
      );

      // Call the callback with the updated shape
      onShapeUpdated(adjustedPosition, currentShape);
    } catch (e) {
      print("Error in handleShapeUpdate: $e");
    }
  }

  // Function to handle shape creation end
  static void handleShapeEnd(
    Offset? startPoint,
    Offset? endPoint,
    ShapeType selectedShape,
    Function(ShapeItem shape) onShapeCreated,
  ) {
    if (startPoint == null || endPoint == null) return;
    
    // Create the final shape
    final shape = ShapeItem(
      type: selectedShape,
      startPoint: startPoint,
      endPoint: endPoint,
    );
    
    // Call the callback with the created shape
    onShapeCreated(shape);
  }

  // Draw shapes on canvas
  static void drawShape(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    bool showMeasurements,
  ) {
    final paint = Paint()
      ..color = shape.color
      ..strokeWidth = shape.strokeWidth
      ..style = PaintingStyle.stroke;
      
    final measurementTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    switch (shape.type) {
      case ShapeType.rectangle:
        _drawRectangle(canvas, size, shape, paint, measurementTextPainter, showMeasurements);
        break;
      case ShapeType.circle:
        _drawCircle(canvas, size, shape, paint, measurementTextPainter, showMeasurements);
        break;
      case ShapeType.triangle:
        _drawTriangle(canvas, size, shape, paint, measurementTextPainter, showMeasurements);
        break;
      case ShapeType.square:
        _drawSquare(canvas, size, shape, paint, measurementTextPainter, showMeasurements);
        break;
    }
  }

  // Helper method to draw rectangle
  static void _drawRectangle(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
    bool showMeasurements,
  ) {
    final rect = Rect.fromPoints(shape.startPoint, shape.endPoint);
    canvas.drawRect(rect, paint);

    if (showMeasurements) {
      final width = (rect.width * pixelToCm).toStringAsFixed(1);
      final height = (rect.height * pixelToCm).toStringAsFixed(1);

      // Draw width measurement (only if within bounds)
      final widthPosition = Offset(rect.center.dx, rect.bottom + 20);
      if (widthPosition.dy < size.height - 20) {
        _drawMeasurement(
          canvas, 
          measurementTextPainter, 
          '$width cm', 
          widthPosition,
        );
      }

      // Draw height measurement (only if within bounds)
      final heightPosition = Offset(rect.right + 20, rect.center.dy);
      if (heightPosition.dx < size.width - 30) {
        _drawMeasurement(
          canvas, 
          measurementTextPainter, 
          '$height cm', 
          heightPosition,
        );
      }
    }
  }

  // Helper method to draw circle
  static void _drawCircle(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
    bool showMeasurements,
  ) {
    final center = shape.startPoint;
    final radius = (shape.endPoint - shape.startPoint).distance;
    canvas.drawCircle(center, radius, paint);

    if (showMeasurements) {
      final diameter = (radius * 2 * pixelToCm).toStringAsFixed(1);
      final position = Offset(center.dx, center.dy + radius + 20);
      if (position.dy < size.height - 20) {
        _drawMeasurement(
          canvas, 
          measurementTextPainter, 
          'Ø $diameter cm', 
          position,
        );
      }
    }
  }

  // Helper method to draw triangle
  static void _drawTriangle(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
    bool showMeasurements,
  ) {
    final path = Path();
    final x1 = shape.startPoint.dx;
    final y1 = shape.startPoint.dy;
    final x2 = shape.endPoint.dx;
    final y2 = shape.endPoint.dy;
    
    // Equilateral triangle
    final centerX = (x1 + x2) / 2;
    
    path.moveTo(centerX, y1);
    path.lineTo(x1, y2);
    path.lineTo(x2, y2);
    path.close();
    
    canvas.drawPath(path, paint);

    if (showMeasurements) {
      final base = ((x2 - x1) * pixelToCm).abs().toStringAsFixed(1);
      final height = ((y2 - y1) * pixelToCm).abs().toStringAsFixed(1);

      // Draw base measurement (only if within bounds)
      final basePosition = Offset(centerX, y2 + 20);
      if (basePosition.dy < size.height - 20) {
        _drawMeasurement(
          canvas, 
          measurementTextPainter, 
          '$base cm', 
          basePosition,
        );
      }

      // Draw height measurement (only if within bounds)
      final heightPosition = Offset(x2 + 20, (y1 + y2) / 2);
      if (heightPosition.dx < size.width - 30) {
        _drawMeasurement(
          canvas, 
          measurementTextPainter, 
          '$height cm', 
          heightPosition,
        );
      }
    }
  }

  // Helper method to draw square
  static void _drawSquare(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
    bool showMeasurements,
  ) {
    final dx = shape.endPoint.dx - shape.startPoint.dx;
    final dy = shape.endPoint.dy - shape.startPoint.dy;
    final side = math.min(dx.abs(), dy.abs());
    
    final signX = dx > 0 ? 1 : -1;
    final signY = dy > 0 ? 1 : -1;
    
    final rect = Rect.fromLTWH(
      shape.startPoint.dx, 
      shape.startPoint.dy, 
      side * signX, 
      side * signY,
    );
    
    canvas.drawRect(rect, paint);

    if (showMeasurements) {
      final sideCm = (side * pixelToCm).toStringAsFixed(1);
      final position = Offset(rect.center.dx, rect.bottom + 20);
      if (position.dy < size.height - 20) {
        _drawMeasurement(
          canvas, 
          measurementTextPainter, 
          '$sideCm cm', 
          position,
        );
      }
    }
  }

  // Helper method to draw measurement text
  static void _drawMeasurement(
    Canvas canvas, 
    TextPainter measurementTextPainter, 
    String text, 
    Offset position,
  ) {
    measurementTextPainter.text = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    measurementTextPainter.layout();
    
    // Draw white background with rounded corners for better visibility
    final bgPaint = Paint()..color = Colors.white;
    final strokePaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position,
        width: measurementTextPainter.width + 10,
        height: measurementTextPainter.height + 4,
      ),
      const Radius.circular(4),
    );
    
    canvas.drawRRect(bgRect, bgPaint);
    canvas.drawRRect(bgRect, strokePaint);
    
    // Draw text
    measurementTextPainter.paint(
      canvas, 
      position - Offset(measurementTextPainter.width / 2, measurementTextPainter.height / 2),
    );
  }
}