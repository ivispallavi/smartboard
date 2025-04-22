import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:smart_board/screens/whiteboard_screen.dart';
// Define the necessary enum and classes
enum ShapeType { rectangle, circle, triangle, square }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Board',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WhiteboardScreen(),
    );
  }
}


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

class DrawingPoints {
  final Offset offset;
  final Paint paint;
  final Color color;
  final double strokeWidth;

  DrawingPoints({
    required this.offset,
    required this.paint,
    required this.color,
    required this.strokeWidth,
  });
}

class ShapeMeasurementWidget extends StatefulWidget {
  final Function(ShapeItem) onShapeCreated;
  
  const ShapeMeasurementWidget({
    super.key,
    required this.onShapeCreated,
  });

  @override
  State<ShapeMeasurementWidget> createState() => _ShapeMeasurementWidgetState();
}

class _ShapeMeasurementWidgetState extends State<ShapeMeasurementWidget> {
  ShapeType selectedShape = ShapeType.rectangle;
  Offset? startPoint;
  Offset? currentPoint;
  ShapeItem? currentShape;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Shape selection bar
        Container(
          height: 60,
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShapeButton(ShapeType.rectangle, Icons.crop_square, 'Rectangle'),
              _buildShapeButton(ShapeType.circle, Icons.circle_outlined, 'Circle'),
              _buildShapeButton(ShapeType.triangle, Icons.change_history, 'Triangle'),
              _buildShapeButton(ShapeType.square, Icons.square_outlined, 'Square'),
            ],
          ),
        ),
        // Drawing area with padding for measurements
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(40), // Add padding to prevent overflow
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      // Ensure points are within bounds
                      startPoint = _constrainPoint(details.localPosition, constraints);
                      currentPoint = startPoint;
                      currentShape = ShapeItem(
                        type: selectedShape,
                        startPoint: startPoint!,
                        endPoint: currentPoint!,
                      );
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      // Ensure points are within bounds
                      currentPoint = _constrainPoint(details.localPosition, constraints);
                      if (currentShape != null) {
                        currentShape = ShapeItem(
                          type: selectedShape,
                          startPoint: startPoint!,
                          endPoint: currentPoint!,
                        );
                      }
                    });
                  },
                  onPanEnd: (details) {
                    if (currentShape != null) {
                      widget.onShapeCreated(currentShape!);
                      setState(() {
                        startPoint = null;
                        currentPoint = null;
                        currentShape = null;
                      });
                    }
                  },
                  child: ClipRect( // Clip content to prevent overflow
                    child: Container(
                      width: constraints.maxWidth - 80, // Account for padding
                      height: constraints.maxHeight - 80, // Account for padding
                      color: Colors.white, // Add background color
                      child: CustomPaint(
                        painter: ShapePainter(
                          currentShape: currentShape,
                          showMeasurements: true,
                        ),
                        size: Size(constraints.maxWidth - 80, constraints.maxHeight - 80),
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }

  // Helper method to constrain points within the available space
  Offset _constrainPoint(Offset point, BoxConstraints constraints) {
    return Offset(
      point.dx.clamp(0, constraints.maxWidth - 80),
      point.dy.clamp(0, constraints.maxHeight - 80),
    );
  }

  Widget _buildShapeButton(ShapeType type, IconData icon, String label) {
    return InkWell(
      onTap: () => setState(() => selectedShape = type),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selectedShape == type ? Colors.blue[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selectedShape == type ? Colors.blue : Colors.black54),
            Text(
              label, 
              style: TextStyle(
                fontSize: 12,
                color: selectedShape == type ? Colors.blue : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final ShapeItem? currentShape;
  final List<ShapeItem>? shapes;
  final bool showMeasurements;
  
  // Assuming 1 pixel = 0.026458333 cm (standard screen resolution)
  static const double pixelToCm = 0.026458333;

  ShapePainter({
    this.currentShape,
    this.shapes,
    this.showMeasurements = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final measurementTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw any completed shapes
    if (shapes != null) {
      for (final shape in shapes!) {
        _drawShape(canvas, size, shape, paint, measurementTextPainter);
      }
    }

    // Draw current shape being drawn
    if (currentShape != null) {
      _drawShape(canvas, size, currentShape!, paint, measurementTextPainter);
    }
  }

  void _drawShape(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
  ) {
    switch (shape.type) {
      case ShapeType.rectangle:
        _drawRectangle(canvas, size, shape, paint, measurementTextPainter);
        break;
      case ShapeType.circle:
        _drawCircle(canvas, size, shape, paint, measurementTextPainter);
        break;
      case ShapeType.triangle:
        _drawTriangle(canvas, size, shape, paint, measurementTextPainter);
        break;
      case ShapeType.square:
        _drawSquare(canvas, size, shape, paint, measurementTextPainter);
        break;
    }
  }

  void _drawRectangle(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
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

  void _drawCircle(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
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

  void _drawTriangle(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
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

  void _drawSquare(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
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

  void _drawMeasurement(
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced WhiteboardPainter class
class EnhancedWhiteboardPainter extends CustomPainter {
  final List<DrawingPoints> points;
  final ui.Image? backgroundImage;
  final List<ShapeItem> shapes;
  final ShapeItem? currentShape;
  
  // Assuming 1 pixel = 0.026458333 cm (standard screen resolution)
  static const double pixelToCm = 0.026458333;

  EnhancedWhiteboardPainter(
    this.points, 
    this.backgroundImage, {
    this.shapes = const [],
    this.currentShape,
  });

  @override
void paint(Canvas canvas, Size size) {
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
    if (points[i].color == Colors.transparent ||
        points[i + 1].color == Colors.transparent) {
      continue;
    }

    if (points[i].offset != Offset.zero &&
        points[i + 1].offset != Offset.zero) {
      Paint paint = Paint()
        ..color = points[i].color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = points[i].strokeWidth;
      canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
    }
  }

  // Draw completed shapes
  final measurementTextPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  
  for (final shape in shapes) {
    _drawShape(canvas, size, shape, measurementTextPainter);
  }

  // Draw current shape being created
  if (currentShape != null) {
    _drawShape(canvas, size, currentShape!, measurementTextPainter);
  }
}

  void _drawShape(Canvas canvas, Size size, ShapeItem shape, TextPainter measurementTextPainter) {
    final paint = Paint()
      ..color = shape.color
      ..strokeWidth = shape.strokeWidth
      ..style = PaintingStyle.stroke;

    switch (shape.type) {
      case ShapeType.rectangle:
        _drawRectangle(canvas, size, shape, paint, measurementTextPainter);
        break;
      case ShapeType.circle:
        _drawCircle(canvas, size, shape, paint, measurementTextPainter);
        break;
      case ShapeType.triangle:
        _drawTriangle(canvas, size, shape, paint, measurementTextPainter);
        break;
      case ShapeType.square:
        _drawSquare(canvas, size, shape, paint, measurementTextPainter);
        break;
    }
  }

  void _drawRectangle(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
  ) {
    final rect = Rect.fromPoints(shape.startPoint, shape.endPoint);
    canvas.drawRect(rect, paint);

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

  void _drawCircle(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
  ) {
    final center = shape.startPoint;
    final radius = (shape.endPoint - shape.startPoint).distance;
    canvas.drawCircle(center, radius, paint);

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

  void _drawTriangle(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
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

  void _drawSquare(
    Canvas canvas, 
    Size size,
    ShapeItem shape, 
    Paint paint, 
    TextPainter measurementTextPainter,
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

  void _drawMeasurement(
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}