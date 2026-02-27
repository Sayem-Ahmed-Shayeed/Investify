import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/services/user_service.dart';
import '../../post_idea/model/post_idea_model.dart';

class PostDetailController extends GetxController {
  final PostIdeaModel post;

  PostDetailController(this.post);

  // State
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

  /// Toggle about section expansion
  void toggleAboutExpanded() {
    isAboutExpanded.value = !isAboutExpanded.value;
  }

  /// Handle page change in media carousel
  void onPageChanged(int index) {
    currentMediaIndex.value = index;
  }
}
