import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart';
import 'package:flutter/material.dart' as material;

import '../models/api_response.dart';

class ApiService {
  final String baseUrl;
  final String apiKey;

  ApiService({required this.baseUrl, required this.apiKey});

  // Health check endpoint to verify API is working
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  // Process image from raw bytes
  Future<ApiResponse> processImageBytes(Uint8List imageBytes) async {
    try {
      // Step 1: Upload the image to get a file ID
      final filename =
          'whiteboard_${DateTime.now().millisecondsSinceEpoch}.png';
      final fileId = await uploadFile(imageBytes, filename);

      if (fileId == null) {
        throw Exception('Failed to upload image');
      }

      debugPrint('File uploaded successfully with ID: $fileId');

      // Step 2: Process the image with the AI model
      final content = await processImage(fileId);

      if (content == null) {
        throw Exception('Failed to process image with AI');
      }

      // Print the response for debugging
      debugPrint(
        'Processed content: ${content.substring(0, min(100, content.length))}...',
      );

      // Return the response in the expected format
      return ApiResponse(
        success: true,
        message: 'Image processed successfully',
        sessionId: fileId,
        htmlContent: content,
      );
    } catch (e) {
      debugPrint('Process image failed: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to process image: ${e.toString()}',
      );
    }
  }

  // Helper function to get min of two numbers
  int min(int a, int b) => a < b ? a : b;

