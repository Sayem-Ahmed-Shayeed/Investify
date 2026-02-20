import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/services/user_service.dart';

import '../model/chat_model.dart';

class ChatController extends GetxController {
  final conversations = <ChatConversation>[].obs;
  final currentMessages = <ChatMessage>[].obs;
  final messageText = ''.obs;
  final isLoading = false.obs;

  final _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Generates a collision-safe room ID by sorting the two UIDs
  static String buildRoomId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    super.onClose();
  }

  // ─── Conversations ───────────────────────────────────────────────────────────

  Future<void> loadConversations() async {
    if (_currentUid.isEmpty) return;
    isLoading.value = true;
    try {
      // Firestore doesn't support OR on different fields in one query,
      // so we run two queries and merge the results.
      final asSender = await _db
          .collection('chat_rooms')
          .where('senderUid', isEqualTo: _currentUid)
          .get();
      final asReceiver = await _db
          .collection('chat_rooms')
          .where('receiverUid', isEqualTo: _currentUid)
          .get();

      final docs = {...asSender.docs, ...asReceiver.docs}.toList();

      final List<ChatConversation> loaded = [];
      for (final doc in docs) {
        final data = doc.data();
        final isCurrentSender = data['senderUid'] == _currentUid;
        final otherId = isCurrentSender
            ? data['receiverUid'] as String
            : data['senderUid'] as String;
        final otherName = isCurrentSender
            ? (data['receiverName'] as String? ?? 'Unknown')
            : (data['senderName'] as String? ?? 'Unknown');

        final lastMsg = data['lastMessage'] as String? ?? '';
        final lastMsgTime = data['lastMessageTime'] != null
            ? (data['lastMessageTime'] as Timestamp).toDate()
            : DateTime.now();

        loaded.add(
          ChatConversation(
            id: doc.id,
            otherUser: ChatUser(id: otherId, name: otherName),
            messages: const [],
            lastMessageTime: lastMsgTime,
            lastMessage: lastMsg,
          ),
        );
      }

      // Sort by most recent
      loaded.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      conversations.assignAll(loaded);
    } catch (e) {
      debugPrint('loadConversations error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Room ────────────────────────────────────────────────────────────────────

  Future<void> createRoom({
    required String sender,
    required String receiver,
  }) async {
    final roomId = buildRoomId(sender, receiver);
    final userService = UserService();

    try {
      // Check if room already exists
      final existing = await _db.collection('chat_rooms').doc(roomId).get();
      if (existing.exists) return;

      // Await both names before writing
      final senderName = await userService.getUserName(sender) ?? 'User';
      final receiverName = await userService.getUserName(receiver) ?? 'User';

      await _db.collection('chat_rooms').doc(roomId).set({
        'senderUid': sender,
        'receiverUid': receiver,
        'senderName': senderName,
        'receiverName': receiverName,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Chat room created: $roomId');
    } catch (e) {
      debugPrint('createRoom error: $e');
    }
  }

  // ─── Messages ────────────────────────────────────────────────────────────────

  /// Start listening to real-time messages for the given room
  void listenToMessages(String roomId) {
    _messagesSubscription?.cancel();
    currentMessages.clear();

    _messagesSubscription = _db
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
          final msgs = snapshot.docs.map((doc) {
            final data = doc.data();
            final senderId = data['senderId'] as String;
            return ChatMessage(
              id: doc.id,
              senderId: senderId,
              content: data['content'] as String? ?? '',
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isMe: senderId == _currentUid,
              isRead: data['isRead'] as bool? ?? false,
            );
          }).toList();
          currentMessages.assignAll(msgs);
        }, onError: (e) => debugPrint('messages stream error: $e'));
  }

  void updateMessageText(String value) {
    messageText.value = value;
  }

  Future<void> sendMessage(String roomId) async {
    final text = messageText.value.trim();
    if (text.isEmpty) return;

    messageText.value = '';

    try {
      final msgRef = _db
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .doc();

      await msgRef.set({
        'senderId': _currentUid,
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      await _db.collection('chat_rooms').doc(roomId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('sendMessage error: $e');
    }
  }
}
