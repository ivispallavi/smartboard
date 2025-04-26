// shape_selection_service.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/drawing_point.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class ShapeSelectionService {
  // Method to handle shape selection mode
  static void toggleShapeSelectionMode(BuildContext context, bool currentMode, Function(bool) updateMode) {
    // Toggle the selection mode
    updateMode(!currentMode);
    
    // Show a hint to guide the user
    if (!currentMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draw a rectangle around the content you want to process'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  // Method to get points within a selection rectangle
  static List<DrawingPoint> getPointsInSelection(List<DrawingPoint> allPoints, Rect selectionRect) {
    // Filter points that fall within the selection rectangle
    return allPoints.where((point) {
      // Skip end-of-stroke markers
      if (point.offset == null) return false;
      
      // Check if the point is within the rectangle
      return selectionRect.contains(point.offset!);
    }).toList();
  }
  
  // Calculate the bounds of the selection for processing
  static Rect calculateSelectionBounds(Offset? start, Offset? end) {
    if (start == null || end == null) {
      return Rect.zero;
    }
    
    // Create a rect from the start and end points
    return Rect.fromPoints(start, end);
  }
  
  // Handle draw start in selection mode
  static void handleSelectionStart(
    DragStartDetails details, 
    GlobalKey canvasKey, 
    ScrollController scrollController,
    double canvasHeight,
    Function(Offset?, Offset?, Rect?) updateSelectionState
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

      // Make sure the position is within the canvas bounds
      if (adjustedPosition.dy < 0 ||
          adjustedPosition.dy > canvasHeight ||
          adjustedPosition.dx < 0 ||
          adjustedPosition.dx > renderBox.size.width) {
        return; // Ignore if outside canvas bounds
      }
      
      // Update selection state
      updateSelectionState(
        adjustedPosition, 
        adjustedPosition, 
        Rect.fromPoints(adjustedPosition, adjustedPosition)
      );
    } catch (e) {
      print("Error in handleSelectionStart: $e");
    }
  }
  
  // Handle draw update in selection mode
  static void handleSelectionUpdate(
    DragUpdateDetails details, 
    GlobalKey canvasKey, 
    ScrollController scrollController,
    double canvasHeight,
    Offset? selectionStart,
    Function(Offset?, Rect?) updateSelectionState
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

      // Make sure the position is within the canvas bounds
      if (adjustedPosition.dy < 0 ||
          adjustedPosition.dy > canvasHeight ||
          adjustedPosition.dx < 0 ||
          adjustedPosition.dx > renderBox.size.width) {
        return; // Ignore if outside canvas bounds
      }
      
      // Update selection state
      updateSelectionState(
        adjustedPosition, 
        calculateSelectionBounds(selectionStart, adjustedPosition)
      );
    } catch (e) {
      print("Error in handleSelectionUpdate: $e");
    }
  }
  
  // Handle draw end in selection mode
  static void handleSelectionEnd(
    BuildContext context,
    Offset? selectionStart,
    Offset? selectionEnd,
    Rect? selectedAreaRect,
    Function processSelection
  ) {
    if (selectionStart != null && selectionEnd != null) {
      // Show action button to process the selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selection complete. Process this area?'),
          action: SnackBarAction(
            label: 'Process',
            onPressed: () => processSelection(),
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }
  
  // Process the selected area
  static Future<void> processSelectedArea({
    required BuildContext context,
    required Rect? selectedAreaRect,
    required GlobalKey repaintBoundaryKey,
    required bool isProcessing,
    required Function(bool) setProcessingState,
    required Function() resetSelectionState,
  }) async {
    if (selectedAreaRect == null || selectedAreaRect == Rect.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid selection area')),
      );
      return;
    }
    
    if (isProcessing) return;

    setProcessingState(true);

    try {
      // Get image bytes from the current view
      final RenderRepaintBoundary boundary =
          repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      
      // Create the full image first
      final fullImage = await boundary.toImage(pixelRatio: 3.0);
      
      // Create a cropped image based on the selection
      final ui.Image croppedImage = await cropImage(
          fullImage, 
          selectedAreaRect.left.toInt(), 
          selectedAreaRect.top.toInt(), 
          selectedAreaRect.width.toInt(), 
          selectedAreaRect.height.toInt());
      
      final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
      final imageBytes = byteData!.buffer.asUint8List();

      // Create API service
      final apiService = ApiService(
        baseUrl: AppConfig.baseUrl,
        apiKey: AppConfig.apiKey,
      );

      // Process image and generate notes
      await apiService.processImageAndGenerateNotes(context, imageBytes);
      
      // Reset selection state after processing
      resetSelectionState();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'))
      );
    } finally {
      setProcessingState(false);
    }
  }
  
  // Helper method to crop an image
  static Future<ui.Image> cropImage(ui.Image image, int x, int y, int width, int height) async {
    // Create a picture recorder
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    
    // Draw the portion of the image we want to keep
    final Paint paint = Paint();
    canvas.drawImageRect(
      image, 
      Rect.fromLTWH(x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble()),
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      paint,
    );
    
    // Convert to an image
    final ui.Picture picture = recorder.endRecording();
    return picture.toImage(width, height);
  }
} 