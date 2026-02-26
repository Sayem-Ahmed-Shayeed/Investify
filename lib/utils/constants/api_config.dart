class ApiConfig {
  static const String baseUrl = 'https://api.imnawshad.me';

  static const String presignedUrl = '/api/uploads/presigned-url';
  static const String batchPresignedUrls = '/api/uploads/batch-presigned-urls';
  static const String posts = '/api/posts';
  static const String users = '/api/users';
  static const String sandboxSubmit = '/api/sandbox/submit';
  static const String sandboxStatus = '/api/sandbox/status';
  static const String enhance = '/api/enhance';

  static const Duration timeout = Duration(seconds: 30);

  static const Duration uploadTimeout = Duration(minutes: 5);
}