  // Process image from a file
  Future<ApiResponse> processImageFile(
    Uint8List fileBytes,
    String filename,
  ) async {
    try {
      // Prepare multipart request
      final uri = Uri.parse('$baseUrl/process-file');
      final request = http.MultipartRequest('POST', uri);

      // Add file to request
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
        contentType: MediaType('image', _getFileExtension(filename)),
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);

      // Parse response
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: jsonResponse['success'] ?? false,
          message: jsonResponse['message'] ?? '',
          sessionId: jsonResponse['session_id'] ?? '',
          htmlContent: jsonResponse['html_content'] ?? '',
        );
      } else {
        return ApiResponse(
          success: false,
          message: jsonResponse['error'] ?? 'Unknown error occurred',
        );
      }
    } catch (e) {
      debugPrint('Process file failed: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to process file: ${e.toString()}',
      );
    }
  }

  // Get results for a specific session ID
  Future<ApiResponse> getResults(String sessionId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/results/$sessionId'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: jsonResponse['success'] ?? false,
          htmlContent: jsonResponse['html_content'] ?? '',
        );
      } else {
        return ApiResponse(
          success: false,
          message: jsonResponse['error'] ?? 'Unknown error occurred',
        );
      }
    } catch (e) {
      debugPrint('Get results failed: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to get results: ${e.toString()}',
      );
    }
  }

  // Function to upload a file, returns file id and named as id in json response
  Future<String?> uploadFile(Uint8List fileBytes, String filename) async {
    try {
      // Ensure the URL doesn't end with a trailing slash
      final baseUrlTrimmed =
          baseUrl.endsWith('/')
              ? baseUrl.substring(0, baseUrl.length - 1)
              : baseUrl;
      final url = Uri.parse('$baseUrlTrimmed/api/v1/files/');

      debugPrint('Uploading file to $url');

      // Create a multipart request
      final request = http.MultipartRequest('POST', url);

      // Add the file to the request
      final multipartFile = http.MultipartFile.fromBytes(
        'file', // This must match exactly what the server expects
        fileBytes,
        filename: filename,
      );
      request.files.add(multipartFile);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $apiKey';
      request.headers['Accept'] = 'application/json';

      // Send the request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }

      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['id']; // Return the file ID from the response
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  // Function to process the image using llama3.2-vision:latest
  Future<String?> processImage(String fileId) async {
    try {
      // Get file content using fileId
      final fileContent = await getFileContent(fileId);
      if (fileContent == null) {
        throw Exception('Failed to get file content');
      }

      // Convert file bytes to base64 string
      final base64Image = base64Encode(fileContent);

      // Ensure baseUrl doesn't end with a slash
      final baseUrlTrimmed =
          baseUrl.endsWith('/')
              ? baseUrl.substring(0, baseUrl.length - 1)
              : baseUrl;
      final url = Uri.parse('$baseUrlTrimmed/api/chat/completions');

      debugPrint('Processing image with chat completion API');

      // Craft the prompt for Llama 3.2-vision
      const prompt = '''
Analyze the handwritten content in this whiteboard image and generate comprehensive educational notes. Please format your response as follows:

1. Start with a clear title in bold (use ** on both sides)
2. Organize content into logical sections with proper headings and subheadings:
   - Use level 1 headings for main sections Let the font size be 20 and let it be bold (# Heading)
   - Use level 2 headings for subsections Let the font size be 16(## Subheading)
   - Use level 3 headings for minor sections (### Minor section)

3. Format key terms and important concepts in bold
4. Use bullet points or numbered lists where appropriate
5. For scientific or mathematical content:
   - Format formulas correctly
   - Include proper subscripts/superscripts when needed
   - Explain key properties and relationships

6. Add relevant context and explanations to deepen understanding
7. End with a brief summary of key points

Present everything as a well-structured markdown document that's easy to read and study from. Do not use ### symbols as heading markers.
''';

      // Create payload matching Python implementation but with simpler prompt
      final payload = {
        'model': 'llama3.2-vision:latest',
        'messages': [
          {
            'role': 'user',
            'content': prompt,
            'images': [base64Image],
          },
        ],
      };

      // Send the request
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 120),
          ); // Longer timeout for processing

      debugPrint('Process image response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed to process image: ${response.statusCode}');
      }

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['choices'] == null ||
          jsonResponse['choices'].isEmpty ||
          jsonResponse['choices'][0]['message'] == null) {
        debugPrint('Unexpected response format: $jsonResponse');
        throw Exception('Unexpected response format from API');
      }

      final content = jsonResponse['choices'][0]['message']['content'];
      debugPrint(
        'Received content from API: ${content.substring(0, min(100, content.length))}...',
      );

      // Return the raw content from the model
      return content;
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }

  Future<Uint8List?> getFileContent(String fileId) async {
    try {
      // Ensure baseUrl doesn't end with a slash
      final baseUrlTrimmed =
          baseUrl.endsWith('/')
              ? baseUrl.substring(0, baseUrl.length - 1)
              : baseUrl;
      final url = Uri.parse('$baseUrlTrimmed/api/v1/files/$fileId/content');

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Accept': 'application/octet-stream',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to get file content: ${response.statusCode}');
      }

      return response.bodyBytes;
    } catch (e) {
      debugPrint('Error getting file content: $e');
      return null;
    }
  }

  // Helper function to get file extension
  String _getFileExtension(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      default:
        return 'octet-stream';
    }
  }

  // NEW FUNCTIONS FOR PDF EXPORT AND PREVIEW

  // Function to show preview of HTML content
  void showPreview(material.BuildContext context, String htmlContent) {
    try {
      debugPrint('Showing preview of HTML content');
      material.showDialog(
        context: context,
        builder: (material.BuildContext context) {
          return material.AlertDialog(
            title: const material.Text('Notes Preview'),
            content: material.Container(
              width: double.maxFinite,
              height: material.MediaQuery.of(context).size.height * 0.6,
              child: material.SingleChildScrollView(
                child: material.Column(
                  crossAxisAlignment: material.CrossAxisAlignment.start,
                  children: _parseHtmlToWidgets(htmlContent),
                ),
              ),
            ),
            actions: [
              material.TextButton(
                onPressed: () => material.Navigator.of(context).pop(),
                child: const material.Text('Close'),
              ),
              material.TextButton(
                onPressed: () {
                  material.Navigator.of(context).pop();
                  exportAsPdf(context, htmlContent);
                },
                child: const material.Text('Export as PDF'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing preview: $e');
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Error showing preview: ${e.toString()}'),
        ),
      );
    }
  }

  // Function to parse HTML content to Flutter widgets
  List<material.Widget> _parseHtmlToWidgets(String htmlContent) {
    try {
      debugPrint('Parsing HTML content to widgets');
      final document = htmlParser.parse(htmlContent);
      final List<material.Widget> widgets = [];

      // Fallback if parsing fails
      if (document.body == null || document.body!.nodes.isEmpty) {
        debugPrint('HTML parsing returned no nodes, using raw content');
        return [
          material.Padding(
            padding: const material.EdgeInsets.all(8.0),
            child: material.Text(htmlContent),
          ),
        ];
      }

      // Parse paragraphs, headings, and other elements
      for (var node in document.body?.nodes ?? []) {
        if (node is Element) {
          switch (node.localName) {
            case 'h1':
              widgets.add(
                material.Padding(
                  padding: const material.EdgeInsets.symmetric(vertical: 8.0),
                  child: material.Text(
                    node.text ?? '',
                    style: const material.TextStyle(
                      fontSize: 24,
                      fontWeight: material.FontWeight.bold,
                    ),
                  ),
                ),
              );
              break;
            case 'h2':
              widgets.add(
                material.Padding(
                  padding: const material.EdgeInsets.symmetric(vertical: 6.0),
                  child: material.Text(
                    node.text ?? '',
                    style: const material.TextStyle(
                      fontSize: 20,
                      fontWeight: material.FontWeight.bold,
                    ),
                  ),
                ),
              );
              break;
            case 'h3':
              widgets.add(
                material.Padding(
                  padding: const material.EdgeInsets.symmetric(vertical: 4.0),
                  child: material.Text(
                    node.text ?? '',
                    style: const material.TextStyle(
                      fontSize: 18,
                      fontWeight: material.FontWeight.bold,
                    ),
                  ),
                ),
              );
              break;
            case 'p':
              widgets.add(
                material.Padding(
                  padding: const material.EdgeInsets.symmetric(vertical: 4.0),
                  child: material.Text(node.text ?? ''),
                ),
              );
              break;
            case 'ul':
              for (var li in node.getElementsByTagName('li')) {
                widgets.add(
                  material.Padding(
                    padding: const material.EdgeInsets.only(
                      left: 16.0,
                      top: 2.0,
                      bottom: 2.0,
                    ),
                    child: material.Row(
                      crossAxisAlignment: material.CrossAxisAlignment.start,
                      children: [
                        const material.Text(
                          '• ',
                          style: material.TextStyle(
                            fontWeight: material.FontWeight.bold,
                          ),
                        ),
                        material.Expanded(child: material.Text(li.text ?? '')),
                      ],
                    ),
                  ),
                );
              }
              break;
            case 'ol':
              int index = 1;
              for (var li in node.getElementsByTagName('li')) {
                widgets.add(
                  material.Padding(
                    padding: const material.EdgeInsets.only(
                      left: 16.0,
                      top: 2.0,
                      bottom: 2.0,
                    ),
                    child: material.Row(
                      crossAxisAlignment: material.CrossAxisAlignment.start,
                      children: [
                        material.Text(
                          '$index. ',
                          style: const material.TextStyle(
                            fontWeight: material.FontWeight.bold,
                          ),
                        ),
                        material.Expanded(child: material.Text(li.text ?? '')),
                      ],
                    ),
                  ),
                );
                index++;
              }
              break;
            case 'pre':
              widgets.add(
                material.Container(
                  margin: const material.EdgeInsets.symmetric(vertical: 4.0),
                  padding: const material.EdgeInsets.all(8.0),
                  decoration: material.BoxDecoration(
                    color: material.Colors.grey[200],
                    borderRadius: material.BorderRadius.circular(4.0),
                  ),
                  child: material.Text(
                    node.text ?? '',
                    style: const material.TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              );
              break;
            default:
              // Handle text content if it's not one of the above types
              if (node.text != null && node.text!.trim().isNotEmpty) {
                widgets.add(
                  material.Padding(
                    padding: const material.EdgeInsets.symmetric(vertical: 4.0),
                    child: material.Text(node.text!.trim()),
                  ),
                );
              }
              break;
          }
        } else if (node is Text && node.text!.trim().isNotEmpty) {
          widgets.add(
            material.Padding(
              padding: const material.EdgeInsets.symmetric(vertical: 4.0),
              child: material.Text(node.text!.trim()),
            ),
          );
        }
      }

      // Fallback if no widgets were created
      if (widgets.isEmpty) {
        widgets.add(
          material.Padding(
            padding: const material.EdgeInsets.all(8.0),
            child: material.Text(htmlContent),
          ),
        );
      }

      return widgets;
    } catch (e) {
      debugPrint('Error parsing HTML: $e');
      return [
        material.Padding(
          padding: const material.EdgeInsets.all(8.0),
          child: material.Text(
            'Error parsing content: ${e.toString()}\n\nRaw content:\n$htmlContent',
          ),
        ),
      ];
    }
  }

  // Function to export content as PDF
  // Function to export content as PDF
  Future<void> exportAsPdf(
    material.BuildContext context,
    String htmlContent,
  ) async {
    try {
      // Show processing dialog
      material.showDialog(
        context: context,
        barrierDismissible: false,
        builder: (material.BuildContext context) {
          return material.AlertDialog(
            content: material.Column(
              mainAxisSize: material.MainAxisSize.min,
              children: const [
                material.CircularProgressIndicator(),
                material.SizedBox(height: 16),
                material.Text('Creating PDF file...'),
              ],
            ),
          );
        },
      );

      debugPrint('Creating PDF from HTML content');

      // Parse HTML content
      final document = htmlParser.parse(htmlContent);

      // Create a PDF document
      final pdf = pw.Document();

      // Extract title or use default
      String? title = 'Generated Notes';
      try {
        // Try to find an h1 tag for title
        final h1Tags = document.getElementsByTagName('h1');
        if (h1Tags.isNotEmpty && h1Tags.first.text != null) {
          title = h1Tags.first.text?.trim();
        }
      } catch (e) {
        debugPrint('Error extracting title: $e');
      }

      // Use simpler approach to create PDF content
      String plainText = '';
      try {
        plainText = document.body?.text ?? htmlContent;
      } catch (e) {
        plainText = htmlContent;
        debugPrint('Error extracting plain text: $e');
      }

      // Add a simple page with the content
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(level: 0, child: pw.Text(title ?? 'Generated Notes')),
                pw.SizedBox(height: 20),
                pw.Text(plainText),
              ],
            );
          },
        ),
      );

      try {
        // Platform-specific directory handling
        final fileName = 'notes_${DateTime.now().millisecondsSinceEpoch}.pdf';
        Uint8List pdfBytes = await pdf.save();

        // First try to get temporary directory (handles most platforms)
        Directory? directory;
        String filePath;

        try {
          // Try getting temporary directory first
          directory = await getTemporaryDirectory();
          filePath = '${directory.path}/$fileName';
        } catch (e) {
          debugPrint('Error getting temporary directory: $e');
          // Fallback for web or unsupported platforms
          // For web, we'll use share directly without saving to a file
          if (kIsWeb) {
            // Close the processing dialog
            if (material.Navigator.canPop(context)) {
              material.Navigator.of(context).pop();
            }

            // On web, we can't use file system, so share bytes directly
            await Share.shareXFiles([
              XFile.fromData(
                pdfBytes,
                name: fileName,
                mimeType: 'application/pdf',
              ),
            ], text: 'Generated Notes');

            material.ScaffoldMessenger.of(context).showSnackBar(
              const material.SnackBar(content: material.Text('PDF shared')),
            );
            return;
          } else {
            // Last resort - try application documents directory
            try {
              directory = await getApplicationDocumentsDirectory();
              filePath = '${directory.path}/$fileName';
            } catch (e2) {
              throw Exception('Could not access any storage directory: $e2');
            }
          }
        }

        // Save PDF to file
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        // Close the processing dialog
        if (material.Navigator.canPop(context)) {
          material.Navigator.of(context).pop();
        }

        // Share the file
        await Share.shareXFiles([XFile(filePath)], text: 'Generated Notes');

        material.ScaffoldMessenger.of(context).showSnackBar(
          material.SnackBar(content: material.Text('PDF saved and shared')),
        );
      } catch (e) {
        debugPrint('Error saving or sharing PDF: $e');
        throw Exception('Error saving or sharing PDF: $e');
      }
    } catch (e) {
      // Close the processing dialog if open
      if (material.Navigator.canPop(context)) {
        material.Navigator.of(context).pop();
      }

      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Error creating PDF: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Main function to process image and generate notes
  Future<void> processImageAndGenerateNotes(
    material.BuildContext context,
    Uint8List imageBytes,
  ) async {
    try {
      // Show processing dialog
      material.showDialog(
        context: context,
        barrierDismissible: false,
        builder: (material.BuildContext context) {
          return material.AlertDialog(
            content: material.Column(
              mainAxisSize: material.MainAxisSize.min,
              children: const [
                material.CircularProgressIndicator(),
                material.SizedBox(height: 16),
                material.Text('Processing image and generating notes...'),
              ],
            ),
          );
        },
      );

      // Process the image with the API
      final response = await processImageBytes(imageBytes);

      // Close the processing dialog
      if (material.Navigator.canPop(context)) {
        material.Navigator.of(context).pop();
      }

      if (!response.success) {
        // Show error message
        material.ScaffoldMessenger.of(context).showSnackBar(
          material.SnackBar(
            content: material.Text('Error: ${response.message}'),
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      debugPrint('API processed image successfully, displaying options');

      // Check if htmlContent is not empty
      if (response.htmlContent.isEmpty) {
        material.ScaffoldMessenger.of(context).showSnackBar(
          const material.SnackBar(
            content: material.Text('Error: Received empty content from API'),
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      // Show options dialog
      material.showDialog(
        context: context,
        builder: (material.BuildContext context) {
          return material.AlertDialog(
            title: const material.Text('Save Notes'),
            content: const material.Text('Choose an option:'),
            actions: [
              material.TextButton(
                onPressed: () {
                  material.Navigator.of(context).pop();
                  showPreview(context, response.htmlContent);
                },
                child: const material.Text('Preview'),
              ),
              material.TextButton(
                onPressed: () {
                  material.Navigator.of(context).pop();
                  exportAsPdf(context, response.htmlContent);
                },
                child: const material.Text('Export as PDF'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Close the processing dialog if open
      if (material.Navigator.canPop(context)) {
        material.Navigator.of(context).pop();
      }

      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
