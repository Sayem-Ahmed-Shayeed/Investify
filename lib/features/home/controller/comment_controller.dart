import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/comment_model.dart';
import '../services/comment_service.dart';

class CommentController extends GetxController {
  final CommentService _commentService = CommentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable state
  final comments = <CommentModel>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;

  // Pagination
  int _page = 1;
  static const int _limit = 20;

  // Current Post ID
  String? postId;

  // Initialize with postId
  void init(String id) {
    postId = id;
    fetchComments();
  }

  /// Check if a comment belongs to current user
  bool isMyComment(CommentModel comment) {
    final user = _auth.currentUser;
    return user != null && comment.userId == user.uid;
  }

  /// Initial fetch
  Future<void> fetchComments() async {
    if (postId == null) return;
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _page = 1;

      final response = await _commentService.getComments(
        postId: postId!,
        page: _page,
        limit: _limit,
      );

      comments.value = response.comments;
      hasMore.value = response.hasMore;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error fetching comments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more (pagination)
  Future<void> loadMoreComments() async {
    if (postId == null || isLoading.value || !hasMore.value) return;

    try {
      final nextPage = _page + 1;
      final response = await _commentService.getComments(
        postId: postId!,
        page: nextPage,
        limit: _limit,
      );

      if (response.comments.isNotEmpty) {
        comments.addAll(response.comments);
        _page = nextPage;
      }
      hasMore.value = response.hasMore;
    } catch (e) {
      debugPrint('Error loading more comments: $e');
    }
  }

  /// Add comment
  Future<int?> addComment(String content) async {
    if (postId == null || content.trim().isEmpty) return null;

    try {
      isSending.value = true;
      final response = await _commentService.addComment(
        postId: postId!,
        content: content,
      );

      // Add to top of list
      comments.insert(0, response.comment);

      Get.snackbar(
        'Success',
        'Comment added',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
      );

      return response.commentCount;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add comment',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return null;
    } finally {
      isSending.value = false;
    }
  }

  /// Delete comment
  Future<int?> deleteComment(String commentId) async {
    if (postId == null) return null;

    try {
      final newCount = await _commentService.deleteComment(
        postId: postId!,
        commentId: commentId,
      );

      comments.removeWhere((c) => c.id == commentId);
      
      Get.snackbar(
        'Success',
        'Comment deleted',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
      );

      return newCount;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete comment',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return null;
    }
  }
}
