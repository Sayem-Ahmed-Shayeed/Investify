import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/controller/home_feed_controller.dart';
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

  /// Delete a post with confirmation dialog
  void deletePost(String postId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _postService.deletePost(postId);
                posts.removeWhere((p) => p.id == postId);
                // Also update the home feed
                if (Get.isRegistered<HomeFeedController>()) {
                  Get.find<HomeFeedController>().posts.removeWhere(
                    (p) => p.id == postId,
                  );
                }
                Get.snackbar(
                  'Deleted',
                  'Post deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade900,
                  margin: const EdgeInsets.all(16),
                );
              } catch (e) {
                debugPrint('❌ Error deleting post: $e');
                Get.snackbar(
                  'Error',
                  'Failed to delete post',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade900,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  /// Edit a post's caption via a dialog
  void editPost(PostIdeaModel post) {
    final editController = TextEditingController(text: post.content);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Caption'),
        content: TextField(
          controller: editController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Edit your caption...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newCaption = editController.text.trim();
              if (newCaption.isEmpty) return;
              if (newCaption == post.content) {
                Get.back();
                return;
              }

              Get.back();
              try {
                await _postService.updatePost(
                  id: post.id!,
                  caption: newCaption,
                );

                // Update locally
                final index = posts.indexWhere((p) => p.id == post.id);
                if (index != -1) {
                  posts[index] = posts[index].copyWith(content: newCaption);
                }
                // Also update the home feed
                if (Get.isRegistered<HomeFeedController>()) {
                  final feedController = Get.find<HomeFeedController>();
                  final feedIndex = feedController.posts.indexWhere(
                    (p) => p.id == post.id,
                  );
                  if (feedIndex != -1) {
                    feedController.posts[feedIndex] = feedController
                        .posts[feedIndex]
                        .copyWith(content: newCaption);
                  }
                }

                Get.snackbar(
                  'Updated',
                  'Caption updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade900,
                  margin: const EdgeInsets.all(16),
                );
              } catch (e) {
                debugPrint('❌ Error updating post: $e');
                Get.snackbar(
                  'Error',
                  'Failed to update post',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade900,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
