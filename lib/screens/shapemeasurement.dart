import 'package:flutter/material.dart';
import 'shape_utils.dart'; // Make sure this has your ShapeType enum and ShapeItem class

class ShapeMeasurementScreen extends StatefulWidget {
  final Function(ShapeItem)? onShapeCreated;
  
  const ShapeMeasurementScreen({
    super.key,
    this.onShapeCreated,
  });

  @override
  State<ShapeMeasurementScreen> createState() => _ShapeMeasurementScreenState();
}

class _ShapeMeasurementScreenState extends State<ShapeMeasurementScreen> {
  ShapeType selectedShape = ShapeType.rectangle;
  Offset? startPoint;
  Offset? currentPoint;
  ShapeItem? currentShape;
  List<ShapeItem> shapes = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shapes & Measurements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Return to previous screen
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
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
          // Drawing area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanStart: (details) {
                    setState(() {
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
                      setState(() {
                        shapes.add(currentShape!);
                      });
                      
                      if (widget.onShapeCreated != null) {
                        widget.onShapeCreated!(currentShape!);
                      }
                      
                      setState(() {
                        startPoint = null;
                        currentPoint = null;
                        currentShape = null;
                      });
                    }
                  },
                  child: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    color: Colors.white,
                    child: CustomPaint(
                      painter: ShapePainter(
                        currentShape: currentShape,
                        shapes: shapes,
                        showMeasurements: true,
                      ),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to constrain points within the available space
  Offset _constrainPoint(Offset point, BoxConstraints constraints) {
    return Offset(
      point.dx.clamp(0, constraints.maxWidth),
      point.dy.clamp(0, constraints.maxHeight),
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