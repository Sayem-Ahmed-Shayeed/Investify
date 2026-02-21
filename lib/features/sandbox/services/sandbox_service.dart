import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../utils/constants/api_config.dart';

/// Service for submitting sandbox content to the backend for n8n review
class SandboxService {
  static final SandboxService _instance = SandboxService._internal();
  factory SandboxService() => _instance;
  SandboxService._internal();

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

  /// Submit sandbox content for AI review via n8n webhook
  Future<String> submitForReview({
    required String caption,
    required List<Map<String, dynamic>> media,
  }) async {
    final headers = await _getAuthHeaders();

    final body = {'caption': caption, 'media': media};

    debugPrint('📤 Submitting sandbox content for review...');

    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sandboxSubmit}'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to submit for review');
    }

    final data = jsonDecode(response.body);
    debugPrint('✅ Sandbox content submitted for review');

    return data['message'] as String;
  }
}
