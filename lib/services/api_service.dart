import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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

  // Add this method to your api_service.dart file
  Future<String?> uploadFileAndReturnFileId(
    Uint8List fileBytes,
    String filename,
  ) async {
    return await uploadFile(fileBytes, filename);
  }

  // Add this new method to process whiteboard images
  Future<ApiResponse> processWhiteboardImage(
    Uint8List imageBytes,
    String filename,
  ) async {
    try {
      // Upload the image to get a file ID
      final fileId = await uploadFile(imageBytes, filename);

      if (fileId == null) {
        throw Exception('Failed to upload image');
      }

      debugPrint('File uploaded successfully with ID: $fileId');

      // Process the image with the AI model
      final content = await processImage(fileId);

      if (content == null) {
        throw Exception('Failed to process image with AI');
      }

      // Return the response in the expected format
      return ApiResponse(
        success: true,
        message: 'Image processed successfully',
        sessionId: fileId,
        htmlContent: content,
      );
    } catch (e) {
      debugPrint('Process whiteboard image failed: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to process image: ${e.toString()}',
      );
    }
  }

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

  //function to process the image using llama3.2-vision:latest
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

      // Return the raw content from the model
      return jsonResponse['choices'][0]['message']['content'];
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
}
