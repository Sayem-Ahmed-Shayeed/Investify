import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../utils/sizes/size.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../controller/post_card_controller.dart';
import 'loading_widget.dart';

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
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.controller.videoControllers.containsKey(widget.videoUrl)) {
      _videoController = widget.controller.videoControllers[widget.videoUrl];
      if (_videoController!.value.isInitialized) {
        setState(() {
          _isInitialized = true;
        });
        _videoController!.pause();
        _videoController!.setVolume(0);
        return;
      }
    }

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    widget.controller.videoControllers[widget.videoUrl] = _videoController!;

    try {
      await _videoController!.initialize();
      _videoController!.setVolume(0);
      _videoController!.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    if (_hasError) {
      return _buildErrorWidget(isDark);
    }

    if (!_isInitialized || _videoController == null) {
      return LoadingWidget();
    }

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
          // Mute indicator
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
