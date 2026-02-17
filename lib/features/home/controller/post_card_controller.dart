import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/services/user_service.dart';
import '../../post_idea/model/post_idea_model.dart';
import '../view/post_detail_page.dart';

class PostCardController extends GetxController {
  // Page index for media carousel
  final currentMediaIndex = 0.obs;
  final PageController pageController = PageController();

  // UI state
  final isSaved = false.obs;
  final isExpanded = false.obs;

  // User cache: userId -> user data
  final userCache = <String, Map<String, dynamic>>{}.obs;
  final isLoadingUser = <String, bool>{}.obs;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
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
}
