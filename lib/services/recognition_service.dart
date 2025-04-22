import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

/// Service for handling text recognition from handwriting
class RecognitionService {
  /// The text recognizer instance
  static final TextRecognizer _textRecognizer = TextRecognizer();

  /// Recognize text from a selection area on the whiteboard
  /// 
  /// [whiteboardKey] is the GlobalKey for the whiteboard RepaintBoundary
  /// [selectionRect] is the rectangle area to recognize text from
  static Future<String> recognizeText({
    required GlobalKey whiteboardKey,
    required Rect selectionRect,
  }) async {
    try {
      // Capture the entire whiteboard as an image
      RenderRepaintBoundary boundary =
          whiteboardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image fullImage = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await fullImage.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception("Failed to get image data");
      }
      
      Uint8List fullImageBytes = byteData.buffer.asUint8List();
      
      // Convert to image library format for cropping
      img.Image? fullImg = img.decodeImage(fullImageBytes);
      if (fullImg == null) {
        throw Exception("Failed to decode image");
      }
      
      // Calculate crop dimensions
      int startX = math.max(0, selectionRect.left.round());
      int startY = math.max(0, selectionRect.top.round());
      int width = math.min(fullImg.width - startX, selectionRect.width.round());
      int height = math.min(fullImg.height - startY, selectionRect.height.round());
      
      // Crop the image
      img.Image croppedImg = img.copyCrop(
        fullImg, 
        x: startX, 
        y: startY, 
        width: width, 
        height: height
      );
      
      // Convert back to bytes
      Uint8List croppedBytes = Uint8List.fromList(img.encodePng(croppedImg));
      
      // Use ML Kit's InputImage.fromBytes directly
      final inputImage = InputImage.fromBytes(
        bytes: croppedBytes,
        metadata: InputImageMetadata(
          size: Size(width.toDouble(), height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: width * 4,
        ),
      );
      
      // Process the image
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Return recognized text
      return recognizedText.text;
    } catch (e) {
      print("Text recognition error: $e");
      return "";
    }
  }

  /// Show a dialog with the recognized text and option to search
  static Future<bool> showRecognizedTextDialog(
    BuildContext context, 
    String text,
    Function(String) onSearch,
  ) async {
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No text was recognized in this area")),
      );
      return false;
    }
    
    bool shouldSearch = false;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Recognized Text"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Text recognized from your handwriting:"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              shouldSearch = true;
              Navigator.pop(context);
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
    
    if (shouldSearch) {
      onSearch(text);
      return true;
    }
    
    return false;
  }

  /// Clean up resources
  static void dispose() {
    _textRecognizer.close();
  }
}