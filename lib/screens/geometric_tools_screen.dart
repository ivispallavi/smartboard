import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

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

// Drawing Painter for rendered drawing points
class DrawingPainter extends CustomPainter {
  final List<DrawingPoints> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
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
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

// Compass Painter
class CompassPainter extends CustomPainter {
  final double radius;
  final bool drawingMode;

  CompassPainter({
    required this.radius,
    required this.drawingMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    // Draw the main compass circle (visible when not in drawing mode)
    if (!drawingMode) {
      canvas.drawCircle(center, radius, paint);
    }
    
    // Draw the compass arms
    final pencilPaint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    // Draw the center pivot
    final pivotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.0, pivotPaint);
    
    // Draw the arms
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius), // Pencil end
      pencilPaint,
    );
    
    // Draw the second arm (perpendicular to the first one)
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy + radius * 0.7), // Support arm
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke,
    );
    
    // Draw the pencil tip
    final pencilTipPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius),
      3.0,
      pencilTipPaint,
    );
    
    // Draw handle
    final handlePaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center,
      10.0,
      handlePaint,
    );
    
    // Drawing mode indicator
    if (drawingMode) {
      final indicatorPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(center.dx + 15, center.dy - 15),
        5.0,
        indicatorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) {
    return oldDelegate.radius != radius || 
           oldDelegate.drawingMode != drawingMode;
  }
}

// Protractor Painter
class ProtractorPainter extends CustomPainter {
  final double size;
  final double measuredAngle;
  final bool isDrawingAngle;
  final Offset? angleStartPoint;

  ProtractorPainter({
    required this.size,
    required this.measuredAngle,
    required this.isDrawingAngle,
    required this.angleStartPoint,
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
    canvas.drawCircle(center, 3.0, centerPaint);
    
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
    }
  }

  @override
  bool shouldRepaint(covariant ProtractorPainter oldDelegate) {
    return oldDelegate.size != size ||
           oldDelegate.measuredAngle != measuredAngle ||
           oldDelegate.isDrawingAngle != isDrawingAngle;
  }
}

// Ruler Painter
class RulerPainter extends CustomPainter {
  final double length;
  final double cmToPixelRatio;
  final bool isDrawingLine;
  final Offset? lineStartPoint;

  RulerPainter({
    required this.length,
    required this.cmToPixelRatio,
    required this.isDrawingLine,
    required this.lineStartPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    // Draw the ruler base
    final rulerRect = Rect.fromLTWH(0, 0, length, 40);
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
    
    // Calculate cm and mm markings based on the ratio
    final totalCm = (length / cmToPixelRatio).floor();
    
    for (int cm = 0; cm <= totalCm; cm++) {
      final x = cm * cmToPixelRatio;
      
      // Draw cm marking (longer line)
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, 15),
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
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, 20));
      
      // Draw mm markings (shorter lines)
      if (cm < totalCm) {
        for (int mm = 1; mm < 10; mm++) {
          final mmX = x + mm * cmToPixelRatio / 10;
          final lineHeight = mm == 5 ? 10.0 : 5.0; // Middle marking is longer
          
          canvas.drawLine(
            Offset(mmX, 0),
            Offset(mmX, lineHeight),
            markingPaint,
          );
        }
      }
    }
    
    // Draw the drawing mode indicator
    if (isDrawingLine) {
      final indicatorPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(10, 10),
        5.0,
        indicatorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RulerPainter oldDelegate) {
    return oldDelegate.length != length ||
           oldDelegate.cmToPixelRatio != cmToPixelRatio ||
           oldDelegate.isDrawingLine != isDrawingLine;
  }
}

// Set Square Painter
class SetSquarePainter extends CustomPainter {
  final double size;
  final double cmToPixelRatio;

