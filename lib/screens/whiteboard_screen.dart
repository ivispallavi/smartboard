import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:smart_board/screens/shape_utils.dart';
import 'package:smart_board/screens/shapemeasurement.dart';
import '../painters/whiteboard_painter.dart' as painter;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/drawing_point.dart';

import '../widgets/advanced_graph_dialog.dart';
import '../services/ai_graph_service.dart';
import '../models/graph_settings_model.dart';
import '../services/nlp_graph_service.dart';
import '../widgets/enhanced_graph_dialog.dart';
import '../services/graph_service.dart';

// Add another drawing mode in the DrawingMode enum in your models or directly in the whiteboard_screen.dart
enum DrawingMode {
  pen,
  eraser,
  graph, // Add this mode
  // Add other modes as needed
}

class WhiteboardScreen extends StatefulWidget {
  final String? imagePath;
  const WhiteboardScreen({this.imagePath, super.key});

  @override
  State<WhiteboardScreen> createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends State<WhiteboardScreen> with SingleTickerProviderStateMixin {
  // Drawing-related variables
  List<DrawingPoint> points = [];
  Color selectedColor = Colors.black;
  double penStrokeWidth = 3.0;
  double eraserStrokeWidth = 15.0;
  DrawingMode currentMode = DrawingMode.pen;
  
  // Undo/Redo history
  List<List<DrawingPoint>> undoHistory = [];
  List<List<DrawingPoint>> redoHistory = [];
  List<DrawingPoint> currentStroke = [];
  
  // Canvas dimensions and control
  double canvasHeight = 800.0;
  double canvasWidth = double.infinity;
  bool isCanvasExtended = false;
  
  // Selection mode
  bool isSelectionMode = false;
  Rect? selectionRect;
  Offset? selectionStart;
  Offset? selectionEnd;

  // Scroll controller for managing large canvases
  final ScrollController _scrollController = ScrollController();

  // Global key for the canvas area to get correct Render object
  final GlobalKey _canvasAreaKey = GlobalKey();
  
  // Key for capturing canvas as image
  final GlobalKey _canvasKey = GlobalKey();
  
  // Toolbar visibility control
  bool isToolbarVisible = false;
  late AnimationController _toolbarAnimationController;
  late Animation<double> _toolbarAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for toolbar
    _toolbarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _toolbarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _toolbarAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _toolbarAnimationController.dispose();
    super.dispose();
  }

