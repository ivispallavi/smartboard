import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Service for handling whiteboard storage, saving and sharing operations
class StorageService {
  /// Save the current whiteboard state to the app's document directory
  /// Returns the saved file path if successful
  static Future<String?> saveWhiteboard({
    required GlobalKey whiteboardKey,
    String? currentImagePath,
  }) async {
    try {
      RenderRepaintBoundary boundary =
          whiteboardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception("Failed to get image data");
      }
      
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      
      // If editing an existing file, use the same path to overwrite it
      String filePath;
      if (currentImagePath != null) {
        filePath = currentImagePath;
      } else {
        filePath = '${directory.path}/whiteboard_$timestamp.png';
      }

      File imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);

      // Only update SharedPreferences if it's a new file
      if (currentImagePath == null) {
        await _updateSharedPreferences(filePath);
      } else {
        // Update timestamp for existing files
        await _updateTimestamp(filePath);
      }

      return filePath;
    } catch (e) {
      print("Error saving whiteboard: $e");
      return null;
    }
  }

  /// Download the whiteboard to device's download directory or documents
  static Future<String?> downloadWhiteboard({
    required GlobalKey whiteboardKey,
  }) async {
    try {
      RenderRepaintBoundary boundary =
          whiteboardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception("Failed to get image data");
      }
      
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // For download functionality, we'll save to the Downloads directory if available,
      // otherwise to external storage
      Directory? directory;
      
      if (Platform.isAndroid) {
        // On Android, try to use the Downloads directory
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to app's documents directory
          directory = await getExternalStorageDirectory() ?? 
                     await getApplicationDocumentsDirectory();
        }
      } else {
        // On iOS, use the app's documents directory
        directory = await getApplicationDocumentsDirectory();
      }
      
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String filePath = '${directory.path}/whiteboard_$timestamp.png';

      File imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);

      return filePath;
    } catch (e) {
      print("Error downloading whiteboard: $e");
      return null;
    }
  }

  /// Share the whiteboard to other apps
  static Future<bool> shareWhiteboard({
    required GlobalKey whiteboardKey,
  }) async {
    try {
      // Make sure to wait until the next frame to ensure everything is rendered
      await Future.delayed(Duration.zero);
      
      // Get the render object for the whiteboard
      RenderRepaintBoundary boundary =
          whiteboardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // Increase pixel ratio for better quality
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception("Failed to get image data");
      }
      
      Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // Create a temporary file to share
      final directory = await getTemporaryDirectory();
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String filePath = '${directory.path}/whiteboard_$timestamp.png';

      File imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);

      // Share the file
      await Share.shareFiles([filePath], text: 'My Whiteboard');
      return true;
    } catch (e) {
      print("Error sharing whiteboard: $e");
      return false;
    }
  }

  /// Load an existing whiteboard image from the provided path
  static Future<ui.Image?> loadExistingWhiteboard(String path) async {
    try {
      // Load the image file
      File imageFile = File(path);
      if (await imageFile.exists()) {
        final Uint8List bytes = await imageFile.readAsBytes();
        
        // Decode the image
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        
        return frameInfo.image;
      } 
      return null;
    } catch (e) {
      print("Error loading whiteboard: $e");
      return null;
    }
  }

  /// Update shared preferences with the new whiteboard path
  static Future<void> _updateSharedPreferences(String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Add to the list if it's a new file
    List<String> savedPaths = prefs.getStringList('whiteboard_paths') ?? [];
    if (!savedPaths.contains(filePath)) {
      savedPaths.add(filePath);
      prefs.setStringList('whiteboard_paths', savedPaths);
    }
    
    // Also update the new format with timestamps
    List<String> savedData = prefs.getStringList('whiteboardsData') ?? [];
    String timestamp = DateTime.now().toString();
    String dataEntry = "$filePath|$timestamp";
    
    // Check if the path already exists in the data
    bool found = false;
    List<String> updatedData = [];
    for (String entry in savedData) {
      List<String> parts = entry.split('|');
      if (parts[0] == filePath) {
        updatedData.add(dataEntry); // Update with new timestamp
        found = true;
      } else {
        updatedData.add(entry);
      }
    }
    
    if (!found) {
      updatedData.add(dataEntry);
    }
    
    prefs.setStringList('whiteboardsData', updatedData);
  }

  /// Update timestamp for an existing whiteboard
  static Future<void> _updateTimestamp(String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedData = prefs.getStringList('whiteboardsData') ?? [];
    String timestamp = DateTime.now().toString();
    
    List<String> updatedData = [];
    for (String entry in savedData) {
      List<String> parts = entry.split('|');
      if (parts[0] == filePath) {
        updatedData.add("$filePath|$timestamp"); // Update with new timestamp
      } else {
        updatedData.add(entry);
      }
    }
    
    prefs.setStringList('whiteboardsData', updatedData);
  }

  /// Import an image from a file path
  static Future<ui.Image?> importImageFromPath(String path) async {
    try {
      final File imageFile = File(path);
      final Uint8List bytes = await imageFile.readAsBytes();
      
      // Decode the image
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      
      return frameInfo.image;
    } catch (e) {
      print("Error importing image: $e");
      return null;
    }
  }
}