import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String _appId = 'cfdc4a9c-e3a1-4a1b-9d51-ae99f62e743f';
  static const String _restApiKey =
      'os_v2_app_z7oevhhduffbxhkrv2m7mltuh57lnx45dwsusx5saeglg6yc3fely4dng53izfa5dffvyjtp3ki4kjhli3ccwmxo7r3lhidxxkiqjjy';
  static const String _baseUrl = 'https://onesignal.com/api/v1/notifications';

  static Future<void> sendMessageNotification({
    required String receiverUid,
    required String senderName,
    required String message,
    required String roomId,
    required String senderUid,
  }) async {
    if (kIsWeb) {
      debugPrint('⚠️ Push notifications skipped on web platform');
      return;
    }

    try {
      debugPrint('📤 Sending notification to: $receiverUid');

      final body = jsonEncode({
        "app_id": _appId,
        "include_external_user_ids": [receiverUid],
        // Fixed: use external_user_ids
        "target_channel": "push",
        "headings": {"en": senderName},
        "contents": {
          "en": message.length > 200
              ? '${message.substring(0, 200)}...'
              : message,
        },
        "data": {
          "type": "chat_message",
          "roomId": roomId,
          "senderUid": senderUid,
        },
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $_restApiKey',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Notification sent: ${response.body}');
      } else {
        debugPrint(
          '❌ Notification failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('sendMessageNotification error: $e');
    }
  }
}
