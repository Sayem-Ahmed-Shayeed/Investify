import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/services/user_service.dart';
import 'package:investify/services/notification_services.dart';

import '../model/chat_model.dart';

class ChatController extends GetxController {
  final conversations = <ChatConversation>[].obs;
  final currentMessages = <ChatMessage>[].obs;
  final messageText = ''.obs;
  final isLoading = false.obs;
  final isSending = false.obs;

  final _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  StreamSubscription<QuerySnapshot>? _senderConversationsSub;
  StreamSubscription<QuerySnapshot>? _receiverConversationsSub;

  final ScrollController scrollController = ScrollController();

  String _currentRoomReceiverUid = '';

  // Simple variable to track which message is currently sending
  String _sendingMessageId = '';

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

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
    _senderConversationsSub?.cancel();
    _receiverConversationsSub?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  // ─── Conversations ───────────────────────────────────────────────────────────

  void loadConversations() {
    if (_currentUid.isEmpty) return;
    isLoading.value = true;

    // Cancel previous subscriptions
    _senderConversationsSub?.cancel();
    _receiverConversationsSub?.cancel();

    // Track raw docs from both queries
    List<QueryDocumentSnapshot<Map<String, dynamic>>> senderDocs = [];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> receiverDocs = [];

    void mergeAndUpdate() {
      final docsMap = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
      for (final doc in senderDocs) {
        docsMap[doc.id] = doc;
      }
      for (final doc in receiverDocs) {
        docsMap[doc.id] = doc;
      }

      final List<ChatConversation> loaded = [];
      for (final doc in docsMap.values) {
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

      loaded.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      conversations.assignAll(loaded);
      isLoading.value = false;
    }

    _senderConversationsSub = _db
        .collection('chat_rooms')
        .where('senderUid', isEqualTo: _currentUid)
        .snapshots()
        .listen(
          (snapshot) {
            senderDocs = snapshot.docs;
            mergeAndUpdate();
          },
          onError: (e) {
            debugPrint('loadConversations sender error: $e');
            isLoading.value = false;
          },
        );

    _receiverConversationsSub = _db
        .collection('chat_rooms')
        .where('receiverUid', isEqualTo: _currentUid)
        .snapshots()
        .listen(
          (snapshot) {
            receiverDocs = snapshot.docs;
            mergeAndUpdate();
          },
          onError: (e) {
            debugPrint('loadConversations receiver error: $e');
            isLoading.value = false;
          },
        );
  }

  // ─── Room ────────────────────────────────────────────────────────────────────

  Future<void> createRoom({
    required String sender,
    required String receiver,
  }) async {
    if (sender == receiver) {
      debugPrint('⚠️ Cannot create chat room with yourself');
      return;
    }
    final roomId = buildRoomId(sender, receiver);
    final userService = UserService();

    try {
      final existing = await _db.collection('chat_rooms').doc(roomId).get();
      if (existing.exists) return;

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

  void setCurrentRoom({required String receiverUid}) {
    _currentRoomReceiverUid = receiverUid;
  }

  /// Listen to messages - simplified without seen status tracking
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
            final messageId = doc.id;

            return ChatMessage(
              id: messageId,
              senderId: senderId,
              content: data['content'] as String? ?? '',
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isMe: senderId == _currentUid,
              isRead: false,
              status: MessageStatus.sent,
            );
          }).toList();

          if (_sendingMessageId.isNotEmpty) {
            final alreadyInFirestore = msgs.any(
              (m) => m.id == _sendingMessageId,
            );
            if (alreadyInFirestore) {
              _sendingMessageId = '';
            } else {
              final sendingMsg = currentMessages.firstWhereOrNull(
                (m) => m.id == _sendingMessageId,
              );
              if (sendingMsg != null) {
                msgs.add(sendingMsg);
              }
            }
          }

          currentMessages.value = msgs;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToBottom();
          });
        }, onError: (e) => debugPrint('messages stream error: $e'));
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void updateMessageText(String value) {
    messageText.value = value;
  }

  Future<void> sendMessage(String roomId) async {
    final text = messageText.value.trim();
    if (text.isEmpty || isSending.value) return;

    messageText.value = '';
    isSending.value = true;

    try {
      final msgRef = _db
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .doc();

      _sendingMessageId = msgRef.id;

      // Add optimistic message with "sending" status
      final optimisticMessage = ChatMessage(
        id: msgRef.id,
        senderId: _currentUid,
        content: text,
        timestamp: DateTime.now(),
        isMe: true,
        isRead: false,
        status: MessageStatus.sending,
      );

      currentMessages.value = [...currentMessages, optimisticMessage];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });

      // Write to Firestore (no isRead field)
      await msgRef.set({
        'senderId': _currentUid,
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _db.collection('chat_rooms').doc(roomId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // Clear the sending ID - the listener will update the message to "sent"
      _sendingMessageId = '';

      debugPrint('✅ Message sent successfully');

      // Send push notification
      if (_currentRoomReceiverUid.isNotEmpty) {
        final senderName =
            await UserService().getUserName(_currentUid) ?? 'Someone';
        await NotificationService.sendMessageNotification(
          receiverUid: _currentRoomReceiverUid,
          senderName: senderName,
          message: text,
          roomId: roomId,
          senderUid: _currentUid,
        );
      }
    } catch (e) {
      debugPrint('❌ sendMessage error: $e');
      _sendingMessageId = '';
      // Remove the failed message
      currentMessages.value = currentMessages
          .where((m) => m.id != _sendingMessageId)
          .toList();
      Get.snackbar('Error', 'Failed to send message. Try again.');
    } finally {
      isSending.value = false;
    }
  }
}