  void _toggleToolbar() {
    setState(() {
      isToolbarVisible = !isToolbarVisible;
      if (isToolbarVisible) {
        _toolbarAnimationController.forward();
      } else {
        _toolbarAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.imagePath != null ? "Edit Whiteboard" : "New Whiteboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showAIGraphHelp,
            tooltip: 'Graph Plotting Help',
          ),
          _buildMoreMenu(),
        ],
      ),
      body: Stack(
        children: [
          // Main canvas area
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                color: Colors.grey[200], // Background color
                width: MediaQuery.of(context).size.width, // Full width
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: Container(
                    key: _canvasAreaKey,
                    color: Colors.white,
                    height: canvasHeight,
                    width: canvasWidth,
                    child: GestureDetector(
                      onPanStart: (details) {
                        _handleDrawStart(details);
                      },
                      onPanUpdate: (details) {
                        _handleDrawUpdate(details);
                      },
                      onPanEnd: (_) {
                        _handleDrawEnd();
                      },
                      child: CustomPaint(
                        painter: painter.WhiteboardPainter(
                          points: points,
                          selectionRect: selectionRect,
                          isSelectionMode: isSelectionMode,
                        ),
                        size: Size(canvasWidth, canvasHeight),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Add a quick access button for graph plotting
          Positioned(
            bottom: isToolbarVisible ? 220 : 70, // Position above toolbar
            right: 20,
            child: FloatingActionButton(
              heroTag: 'graphButton',
              mini: true,
              child: const Icon(Icons.functions),
              onPressed: () => _showGraphDialog(),
              tooltip: 'Plot Graph',
            ),
          ),
          // Download button (always visible above toolbar)
          Positioned(
            bottom: isToolbarVisible ? 200 : 30, // Positioned above the toolbar or toggle button
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.download),
                onPressed: _saveToGallery,
                tooltip: 'Download',
              ),
            ),
          ),
          // Toolbar toggle button (always visible)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _toggleToolbar,
              child: Container(
                height: 30,
                color: Colors.white.withOpacity(0.8),
                child: Center(
                  child: Icon(
                    isToolbarVisible ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
          // Sliding toolbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _toolbarAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _toolbarAnimation.value) * 200),
                  child: child,
                );
              },
              child: _buildToolbar(),
            ),
          ),
        ],
      ),
    );
  }

  // Fixed drawing handlers with proper coordinate translation
  void _handleDrawStart(DragStartDetails details) {
    if (!_canvasAreaKey.currentContext!.findRenderObject()!.paintBounds.contains(
      _canvasAreaKey.currentContext!.findRenderObject()! as RenderBox != null
          ? (_canvasAreaKey.currentContext!.findRenderObject()! as RenderBox)
              .globalToLocal(details.globalPosition)
          : details.localPosition,
    )) {
      return; // Ignore if not on canvas
    }
    
    // Get the local position relative to the canvas widget
    RenderBox canvasRenderBox = _canvasAreaKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = canvasRenderBox.globalToLocal(details.globalPosition);
    
    // Adjust for scroll offset
    double scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    Offset adjustedPosition = Offset(localPosition.dx, localPosition.dy + scrollOffset);
    
    // Start new stroke
    currentStroke = [];
    
    // Set appropriate color and stroke width based on mode
    Color pointColor = currentMode == DrawingMode.eraser 
        ? Colors.white 
        : selectedColor;
    
    double width = currentMode == DrawingMode.eraser 
        ? eraserStrokeWidth 
        : penStrokeWidth;
    
    setState(() {
      // Add first point to current stroke
      DrawingPoint newPoint = DrawingPoint(adjustedPosition, pointColor, width);
      currentStroke.add(newPoint);
      points.add(newPoint);
    });
  }

  void _handleDrawUpdate(DragUpdateDetails details) {
    // Get the local position relative to the canvas widget
    RenderBox canvasRenderBox = _canvasAreaKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = canvasRenderBox.globalToLocal(details.globalPosition);
    
    // Adjust for scroll offset
    double scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    Offset adjustedPosition = Offset(localPosition.dx, localPosition.dy + scrollOffset);
    
    // Set appropriate color and stroke width based on mode
    Color pointColor = currentMode == DrawingMode.eraser 
        ? Colors.white 
        : selectedColor;
    
    double width = currentMode == DrawingMode.eraser 
        ? eraserStrokeWidth 
        : penStrokeWidth;
    
    setState(() {
      // Add point to current stroke and main points list
      DrawingPoint newPoint = DrawingPoint(adjustedPosition, pointColor, width);
      currentStroke.add(newPoint);
      points.add(newPoint);
    });
  }

  void _handleDrawEnd() {
    setState(() {
      // Add end-of-stroke marker
      points.add(DrawingPoint.endStroke());
      
      // Add current stroke to undo history
      if (currentStroke.isNotEmpty) {
        // Create a deep copy of points for undo
        undoHistory.add(List.from(points));
        // Clear redo history since we drew something new
        redoHistory.clear();
        currentStroke = [];
      }
    });
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Pen Button
              _buildToolButton(
                icon: Icons.edit,
                isSelected: currentMode == DrawingMode.pen,
                onPressed: () => setState(() => currentMode = DrawingMode.pen),
                color: selectedColor,
              ),
              
              // Eraser Button
              _buildToolButton(
                icon: Icons.auto_fix_high,
                isSelected: currentMode == DrawingMode.eraser,
                onPressed: () => setState(() => currentMode = DrawingMode.eraser),
              ),
              
              // Graph Button (Add this)
              _buildToolButton(
                icon: Icons.functions,
                isSelected: currentMode == DrawingMode.graph,
                onPressed: () => _showGraphDialog(),
                tooltip: 'Plot Graph',
              ),

              // Color Picker
              _buildColorPicker(),
              
              // Undo Button
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: undoHistory.isEmpty ? null : _undo,
                color: undoHistory.isEmpty ? Colors.grey : Colors.black,
              ),
              
              // Redo Button
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: redoHistory.isEmpty ? null : _redo,
                color: redoHistory.isEmpty ? Colors.grey : Colors.black,
              ),
              
              // Clear Button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: points.isEmpty ? null : _showClearConfirmation,
                color: points.isEmpty ? Colors.grey : Colors.black,
              ),
              // New button for shapes and measurements
            IconButton(
              icon: const Icon(Icons.crop_square),
              tooltip: 'Shapes & Measurements',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShapeMeasurementScreen(
                      onShapeCreated: (ShapeItem shape) {
                        // Here you can handle the shape data returned from the screen
                        // For example, you could add it to a list of shapes to be rendered
                        // on your whiteboard
                        setState(() {
                          // Add shape to your whiteboard's shape list
                          // Example: shapes.add(shape);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
              
              // Extend Canvas Button
              _buildToolButton(
                icon: Icons.expand_more,
                isSelected: false,
                onPressed: _extendCanvas,
                tooltip: 'Extend Canvas',
              ),
            ],
          ),
          
          // Size Sliders
          if (currentMode == DrawingMode.pen)
            Slider(
              value: penStrokeWidth,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              label: penStrokeWidth.round().toString(),
              onChanged: (value) => setState(() => penStrokeWidth = value),
            ),
          
          if (currentMode == DrawingMode.eraser)
            Slider(
              value: eraserStrokeWidth,
              min: 5.0,
              max: 30.0,
              divisions: 5,
              label: eraserStrokeWidth.round().toString(),
              onChanged: (value) => setState(() => eraserStrokeWidth = value),
            ),
        ],
      ),
    );
  }

  Widget _buildMoreMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        switch (value) {
          case 'save':
            await _saveLocally();
            break;
          case 'share':
            await _shareCanvas();
            break;
        }
      },
      itemBuilder: (context) => [
        // Download option removed from menu
        const PopupMenuItem(
          value: 'save',
          child: Row(
            children: [
              Icon(Icons.save),
              SizedBox(width: 8),
              Text('Save Locally'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share),
              SizedBox(width: 8),
              Text('Share'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
    Color? color,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? (color ?? Colors.black) : Colors.grey,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildColorPicker() {
    final List<Color> colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
    ];

    return PopupMenuButton<Color>(
      icon: Icon(
        Icons.color_lens,
        color: selectedColor,
      ),
      itemBuilder: (context) {
        return colors.map((color) {
          return PopupMenuItem<Color>(
            value: color,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey,
                  width: color == selectedColor ? 2 : 0,
                ),
              ),
            ),
          );
        }).toList();
      },
      onSelected: (color) {
        setState(() {
          selectedColor = color;
        });
      },
    );
  }

  void _undo() {
    if (undoHistory.isEmpty) return;
    
    setState(() {
      // Store the current state for redo before undoing
      redoHistory.add(List.from(points));
      
      // Go back to the previous state from undo history
      if (undoHistory.isNotEmpty) {
        points = List.from(undoHistory.removeLast());
      }
    });
  }

  void _redo() {
    if (redoHistory.isEmpty) return;
    
    setState(() {
      // Store current state in undo history
      undoHistory.add(List.from(points));
      
      // Restore state from redo history
      points = List.from(redoHistory.removeLast());
    });
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Canvas'),
        content: const Text('Are you sure you want to clear the canvas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCanvas();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showGraphDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AdvancedGraphDialog(
        onPlotRequested: _plotGraphWithSettings,
      ),
    );
  }

  // Update the _plotGraph method to use AI when requested:
  void _plotGraph(String equation, bool useAI) {
    // Get the center of the visible canvas area
    RenderBox canvasRenderBox = _canvasAreaKey.currentContext!.findRenderObject() as RenderBox;
    final size = canvasRenderBox.size;
    
    // Calculate the center point, considering scroll position
    double scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final center = Offset(
      size.width / 2, 
      (size.height / 2) + scrollOffset
    );
    
    // Add current points to undo history
    if (points.isNotEmpty) {
      undoHistory.add(List.from(points));
    }
    
    // Plot the graph using either basic or AI service
    List<DrawingPoint> graphPoints;
    
    if (useAI) {
      // Use the AI-powered service
      graphPoints = AIGraphService.plotEquation(
        equation,
        size.width * 0.8, // 80% of canvas width for the graph
        size.height * 0.6, // 60% of canvas height for the graph
        center,
        selectedColor,
        penStrokeWidth
      );
    } else {
      // Use the basic service
      graphPoints = GraphService.plotEquation(
        equation,
        size.width * 0.8,
        size.height * 0.6,
        center,
        selectedColor,
        penStrokeWidth
      );
    }
    
    // Add graph points to the canvas
    setState(() {
      points.addAll(graphPoints);
      // Add current stroke to undo history
      undoHistory.add(List.from(points));
      // Clear redo history since we added something new
      redoHistory.clear();
    });
  }

  void _showAIGraphHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Graph Plotting'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The AI Graph Plotter can plot these types of equations:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Basic expressions: x^2, 2*x+1'),
            Text('• Trigonometric functions: sin(x), cos(x), tan(x)'),
            Text('• Square roots: sqrt(x)'),
            Text('• Absolute values: abs(x)'),
            Text('• Polynomials: x^3-2*x^2+3*x-4'),
            SizedBox(height: 16),
            Text(
              'Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Use * for multiplication (e.g., 2*x not 2x)'),
            Text('• Use parentheses to group operations'),
            Text('• Enter one equation at a time'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // Add a method to plot using the enhanced settings
  void _plotGraphWithSettings(GraphSettings settings) {
    // Get the center of the visible canvas area
    RenderBox canvasRenderBox = _canvasAreaKey.currentContext!.findRenderObject() as RenderBox;
    final size = canvasRenderBox.size;
    
    // Calculate the center point, considering scroll position
    double scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final center = Offset(
      size.width / 2, 
      (size.height / 2) + scrollOffset
    );
    
    // Add current points to undo history
    if (points.isNotEmpty) {
      undoHistory.add(List.from(points));
    }
    
    // Plot the graph using the AI service
    List<DrawingPoint> graphPoints = AIGraphService.plotEquation(
      settings.equation,
      size.width * 0.8, // 80% of canvas width for the graph
      size.height * 0.6, // 60% of canvas height for the graph
      center,
      selectedColor,
      penStrokeWidth
    );
    
    // Add graph points to the canvas
    setState(() {
      points.addAll(graphPoints);
      // Add current stroke to undo history
      undoHistory.add(List.from(points));
      // Clear redo history since we added something new
      redoHistory.clear();
    });
    
    // Show a toast notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AI-generated graph of "${settings.equation}" plotted'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
    
    // Scroll to ensure the graph is visible if needed
    if (_scrollController.hasClients) {
      // Calculate the position to scroll to (center of the graph)
      double targetPosition = center.dy - (size.height / 2);
      
      // Ensure it's within bounds
      targetPosition = targetPosition.clamp(
        0.0, 
        _scrollController.position.maxScrollExtent
      );
      
      // Animate to the position
      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _clearCanvas() {
    setState(() {
      // Save current points to undo history before clearing
      if (points.isNotEmpty) {
        undoHistory.add(List.from(points));
      }
      
      // Clear points
      points = [];
    });
  }

  void _extendCanvas() {
    setState(() {
      // Increase canvas height by 500 pixels
      canvasHeight += 500.0;
      isCanvasExtended = true;
    });

    // Wait for the UI to rebuild and then scroll to the bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Show a confirmation toast
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Canvas extended by 500 pixels'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Convert canvas to image
  Future<Uint8List?> _captureCanvasAsImage() async {
    try {
      RenderRepaintBoundary boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture canvas: $e')),
      );
      return null;
    }
  }

  Future<void> _saveToGallery() async {
    try {
      Uint8List? imageBytes = await _captureCanvasAsImage();
      if (imageBytes == null) return;

      // You'll need to implement image saving to gallery using image_gallery_saver
      // For this example we'll just save it locally and show a message
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'whiteboard_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Whiteboard downloaded to gallery')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  Future<void> _saveLocally() async {
    try {
      Uint8List? imageBytes = await _captureCanvasAsImage();
      if (imageBytes == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'whiteboard_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Whiteboard saved locally: ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save locally: $e')),
      );
    }
  }

  Future<void> _shareCanvas() async {
    try {
      Uint8List? imageBytes = await _captureCanvasAsImage();
      if (imageBytes == null) return;

      final directory = await getTemporaryDirectory();
      final String fileName = 'whiteboard_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Whiteboard',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }
}