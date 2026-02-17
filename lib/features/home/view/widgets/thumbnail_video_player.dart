import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../utils/cache/video_cache_manager.dart';
import '../../../../utils/theme/app_colors.dart';

/// Click-to-play video player with thumbnail and caching
/// Shows thumbnail first, downloads video only when play button clicked
class ThumbnailVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool looping;
  final bool showControls;

  const ThumbnailVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.looping = true,
    this.showControls = true,
  });

  @override
  State<ThumbnailVideoPlayer> createState() => _ThumbnailVideoPlayerState();
}

class _ThumbnailVideoPlayerState extends State<ThumbnailVideoPlayer> {
  final _cacheManager = VideoCacheManager();
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Initialize video only when user clicks play
  Future<void> _initializeAndPlayVideo() async {
    if (_isInitializing || _isInitialized) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      // Get video controller with caching
      _controller = await _cacheManager.getVideoController(widget.videoUrl);
      await _controller!.initialize();

      if (mounted) {
        _controller!.setLooping(widget.looping);
        _controller!.setVolume(0); // Start muted
        _controller!.play();

        setState(() {
          _isInitialized = true;
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitializing = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized) {
      // First time - initialize and play
      _initializeAndPlayVideo();
      return;
    }

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      final currentVolume = _controller!.value.volume;
      _controller!.setVolume(currentVolume > 0 ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    if (_hasError) {
      return _buildErrorWidget(isDark);
    }

    if (!_isInitialized) {
      return _buildThumbnailWithPlayButton(isDark);
    }

    return _buildVideoPlayer(isDark);
  }

  Widget _buildThumbnailWithPlayButton(bool isDark) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thumbnail (cached)
          if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: widget.thumbnailUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => _buildPlaceholder(isDark),
              errorWidget: (_, __, ___) => _buildPlaceholder(isDark),
            )
          else
            _buildPlaceholder(isDark),

          // Play button or loading indicator
          if (_isInitializing)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      child: Center(
        child: Icon(
          Icons.videocam_outlined,
          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(bool isDark) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),

          // Play/Pause overlay
          if (!_controller!.value.isPlaying)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),

          // Progress indicator
          if (widget.showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                  bufferedColor: Colors.white.withValues(alpha: 0.3),
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),

          // Mute button
          if (widget.showControls)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _toggleMute,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _controller!.value.volume > 0
                        ? Icons.volume_up
                        : Icons.volume_off,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Container(
      color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load video',
              style: TextStyle(
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                  _isInitializing = false;
                });
                _initializeAndPlayVideo();
              },
              child: Text(
                'Retry',
                style: TextStyle(
                  color: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
