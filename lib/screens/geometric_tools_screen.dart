import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';  // Make sure this import is included

// Class to store drawing points data
class DrawingPoints {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawingPoints({
    required this.points,
    required this.color,
    required this.width,
  });
}

// Class to store geometric shapes
class GeometricShape {
  final String type; // 'circle', 'arc', 'line', 'angle'
  final Map<String, dynamic> properties;
  final Color color;
  final double width;

  GeometricShape({
    required this.type,
    required this.properties,
    required this.color,
    required this.width,
  });
}

// Drawing Painter for rendered drawing points
class DrawingPainter extends CustomPainter {
  final List<DrawingPoints> points;
  final List<GeometricShape> shapes;
  final double pixelToCmRatio; // Pixels per cm

  DrawingPainter({
    required this.points, 
    required this.shapes,
    this.pixelToCmRatio = 37.8, // Approximate default value (96 DPI / 2.54)
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw freehand points
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      
      final paint = Paint()
        ..color = point.color
        ..strokeWidth = point.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      final pointsList = point.points;
      if (pointsList.length < 2) continue;
      
      // Create a path from the points
      final path = Path();
      path.moveTo(pointsList[0].dx, pointsList[0].dy);
      
      for (int j = 1; j < pointsList.length; j++) {
        path.lineTo(pointsList[j].dx, pointsList[j].dy);
      }
      
      canvas.drawPath(path, paint);
    }

    // Draw geometric shapes
    for (final shape in shapes) {
      final paint = Paint()
        ..color = shape.color
        ..strokeWidth = shape.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (shape.type == 'circle') {
        final center = shape.properties['center'] as Offset;
        final radius = shape.properties['radius'] as double;
        canvas.drawCircle(center, radius, paint);
        
        // Draw radius line for reference
        if (shape.properties['showRadius'] == true) {
          final radiusPaint = Paint()
            ..color = shape.color.withOpacity(0.5)
            ..strokeWidth = 1.0
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;
          
          canvas.drawLine(center, Offset(center.dx + radius, center.dy), radiusPaint);
          
          // Draw radius measurement in cm
          final radiusCm = radius / pixelToCmRatio;
          final textPainter = TextPainter(
            text: TextSpan(
              text: 'r: ${radiusCm.toStringAsFixed(1)} cm',
              style: TextStyle(color: shape.color, fontSize: 12),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas, 
            Offset(center.dx + radius / 2 - textPainter.width / 2, center.dy - 15)
          );
        }
      } 
      else if (shape.type == 'arc') {
        final center = shape.properties['center'] as Offset;
        final radius = shape.properties['radius'] as double;
        final startAngle = shape.properties['startAngle'] as double;
        final endAngle = shape.properties['endAngle'] as double;
        final showRadius = shape.properties['showRadius'] as bool? ?? false;
        
        // Draw the arc
        final rect = Rect.fromCircle(center: center, radius: radius);
        canvas.drawArc(rect, startAngle, endAngle - startAngle, false, paint);

        // Draw center point
        final centerPaint = Paint()
          ..color = shape.color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 3.0, centerPaint);
        
        // Draw radius measurement in cm
        if (showRadius) {
          final radiusCm = radius / pixelToCmRatio;
          final midAngle = startAngle + (endAngle - startAngle) / 2;
          final midX = center.dx + radius * 0.7 * math.cos(midAngle);
          final midY = center.dy + radius * 0.7 * math.sin(midAngle);
          
          final textPainter = TextPainter(
            text: TextSpan(
              text: 'r: ${radiusCm.toStringAsFixed(1)} cm',
              style: TextStyle(color: shape.color, fontSize: 12),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas, 
            Offset(midX - textPainter.width / 2, midY - textPainter.height / 2)
          );
        }
      }
      else if (shape.type == 'line') {
        final start = shape.properties['start'] as Offset;
        final end = shape.properties['end'] as Offset;
        canvas.drawLine(start, end, paint);
        
        // Draw length measurement
        if (shape.properties['showMeasurement'] == true) {
          final dx = end.dx - start.dx;
          final dy = end.dy - start.dy;
          final length = math.sqrt(dx * dx + dy * dy);
          final lengthInCm = length / pixelToCmRatio;
          
          // Position the text along the line
          final textPoint = Offset(
            (start.dx + end.dx) / 2,
            (start.dy + end.dy) / 2 - 10,
          );
          
          final textPainter = TextPainter(
            text: TextSpan(
              text: '${lengthInCm.toStringAsFixed(1)} cm',
              style: TextStyle(
                color: shape.color,
                fontSize: 12,
                backgroundColor: Colors.white.withOpacity(0.7),
              ),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          );
          textPainter.layout();
          
          // Draw text background
          final textRect = Rect.fromCenter(
            center: textPoint,
            width: textPainter.width + 6,
            height: textPainter.height + 4,
          );
          canvas.drawRect(
            textRect,
            Paint()..color = Colors.white.withOpacity(0.7),
          );
          
          textPainter.paint(
            canvas, 
            Offset(textPoint.dx - textPainter.width / 2, textPoint.dy - textPainter.height / 2)
          );
        }
      } 
      else if (shape.type == 'angle') {
        final center = shape.properties['center'] as Offset;
        final startAngle = shape.properties['startAngle'] as double;
        final endAngle = shape.properties['endAngle'] as double;
        final radius = shape.properties['radius'] as double;
        
        // Calculate the sweep angle ensuring it's positive
        final sweepAngle = ((endAngle - startAngle) + 2 * math.pi) % (2 * math.pi);
        
        // Draw angle arms
        final arm1End = Offset(
          center.dx + radius * math.cos(startAngle),
          center.dy + radius * math.sin(startAngle),
        );
        
        final arm2End = Offset(
          center.dx + radius * math.cos(endAngle),
          center.dy + radius * math.sin(endAngle),
        );
        
        // Draw arms
        canvas.drawLine(center, arm1End, paint);
        canvas.drawLine(center, arm2End, paint);
        
        // Draw arc
        final arcPaint = Paint()
          ..color = shape.color.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        
        final arcRect = Rect.fromCircle(center: center, radius: radius * 0.5);
        canvas.drawArc(arcRect, startAngle, sweepAngle, true, arcPaint);
        
        // Draw arc outline
        canvas.drawArc(
          arcRect,
          startAngle,
          sweepAngle,
          false,
          Paint()
            ..color = shape.color
            ..strokeWidth = shape.width * 0.5
            ..style = PaintingStyle.stroke,
        );
        
        // Show angle measurement
        final angleDegrees = sweepAngle * 180 / math.pi;
        
        // Position for the text
        final midAngle = startAngle + sweepAngle / 2;
        final textRadius = radius * 0.3;
        final textPoint = Offset(
          center.dx + textRadius * math.cos(midAngle),
          center.dy + textRadius * math.sin(midAngle),
        );
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${angleDegrees.toStringAsFixed(1)}°',
            style: TextStyle(
              color: shape.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();
        
        textPainter.paint(
          canvas, 
          Offset(textPoint.dx - textPainter.width / 2, textPoint.dy - textPainter.height / 2)
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.shapes != shapes;
  }
}

// Compass Painter
class CompassPainter extends CustomPainter {
  final double radius;
  final bool drawingMode;
  final double? currentRadius;
  final Offset? pivotPoint;
  final double startAngle;
  final double? endAngle;
  final CompassDrawMode drawMode;
  final double pixelToCmRatio;

  CompassPainter({
    required this.radius,
    required this.drawingMode,
    this.currentRadius,
    this.pivotPoint,
    this.startAngle = 0,
    this.endAngle,
    this.drawMode = CompassDrawMode.circle,
    this.pixelToCmRatio = 37.8, // Default pixels per cm
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    // Draw the main compass body
    // Drawing compass legs
    final legPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    // First leg
    canvas.drawLine(
      center,
      Offset(center.dx - radius * 0.6, center.dy + radius * 0.8), 
      legPaint
    );
    
    // Second leg (with pencil)
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.6, center.dy + radius * 0.8), 
      legPaint
    );
    
    // Draw hinge at the top
    final hingePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.0, hingePaint);
    
    // Draw pencil tip
    final pencilTipPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx + radius * 0.6, center.dy + radius * 0.8),
      3.0,
      pencilTipPaint,
    );
    
    // Draw compass point
    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.6, center.dy + radius * 0.8),
      3.0,
      pointPaint,
    );
    
    // Draw the actual circle/arc guide when in drawing mode
    if (drawingMode && pivotPoint != null) {
      final guidePaint = Paint()
        ..color = Colors.blue.withOpacity(0.5)
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
        
      final double actualRadius = currentRadius ?? radius;
      
      // Draw based on the drawing mode
      switch (drawMode) {
        case CompassDrawMode.circle:
          canvas.drawCircle(pivotPoint!, actualRadius, guidePaint);
          break;
        case CompassDrawMode.arc:
          if (endAngle != null) {
            final rect = Rect.fromCircle(center: pivotPoint!, radius: actualRadius);
            canvas.drawArc(rect, startAngle, endAngle! - startAngle, false, guidePaint);
            
            // Draw radii at start and end points
            final startPoint = Offset(
              pivotPoint!.dx + actualRadius * math.cos(startAngle),
              pivotPoint!.dy + actualRadius * math.sin(startAngle)
            );
            final endPoint = Offset(
              pivotPoint!.dx + actualRadius * math.cos(endAngle!),
              pivotPoint!.dy + actualRadius * math.sin(endAngle!)
            );
            
            canvas.drawLine(pivotPoint!, startPoint, guidePaint);
            canvas.drawLine(pivotPoint!, endPoint, guidePaint);
          }
          break;
        case CompassDrawMode.halfCircle:
          final rect = Rect.fromCircle(center: pivotPoint!, radius: actualRadius);
          canvas.drawArc(rect, 0, math.pi, false, guidePaint);
          break;
      }
      
      // Draw center of the drawing
      canvas.drawCircle(pivotPoint!, 4.0, pointPaint);
      
      // Show radius measurement
      if (currentRadius != null) {
        final radiusCm = currentRadius! / pixelToCmRatio;
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'r: ${radiusCm.toStringAsFixed(1)} cm',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.white.withOpacity(0.7),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        // Background for text
        final textPoint = Offset(
          pivotPoint!.dx, 
          pivotPoint!.dy - actualRadius - 20
        );
        
        final bgRect = Rect.fromLTWH(
          textPoint.dx - textPainter.width / 2 - 4, 
          textPoint.dy - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        );
        
        canvas.drawRect(
          bgRect,
          Paint()..color = Colors.white.withOpacity(0.7),
        );
        
        textPainter.paint(
          canvas, 
          Offset(textPoint.dx - textPainter.width / 2, textPoint.dy)
        );
      }
    }
    
    // Drawing mode indicator
    if (drawingMode) {
      final indicatorPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(center.dx - 20, center.dy - 20),
        5.0,
        indicatorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) {
    return oldDelegate.radius != radius || 
           oldDelegate.drawingMode != drawingMode ||
           oldDelegate.currentRadius != currentRadius ||
           oldDelegate.pivotPoint != pivotPoint ||
           oldDelegate.startAngle != startAngle ||
           oldDelegate.endAngle != endAngle ||
           oldDelegate.drawMode != drawMode;
  }
}
// Protractor Painter
class ProtractorPainter extends CustomPainter {
  final double size;
  final double measuredAngle;
  final bool isDrawingAngle;
  final Offset? angleStartPoint;
  final Offset? angleEndPoint;
  final bool snapAngles;

