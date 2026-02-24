import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../post_idea/model/post_idea_model.dart';
import '../../post_idea/services/post_service.dart';

class HomeFeedController extends GetxController {
  final _postService = PostService();

  // Posts list
  final posts = <PostIdeaModel>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMorePages = true.obs;
  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  /// Fetch initial posts
  Future<void> fetchPosts() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await _postService.getPosts(
        page: 1,
        limit: _pageSize,
        status: 'published',
      );

      posts.value = response.posts;
      currentPage.value = 1;
      hasMorePages.value = response.pagination.page < response.pagination.pages;

      debugPrint('✅ Fetched ${response.posts.length} posts');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      debugPrint('❌ Error fetching posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more posts (pagination)
  Future<void> loadMorePosts() async {
    if (isLoadingMore.value || !hasMorePages.value) return;

    isLoadingMore.value = true;

    try {
      final nextPage = currentPage.value + 1;
      final response = await _postService.getPosts(
        page: nextPage,
        limit: _pageSize,
        status: 'published',
      );

      posts.addAll(response.posts);
      currentPage.value = nextPage;
      hasMorePages.value = response.pagination.page < response.pagination.pages;

      debugPrint('✅ Loaded ${response.posts.length} more posts');
    } catch (e) {
      debugPrint('❌ Error loading more posts: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Refresh posts (pull-to-refresh)
  Future<void> refreshPosts() async {
    currentPage.value = 1;
    hasMorePages.value = true;
    await fetchPosts();
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId) async {
    try {
      final response = await _postService.toggleLike(postId);

      // Update the post in the list
      final index = posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = posts[index];
        posts[index] = post.copyWith(likes: response.likes);
      }
    } catch (e) {
      debugPrint('❌ Error toggling like: $e');
    }
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
              Get.back(); // Close dialog
              try {
                await _postService.deletePost(postId);
                posts.removeWhere((p) => p.id == postId);
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

              Get.back(); // Close dialog
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