  SetSquarePainter({
    required this.size,
    required this.cmToPixelRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    // Draw 45-degree set square (right triangle)
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(this.size, this.size);
    path.lineTo(0, this.size);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw the border
    final borderPaint = Paint()
      ..color = Colors.green.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);
    
    // Draw measurement markings
    final markingPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;
    
    // Helper method to draw markings along a line
    void drawMarkingsAlongLine(Offset start, Offset end, int divisions) {
      final dx = (end.dx - start.dx) / divisions;
      final dy = (end.dy - start.dy) / divisions;
      
      for (int i = 0; i <= divisions; i++) {
        final x = start.dx + dx * i;
        final y = start.dy + dy * i;
        
        final markLength = i % 5 == 0 ? 8.0 : 4.0;
        final angle = math.atan2(dy, dx) + math.pi/2;
        
        canvas.drawLine(
          Offset(x, y),
          Offset(
            x + markLength * math.cos(angle),
            y + markLength * math.sin(angle),
          ),
          markingPaint,
        );
        
        // Add label for major divisions
        if (i % 5 == 0) {
          final textPainter = TextPainter(
            textDirection: TextDirection.ltr,
            text: TextSpan(
              text: '${i ~/ 5}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
            ),
          );
          textPainter.layout();
          
          textPainter.paint(
            canvas, 
            Offset(
              x + 12 * math.cos(angle) - textPainter.width / 2,
              y + 12 * math.sin(angle) - textPainter.height / 2,
            ),
          );
        }
      }
    }
    
    // Draw markings on the hypotenuse
    final hypotenuseDivisions = (this.size / cmToPixelRatio * 1.414).floor() * 5;
    drawMarkingsAlongLine(
      Offset(0, 0), 
      Offset(this.size, this.size),
      hypotenuseDivisions,
    );
    
    // Draw markings on the vertical edge
    final verticalDivisions = (this.size / cmToPixelRatio).floor() * 5;
    drawMarkingsAlongLine(
      Offset(0, 0), 
      Offset(0, this.size),
      verticalDivisions,
    );
    
    // Draw markings on the horizontal edge
    final horizontalDivisions = (this.size / cmToPixelRatio).floor() * 5;
    drawMarkingsAlongLine(
      Offset(0, this.size), 
      Offset(this.size, this.size),
      horizontalDivisions,
    );
    
    // Draw angle markers
    final angleTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // 45° angle marker
    angleTextPainter.text = TextSpan(
      text: '45°',
      style: TextStyle(
        color: Colors.red,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    angleTextPainter.layout();
    angleTextPainter.paint(canvas, Offset(this.size * 0.15, this.size * 0.15));
    
    // 90° angle marker
    angleTextPainter.text = TextSpan(
      text: '90°',
      style: TextStyle(
        color: Colors.red,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    angleTextPainter.layout();
    angleTextPainter.paint(canvas, Offset(this.size * 0.08, this.size * 0.85));
    
    // 45° angle marker (top right)
    angleTextPainter.text = TextSpan(
      text: '45°',
      style: TextStyle(
        color: Colors.red,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    angleTextPainter.layout();
    angleTextPainter.paint(canvas, Offset(this.size * 0.85, this.size * 0.85));
  }

  @override
  bool shouldRepaint(covariant SetSquarePainter oldDelegate) {
    return oldDelegate.size != size ||
           oldDelegate.cmToPixelRatio != cmToPixelRatio;
  }
}

// Main Screen Widget
class GeometricToolsScreen extends StatefulWidget {
  const GeometricToolsScreen({Key? key}) : super(key: key);

  @override
  _GeometricToolsScreenState createState() => _GeometricToolsScreenState();
}

class _GeometricToolsScreenState extends State<GeometricToolsScreen> {
  // Tool selection
  String selectedTool = 'none';
  GlobalKey canvasKey = GlobalKey();
  
  // Tool properties
  double scale = 1.0;
  double rotation = 0.0;
  Offset position = Offset.zero;
  
  // For rotation control
  bool isRotating = false;
  Offset? rotationStartPosition;
  double startRotation = 0.0;
  
  // For compass
  double compassRadius = 100.0;
  bool drawingWithCompass = false;
  Offset? compassCenter;
  Offset? compassPencilPosition; // Position of the pencil end
  
  // For protractor
  double protractorSize = 150.0;
  double measuredAngle = 0.0;
  bool isDrawingAngle = false;
  Offset? angleStartPoint;
  
  // For ruler
  double rulerLength = 200.0;
  double cmToPixelRatio = 10.0; // 10 pixels = 1 cm
  bool isDrawingLine = false;
  Offset? lineStartPoint;
  
  // For set square
  double setSquareSize = 150.0;
  
  // Drawing properties
  List<DrawingPoints> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 3.0;

  // Zoom settings
  final double zoomFactor = 0.1; // 10% zoom increment/decrement
  final double minZoom = 0.5;    // 50% minimum zoom
  final double maxZoom = 2.0;    // 200% maximum zoom
  Offset? lastZoomCenter;        // Track the zoom center for mouse wheel zoom
  
  // Gesture handling flags
  bool isDragging = false;
  bool isToolPressed = false;
  bool isModifierKeyPressed = false; // For Ctrl key to rotate
  bool isDrawing = false; // Flag to track drawing state

  @override
  void initState() {
    super.initState();
    // Initialize position to be center of the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Calculate the center position of the screen
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height - 160; // Accounting for AppBar and tool bar
      setState(() {
        position = Offset(screenWidth / 2, screenHeight / 2);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geometric Tools'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCanvas,
            tooltip: 'Save',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearCanvas,
            tooltip: 'Clear',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Drawing canvas with tools
                RepaintBoundary(
                  key: canvasKey,
                  child: Listener(
                    onPointerSignal: _handlePointerSignal,
                    onPointerDown: _handlePointerDown,
                    onPointerUp: _handlePointerUp,
                    child: GestureDetector(
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      onScaleEnd: _onScaleEnd,
                      child: Stack(
                        children: [
                          // Drawing canvas
                          CustomPaint(
                            size: Size.infinite,
                            painter: DrawingPainter(points: points),
                          ),
                          
                          // Active tool (with fixed dragging)
                          if (selectedTool == 'compass') _buildCompassTool(),
                          if (selectedTool == 'protractor') _buildProtractorTool(),
                          if (selectedTool == 'ruler') _buildRulerTool(),
                          if (selectedTool == 'setSquare') _buildSetSquareTool(),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Show instructions when a geometric tool is selected
                if (_isGeometricTool(selectedTool))
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drag: Touch and move',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rotate: Hold Ctrl + Drag',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Zoom: Pinch or Mouse wheel',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          // Tool-specific instructions
                          if (selectedTool == 'compass')
                            Text(
                              'Double-tap: Toggle drawing mode',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                  ),
                
                // Add zoom controls - only show when a tool is selected
                if (_isGeometricTool(selectedTool))
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        _buildZoomButton(
                          icon: Icons.add,
                          onPressed: () => _zoomIn(null),
                          tooltip: 'Zoom In',
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(scale * 100).toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildZoomButton(
                          icon: Icons.remove,
                          onPressed: () => _zoomOut(null),
                          tooltip: 'Zoom Out',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Tool selection bar
          Container(
            height: 80,
            color: Colors.grey[200],
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              children: [
                _buildToolButton('compass', 'Compass', Icons.radio_button_unchecked),
                _buildToolButton('protractor', 'Protractor', Icons.architecture),
                _buildToolButton('ruler', 'Ruler', Icons.straighten),
                _buildToolButton('setSquare', 'Set Square', Icons.change_history),
                _buildToolButton('pencil', 'Pencil', Icons.edit),
                _buildToolButton('eraser', 'Eraser', Icons.auto_fix_high),
                _buildToolButton('none', 'Select', Icons.pan_tool),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Improved pointer handling for key modifiers
  void _handlePointerDown(PointerDownEvent event) {
    // Check for modifier keys (Ctrl for rotation)
    isModifierKeyPressed = event.down;
    
    if (isModifierKeyPressed && _isGeometricTool(selectedTool)) {
      setState(() {
        isRotating = true;
        rotationStartPosition = event.position;
        startRotation = rotation;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    isModifierKeyPressed = false;
    if (isRotating) {
      setState(() {
        isRotating = false;
        rotationStartPosition = null;
      });
    }
    
    // End drawing if drawing with pencil or eraser
    if (isDrawing) {
      setState(() {
        isDrawing = false;
      });
    }
  }

  // Handle mouse wheel events for zooming
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && _isGeometricTool(selectedTool)) {
      // Check if Ctrl key is pressed - for rotation
      if (isModifierKeyPressed) {
        // Rotate with Ctrl + mouse wheel
        setState(() {
          rotation += (event.scrollDelta.dy > 0 ? -0.05 : 0.05);
        });
      } else {
        // Normal mouse wheel handles zoom
        setState(() {
          lastZoomCenter = event.position;
          if (event.scrollDelta.dy < 0) {
            _zoomIn(event.position);
          } else {
            _zoomOut(event.position);
          }
        });
      }
    }
  }

  // Scale gesture handlers for pinch-to-zoom and also handle drawing
  void _onScaleStart(ScaleStartDetails details) {
    if (_isGeometricTool(selectedTool)) {
      // Store initial scale and rotation values
      setState(() {
        lastZoomCenter = details.focalPoint;
        isDragging = true;
      });
    } else if (selectedTool == 'pencil' || selectedTool == 'eraser') {
      // For drawing with pencil
      _startDrawingAt(details.focalPoint);
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_isGeometricTool(selectedTool)) {
      setState(() {
        // Handle pinch zoom
        if (details.scale != 1.0) {
          double newScale = scale * details.scale;
          newScale = newScale.clamp(minZoom, maxZoom);
          
          // If scale changed, update position to zoom toward focal point
          if (newScale != scale) {
            // Calculate the vector from zoom center to position
            Offset positionVector = position - details.focalPoint;
            // Scale this vector by the zoom factor ratio
            positionVector = positionVector * (newScale / scale);
            // Update position
            position = details.focalPoint + positionVector;
            // Update scale
            scale = newScale;
          }
        }
        
        // Handle rotation if modifier key is pressed or two-finger rotation
        if (isModifierKeyPressed && details.rotation != 0.0) {
          rotation += details.rotation;
        }
        
        // Handle movement if not rotating and not doing a multi-finger gesture
        if (!isRotating && details.scale == 1.0 && details.rotation == 0.0) {
          position += details.focalPointDelta;
        }
      });
    } else if (selectedTool == 'pencil' || selectedTool == 'eraser') {
      // Only draw if it's a single finger gesture (no scaling)
      if (details.scale == 1.0 && details.rotation == 0.0) {
        _continueDrawingAt(details.focalPoint);
      }
    }
  }

  // Start drawing at the
  void _onScaleEnd(ScaleEndDetails details) {
    if (_isGeometricTool(selectedTool)) {
      setState(() {
        isDragging = false;
      });
    } else if (selectedTool == 'pencil' || selectedTool == 'eraser') {
      setState(() {
        isDrawing = false;
      });
    }
  }

  // Drawing functions
  void _startDrawingAt(Offset position) {
    if (selectedTool == 'pencil' || selectedTool == 'eraser') {
      setState(() {
        isDrawing = true;
        final newPoint = DrawingPoints(
          points: [position],
          color: selectedTool == 'eraser' ? Colors.white : selectedColor,
          width: selectedTool == 'eraser' ? strokeWidth * 3 : strokeWidth,
        );
        points.add(newPoint);
      });
    }
  }

  void _continueDrawingAt(Offset position) {
    if (isDrawing && (selectedTool == 'pencil' || selectedTool == 'eraser')) {
      setState(() {
        final lastPointIndex = points.length - 1;
        if (lastPointIndex >= 0) {
          final lastPointsList = points[lastPointIndex].points;
          lastPointsList.add(position);
          
          // Create a new point object with updated points list
          points[lastPointIndex] = DrawingPoints(
            points: lastPointsList,
            color: points[lastPointIndex].color,
            width: points[lastPointIndex].width,
          );
        }
      });
    }
  }

  // Helper to check if a geometric tool is selected
  bool _isGeometricTool(String tool) {
    return ['compass', 'protractor', 'ruler', 'setSquare'].contains(tool);
  }

  // Zoom controls
  void _zoomIn(Offset? center) {
    setState(() {
      final newScale = (scale * (1 + zoomFactor)).clamp(minZoom, maxZoom);
      _updateZoom(newScale, center ?? Offset(MediaQuery.of(context).size.width / 2, 
                                           MediaQuery.of(context).size.height / 2));
    });
  }

  void _zoomOut(Offset? center) {
    setState(() {
      final newScale = (scale * (1 - zoomFactor)).clamp(minZoom, maxZoom);
      _updateZoom(newScale, center ?? Offset(MediaQuery.of(context).size.width / 2, 
                                           MediaQuery.of(context).size.height / 2));
    });
  }

  void _updateZoom(double newScale, Offset center) {
    // Calculate the vector from zoom center to position
    final zoomCenter = center;
    final positionVector = position - zoomCenter;
    
    // Apply zoom
    final scaleFactor = newScale / scale;
    final newPosition = zoomCenter + positionVector * scaleFactor;
    
    // Update state
    scale = newScale;
    position = newPosition;
  }

  // Tool creation widgets
  Widget _buildCompassTool() {
    return Positioned(
      left: position.dx - compassRadius,
      top: position.dy - compassRadius,
      child: Transform.rotate(
        angle: rotation,
        child: GestureDetector(
          onDoubleTap: () {
            setState(() {
              drawingWithCompass = !drawingWithCompass;
              if (drawingWithCompass) {
                compassCenter = position;
              } else {
                compassCenter = null;
                compassPencilPosition = null;
              }
            });
          },
          child: CustomPaint(
            size: Size(compassRadius * 2, compassRadius * 2),
            painter: CompassPainter(
              radius: compassRadius,
              drawingMode: drawingWithCompass,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProtractorTool() {
    return Positioned(
      left: position.dx - protractorSize,
      top: position.dy - protractorSize / 2,
      child: Transform.rotate(
        angle: rotation,
        child: GestureDetector(
          onDoubleTap: () {
            setState(() {
              isDrawingAngle = !isDrawingAngle;
              if (isDrawingAngle) {
                angleStartPoint = position;
              } else {
                angleStartPoint = null;
                measuredAngle = 0.0;
              }
            });
          },
          child: CustomPaint(
            size: Size(protractorSize * 2, protractorSize),
            painter: ProtractorPainter(
              size: protractorSize,
              measuredAngle: measuredAngle,
              isDrawingAngle: isDrawingAngle,
              angleStartPoint: angleStartPoint,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRulerTool() {
    return Positioned(
      left: position.dx - rulerLength / 2,
      top: position.dy - 20,
      child: Transform.rotate(
        angle: rotation,
        child: GestureDetector(
          onDoubleTap: () {
            setState(() {
              isDrawingLine = !isDrawingLine;
              if (isDrawingLine) {
                lineStartPoint = position;
              } else {
                lineStartPoint = null;
              }
            });
          },
          child: CustomPaint(
            size: Size(rulerLength, 40),
            painter: RulerPainter(
              length: rulerLength,
              cmToPixelRatio: cmToPixelRatio,
              isDrawingLine: isDrawingLine,
              lineStartPoint: lineStartPoint,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetSquareTool() {
    return Positioned(
      left: position.dx - setSquareSize / 2,
      top: position.dy - setSquareSize / 2,
      child: Transform.rotate(
        angle: rotation,
        child: CustomPaint(
          size: Size(setSquareSize, setSquareSize),
          painter: SetSquarePainter(
            size: setSquareSize,
            cmToPixelRatio: cmToPixelRatio,
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton(String tool, String label, IconData icon) {
    final isSelected = selectedTool == tool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            color: isSelected ? Colors.blue : Colors.black54,
            iconSize: isSelected ? 32 : 24,
            onPressed: () {
              setState(() {
                selectedTool = tool;
              });
            },
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: 24,
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  // Save canvas to image
  Future<void> _saveCanvas() async {
    try {
      final boundary = canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        
        // Get application documents directory to save the image
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'geometric_drawing_${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = '${directory.path}/$fileName';
        
        // Write to file
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Drawing saved to $filePath')),
        );
      }
    } catch (e) {
      print('Error saving canvas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save drawing')),
      );
    }
  }

  // Clear canvas
  void _clearCanvas() {
    setState(() {
      points.clear();
    });
  }
}

// Main app
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geometric Tools',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GeometricToolsScreen(),
    );
  }
}