import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../auth/services/user_service.dart';
import '../../post_idea/model/media_model.dart';
import '../../post_idea/model/post_idea_model.dart';
import '../view/post_detail_page.dart';

class PostCardController extends GetxController {
  // Page index for media carousel
  final currentMediaIndex = 0.obs;
  final PageController pageController = PageController();

  // Video controllers map: url -> controller
  final videoControllers = <String, VideoPlayerController>{}.obs;
  final initializedVideos = <String, bool>{}.obs;

  // UI state
  final isSaved = false.obs;
  final isExpanded = false.obs;

  // User cache: userId -> user data
  final userCache = <String, Map<String, dynamic>>{}.obs;
  final isLoadingUser = <String, bool>{}.obs;

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
      if (item.type == 'video') {
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
      controller.setLooping(true);
      initializedVideos[url] = true;
    } catch (e) {
      debugPrint('Error initializing video: $e');
      initializedVideos[url] = false;
    }
  }

  void onPageChanged(int index) {
    currentMediaIndex.value = index;
  }

  /// Toggle saved/bookmark state
  void toggleSaved() {
    isSaved.value = !isSaved.value;
    // TODO: Implement actual save/bookmark logic (e.g., save to backend)
  }

  /// Toggle expanded description state
  void toggleExpanded() {
    isExpanded.value = !isExpanded.value;
  }

  /// Fetch user profile for a post from backend
  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    if (userId.isEmpty) return null;

    if (userCache.containsKey(userId)) {
      return userCache[userId];
    }

    if (isLoadingUser[userId] == true) {
      return null;
    }

    isLoadingUser[userId] = true;

    try {
      final userService = UserService();
      final userData = await userService.getUserById(userId);

      if (userData != null) {
        userCache[userId] = userData;
        return userData;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    } finally {
      isLoadingUser[userId] = false;
    }
  }

  /// Calculate match percentage based on tags
  int calculateMatchPercentage(List<String> postTags) {
    // TODO: Implement actual matching algorithm based on user interests
    // For now, return a random percentage between 85-98
    if (postTags.isEmpty) return 90;
    return 85 + (postTags.length % 14);
  }

  /// Handle connect button action
  void onConnect(PostIdeaModel post) {
    Get.snackbar(
      'Connection Request',
      'Connecting with this startup...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    // TODO: Implement actual connect logic
  }

  /// Navigate to post detail page
  void onSeeMore(PostIdeaModel post) {
    Get.to(
      () => const PostDetailPage(),
      arguments: post,
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
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
