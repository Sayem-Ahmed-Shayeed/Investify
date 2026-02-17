import 'package:flutter/material.dart';

import '../../controller/post_card_controller.dart';
import 'thumbnail_video_player.dart';

/// Video player for post cards - shows thumbnail, loads video on click
class PostCardVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final PostCardController controller;

  const PostCardVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ThumbnailVideoPlayer(
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      looping: true,
      showControls: true,
    );
  }
}
