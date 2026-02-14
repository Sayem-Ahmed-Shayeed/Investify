import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../post_idea/model/media_model.dart';
import '../../post_idea/model/post_idea_model.dart';

class PostCardController extends GetxController {
  // Page index for media carousel
  final currentMediaIndex = 0.obs;
  final PageController pageController = PageController();

  // Video controllers map: url -> controller
  final videoControllers = <String, VideoPlayerController>{}.obs;
  final initializedVideos = <String, bool>{}.obs;

  @override
  void onClose() {
    pageController.dispose();
    for (final controller in videoControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  /// Initialize video controllers for media items
  void initMedia(List<MediaItem> media) {
    for (final item in media) {
      if (item.type == FileType.video) {
        _initVideo(item.url);
      }
    }
  }

  Future<void> _initVideo(String url) async {
    if (videoControllers.containsKey(url)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    videoControllers[url] = controller;

    try {
      await controller.initialize();
      controller.setLooping(true); // Auto-loop videos in feed is common
      // controller.play(); // Auto-play? Maybe not for performance/noise
      initializedVideos[url] = true;
    } catch (e) {
      debugPrint('Error initializing video: $e');
      initializedVideos[url] = false;
    }
  }

  void onPageChanged(int index) {
    currentMediaIndex.value = index;
    // logic to play/pause videos based on visibility could go here
  }

  /// Share post
  void sharePost(PostIdeaModel post) {
    final text = post.content;
    final mediaUrl = post.media.isNotEmpty ? post.media.first.url : null;
    final shareText = mediaUrl != null ? '$text\n\n$mediaUrl' : text;
    Share.share(shareText);
  }

  /// Get video controller for a url
  VideoPlayerController? getVideoController(String url) {
    return videoControllers[url];
  }

  /// Check if video is initialized
  bool isVideoInitialized(String url) {
    return initializedVideos[url] ?? false;
  }
}
