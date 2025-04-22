import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'whiteboard_screen.dart';
import 'periodic_table_screen.dart'; // Import the new screen

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isDarkMode = false;
  List<Map<String, dynamic>> savedWhiteboards = [];

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadSavedWhiteboards();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }


  Future<void> _loadSavedWhiteboards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? savedData = prefs.getStringList('whiteboardsData');

    if (savedData != null) {
      setState(() {
        savedWhiteboards = savedData.map((item) {
          final parts = item.split('|');
          if (parts.length >= 2) {
            return {
              'path': parts[0],
              'lastModified': parts[1],
            };
          }
          return {
            'path': parts[0],
            'lastModified': DateTime.now().toString(),
          };
        }).toList();
      });
    } else {
      final List<String>? oldPaths = prefs.getStringList('whiteboards');
      if (oldPaths != null && oldPaths.isNotEmpty) {
        final now = DateTime.now().toString();
        setState(() {
          savedWhiteboards = oldPaths.map((path) => {
            'path': path,
            'lastModified': now,
          }).toList();
        });
        await _saveWhiteboardsData();
      }
    }
  }

  Future<void> _saveWhiteboardsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> dataToSave = savedWhiteboards.map((item) {
      return "${item['path']}|${item['lastModified']}";
    }).toList();
    await prefs.setStringList('whiteboardsData', dataToSave);
  }

  Future<void> _deleteWhiteboard(int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Whiteboard'),
        content: const Text('Are you sure you want to delete this whiteboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        savedWhiteboards.removeAt(index);
      });
      await _saveWhiteboardsData();
    }
  }

  void _editWhiteboard(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhiteboardScreen(imagePath: path),
      ),
    ).then((_) {
      _loadSavedWhiteboards();
    });
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    } catch (e) {
      return "Unknown date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode 
        ? ThemeData.dark().copyWith(
            primaryColor: Colors.blueAccent,
            colorScheme: ColorScheme.dark(
              primary: Colors.blueAccent,
              secondary: Colors.blueAccent,
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent,
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent,
              secondary: Colors.blueAccent,
            ),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: _isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WhiteboardScreen(),
                      ),
                    ).then((_) {
                      _loadSavedWhiteboards();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'New Whiteboard',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                // Add Periodic Table button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PeriodicTableScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    backgroundColor: Colors.greenAccent[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Periodic Table',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: savedWhiteboards.isEmpty
                  ? const Center(child: Text("No saved whiteboards"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: savedWhiteboards.length,
                      itemBuilder: (context, index) {
                        final whiteboard = savedWhiteboards[index];
                        final path = whiteboard['path'];
                        final lastModified = whiteboard['lastModified'];
                        final file = File(path);
                        final fileExists = file.existsSync();

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: fileExists
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ImageViewer(path),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      fileExists
                                          ? Image.file(
                                              file,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Text(
                                                  "Image not found",
                                                  style: TextStyle(color: Colors.red),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                      if (fileExists)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: PopupMenuButton<String>(
                                            icon: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black45,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.more_vert,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _editWhiteboard(path);
                                              } else if (value == 'delete') {
                                                _deleteWhiteboard(index);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete),
                                                    SizedBox(width: 8),
                                                    Text('Delete'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                color: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                child: Text(
                                  _formatDate(lastModified),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  final String imagePath;

  const ImageViewer(this.imagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Whiteboard View")),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(imagePath)),
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
        ),
      ),
    );
  }
}