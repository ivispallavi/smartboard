import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for searching content based on recognized text
class SearchService {
  /// Search for content based on a text query
  /// Returns a list of search results
  static Future<List<Map<String, dynamic>>> searchForContent(String query) async {
    try {
      // In a real application, you would implement an actual API call here
      // This is a placeholder implementation that simulates an API response
      await Future.delayed(const Duration(seconds: 1)); // Simulating API call
      
      // Example search results (replace with actual API integration)
      List<Map<String, dynamic>> results = [
        {
          'title': 'Results for "$query"',
          'description': 'Information about $query from various sources',
          'url': 'https://example.com/search?q=${Uri.encodeComponent(query)}',
          'imageUrl': 'https://via.placeholder.com/150?text=${Uri.encodeComponent(query)}',
        },
        {
          'title': '$query - Wikipedia',
          'description': 'Learn more about $query from Wikipedia',
          'url': 'https://en.wikipedia.org/wiki/${Uri.encodeComponent(query)}',
          'imageUrl': 'https://via.placeholder.com/150?text=Wikipedia',
        },
        {
          'title': '$query Images',
          'description': 'Visual resources related to $query',
          'url': 'https://images.google.com/search?q=${Uri.encodeComponent(query)}',
          'imageUrl': 'https://via.placeholder.com/150?text=Images',
        },
      ];
      
      // Here's how you might integrate a real search API like Google Custom Search:
      /*
      final apiKey = 'YOUR_API_KEY';
      final searchEngineId = 'YOUR_SEARCH_ENGINE_ID';
      final url = 'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$searchEngineId&q=${Uri.encodeComponent(query)}';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> results = [];
        
        if (data['items'] != null) {
          for (var item in data['items']) {
            results.add({
              'title': item['title'],
              'description': item['snippet'],
              'url': item['link'],
              'imageUrl': item['pagemap']?['cse_image']?[0]?['src'] ?? 'https://via.placeholder.com/150',
            });
          }
        }
        
        return results;
      } else {
        throw Exception('Failed to load search results');
      }
      */
      
      return results;
    } catch (e) {
      print('Error during search: $e');
      return [];
    }
  }

  /// Show search results in a modal bottom sheet
  static void showSearchResults(
    BuildContext context, 
    String searchQuery,
    List<Map<String, dynamic>> results,
    Function(String) onOpenWebView,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Search Results for "$searchQuery"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text("No results found"))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            onOpenWebView(result['url']);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail image (if available)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    result['imageUrl'] ?? 'https://via.placeholder.com/50',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image, color: Colors.grey),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Text content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result['title'] ?? 'No title',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        result['description'] ?? 'No description',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

  /// Open web view for a search result
  static void openWebView(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Search Result'),
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_browser),
                onPressed: () {
                  // Open in external browser if needed
                },
              ),
            ],
          ),
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(url)),
          ),
        ),
      ),
    );
  }
}