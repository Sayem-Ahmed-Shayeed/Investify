import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../post_idea/model/post_idea_model.dart';
import '../../post_idea/services/post_service.dart';

/// Controller for fetching and displaying the current user's posts on their profile
class ProfileController extends GetxController {
  final _postService = PostService();

  // User's posts
  final posts = <PostIdeaModel>[].obs;

  // Loading states
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyPosts();
  }

  /// Get the current user's Firebase UID
  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  /// Fetch posts belonging to the current user
  Future<void> fetchMyPosts() async {
    final uid = _currentUid;
    if (uid == null) return;

    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await _postService.getPosts(
        page: 1,
        limit: 50,
        userId: uid,
      );

      posts.value = response.posts;
      debugPrint('✅ Fetched ${response.posts.length} user posts');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      debugPrint('❌ Error fetching user posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh posts (pull-to-refresh)
  Future<void> refreshMyPosts() async {
    await fetchMyPosts();
  }
}
