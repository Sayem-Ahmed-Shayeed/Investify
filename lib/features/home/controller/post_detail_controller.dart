import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/services/user_service.dart';
import '../../post_idea/model/post_idea_model.dart';

class PostDetailController extends GetxController {
  final PostIdeaModel post;

  PostDetailController(this.post);

  // State
  final isSaved = false.obs;
  final isAboutExpanded = false.obs;
  final currentMediaIndex = 0.obs;

  // User data
  final userData = Rxn<Map<String, dynamic>>();
  final isLoadingUser = false.obs;

  // Media carousel
  final pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    _fetchUserProfile();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// Fetch user profile from backend
  Future<void> _fetchUserProfile() async {
    if (post.userId == null || post.userId!.isEmpty) return;

    isLoadingUser.value = true;

    try {
      final userService = UserService();
      final data = await userService.getUserById(post.userId!);

      if (data != null) {
        userData.value = data;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    } finally {
      isLoadingUser.value = false;
    }
  }

  /// Toggle saved/bookmark state
  void toggleSaved() {
    isSaved.value = !isSaved.value;
    // TODO: Implement actual save logic
  }

  /// Toggle about section expansion
  void toggleAboutExpanded() {
    isAboutExpanded.value = !isAboutExpanded.value;
  }

  /// Handle page change in media carousel
  void onPageChanged(int index) {
    currentMediaIndex.value = index;
  }

  /// Calculate match percentage
  int calculateMatchPercentage() {
    // TODO: Implement actual matching algorithm
    if (post.tags.isEmpty) return 90;
    return 85 + (post.tags.length % 14);
  }

  /// Handle share action
  void onShare() {
    Get.snackbar(
      'Share',
      'Sharing ${userData.value?['name'] ?? 'this startup'}...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    // TODO: Implement actual share functionality
  }

  /// Handle invest now action - navigate to messages tab
  void onInvestNow() {
    final userName = userData.value?['name'] ?? 'this startup';
    // TODO: Implement navigating to the chat page start chat make a room and start chatting
  }
}
