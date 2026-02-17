import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../utils/sizes/size.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../controller/post_card_controller.dart';

/// Lazy video player — shows a thumbnail placeholder with a play button.
/// Video only loads when the user taps play, saving bandwidth and memory.
class PostCardVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final PostCardController controller;

  const PostCardVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.controller,
  });

  @override
  State<PostCardVideoPlayer> createState() => _PostCardVideoPlayerState();
}

class _PostCardVideoPlayerState extends State<PostCardVideoPlayer> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void dispose() {
    // Dispose the controller only if we own it (created on tap)
    _videoController?.pause();
    _videoController?.dispose();
    super.dispose();
  }

  /// Initialize video ONLY when user taps play
  Future<void> _initializeVideo() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    try {
      await _videoController!.initialize().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Video loading timed out');
        },
      );

      if (!mounted) {
        _videoController?.dispose();
        return;
      }

      _videoController!.setVolume(0);
      _videoController!.setLooping(true);
      _videoController!.play();

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
      _videoController?.dispose();
      _videoController = null;
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    // Error state — show retry
    if (_hasError) {
      return _buildErrorWidget(isDark);
    }

    // Loading state — user tapped play, video is buffering
    if (_isLoading && !_isInitialized) {
      return _buildLoadingWidget(isDark);
    }

    // Video ready — show the player
    if (_isInitialized && _videoController != null) {
      return _buildVideoPlayer(isDark);
    }

    // Default: thumbnail placeholder with play button (no download yet)
    return _buildThumbnailPlaceholder(isDark);
  }

  /// Placeholder shown before user taps play — zero network cost
  Widget _buildThumbnailPlaceholder(bool isDark) {
    return GestureDetector(
      onTap: _initializeVideo,
      child: Container(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE8EAF0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video icon background
            Icon(
              Icons.videocam_rounded,
              size: 64,
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.1,
              ),
            ),
            // Play button
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    .withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            // "Tap to play" label
            Positioned(
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Tap to play',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Loading spinner while video is buffering
  Widget _buildLoadingWidget(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE8EAF0),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 2.5),
            SizedBox(height: 12),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Active video player with controls
  Widget _buildVideoPlayer(bool isDark) {
    return GestureDetector(
      onTap: () {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),
          // Play/pause overlay
          if (!_videoController!.value.isPlaying)
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
          // Progress bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _videoController!,
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
          // Mute/unmute button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                final currentVolume = _videoController!.value.volume;
                _videoController!.setVolume(currentVolume > 0 ? 0 : 1);
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _videoController!.value.volume > 0
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color: Colors.white,
                  size: RomRomSizes.spaceBetweenElements,
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
                  _isLoading = false;
                });
                _initializeVideo();
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
