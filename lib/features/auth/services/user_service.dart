import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../utils/constants/api_config.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal();

  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

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

  Future<void> createUser({
    required String name,
    String? email,
    int? age,
    String? nidCardUrl,
  }) async {
    final headers = await _getAuthHeaders();

    final body = {
      'name': name,
      if (email != null) 'email': email,
      if (age != null) 'age': age,
      if (nidCardUrl != null) 'nidCardUrl': nidCardUrl,
    };

    debugPrint('📤 Creating user profile...');

    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create user');
    }

    debugPrint('✅ User profile created');
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final headers = await _getAuthHeaders();

    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/me'),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch user');
    }

    final data = jsonDecode(response.body);
    return data['data'];
  }

  Future<void> updateUser({
    String? name,
    int? age,
    String? bio,
    String? profileImageUrl,
  }) async {
    final headers = await _getAuthHeaders();

    final body = {
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (bio != null) 'bio': bio,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };

    final response = await http
        .put(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/me'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update user');
    }

    debugPrint('✅ User profile updated');
  }

  Future<String?> getUserName(String userId) async {
    try {
      final user = await getUserById(userId);
      return user?['name'] as String?;
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      return null;
    }
  }

  /// Get user by ID (for viewing other users' profiles)
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    if (userId.isEmpty) return null;

    final headers = await _getAuthHeaders();

    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/$userId'),
          headers: headers,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch user');
    }

    final data = jsonDecode(response.body);
    return data['data'];
  }
}
