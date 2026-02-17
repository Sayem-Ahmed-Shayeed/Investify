import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

/// Custom cache manager for video files
/// Handles caching, downloading, and checking cache status
class VideoCacheManager {
  static final VideoCacheManager _instance = VideoCacheManager._internal();

  factory VideoCacheManager() => _instance;

  VideoCacheManager._internal();

  // Custom cache manager with longer cache duration for videos
  static final CacheManager _cacheManager = CacheManager(
    Config(
      'video_cache',
      stalePeriod: const Duration(days: 30), // Keep videos for 30 days
      maxNrOfCacheObjects: 100, // Max 100 videos
    ),
  );

  /// Check if a video is already cached
  Future<bool> isVideoCached(String url) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(url);
      return fileInfo != null && fileInfo.file.existsSync();
    } catch (e) {
      debugPrint('⚠️ Error checking cache for $url: $e');
      return false;
    }
  }

  /// Get video controller with caching support
  /// Checks cache first, downloads if needed, then caches for future use
  Future<VideoPlayerController> getVideoController(String url) async {
    try {
      if (kIsWeb) {
        // Web doesn't support file:// URIs, use network directly
        debugPrint('🌐 Web: Using network URL for video');
        return VideoPlayerController.networkUrl(Uri.parse(url));
      }

      // Check if video is already cached
      final isCached = await isVideoCached(url);

      if (isCached) {
        // Load from cache
        final fileInfo = await _cacheManager.getFileFromCache(url);
        debugPrint('✅ Video loaded from cache: $url');
        return VideoPlayerController.file(fileInfo!.file);
      }

      // Download and cache the video
      debugPrint('📥 Downloading and caching video: $url');
      final file = await _cacheManager.getSingleFile(url);
      debugPrint('✅ Video downloaded and cached: $url');

      return VideoPlayerController.file(file);
    } catch (e) {
      debugPrint('⚠️ Cache failed, falling back to network: $e');
      // Fallback to network if caching fails
      return VideoPlayerController.networkUrl(Uri.parse(url));
    }
  }

  /// Clear all cached videos
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
      debugPrint('✅ Video cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  /// Remove a specific video from cache
  Future<void> removeFromCache(String url) async {
    try {
      await _cacheManager.removeFile(url);
      debugPrint('✅ Video removed from cache: $url');
    } catch (e) {
      debugPrint('❌ Error removing from cache: $e');
    }
  }
}
