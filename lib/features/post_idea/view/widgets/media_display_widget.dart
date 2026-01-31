import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../model/media_model.dart';

/// Widget to display a single media item (image or video)
class MediaItemWidget extends StatefulWidget {
  final MediaItem media;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const MediaItemWidget({
    super.key,
    required this.media,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<MediaItemWidget> createState() => _MediaItemWidgetState();
}

class _MediaItemWidgetState extends State<MediaItemWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.media.type == 'video') {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.media.url),
    );
    await _videoController!.initialize();
    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content;

    if (widget.media.type == 'video') {
      content = _buildVideoWidget(isDark);
    } else {
      content = _buildImageWidget(isDark);
    }

    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: content);
    }

    return content;
  }

  Widget _buildImageWidget(bool isDark) {
    return CachedNetworkImage(
      imageUrl: widget.media.url,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      placeholder: (context, url) => Container(
        height: widget.height,
        width: widget.width,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        height: widget.height,
        width: widget.width,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        child: Icon(
          Icons.broken_image,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildVideoWidget(bool isDark) {
    if (!_isVideoInitialized) {
      return Container(
        height: widget.height,
        width: widget.width,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: widget.height,
          width: widget.width,
          child: FittedBox(
            fit: widget.fit,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
        // Play/Pause button overlay
        GestureDetector(
          onTap: () {
            setState(() {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
              } else {
                _videoController!.play();
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              _videoController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget to display a gallery of media items
class MediaGalleryWidget extends StatelessWidget {
  final List<MediaItem> media;
  final double height;
  final double spacing;
  final BorderRadius borderRadius;
  final Function(int)? onMediaTap;

  const MediaGalleryWidget({
    super.key,
    required this.media,
    this.height = 200,
    this.spacing = 4,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();

    if (media.length == 1) {
      return GestureDetector(
        onTap: () => onMediaTap?.call(0),
        child: MediaItemWidget(
          media: media[0],
          height: height,
          width: double.infinity,
          borderRadius: borderRadius,
        ),
      );
    }

    if (media.length == 2) {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onMediaTap?.call(0),
              child: MediaItemWidget(
                media: media[0],
                height: height,
                borderRadius: BorderRadius.only(
                  topLeft: borderRadius.topLeft,
                  bottomLeft: borderRadius.bottomLeft,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: GestureDetector(
              onTap: () => onMediaTap?.call(1),
              child: MediaItemWidget(
                media: media[1],
                height: height,
                borderRadius: BorderRadius.only(
                  topRight: borderRadius.topRight,
                  bottomRight: borderRadius.bottomRight,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 3+ images: first large, rest in column
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => onMediaTap?.call(0),
            child: MediaItemWidget(
              media: media[0],
              height: height,
              borderRadius: BorderRadius.only(
                topLeft: borderRadius.topLeft,
                bottomLeft: borderRadius.bottomLeft,
              ),
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => onMediaTap?.call(1),
                child: MediaItemWidget(
                  media: media[1],
                  height: (height - spacing) / 2,
                  borderRadius: BorderRadius.only(
                    topRight: borderRadius.topRight,
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => onMediaTap?.call(2),
                    child: MediaItemWidget(
                      media: media[2],
                      height: (height - spacing) / 2,
                      borderRadius: BorderRadius.only(
                        bottomRight: borderRadius.bottomRight,
                      ),
                    ),
                  ),
                  if (media.length > 3)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => onMediaTap?.call(2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.only(
                              bottomRight: borderRadius.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '+${media.length - 3}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
