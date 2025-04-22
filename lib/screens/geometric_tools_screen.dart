import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';

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
  List<DrawingPoint> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 3.0;

  // Zoom settings
  final double zoomFactor = 0.1; // 10% zoom increment/decrement
  final double minZoom = 0.5;    // 50% minimum zoom
  final double maxZoom = 2.0;    // 200% maximum zoom

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
                // Reset scale when selecting a new tool
                if (tool == 'compass' || tool == 'protractor' || 
                    tool == 'ruler' || tool == 'setSquare') {
                  // Keep the scale if we're switching between geometric tools
                } else {
                  scale = 1.0;
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
            onScaleStart: (details) {
              if (selectedTool == 'compass') {
                // Store initial values if needed
              }
            },
            onScaleUpdate: (details) {
              if (selectedTool == 'compass') {
                setState(() {
                  position += details.focalPointDelta;
                  // We'll handle scale via buttons now, but preserve rotation
                  rotation += details.rotation;
                });
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
            onScaleStart: (details) {
              if (selectedTool == 'protractor') {
                // Store initial values if needed
              }
            },
            onScaleUpdate: (details) {
              if (selectedTool == 'protractor') {
                setState(() {
                  position += details.focalPointDelta;
                  // We'll handle scale via buttons now, but preserve rotation
                  rotation += details.rotation;
                });
              }
            },
            child: CustomPaint(
              size: Size(protractorSize * 2, protractorSize),
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
            onScaleStart: (details) {
              if (selectedTool == 'ruler') {
                // Store initial values if needed
              }
            },
            onScaleUpdate: (details) {
              if (selectedTool == 'ruler') {
                setState(() {
                  // Update position using the focal point delta
                  position += details.focalPointDelta;
                  
                  // We'll handle scale via buttons now, but preserve rotation
                  rotation += details.rotation;
                });
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
            onScaleStart: (details) {
              if (selectedTool == 'setSquare') {
                // Store initial values if needed
              }
            },
            onScaleUpdate: (details) {
              if (selectedTool == 'setSquare') {
                setState(() {
                  // Update position using the focal point delta
                  position += details.focalPointDelta;
                  
                  // We'll handle scale via buttons now, but preserve rotation
                  rotation += details.rotation;
                });
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
      final point = DrawingPoint(
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
        points.last = DrawingPoint(
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

// Custom painters for each tool remain the same

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;
  
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
    
    // Pencil tip
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius), 
      3, 
      Paint()..color = Colors.black
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
    
    // Draw the protractor semicircle
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
    for (int degree = 0; degree <= 180; degree += 10) {
      final angle = (degree * math.pi / 180);
      final start = Offset(
        center.dx + this.size * math.cos(angle),
        center.dy - this.size * math.sin(angle),
      );
      
      // Longer lines for major divisions
      final double markLength = degree % 30 == 0 ? 15 : 10;
      final end = Offset(
        center.dx + (this.size - markLength) * math.cos(angle),
        center.dy - (this.size - markLength) * math.sin(angle),
      );
      
      canvas.drawLine(start, end, paint);
      
      // Draw text for major divisions
      if (degree % 30 == 0) {
        textPainter.text = TextSpan(
          text: '$degree°',
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
        );
        textPainter.layout();
        
        final textOffset = Offset(
          center.dx + (this.size - 25) * math.cos(angle) - textPainter.width / 2,
          center.dy - (this.size - 25) * math.sin(angle) - textPainter.height / 2,
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
    
    // Assuming 10 pixels = 1 cm
    final unitLength = 10.0;
    
    for (double i = 0; i <= length; i += unitLength) {
      // Height of the marking line
      double markHeight;
      
      if (i % (unitLength * 10) == 0) {
        // Major marks (cm)
        markHeight = 20;
        
        // Add text label
        textPainter.text = TextSpan(
          text: '${(i / unitLength).toInt()}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(i - textPainter.width / 2, 30));
      } else if (i % (unitLength * 5) == 0) {
        // Half-marks
        markHeight = 15;
      } else {
        // Minor marks (mm)
        markHeight = 10;
      }
      
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, markHeight),
        markPaint,
      );
    }
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
    
    // Assuming 10 pixels = 1 cm
    final unitLength = 10.0;
    
    // Draw horizontal markings
    for (double i = 0; i <= this.size; i += unitLength) {
      double markHeight = i % (unitLength * 5) == 0 ? 10 : 5;
      
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, markHeight),
        markPaint,
      );
    }
    
    // Draw vertical markings
    for (double i = 0; i <= this.size; i += unitLength) {
      double markWidth = i % (unitLength * 5) == 0 ? 10 : 5;
      
      canvas.drawLine(
        Offset(0, i),
        Offset(markWidth, i),
        markPaint,
      );
    }
    
    // Draw the diagonal line
    canvas.drawLine(
      Offset(0, 0),
      Offset(this.size, this.size),
      markPaint,
    );
  }
  
  @override
  bool shouldRepaint(SetSquarePainter oldDelegate) => size != oldDelegate.size;
}

class DrawingPoint {
  final List<Offset> points;
  final Color color;
  final double width;
  
  DrawingPoint({
    required this.points,
    required this.color,
    required this.width,
  });
}