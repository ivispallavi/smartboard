import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart'; // Add this package for sharing
import 'package:image/image.dart'
    as img; // Add this package for image processing
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart'; // Add this for image picking
import 'package:smart_board/config/app_config.dart';
import 'package:smart_board/services/api_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WhiteboardScreen extends StatefulWidget {
  final String? imagePath;

  const WhiteboardScreen({this.imagePath, super.key});

  @override
  _WhiteboardScreenState createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends State<WhiteboardScreen> {
  List<DrawingPoint> currentPage = [];
  List<List<DrawingPoint>> undoStack = [];
  List<List<DrawingPoint>> redoStack = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 3.0;
  double eraserWidth = 5.0;
  bool isEraser = false;
  final GlobalKey _whiteboardKey = GlobalKey();
  double pageHeight = 1000.0; // Increased initial page height
  ScrollController _scrollController = ScrollController();
  ui.Image? backgroundImage;
  bool isLoading = false;
  String? currentImagePath;
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _loadLastUsedSettings();

    // If an image path was provided, load it
    if (widget.imagePath != null) {
      currentImagePath = widget.imagePath;
      _loadExistingWhiteboard(widget.imagePath!);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    backgroundImage?.dispose();
    super.dispose();
  }

  // New method to import image from gallery
  Future<void> _importImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        // If we already have a background image, dispose it first
        if (backgroundImage != null) {
          backgroundImage!.dispose();
          backgroundImage = null;
        }

        // Load the picked image
        setState(() {
          isLoading = true;
        });

        final File imageFile = File(pickedFile.path);
        final Uint8List bytes = await imageFile.readAsBytes();

        // Decode the image
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();

        setState(() {
          backgroundImage = frameInfo.image;
          // Adjust page height to match the image if needed
          pageHeight = math.max(pageHeight, backgroundImage!.height.toDouble());
          isLoading = false;

          // Clear the current drawing if importing a new image
          if (currentPage.isNotEmpty) {
            // Ask user if they want to clear current drawing
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showClearDrawingDialog();
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to import image: ${e.toString()}")),
      );
    }
  }

  // Dialog to confirm clearing drawing when importing new image
  void _showClearDrawingDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Clear Current Drawing?"),
            content: const Text(
              "Do you want to clear your current drawing on this imported image?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Keep Drawing"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    currentPage.clear();
                    undoStack.clear();
                    redoStack.clear();
                    // Keep the background image
                  });
                  Navigator.pop(context);
                },
                child: const Text("Clear Drawing"),
              ),
            ],
          ),
    );
  }

  Future<void> _loadExistingWhiteboard(String path) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load the image file
      File imageFile = File(path);
      if (await imageFile.exists()) {
        final Uint8List bytes = await imageFile.readAsBytes();

        // Decode the image
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();

        setState(() {
          backgroundImage = frameInfo.image;
          // Adjust page height to match the image if needed
          pageHeight = math.max(pageHeight, backgroundImage!.height.toDouble());
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image file not found")));
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load whiteboard: ${e.toString()}")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadLastUsedSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedColor = Color(prefs.getInt('penColor') ?? Colors.black.value);
      strokeWidth = prefs.getDouble('penSize') ?? 3.0;
      eraserWidth = prefs.getDouble('eraserSize') ?? 5.0;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('penColor', selectedColor.value);
    prefs.setDouble('penSize', strokeWidth);
    prefs.setDouble('eraserSize', eraserWidth);
  }

  void _undo() {
    if (currentPage.isNotEmpty) {
      setState(() {
        List<DrawingPoint> lastStroke = [];
        int i = currentPage.length - 1;

        // Find the last stroke's end (marked by transparent point)
        while (i >= 0 && currentPage[i].color != Colors.transparent) {
          i--;
        }

        // If found transparent point (end of stroke), remove the stroke
        if (i >= 0) {
          redoStack.add(List.from(currentPage));
          currentPage = currentPage.sublist(0, i);
        }
      });
    }
  }

  void _redo() {
    if (redoStack.isNotEmpty) {
      setState(() {
        undoStack.add(List.from(currentPage));
        currentPage = redoStack.removeLast();
      });
    }
  }

  void _clearBoard() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Clear Whiteboard"),
            content: const Text(
              "Are you sure you want to clear the entire whiteboard?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    currentPage.clear();
                    undoStack.clear();
                    redoStack.clear();
                    backgroundImage?.dispose();
                    backgroundImage = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Clear"),
              ),
            ],
          ),
    );
  }

  void _extendCurrentPage() {
    setState(() {
      pageHeight += 200.0; // Extend by 200 units each time

      // Schedule a scroll to the bottom after the UI updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  Future<void> _saveWhiteboard() async {
    try {
      RenderRepaintBoundary boundary =
          _whiteboardKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      // If editing an existing file, use the same path to overwrite it
      String filePath;
      if (currentImagePath != null) {
        filePath = currentImagePath!;
      } else {
        filePath = '${directory.path}/whiteboard_$timestamp.png';
      }

      File imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);

      // Only add to the list if it's a new file
      if (currentImagePath == null) {
        // Update SharedPreferences - both the old way for backwards compatibility
        SharedPreferences prefs = await SharedPreferences.getInstance();
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

        // Set current image path for future saves
        currentImagePath = filePath;
      } else {
        // Update the timestamp for existing files
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> savedData = prefs.getStringList('whiteboardsData') ?? [];
        String timestamp = DateTime.now().toString();

        List<String> updatedData = [];
        for (String entry in savedData) {
          List<String> parts = entry.split('|');
          if (parts[0] == filePath) {
            updatedData.add(
              "$filePath|$timestamp",
            ); // Update with new timestamp
          } else {
            updatedData.add(entry);
          }
        }

        prefs.setStringList('whiteboardsData', updatedData);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Whiteboard saved!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save whiteboard: ${e.toString()}")),
      );
    }
  }

  Future<void> _downloadWhiteboard(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Capture whiteboard as image
      RenderRepaintBoundary boundary =
          _whiteboardKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Close loading indicator
      Navigator.pop(context);

      // Create filename
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String filename = 'whiteboard_$timestamp.png';

      if (kIsWeb) {
        await _processWhiteboardForWeb(context, pngBytes);
      } else {
        // Handle native platforms with your existing code
        await _processWhiteboardForNative(context, pngBytes, filename);
      }
    } catch (e) {
      // Error handling
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: ${e.toString()}")));
    }
  }

  // Web-specific implementation
  Future<void> _processWhiteboardForWeb(
    BuildContext context,
    Uint8List imageBytes,
  ) async {
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Processing Whiteboard'),
          content: const Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Generating notes from your whiteboard...'),
            ],
          ),
        );
      },
    );

    try {
      // Convert image to base64
      final base64Image = base64Encode(imageBytes);

      // Use direct API call
      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.completionsPath}');

      // Create payload with image directly embedded
      final payload = {
        'model': 'llama3.2-vision:latest',
        'messages': [
          {
            'role': 'user',
            'content': '''
          I'm showing you an image from a smart panel containing various content. Please create clean, organized notes that:

          Identify the main concept or topic with a clear heading
          Present all textual content, diagrams, charts, and visual elements accurately
          Maintain hierarchical relationships and logical organization
          For mathematical content:

          Format equations properly
          Analyze properties when relevant
          Provide complete solutions with steps

          For non-mathematical content:

          Organize into logical sections with clear headings
          Preserve important relationships between concepts
          Summarize diagrams or visual elements effectively

          Present everything in a clean, well-structured format with proper formatting and notation. Skip any explanation of your analysis process and focus solely on delivering organized, comprehensive notes.
          ''',
            'images': [base64Image],
          },
        ],
      };

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer ${AppConfig.apiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 120));

      // Close the dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];

        // Show results
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Notes Generated'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your whiteboard has been processed:'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: SelectableText(
                          content ?? 'No content generated',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text('Copy to Clipboard'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: content ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notes copied to clipboard'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
        );
      } else {
        // Handle error
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Processing Failed'),
                content: Text(
                  'Error: ${response.statusCode} - ${response.body}',
                ),
                actions: [
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      // Close dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to process: ${e.toString()}'),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    }
  }

  // Native platform implementation (your existing code)
  Future<void> _processWhiteboardForNative(
    BuildContext context,
    Uint8List pngBytes,
    String filename,
  ) async {
    // Save to device - your existing code
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory =
            await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    String filePath = '${directory.path}/$filename';
    File imgFile = File(filePath);
    await imgFile.writeAsBytes(pngBytes);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Whiteboard saved to: $filePath")));

    // Rest of your original native platform processing code
    // ...
  }

  Future<void> _exportAndShareWhiteboard() async {
    try {
      // Make sure to wait until the next frame to ensure everything is rendered
      await Future.delayed(Duration.zero);

      // Get the render object for the whiteboard
      RenderRepaintBoundary boundary =
          _whiteboardKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // Increase pixel ratio for better quality
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to export: ${e.toString()}")),
      );
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Pick a color"),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    selectedColor = color;
                    isEraser = false;
                  });
                  _saveSettings();
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              ),
            ],
          ),
    );
  }

  void _selectBrushSize() {
    // Reset to valid values before showing dialog
    double currentValue = isEraser ? eraserWidth : strokeWidth;
    double minValue = isEraser ? 5.0 : 3.0;
    double maxValue = 10.0;

    // Ensure the current value is within bounds
    if (currentValue < minValue) currentValue = minValue;
    if (currentValue > maxValue) currentValue = maxValue;

    // Update the state with valid values
    setState(() {
      if (isEraser) {
        eraserWidth = currentValue;
      } else {
        strokeWidth = currentValue;
      }
    });

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEraser ? "Select Eraser Size" : "Select Pen Size"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: isEraser ? eraserWidth : strokeWidth,
                  min: isEraser ? 5.0 : 3.0,
                  max: 10.0,
                  divisions: isEraser ? 5 : 7,
                  label: (isEraser ? eraserWidth : strokeWidth).toStringAsFixed(
                    1,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (isEraser) {
                        eraserWidth = value;
                      } else {
                        strokeWidth = value;
                      }
                    });
                  },
                ),
                Text(
                  "Size: ${(isEraser ? eraserWidth : strokeWidth).toStringAsFixed(1)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _saveSettings();
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentImagePath != null ? "Edit Whiteboard" : "New Whiteboard",
        ),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: _redo),
          // Removed the import button from here
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Save') _saveWhiteboard();
              if (value == 'Export') _exportAndShareWhiteboard();
              if (value == 'Import') _importImage();
              if (value == 'Download')
                _downloadWhiteboard(context); // Added download option
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'Save',
                    child: Text('Save Whiteboard'),
                  ),
                  const PopupMenuItem(
                    value: 'Export',
                    child: Text('Share Whiteboard'),
                  ),
                  const PopupMenuItem(
                    value: 'Import',
                    child: Text('Import Image'),
                  ),
                  const PopupMenuItem(
                    value: 'Download',
                    child: Text('Download Whiteboard'),
                  ), // Added download option
                ],
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: pageHeight,
                  child: RepaintBoundary(
                    key: _whiteboardKey,
                    child: GestureDetector(
                      onPanStart: (details) {
                        RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        // Get the position relative to the current scroll offset
                        Offset localPosition = renderBox.globalToLocal(
                          details.globalPosition,
                        );

                        // Adjust for scroll position
                        localPosition = Offset(
                          localPosition.dx,
                          localPosition.dy + _scrollController.offset,
                        );

                        setState(() {
                          // Save current state for undo
                          undoStack.add(List.from(currentPage));
                          redoStack.clear();

                          // Add the starting point
                          currentPage.add(
                            DrawingPoint(
                              localPosition,
                              isEraser ? Colors.white : selectedColor,
                              isEraser ? eraserWidth : strokeWidth,
                            ),
                          );
                        });
                      },
                      onPanUpdate: (details) {
                        RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        // Get the position relative to the current scroll offset
                        Offset localPosition = renderBox.globalToLocal(
                          details.globalPosition,
                        );

                        // Adjust for scroll position
                        localPosition = Offset(
                          localPosition.dx,
                          localPosition.dy + _scrollController.offset,
                        );

                        setState(() {
                          currentPage.add(
                            DrawingPoint(
                              localPosition,
                              isEraser ? Colors.white : selectedColor,
                              isEraser ? eraserWidth : strokeWidth,
                            ),
                          );
                        });
                      },
                      onPanEnd:
                          (_) => setState(() {
                            // Add a transparent point to mark the end of a stroke
                            currentPage.add(
                              DrawingPoint(Offset.zero, Colors.transparent, 0),
                            );
                          }),
                      child: CustomPaint(
                        painter: WhiteboardPainter(
                          currentPage,
                          backgroundImage,
                        ),
                        size: Size(
                          MediaQuery.of(context).size.width,
                          pageHeight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.brush),
              color: !isEraser ? Theme.of(context).primaryColor : null,
              onPressed: () {
                setState(() {
                  isEraser = false;
                  // Ensure valid value when switching
                  if (strokeWidth < 3.0) strokeWidth = 3.0;
                  if (strokeWidth > 10.0) strokeWidth = 10.0;
                });
                _selectBrushSize();
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_off),
              color: isEraser ? Theme.of(context).primaryColor : null,
              onPressed: () {
                setState(() {
                  isEraser = true;
                  // Ensure valid value when switching
                  if (eraserWidth < 5.0) eraserWidth = 5.0;
                  if (eraserWidth > 10.0) eraserWidth = 10.0;
                });
                _selectBrushSize();
              },
            ),
            IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: _pickColor,
            ),
            IconButton(icon: const Icon(Icons.clear), onPressed: _clearBoard),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _extendCurrentPage,
              tooltip: "Extend Page",
            ),
            // Removed the import button from here
          ],
        ),
      ),
    );
  }
}

class DrawingPoint {
  Offset offset;
  Color color;
  double strokeWidth;
  DrawingPoint(this.offset, this.color, this.strokeWidth);
}

class WhiteboardPainter extends CustomPainter {
  final List<DrawingPoint> points;
  final ui.Image? backgroundImage;

  WhiteboardPainter(this.points, this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background image if available
    if (backgroundImage != null) {
      canvas.drawImage(backgroundImage!, Offset.zero, Paint());
    }

    // Draw strokes
    for (int i = 0; i < points.length - 1; i++) {
      // Skip the "invisible" points (used as stroke separators)
      if (points[i].color == Colors.transparent ||
          points[i + 1].color == Colors.transparent) {
        continue;
      }

      if (points[i].offset != Offset.zero &&
          points[i + 1].offset != Offset.zero) {
        Paint paint =
            Paint()
              ..color = points[i].color
              ..strokeCap = StrokeCap.round
              ..strokeWidth = points[i].strokeWidth;
        canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
