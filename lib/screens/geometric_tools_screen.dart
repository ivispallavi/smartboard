import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:smart_board/screens/shape_utils.dart';
import 'package:flutter/gestures.dart'; // Add this for mouse wheel support

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
  
  // For compass
  double compassRadius = 100.0;
  bool drawingWithCompass = false;
  Offset? compassCenter;
  
  // For protractor
  double protractorSize = 150.0;
  double measuredAngle = 0.0;
  
  // For ruler
  double rulerLength = 200.0;
  
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
  
  // Rotation control
  bool isRotating = false;
  double rotationStartAngle = 0.0;

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
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: Stack(
                        children: [
                          // Drawing canvas
                          CustomPaint(
                            size: Size.infinite,
                            painter: DrawingPainter(points: points),
                          ),
                          
                          // Active tool
                          if (selectedTool == 'compass') _buildCompassTool(),
                          if (selectedTool == 'protractor') _buildProtractorTool(),
                          if (selectedTool == 'ruler') _buildRulerTool(),
                          if (selectedTool == 'setSquare') _buildSetSquareTool(),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Add zoom controls - only show when a tool is selected
                if (selectedTool != 'none' && 
                    selectedTool != 'pencil' && 
                    selectedTool != 'eraser')
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        _buildZoomButton(
                          icon: Icons.add,
                          onPressed: _zoomIn,
                          tooltip: 'Zoom In',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(scale * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            backgroundColor: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildZoomButton(
                          icon: Icons.remove,
                          onPressed: _zoomOut,
                          tooltip: 'Zoom Out',
                        ),
                        const SizedBox(height: 16),
                        _buildRotationButton(
                          icon: Icons.rotate_right,
                          onPressed: _rotateClockwise,
                          tooltip: 'Rotate Clockwise',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(rotation * 180 / math.pi).toInt()}°',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            backgroundColor: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRotationButton(
                          icon: Icons.rotate_left,
                          onPressed: _rotateCounterClockwise,
                          tooltip: 'Rotate Counter-Clockwise',
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

  // Handle mouse wheel for zooming
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Only handle zoom if a geometric tool is active
      if (selectedTool == 'compass' || selectedTool == 'protractor' || 
          selectedTool == 'ruler' || selectedTool == 'setSquare') {
        final double normalizedScrollDelta = 
            event.scrollDelta.dy.sign * math.min(0.2, event.scrollDelta.dy.abs() / 200);
        
        setState(() {
          // Zoom in or out based on scroll direction
          scale -= normalizedScrollDelta * zoomFactor;
          
          // Constrain scale within min and max values
          scale = scale.clamp(minZoom, maxZoom);
        });
      }
    }
  }

  // Zoom button widget
  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  // Rotation button widget
  Widget _buildRotationButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  // Rotation functions
  void _rotateClockwise() {
    setState(() {
      rotation += math.pi / 18; // 10 degrees clockwise
    });
  }

  void _rotateCounterClockwise() {
    setState(() {
      rotation -= math.pi / 18; // 10 degrees counter-clockwise
    });
  }

  // Zoom in function
  void _zoomIn() {
    setState(() {
      if (scale < maxZoom) {
        scale += zoomFactor;
        // Ensure scale doesn't exceed maximum
        scale = math.min(scale, maxZoom);
      }
    });
  }

  // Zoom out function
  void _zoomOut() {
    setState(() {
      if (scale > minZoom) {
        scale -= zoomFactor;
        // Ensure scale doesn't go below minimum
        scale = math.max(scale, minZoom);
      }
    });
  }

  Widget _buildToolButton(String tool, String label, IconData icon) {
    final isSelected = selectedTool == tool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: () {
              setState(() {
                selectedTool = tool;
                // Reset position and rotation when selecting a new tool
                if (selectedTool == 'compass') {
                  position = Offset(MediaQuery.of(context).size.width / 2, 
                                    MediaQuery.of(context).size.height / 3);
                } else if (selectedTool == 'protractor') {
                  position = Offset(MediaQuery.of(context).size.width / 2, 
                                    MediaQuery.of(context).size.height / 3);
                } else if (selectedTool == 'ruler') {
                  position = Offset(MediaQuery.of(context).size.width / 2, 
                                    MediaQuery.of(context).size.height / 3);
                } else if (selectedTool == 'setSquare') {
                  position = Offset(MediaQuery.of(context).size.width / 2, 
                                    MediaQuery.of(context).size.height / 3);
                }
              });
            },
            color: isSelected ? Colors.blue : null,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassTool() {
    return Positioned(
      left: position.dx - compassRadius,
      top: position.dy - compassRadius,
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: GestureDetector(
            onPanStart: (details) {
              if (selectedTool == 'compass') {
                // Check if we're touching the rotation handle (pencil tip)
                final localPosition = details.localPosition;
                final center = Offset(compassRadius, compassRadius);
                final tipPosition = Offset(center.dx, center.dy - compassRadius);
                
                if ((localPosition - tipPosition).distance < 20) {
                  isRotating = true;
                  rotationStartAngle = math.atan2(
                    localPosition.dy - center.dy,
                    localPosition.dx - center.dx,
                  );
                }
              }
            },
            onPanUpdate: (details) {
              if (selectedTool == 'compass') {
                if (isRotating) {
                  final center = Offset(compassRadius, compassRadius);
                  final localPosition = details.localPosition;
                  final currentAngle = math.atan2(
                    localPosition.dy - center.dy,
                    localPosition.dx - center.dx,
                  );
                  
                  setState(() {
                    // Calculate the rotation delta and apply it
                    position += details.delta;
                  });
                } else {
                  setState(() {
                    position += details.delta;
                  });
                }
              }
            },
            onPanEnd: (details) {
              if (selectedTool == 'compass') {
                isRotating = false;
              }
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
      ),
    );
  }

  Widget _buildProtractorTool() {
    return Positioned(
      left: position.dx - protractorSize,
      top: position.dy - protractorSize,
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: GestureDetector(
            onPanStart: (details) {
              if (selectedTool == 'protractor') {
                // Check if we're touching the rotation handle
                final localPosition = details.localPosition;
                final center = Offset(protractorSize, protractorSize);
                
                if ((localPosition - center).distance < 20) {
                  isRotating = true;
                  rotationStartAngle = math.atan2(
                    localPosition.dy - center.dy,
                    localPosition.dx - center.dx,
                  );
                }
              }
            },
            onPanUpdate: (details) {
              if (selectedTool == 'protractor') {
                setState(() {
                  position += details.delta;
                });
              }
            },
            onPanEnd: (details) {
              if (selectedTool == 'protractor') {
                isRotating = false;
              }
            },
            child: CustomPaint(
              size: Size(protractorSize * 2, protractorSize * 2),
              painter: ProtractorPainter(
                size: protractorSize,
                measuredAngle: measuredAngle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRulerTool() {
    return Positioned(
      left: position.dx - rulerLength / 2,
      top: position.dy - 25,
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: GestureDetector(
            onPanStart: (details) {
              if (selectedTool == 'ruler') {
                // Check if we're touching the rotation handle
                final localPosition = details.localPosition;
                final center = Offset(rulerLength / 2, 25);
                
                if ((localPosition - Offset(rulerLength - 20, 25)).distance < 20) {
                  isRotating = true;
                  rotationStartAngle = math.atan2(
                    localPosition.dy - center.dy,
                    localPosition.dx - center.dx,
                  );
                }
              }
            },
            onPanUpdate: (details) {
              if (selectedTool == 'ruler') {
                setState(() {
                  position += details.delta;
                });
              }
            },
            onPanEnd: (details) {
              if (selectedTool == 'ruler') {
                isRotating = false;
              }
            },
            child: CustomPaint(
              size: Size(rulerLength, 50),
              painter: RulerPainter(length: rulerLength),
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
        child: Transform.scale(
          scale: scale,
          child: GestureDetector(
            onPanStart: (details) {
              if (selectedTool == 'setSquare') {
                // Check if we're touching the rotation handle
                final localPosition = details.localPosition;
                final center = Offset(setSquareSize / 2, setSquareSize / 2);
                
                if ((localPosition - Offset(setSquareSize - 15, 15)).distance < 20) {
                  isRotating = true;
                  rotationStartAngle = math.atan2(
                    localPosition.dy - center.dy,
                    localPosition.dx - center.dx,
                  );
                }
              }
            },
            onPanUpdate: (details) {
              if (selectedTool == 'setSquare') {
                setState(() {
                  position += details.delta;
                });
              }
            },
            onPanEnd: (details) {
              if (selectedTool == 'setSquare') {
                isRotating = false;
              }
            },
            child: CustomPaint(
              size: Size(setSquareSize, setSquareSize),
              painter: SetSquarePainter(size: setSquareSize),
            ),
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    // Handle different tools' behaviors on pan start
    if (selectedTool == 'pencil') {
      final point = DrawingPoints(
        points: [details.localPosition],
        color: selectedColor,
        width: strokeWidth,
      );
      setState(() {
        points.add(point);
      });
    } else if (selectedTool == 'compass' && drawingWithCompass) {
      compassCenter = position;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Handle different tools' behaviors on pan update
    if (selectedTool == 'pencil') {
      final point = points.last;
      final newPoints = List<Offset>.from(point.points)..add(details.localPosition);
      
      setState(() {
        points.last = DrawingPoints(
          points: newPoints,
          color: point.color,
          width: point.width,
        );
      });
    } else if (selectedTool == 'compass' && drawingWithCompass && compassCenter != null) {
      // Drawing with compass logic
      // This would need to be implemented based on how you want the compass to draw
    }
  }

  void _onPanEnd(DragEndDetails details) {
    // Handle different tools' behaviors on pan end
    if (selectedTool == 'compass' && drawingWithCompass) {
      compassCenter = null;
    }
  }

  Future<void> _saveCanvas() async {
    try {
      // Get the RenderRepaintBoundary from the key
      RenderRepaintBoundary boundary = canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // Convert boundary to image
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = 'geometric_drawing_${DateTime.now().millisecondsSinceEpoch}.png';
        final String path = '${directory.path}/$fileName';
        
        // Write to file
        File file = File(path);
        await file.writeAsBytes(byteData.buffer.asUint8List());
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to $path')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  void _clearCanvas() {
    setState(() {
      points.clear();
    });
  }
}

// Custom painters for each tool

class DrawingPainter extends CustomPainter {
  final List<DrawingPoints> points;
  
  DrawingPainter({required this.points});
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var point in points) {
      final paint = Paint()
        ..color = point.color
        ..strokeWidth = point.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      for (int i = 0; i < point.points.length - 1; i++) {
        canvas.drawLine(point.points[i], point.points[i + 1], paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class CompassPainter extends CustomPainter {
  final double radius;
  final bool drawingMode;
  
  CompassPainter({required this.radius, required this.drawingMode});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Draw the compass circle
    canvas.drawCircle(center, radius, paint);
    
    // Draw the compass arms
    final armPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    // Central pivot
    canvas.drawCircle(center, 5, Paint()..color = Colors.red);
    
    // Arms
    canvas.drawLine(center, Offset(center.dx, center.dy - radius), armPaint);
    canvas.drawLine(center, Offset(center.dx + radius * 0.6, center.dy), armPaint);
    
    // Pencil tip - this will be the rotation handle
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius), 
      5, 
      Paint()..color = Colors.black
    );
    
    // Add a visual indicator for rotation
    final rotationHandle = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius),
      10,
      rotationHandle
    );
  }
  
  @override
  bool shouldRepaint(CompassPainter oldDelegate) => 
      radius != oldDelegate.radius || drawingMode != oldDelegate.drawingMode;
}

class ProtractorPainter extends CustomPainter {
  final double size;
  final double measuredAngle;
  
  ProtractorPainter({required this.size, required this.measuredAngle});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(this.size, this.size);
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Draw the protractor semi-circle background
    final bgPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
      
    canvas.drawArc(
      Rect.fromCenter(center: center, width: this.size * 2, height: this.size * 2),
      math.pi, // Start angle (bottom)
      -math.pi, // End angle (semicircle)
      true,
      bgPaint,
    );
    
    // Draw the protractor semicircle border
    canvas.drawArc(
      Rect.fromCenter(center: center, width: this.size * 2, height: this.size * 2),
      math.pi, // Start angle (bottom)
      -math.pi, // End angle (semicircle)
      false,
      paint,
    );
    
    // Draw the scale markings
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Draw degree markings
    for (int degree = 0; degree <= 180; degree += 5) {
      final angle = (degree * math.pi / 180);
      final start = Offset(
        center.dx + this.size * math.cos(angle),
        center.dy - this.size * math.sin(angle),
      );
      
      // Longer lines for major divisions
      final double markLength = degree % 10 == 0 ? 15 : 
                               (degree % 5 == 0 ? 10 : 5);
      final end = Offset(
        center.dx + (this.size - markLength) * math.cos(angle),
        center.dy - (this.size - markLength) * math.sin(angle),
      );
      
      canvas.drawLine(start, end, paint);
      
      // Draw text for major divisions
      if (degree % 10 == 0) {
        textPainter.text = TextSpan(
          text: '$degree°',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: degree % 30 == 0 ? FontWeight.bold : FontWeight.normal,
          ),
        );
        textPainter.layout();
        
        final textOffset = Offset(
          center.dx + (this.size - 30) * math.cos(angle) - textPainter.width / 2,
          center.dy - (this.size - 30) * math.sin(angle) - textPainter.height / 2,
        );
        
        textPainter.paint(canvas, textOffset);
      }
    }
    
    // Draw the baseline
    canvas.drawLine(
      Offset(center.dx - this.size, center.dy),
      Offset(center.dx + this.size, center.dy),
      paint..strokeWidth = 2,
    );
    
    // Add a rotation handle in the center
    final handlePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, 10, handlePaint);
    canvas.drawCircle(center, 10, Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
  }
  
  @override
  bool shouldRepaint(ProtractorPainter oldDelegate) =>
      size != oldDelegate.size || measuredAngle != oldDelegate.measuredAngle;
}

class RulerPainter extends CustomPainter {
  final double length;
  
  RulerPainter({required this.length});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    // Draw ruler body
    canvas.drawRect(
      Rect.fromLTWH(0, 0, length, 50),
      paint,
    );
    
    // Draw border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, length, 50),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    
    // Draw scale markings
    final markPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Using proper scale: 100 pixels = 10 cm (1:10 scale)
    // So 10 pixels = 1 cm
    final unitLength = 10.0;
    
    for (double i = 0; i <= length; i += unitLength) {
      // Height of the marking line
      double markHeight;
      
      if (i % (unitLength * 10) == 0) {
        // Major marks (cm)
        markHeight = 25;
        
        // Add text label (in cm)
        textPainter.text = TextSpan(
          text: '${(i / unitLength).toInt()}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(i - textPainter.width / 2, 30));
      } else if (i % (unitLength * 5) == 0) {
        // Half-marks (5 mm)
        markHeight = 20;
        
        // Add text label for 5mm increments
        textPainter.text = TextSpan(
          text: '${(i / unitLength).toInt()}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(i - textPainter.width / 2, 30));
      } else {
        // Minor marks (mm)
        markHeight = 15;
      }
      
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, markHeight),
        markPaint,
      );
    }
    
    // Add scale indicator "1:10" at the end of the ruler
    textPainter.text = TextSpan(
      text: 'Scale 1:10',
      style: TextStyle(
        color: Colors.black,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(length - textPainter.width - 5, 5));
    
    // Add a rotation handle at the end of the ruler
    final handlePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(length - 10, 25), 8, handlePaint);
    canvas.drawCircle(Offset(length - 10, 25), 8, Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
  }
  
  @override
  bool shouldRepaint(RulerPainter oldDelegate) => length != oldDelegate.length;
}

class SetSquarePainter extends CustomPainter {
  final double size;
  
  SetSquarePainter({required this.size});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    // Create a path for a 45-45-90 triangle
    final path = Path()
      ..moveTo(0, 0)  // Start at top-left
      ..lineTo(this.size, 0)  // Move right
      ..lineTo(0, this.size)  // Move to bottom-left
      ..close();  // Close the path
    
    canvas.drawPath(path, paint);
    
    // Draw border
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    
    // Draw scale markings (similar to ruler)
    final markPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Using proper scale: 100 pixels = 10 cm (1:10 scale)
    // So 10 pixels = 1 cm
    final unitLength = 10.0;
    
    // Draw horizontal markings
    for (double i = 0; i <= this.size; i += unitLength) {
      double markHeight = i % (unitLength * 5) == 0 ? 10 : 5;
      
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, markHeight),
        markPaint,
      );
      
      // Add text label for cm markings
      if (i % (unitLength * 5) == 0 && i > 0) {
        textPainter.text = TextSpan(
          text: '${(i / unitLength).toInt()}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 9,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(i - textPainter.width / 2, 15));
      }
    }
    
    // Draw vertical markings
    for (double i = 0; i <= this.size; i += unitLength) {
      double markWidth = i % (unitLength * 5) == 0 ? 10 : 5;
      
      canvas.drawLine(
        Offset(0, i),
        Offset(markWidth, i),
        markPaint,
      );
      
      // Add text label for cm markings
      if (i % (unitLength * 5) == 0 && i > 0) {
        textPainter.text = TextSpan(
          text: '${(i / unitLength).toInt()}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 9,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(15, i - textPainter.height / 2));
      }
    }
    
    // Draw the diagonal line (45° angle)
    canvas.drawLine(
      Offset(0, 0),
      Offset(this.size, this.size),
      markPaint..strokeWidth = 1.5,
    );
    
    // Add scale indicator "1:10" on the set square
    textPainter.text = TextSpan(
      text: 'Scale 1:10',
      style: TextStyle(
        color: Colors.black,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(this.size / 2 - 25, this.size / 3));
    
    // Add a rotation handle in the corner
    final handlePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(this.size - 15, 15), 8, handlePaint);
    canvas.drawCircle(Offset(this.size - 15, 15), 8, Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    
    // Add angle markings
    textPainter.text = TextSpan(
      text: '45°',
      style: TextStyle(
        color: Colors.black,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(this.size / 4, this.size / 4));
    
    textPainter.text = TextSpan(
      text: '90°',
      style: TextStyle(
        color: Colors.black,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, this.size - 20));
    
    textPainter.text = TextSpan(
      text: '45°',
      style: TextStyle(
        color: Colors.black,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(this.size - 25, 10));
  }
  
  @override
  bool shouldRepaint(SetSquarePainter oldDelegate) => size != oldDelegate.size;
}

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