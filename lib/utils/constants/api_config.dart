/// API configuration for connecting to the backend
/// The base URL should be configured based on environment
class ApiConfig {
  // Your DigitalOcean droplet IP
  static const String _serverIP = '157.230.34.248';

  /// Base URL for the backend API
  static String get baseUrl {
    return 'http://$_serverIP:3000';
  }

  /// API endpoints
  static const String presignedUrl = '/api/uploads/presigned-url';
  static const String batchPresignedUrls = '/api/uploads/batch-presigned-urls';
  static const String posts = '/api/posts';

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);

  /// Upload timeout (longer for large files)
  static const Duration uploadTimeout = Duration(minutes: 5);
}