  ProtractorPainter({
    required this.size,
    required this.measuredAngle,
    required this.isDrawingAngle,
    required this.angleStartPoint,
    this.angleEndPoint,
    this.snapAngles = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(this.size, this.size / 2);
    final radius = this.size;
    
    // Draw the protractor's base shape - semicircle
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    // Draw the semicircle
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 2,
    );
    canvas.drawArc(rect, 0, math.pi, false, paint);
    
    // Fill with transparent color
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawArc(rect, 0, math.pi, true, fillPaint);
    
    // Draw the baseline
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(this.size * 2, center.dy),
      paint,
    );

    // Draw the angle markings every 10 degrees
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    for (int angle = 0; angle <= 180; angle += 10) {
      final radians = angle * math.pi / 180;
      final markerLength = angle % 30 == 0 ? 15.0 : (angle % 10 == 0 ? 10.0 : 5.0);
      
      final x = center.dx + radius * math.cos(radians);
      final y = center.dy - radius * math.sin(radians);
      
      // Draw the marker line
      canvas.drawLine(
        Offset(x, y),
        Offset(
          center.dx + (radius - markerLength) * math.cos(radians),
          center.dy - (radius - markerLength) * math.sin(radians),
        ),
        paint,
      );
      
      // Label major angles
      if (angle % 30 == 0) {
        textPainter.text = TextSpan(
          text: '$angle°',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        );
        textPainter.layout();
        
        final textX = center.dx + (radius - 25) * math.cos(radians) - textPainter.width / 2;
        final textY = center.dy - (radius - 25) * math.sin(radians) - textPainter.height / 2;
        
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
    
    // Draw the center point
    final centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, centerPaint);
    
    // Draw the measured angle if in angle drawing mode
    if (isDrawingAngle && measuredAngle > 0) {
      final anglePaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      final angleInRadians = measuredAngle * math.pi / 180;
      final angleEndX = center.dx + radius * 0.8 * math.cos(angleInRadians);
      final angleEndY = center.dy - radius * 0.8 * math.sin(angleInRadians);
      
      // Draw the angle line
      canvas.drawLine(center, Offset(angleEndX, angleEndY), anglePaint);
      
      // Draw angle arc
      final arcPaint = Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.3),
        0,
        angleInRadians,
        true,
        arcPaint,
      );
      
