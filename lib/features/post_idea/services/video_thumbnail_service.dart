import 'package:flutter/foundation.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Service for generating video thumbnails
class VideoThumbnailService {
  static final VideoThumbnailService _instance =
      VideoThumbnailService._internal();

  factory VideoThumbnailService() => _instance;

  VideoThumbnailService._internal();

  /// Generate a thumbnail from a video file path (mobile only)
  /// Returns null if thumbnail generation fails or on web
  Future<Uint8List?> generateThumbnailFromFile(String videoPath) async {
    if (kIsWeb) {
      debugPrint('⚠️ Thumbnail generation not supported on web');
      return null;
    }

    try {
      debugPrint('📸 Generating thumbnail from: $videoPath');
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 480,
        quality: 75,
        timeMs: 1000, // Get frame at 1 second
      );

      if (thumbnail != null) {
        debugPrint('✅ Thumbnail generated: ${thumbnail.length} bytes');
      }
      return thumbnail;
    } catch (e) {
      debugPrint('❌ Error generating thumbnail: $e');
      return null;
    }
  }
}
