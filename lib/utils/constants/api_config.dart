/// API configuration for connecting to the backend
/// The base URL should be configured based on environment
class ApiConfig {
  /// Base URL for the backend API
  static const String baseUrl = 'https://api.imnawshad.me';

  /// API endpoints
  static const String presignedUrl = '/api/uploads/presigned-url';
  static const String batchPresignedUrls = '/api/uploads/batch-presigned-urls';
  static const String posts = '/api/posts';
  static const String users = '/api/users';
  static const String sandboxSubmit = '/api/sandbox/submit';
  static const String sandboxStatus = '/api/sandbox/status';

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);

  /// Upload timeout (longer for large files)
  static const Duration uploadTimeout = Duration(minutes: 5);
}
