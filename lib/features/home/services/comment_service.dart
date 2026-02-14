import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../../utils/constants/api_config.dart';
import '../model/comment_model.dart';

/// Service for comment-related API calls
class CommentService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> _getAuthHeaders() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final token = await user.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch comments for a post (paginated)
  Future<CommentListResponse> getComments({
    required String postId,
    int page = 1,
    int limit = 20,
  }) async {
    final headers = await _getAuthHeaders();
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}/$postId/comments')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers).timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch comments: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final comments = (data['data'] as List)
        .map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
        .toList();

    return CommentListResponse(
      comments: comments,
      total: data['pagination']?['total'] as int? ?? comments.length,
      hasMore: (data['pagination']?['page'] as int? ?? 1) <
          (data['pagination']?['pages'] as int? ?? 1),
    );
  }

  /// Add a comment to a post
  Future<AddCommentResponse> addComment({
    required String postId,
    required String content,
  }) async {
    final headers = await _getAuthHeaders();
    final body = jsonEncode({'content': content});

    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}/$postId/comments'),
          headers: headers,
          body: body,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 201) {
      throw Exception('Failed to add comment: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return AddCommentResponse(
      comment: CommentModel.fromJson(data['data'] as Map<String, dynamic>),
      commentCount: data['commentCount'] as int? ?? 0,
    );
  }

  /// Delete a comment
  Future<int> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final headers = await _getAuthHeaders();

    final response = await http
        .delete(
          Uri.parse(
              '${ApiConfig.baseUrl}${ApiConfig.posts}/$postId/comments/$commentId'),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return data['commentCount'] as int? ?? 0;
  }
}

class CommentListResponse {
  final List<CommentModel> comments;
  final int total;
  final bool hasMore;

  CommentListResponse({
    required this.comments,
    required this.total,
    required this.hasMore,
  });
}

class AddCommentResponse {
  final CommentModel comment;
  final int commentCount;

  AddCommentResponse({
    required this.comment,
    required this.commentCount,
  });
}
