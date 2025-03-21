import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'whiteboard_screen.dart';
import 'signin_screen.dart';
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
    
    // Apply the theme change
    final ThemeMode themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    // This assumes you have a way to update your app's theme
    // You may need to adapt this to your theme implementation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Update your app theme here if needed
    });
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  /// Load saved whiteboards from SharedPreferences
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
      // For backward compatibility with your old format
      final List<String>? oldPaths = prefs.getStringList('whiteboards');
      if (oldPaths != null && oldPaths.isNotEmpty) {
        final now = DateTime.now().toString();
        setState(() {
          savedWhiteboards = oldPaths.map((path) => {
            'path': path,
            'lastModified': now,
          }).toList();
        });
        
        // Save in the new format
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
    // Show confirmation dialog
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
    _loadSavedWhiteboards(); // Refresh after returning from Whiteboard
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
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhiteboardScreen(),
                  ),
                ).then((_) {
                  _loadSavedWhiteboards(); // Refresh after returning from Whiteboard
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
            const SizedBox(height: 20),
            Expanded(
              child: savedWhiteboards.isEmpty
                  ? const Center(child: Text("No saved whiteboards"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8, // Adjusted for date display
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: savedWhiteboards.length,
                      itemBuilder: (context, index) {
                        final whiteboard = savedWhiteboards[index];
                        final path = whiteboard['path'];
                        final lastModified = whiteboard['lastModified'];
                        
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ImageViewer(path),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(path),
                                        fit: BoxFit.cover,
                                      ),
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

/// Image Viewer for saved whiteboards
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