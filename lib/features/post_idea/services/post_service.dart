import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../utils/constants/api_config.dart';
import '../model/post_idea_model.dart';
import 'media_upload_service.dart';

/// Service for managing posts via the backend API
class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  /// Get the current user's Firebase ID token for authentication
  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// Get authenticated headers for API requests
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Create a new post
  Future<PostIdeaModel> createPost({
    required String caption,
    required List<UploadedMedia> media,
    required bool isDraft,
    List<String>? tags,
  }) async {
    final headers = await _getAuthHeaders();

    final body = {
      'caption': caption,
      'media': media.map((m) => m.toJson()).toList(),
      'status': isDraft ? 'draft' : 'published',
      'tags': tags ?? [],
    };

    debugPrint('📤 Creating post...');

    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create post');
    }

    final data = jsonDecode(response.body);
    debugPrint('✅ Post created successfully');

    return PostIdeaModel.fromApiJson(data['data']);
  }

  /// Get posts with pagination
  Future<PostListResponse> getPosts({
    int page = 1,
    int limit = 20,
    String? status,
    String? userId,
  }) async {
    final headers = await _getAuthHeaders();

    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (userId != null) 'userId': userId,
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.posts}',
    ).replace(queryParameters: queryParams);

    final response = await http
        .get(uri, headers: headers)
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch posts');
    }

    final data = jsonDecode(response.body);

    return PostListResponse(
      posts: (data['data'] as List)
          .map((p) => PostIdeaModel.fromApiJson(p))
          .toList(),
      pagination: Pagination.fromJson(data['pagination']),
    );
  }

  /// Get a single post by ID
  Future<PostIdeaModel> getPost(String id) async {
    final headers = await _getAuthHeaders();

    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}/$id'),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch post');
    }

    final data = jsonDecode(response.body);
    return PostIdeaModel.fromApiJson(data['data']);
  }

  /// Update a post
  Future<PostIdeaModel> updatePost({
    required String id,
    String? caption,
    List<UploadedMedia>? media,
    String? status,
    List<String>? tags,
  }) async {
    final headers = await _getAuthHeaders();

    final body = <String, dynamic>{};
    if (caption != null) body['caption'] = caption;
    if (media != null) body['media'] = media.map((m) => m.toJson()).toList();
    if (status != null) body['status'] = status;
    if (tags != null) body['tags'] = tags;

    final response = await http
        .put(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}/$id'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update post');
    }

    final data = jsonDecode(response.body);
    return PostIdeaModel.fromApiJson(data['data']);
  }

  /// Delete a post
  Future<void> deletePost(String id) async {
    final headers = await _getAuthHeaders();

    final response = await http
        .delete(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}/$id'),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete post');
    }

    debugPrint('✅ Post deleted successfully');
  }

}

/// Response containing a list of posts with pagination
class PostListResponse {
  final List<PostIdeaModel> posts;
  final Pagination pagination;

  PostListResponse({required this.posts, required this.pagination});
}

/// Pagination info
class Pagination {
  final int page;
  final int limit;
  final int total;
  final int pages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      pages: json['pages'] as int,
    );
  }
}

/// Response from like toggle
class LikeResponse {
  final bool liked;
  final int likes;

  LikeResponse({required this.liked, required this.likes});
}
