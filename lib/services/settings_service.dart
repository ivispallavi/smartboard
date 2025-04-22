import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Service for handling whiteboard settings and preferences
class SettingsService {
  /// Default color for the pen
  static const defaultPenColor = Colors.black;
  
  /// Default width for the pen stroke
  static const defaultPenWidth = 3.0;
  
  /// Default width for the eraser
  static const defaultEraserWidth = 5.0;
  
  /// Minimum width for the pen stroke
  static const minPenWidth = 3.0;
  
  /// Maximum width for the pen stroke
  static const maxPenWidth = 10.0;
  
  /// Minimum width for the eraser
  static const minEraserWidth = 5.0;
  
  /// Maximum width for the eraser
  static const maxEraserWidth = 10.0;

  /// Load the last used settings from SharedPreferences
  static Future<Map<String, dynamic>> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    return {
      'penColor': Color(prefs.getInt('penColor') ?? defaultPenColor.value),
      'penSize': prefs.getDouble('penSize') ?? defaultPenWidth,
      'eraserSize': prefs.getDouble('eraserSize') ?? defaultEraserWidth,
    };
  }

  /// Save the current settings to SharedPreferences
  static Future<void> saveSettings({
    required Color penColor,
    required double penSize,
    required double eraserSize,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('penColor', penColor.value);
    prefs.setDouble('penSize', penSize);
    prefs.setDouble('eraserSize', eraserSize);
  }

  /// Show a color picker dialog to select the pen color
  static Future<Color?> showColorPicker(
    BuildContext context, 
    Color initialColor,
  ) async {
    Color pickedColor = initialColor;
    Color? result;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pick a color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: (color) {
              pickedColor = color;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              result = pickedColor;
              Navigator.pop(context);
            }, 
            child: const Text("Done")
          ),
        ],
      ),
    );
    
    return result;
  }

  /// Show a dialog to select the pen or eraser size
  static Future<double?> showSizePickerDialog({
    required BuildContext context,
    required bool isEraser,
    required double initialSize,
  }) async {
    double currentSize = initialSize;
    double? result;
    
    // Set valid bounds
    double minValue = isEraser ? minEraserWidth : minPenWidth;
    double maxValue = isEraser ? maxEraserWidth : maxPenWidth;
    
    // Ensure the current value is within bounds
    if (currentSize < minValue) currentSize = minValue;
    if (currentSize > maxValue) currentSize = maxValue;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEraser ? "Select Eraser Size" : "Select Pen Size"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: currentSize,
                  min: minValue,
                  max: maxValue,
                  divisions: isEraser ? 5 : 7,
                  label: currentSize.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      currentSize = value;
                    });
                  },
                ),
                Text(
                  "Size: ${currentSize.toStringAsFixed(1)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              result = currentSize;
              Navigator.pop(context);
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
    
    return result;
  }

  /// Show a confirmation dialog for clearing the whiteboard
  static Future<bool> showClearConfirmationDialog(BuildContext context) async {
    bool result = false;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Whiteboard"),
        content: const Text("Are you sure you want to clear the entire whiteboard?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              result = true;
              Navigator.pop(context);
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
    
    return result;
  }

  /// Show a dialog to confirm clearing drawing when importing a new image
  static Future<bool> showClearDrawingDialog(BuildContext context) async {
    bool result = false;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Current Drawing?"),
        content: const Text("Do you want to clear your current drawing on this imported image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Keep Drawing"),
          ),
          TextButton(
            onPressed: () {
              result = true;
              Navigator.pop(context);
            },
            child: const Text("Clear Drawing"),
          ),
        ],
      ),
    );
    
    return result;
  }
}