      // Show angle measurement
      textPainter.text = TextSpan(
        text: '${measuredAngle.toStringAsFixed(1)}°',
        style: TextStyle(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      
      final textAngle = angleInRadians / 2;
      final textDistance = radius * 0.4;
      final textX = center.dx + textDistance * math.cos(textAngle) - textPainter.width / 2;
      final textY = center.dy - textDistance * math.sin(textAngle) - textPainter.height / 2;
      
      textPainter.paint(canvas, Offset(textX, textY));
      
      // If we have both start and end points in active drawing mode, show angle construction lines
      if (angleStartPoint != null && angleEndPoint != null) {
        final constructionPaint = Paint()
          ..color = Colors.orange
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
          
        canvas.drawLine(center, angleEndPoint!, constructionPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ProtractorPainter oldDelegate) {
    return oldDelegate.size != size ||
           oldDelegate.measuredAngle != measuredAngle ||
           oldDelegate.isDrawingAngle != isDrawingAngle ||
           oldDelegate.angleStartPoint != angleStartPoint ||
           oldDelegate.angleEndPoint != angleEndPoint ||
           oldDelegate.snapAngles != snapAngles;
  }
}

// Ruler Painter
class RulerPainter extends CustomPainter {
  final double length;
  final double cmToPixelRatio;
  final bool isDrawingLine;
  final Offset? lineStartPoint;
  final Offset? lineEndPoint;
  final bool snapAngles;

  RulerPainter({
    required this.length,
    required this.cmToPixelRatio,
    required this.isDrawingLine,
    required this.lineStartPoint,
    this.lineEndPoint,
    this.snapAngles = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade300
      ..style = PaintingStyle.fill;
    
    // Draw the ruler base
    final rulerRect = Rect.fromLTWH(0, 0, length, 50);
    canvas.drawRect(rulerRect, paint);
    
    // Draw the ruler border
    final borderPaint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(rulerRect, borderPaint);
    
    // Draw measurement markings
    final markingPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Calculate total cm based on the ratio
    final totalCm = (length / cmToPixelRatio).ceil();
    
    for (int cm = 0; cm <= totalCm; cm++) {
      final x = cm * cmToPixelRatio;
      
      // Draw cm marking (longer line)
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, 20),
        markingPaint,
      );
      
      // Add cm number
      textPainter.text = TextSpan(
        text: '$cm',
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, 25));
      
      // Draw mm markings (shorter lines)
      if (cm < totalCm) {
        for (int mm = 1; mm < 10; mm++) {
          final mmX = x + mm * cmToPixelRatio / 10;
          final lineHeight = mm == 5 ? 12.0 : 7.0; // Middle marking is longer
          
          canvas.drawLine(
            Offset(mmX, 0),
            Offset(mmX, lineHeight),
            markingPaint,
          );
        }
      }
    }
    
    // Draw "cm" unit label
    textPainter.text = TextSpan(
      text: 'cm',
      style: TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(length - textPainter.width - 5, 35));
    
    // Draw the drawing mode indicator
    if (isDrawingLine) {
      final indicatorPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(15, 15),
        5.0,
        indicatorPaint,
      );
      
      // Show measurement line if we have start and end points
      if (lineStartPoint != null && lineEndPoint != null) {
        final linePaint = Paint()
          ..color = Colors.red
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        
        canvas.drawLine(lineStartPoint!, lineEndPoint!, linePaint);
        
        // Calculate length
        final dx = lineEndPoint!.dx - lineStartPoint!.dx;
        final dy = lineEndPoint!.dy - lineStartPoint!.dy;
        final length = math.sqrt(dx * dx + dy * dy);
        final lengthInCm = length / cmToPixelRatio;
        
        // Calculate angle for snapping if enabled
        double angle = math.atan2(dy, dx);
        if (snapAngles) {
          // Snap to 0, 45, 90, 135, etc. degrees
          final snapAngle = (angle / (math.pi / 4)).round() * (math.pi / 4);
          
          // If snapped, recalculate end point
          if (snapAngle != angle) {
            angle = snapAngle;
            final snappedEndX = lineStartPoint!.dx + length * math.cos(angle);
            final snappedEndY = lineStartPoint!.dy + length * math.sin(angle);
            
            // Draw the snapped line with a different style
            final snappedPaint = Paint()
              ..color = Colors.green
              ..strokeWidth = 2.0
              ..style = PaintingStyle.stroke;
            
            canvas.drawLine(
              lineStartPoint!, 
              Offset(snappedEndX, snappedEndY),
              snappedPaint,
            );
          }
        }
        
        // Show measurement
        final textPoint = Offset(
          (lineStartPoint!.dx + lineEndPoint!.dx) / 2,
          (lineStartPoint!.dy + lineEndPoint!.dy) / 2 - 15,
        );
        
        final angleText = snapAngles
            ? '${(angle * 180 / math.pi).round()}°'
            : '';
        
        textPainter.text = TextSpan(
          text: '${lengthInCm.toStringAsFixed(1)} cm $angleText',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            backgroundColor: Colors.white.withOpacity(0.7),
          ),
        );
        textPainter.layout();
        
        // Draw background for text
        final bgRect = Rect.fromLTWH(
          textPoint.dx - textPainter.width / 2 - 4,
          textPoint.dy - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        );
        
        canvas.drawRect(
          bgRect,
          Paint()..color = Colors.white.withOpacity(0.7),
        );
        
        textPainter.paint(
          canvas, 
          Offset(textPoint.dx - textPainter.width / 2, textPoint.dy)
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RulerPainter oldDelegate) {
    return oldDelegate.length != length ||
           oldDelegate.cmToPixelRatio != cmToPixelRatio ||
           oldDelegate.isDrawingLine != isDrawingLine ||
           oldDelegate.lineStartPoint != lineStartPoint ||
           oldDelegate.lineEndPoint != lineEndPoint ||
           oldDelegate.snapAngles != snapAngles;
  }
}

// Enum for compass drawing modes
enum CompassDrawMode {
  circle,
  arc,
  halfCircle,
}

// Main Screen Widget -
// Main Screen Widget
class GeometricToolsScreen extends StatefulWidget {
  // Changed from const to regular constructor
  const GeometricToolsScreen({Key? key}) : super(key: key);

  @override
  _GeometricToolsScreenState createState() => _GeometricToolsScreenState();
}

class _GeometricToolsScreenState extends State<GeometricToolsScreen> {
  // Drawing state
  List<DrawingPoints> points = [];
  List<GeometricShape> shapes = [];
  
  // Current drawing properties
  Color selectedColor = Colors.black;
  double strokeWidth = 3.0;
  
  // Tools state
  String selectedTool = 'pen'; // 'pen', 'compass', 'protractor', 'ruler'
  bool isDrawing = false;
  
  // Compass properties
  double compassRadius = 100.0;
  bool compassDrawingMode = false;
  Offset? compassPivotPoint;
  double compassCurrentRadius = 0.0;
  double compassStartAngle = 0.0;
  double? compassEndAngle;
  CompassDrawMode compassDrawMode = CompassDrawMode.circle;
  
  // Protractor properties
  double protractorSize = 150.0;
  double measuredAngle = 0.0;
  bool isDrawingAngle = false;
  Offset? angleStartPoint;
  Offset? angleEndPoint;
  
  // Ruler properties
  double rulerLength = 300.0;
  double pixelToCmRatio = 37.8; // Approximate default value (96 DPI / 2.54)
  bool isDrawingLine = false;
  Offset? lineStartPoint;
  Offset? lineEndPoint;
  bool snapAngles = false;
  
  // Tool positions
  Offset compassPosition = Offset(100, 100);
  Offset protractorPosition = Offset(200, 300);
  Offset rulerPosition = Offset(100, 400);
  
  // Pan controllers for tools
  Offset panStart = Offset.zero;
  
  // Global key for capturing screenshot
  final GlobalKey canvasKey = GlobalKey();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geometric Drawing Tools'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveCanvas,
            tooltip: 'Save Drawing',
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearCanvas,
            tooltip: 'Clear Canvas',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tool Selection Bar
          Container(
            height: 60,
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolButton('pen', Icons.edit, 'Free Drawing'),
                _buildToolButton('compass', Icons.compass_calibration, 'Compass'),
                _buildToolButton('protractor', Icons.architecture, 'Protractor'),
                _buildToolButton('ruler', Icons.straighten, 'Ruler'),
                // Color Picker
                IconButton(
                  icon: Icon(Icons.color_lens, color: selectedColor),
                  onPressed: _showColorPicker,
                  tooltip: 'Change Color',
                ),
                // Stroke Width Slider
                Container(
                  width: 150,
                  child: Slider(
                    value: strokeWidth,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    label: strokeWidth.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        strokeWidth = value;
                      });
                    },
                  ),
                ),
                // Snap angles toggle
                Row(
                  children: [
                    Text('Snap Angles'),
                    Switch(
                      value: snapAngles,
                      onChanged: (value) {
                        setState(() {
                          snapAngles = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main Drawing Canvas
          Expanded(
            child: Stack(
              children: [
                // Background
                Container(
                  color: Colors.white,
                ),
                
                // Drawing Canvas
                RepaintBoundary(
                  key: canvasKey,
                  child: GestureDetector(
                    onPanStart: _handlePanStart,
                    onPanUpdate: _handlePanUpdate,
                    onPanEnd: _handlePanEnd,
                    child: CustomPaint(
                      painter: DrawingPainter(
                        points: points,
                        shapes: shapes,
                        pixelToCmRatio: pixelToCmRatio,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
                
                // Compass Tool
                if (selectedTool == 'compass')
                  Positioned(
                    left: compassPosition.dx - compassRadius,
                    top: compassPosition.dy - compassRadius,
                    child: GestureDetector(
                      onPanStart: (details) {
                        panStart = details.localPosition;
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          if (!compassDrawingMode) {
                            compassPosition = Offset(
                              compassPosition.dx + details.localPosition.dx - panStart.dx,
                              compassPosition.dy + details.localPosition.dy - panStart.dy,
                            );
                          } else if (compassPivotPoint != null) {
                            // Update compass radius when drawing
                            final dx = details.globalPosition.dx - compassPivotPoint!.dx;
                            final dy = details.globalPosition.dy - compassPivotPoint!.dy;
                            compassCurrentRadius = math.sqrt(dx * dx + dy * dy);
                            
                            if (compassDrawMode == CompassDrawMode.arc) {
                              compassEndAngle = math.atan2(dy, dx);
                            }
                          }
                        });
                      },
                      onTap: () {
                        if (!compassDrawingMode) {
                          // Enter drawing mode
                          setState(() {
                            compassDrawingMode = true;
                            compassPivotPoint = null;
                          });
                        } else if (compassPivotPoint == null) {
                          // Set pivot point
                          setState(() {
                            compassPivotPoint = Offset(
                              compassPosition.dx,
                              compassPosition.dy,
                            );
                            compassCurrentRadius = compassRadius;
                            
                            // For arc mode, set starting angle
                            if (compassDrawMode == CompassDrawMode.arc) {
                              compassStartAngle = 0; // Default starting angle
                            }
                          });
                        } else {
                          // Finalize drawing
                          _finalizeCompassDrawing();
                        }
                      },
                      onDoubleTap: () {
                        setState(() {
                          // Toggle drawing mode
                          if (compassDrawingMode) {
                            compassDrawingMode = false;
                            compassPivotPoint = null;
                          } else {
                            // Toggle drawing mode
                            switch (compassDrawMode) {
                              case CompassDrawMode.circle:
                                compassDrawMode = CompassDrawMode.arc;
                                break;
                              case CompassDrawMode.arc:
                                compassDrawMode = CompassDrawMode.halfCircle;
                                break;
                              case CompassDrawMode.halfCircle:
                                compassDrawMode = CompassDrawMode.circle;
                                break;
                            }
                          }
                        });
                      },
                      onLongPress: () {
                        // Adjust compass radius
                        _showRadiusDialog();
                      },
                      child: CustomPaint(
                        painter: CompassPainter(
                          radius: compassRadius,
                          drawingMode: compassDrawingMode,
                          currentRadius: compassCurrentRadius,
                          pivotPoint: compassPivotPoint,
                          startAngle: compassStartAngle,
                          endAngle: compassEndAngle,
                          drawMode: compassDrawMode,
                          pixelToCmRatio: pixelToCmRatio,
                        ),
                        size: Size(compassRadius * 2, compassRadius * 2),
                      ),
                    ),
                  ),
                
                // Protractor Tool
                if (selectedTool == 'protractor')
                  Positioned(
                    left: protractorPosition.dx - protractorSize,
                    top: protractorPosition.dy - protractorSize / 2,
                    child: GestureDetector(
                      onPanStart: (details) {
                        panStart = details.localPosition;
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          if (!isDrawingAngle) {
                            protractorPosition = Offset(
                              protractorPosition.dx + details.localPosition.dx - panStart.dx,
                              protractorPosition.dy + details.localPosition.dy - panStart.dy,
                            );
                          } else if (angleStartPoint != null) {
                            // Calculate angle with baseline
                            final dx = details.globalPosition.dx - protractorPosition.dx;
                            final dy = protractorPosition.dy - details.globalPosition.dy;
                            
                            measuredAngle = math.atan2(dy, dx) * 180 / math.pi;
                            if (measuredAngle < 0) measuredAngle += 360;
                            
                            // Constrain to 0-180 degrees for a protractor
                            if (measuredAngle > 180) measuredAngle = 180;
                            
                            angleEndPoint = details.globalPosition;
                          }
                        });
                      },
                      onTap: () {
                        if (!isDrawingAngle) {
                          // Enter angle drawing mode
                          setState(() {
                            isDrawingAngle = true;
                            angleStartPoint = null;
                          });
                        } else if (angleStartPoint == null) {
                          // Set first point of angle
                          setState(() {
                            angleStartPoint = protractorPosition;
                          });
                        } else {
                          // Finalize angle
                          _finalizeAngleMeasurement();
                        }
                      },
                      onDoubleTap: () {
                        setState(() {
                          // Toggle drawing mode
                          isDrawingAngle = !isDrawingAngle;
                          angleStartPoint = null;
                          angleEndPoint = null;
                        });
                      },
                      child: CustomPaint(
                        painter: ProtractorPainter(
                          size: protractorSize,
                          measuredAngle: measuredAngle,
                          isDrawingAngle: isDrawingAngle,
                          angleStartPoint: angleStartPoint,
                          angleEndPoint: angleEndPoint,
                          snapAngles: snapAngles,
                        ),
                        size: Size(protractorSize * 2, protractorSize),
                      ),
                    ),
                  ),
                
                // Ruler Tool
                if (selectedTool == 'ruler')
                  Positioned(
                    left: rulerPosition.dx,
                    top: rulerPosition.dy,
                    child: Transform.rotate(
                      angle: 0, // Can be enhanced to allow rotation
                      child: GestureDetector(
                        onPanStart: (details) {
                          panStart = details.localPosition;
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            if (!isDrawingLine) {
                              rulerPosition = Offset(
                                rulerPosition.dx + details.localPosition.dx - panStart.dx,
                                rulerPosition.dy + details.localPosition.dy - panStart.dy,
                              );
                            } else if (lineStartPoint != null) {
                              lineEndPoint = details.globalPosition;
                            }
                          });
                        },
                        onTapUp: (TapUpDetails tapDetails) {
  if (!isDrawingLine) {
    // Enter line drawing mode
    setState(() {
      isDrawingLine = true;
      lineStartPoint = null;
    });
  } else if (lineStartPoint == null) {
    // Set first point of line
    setState(() {
      lineStartPoint = tapDetails.globalPosition;
    });
  } else {
    // Finalize line
    _finalizeLineMeasurement();
  }
},
                        onDoubleTap: () {
                          setState(() {
                            // Toggle drawing mode
                            isDrawingLine = !isDrawingLine;
                            lineStartPoint = null;
                            lineEndPoint = null;
                          });
                        },
                        onLongPress: () {
                          // Adjust ruler settings
                          _showRulerSettingsDialog();
                        },
                        child: CustomPaint(
                          painter: RulerPainter(
                            length: rulerLength,
                            cmToPixelRatio: pixelToCmRatio,
                            isDrawingLine: isDrawingLine,
                            lineStartPoint: lineStartPoint,
                            lineEndPoint: lineEndPoint,
                            snapAngles: snapAngles,
                          ),
                          size: Size(rulerLength, 50),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Selected Tool: ${selectedTool.toUpperCase()}'),
              SizedBox(width: 20),
              if (selectedTool == 'compass') 
                Text('Double-tap to change mode: ${compassDrawMode.toString().split('.').last}'),
              if (selectedTool == 'protractor')
                Text('Angle: ${measuredAngle.toStringAsFixed(1)}°'),
              if (selectedTool == 'ruler')
                Text('Ruler Length: ${(rulerLength / pixelToCmRatio).toStringAsFixed(1)} cm'),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build a tool button with icon and tooltip
  Widget _buildToolButton(String tool, IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(
        icon,
        color: selectedTool == tool ? Colors.blue : Colors.grey,
        size: 30,
      ),
      onPressed: () {
        setState(() {
          selectedTool = tool;
          // Reset all drawing modes when switching tools
          compassDrawingMode = false;
          isDrawingAngle = false;
          isDrawingLine = false;
          isDrawing = false;
        });
      },
      tooltip: tooltip,
    );
  }
  
  // Handle pan start based on selected tool
  void _handlePanStart(DragStartDetails details) {
    if (selectedTool == 'pen') {
      setState(() {
        isDrawing = true;
        points.add(
          DrawingPoints(
            points: [details.localPosition],
            color: selectedColor,
            width: strokeWidth,
          ),
        );
      });
    }
  }
  
  // Handle pan update based on selected tool
  void _handlePanUpdate(DragUpdateDetails details) {
    if (selectedTool == 'pen' && isDrawing) {
      setState(() {
        if (points.isNotEmpty) {
          List<Offset> updatedPoints = List.from(points.last.points)
            ..add(details.localPosition);
          
          points[points.length - 1] = DrawingPoints(
            points: updatedPoints,
            color: selectedColor,
            width: strokeWidth,
          );
        }
      });
    }
  }
  
  // Handle pan end based on selected tool
  void _handlePanEnd(DragEndDetails details) {
    if (selectedTool == 'pen') {
      setState(() {
        isDrawing = false;
      });
    }
  }
  
  // Show color picker dialog
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Color'),
          content: SingleChildScrollView(
            child: Container(
              width: 300,
              height: 300,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: _colors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = _colors[index];
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _colors[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Color palette
  final List<Color> _colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.grey,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.redAccent,
  ];
  
  // Show radius adjustment dialog for compass
  void _showRadiusDialog() {
    TextEditingController controller = TextEditingController(
      text: (compassRadius / pixelToCmRatio).toStringAsFixed(1),
    );
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adjust Compass Radius'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Radius (cm)',
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 20),
              Text('Current mode: ${compassDrawMode.toString().split('.').last}'),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        compassDrawMode = CompassDrawMode.circle;
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Circle'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        compassDrawMode = CompassDrawMode.arc;
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Arc'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        compassDrawMode = CompassDrawMode.halfCircle;
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Half Circle'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  double newRadius = double.tryParse(controller.text) ?? 5.0;
                  compassRadius = newRadius * pixelToCmRatio;
                });
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }
  
  // Show ruler settings dialog
  void _showRulerSettingsDialog() {
    TextEditingController lengthController = TextEditingController(
      text: (rulerLength / pixelToCmRatio).toStringAsFixed(1),
    );
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ruler Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: lengthController,
                decoration: InputDecoration(
                  labelText: 'Length (cm)',
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 20),
              CheckboxListTile(
                title: Text('Snap to angles'),
                value: snapAngles,
                onChanged: (value) {
                  setState(() {
                    snapAngles = value ?? false;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  double newLength = double.tryParse(lengthController.text) ?? 10.0;
                  rulerLength = newLength * pixelToCmRatio;
                });
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }
  
  // Finalize compass drawing
  void _finalizeCompassDrawing() {
    if (compassPivotPoint != null) {
      final properties = <String, dynamic>{
        'center': compassPivotPoint,
        'radius': compassCurrentRadius,
        'showRadius': true,
      };
      
      if (compassDrawMode == CompassDrawMode.circle) {
        shapes.add(GeometricShape(
          type: 'circle',
          properties: properties,
          color: selectedColor,
          width: strokeWidth,
        ));
      } else if (compassDrawMode == CompassDrawMode.arc && compassEndAngle != null) {
        shapes.add(GeometricShape(
          type: 'arc',
          properties: {
            ...properties,
            'startAngle': compassStartAngle,
            'endAngle': compassEndAngle,
          },
          color: selectedColor,
          width: strokeWidth,
        ));
      } else if (compassDrawMode == CompassDrawMode.halfCircle) {
        shapes.add(GeometricShape(
          type: 'arc',
          properties: {
            ...properties,
            'startAngle': 0.0,
            'endAngle': math.pi,
          },
          color: selectedColor,
          width: strokeWidth,
        ));
      }
      
      setState(() {
        compassDrawingMode = false;
        compassPivotPoint = null;
      });
    }
  }
  
  // Finalize angle measurement
  void _finalizeAngleMeasurement() {
    if (angleStartPoint != null && angleEndPoint != null) {
      // Calculate angle
      final dx = angleEndPoint!.dx - protractorPosition.dx;
      final dy = protractorPosition.dy - angleEndPoint!.dy;
      double angle = math.atan2(dy, dx);
      if (angle < 0) angle += 2 * math.pi;
      
      shapes.add(GeometricShape(
        type: 'angle',
        properties: {
          'center': protractorPosition,
          'startAngle': 0,
          'endAngle': angle,
          'radius': protractorSize * 0.8,
        },
        color: selectedColor,
        width: strokeWidth,
      ));
      
      setState(() {
        isDrawingAngle = false;
        angleStartPoint = null;
        angleEndPoint = null;
      });
    }
  }
  
  // Finalize line measurement
  void _finalizeLineMeasurement() {
    if (lineStartPoint != null && lineEndPoint != null) {
      Offset startPoint = lineStartPoint!;
      Offset endPoint = lineEndPoint!;
      
      // Apply angle snapping if enabled
      if (snapAngles) {
        final dx = endPoint.dx - startPoint.dx;
        final dy = endPoint.dy - startPoint.dy;
        final length = math.sqrt(dx * dx + dy * dy);
        final angle = math.atan2(dy, dx);
        
        // Snap to nearest 45 degrees
        final snapAngle = (angle / (math.pi / 4)).round() * (math.pi / 4);
        
        endPoint = Offset(
          startPoint.dx + length * math.cos(snapAngle),
          startPoint.dy + length * math.sin(snapAngle),
        );
      }
      
      shapes.add(GeometricShape(
        type: 'line',
        properties: {
          'start': startPoint,
          'end': endPoint,
          'showMeasurement': true,
        },
        color: selectedColor,
        width: strokeWidth,
      ));
      
      setState(() {
        isDrawingLine = false;
        lineStartPoint = null;
        lineEndPoint = null;
      });
    }
  }
  
  // Clear the canvas
  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Clear Canvas'),
          content: Text('Are you sure you want to clear the entire canvas?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  points.clear();
                  shapes.clear();
                });
                Navigator.pop(context);
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }
  
  // Save canvas as image
  Future<void> _saveCanvas() async {
    try {
      // Capture the canvas as an image
      RenderRepaintBoundary boundary = canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image')),
        );
        return;
      }
      
      Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'geometric_drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${directory.path}/$fileName';
      
      // Write the file
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Drawing saved to $filePath')),
      );
      
      // Copy to clipboard option
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Drawing Saved'),
            content: Text('Drawing saved to:\n$filePath\n\nWould you like to copy the path to clipboard?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: filePath));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Path copied to clipboard')),
                  );
                },
                child: Text('Copy Path'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving drawing: $e')),
      );
    }
  }
}