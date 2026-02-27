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
