class ApiResponse {
  final bool success;
  final String message;
  final String sessionId;
  final String htmlContent;
  
  ApiResponse({
    this.success = false,
    this.message = '',
    this.sessionId = '',
    this.htmlContent = '',
  });
  
  // Create a copy with modified values
  ApiResponse copyWith({
    bool? success,
    String? message,
    String? sessionId,
    String? htmlContent,
  }) {
    return ApiResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      sessionId: sessionId ?? this.sessionId,
      htmlContent: htmlContent ?? this.htmlContent,
    );
  }
  
  // Factory to create from JSON
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      sessionId: json['session_id'] ?? '',
      htmlContent: json['html_content'] ?? '',
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'session_id': sessionId,
      'html_content': htmlContent,
    };
  }
  
  // Added debug helper method to check content
  String getSummary() {
    return 'ApiResponse{success: $success, message: $message, sessionId: $sessionId, htmlContentLength: ${htmlContent.length}}';
  }
  
  @override
  String toString() {
    return getSummary();
  }
}