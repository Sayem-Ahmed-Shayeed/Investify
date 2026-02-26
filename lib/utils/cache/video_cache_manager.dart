import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

class VideoCacheManager {
  static final VideoCacheManager _instance = VideoCacheManager._internal();

  factory VideoCacheManager() => _instance;

  VideoCacheManager._internal();

  static final CacheManager _cacheManager = CacheManager(
    Config(
      'video_cache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 100,
    ),
  );

  Future<bool> isVideoCached(String url) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(url);
      return fileInfo != null && fileInfo.file.existsSync();
    } catch (e) {
      debugPrint('Error checking cache for $url: $e');
      return false;
    }
  }

  Future<VideoPlayerController> getVideoController(String url) async {
    try {
      if (kIsWeb) {
        return VideoPlayerController.networkUrl(Uri.parse(url));
      }
      final isCached = await isVideoCached(url);
      if (isCached) {
        final fileInfo = await _cacheManager.getFileFromCache(url);
        return VideoPlayerController.file(fileInfo!.file);
      }
      final file = await _cacheManager.getSingleFile(url);

      return VideoPlayerController.file(file);
    } catch (e) {
      return VideoPlayerController.networkUrl(Uri.parse(url));
    }
  }
}
