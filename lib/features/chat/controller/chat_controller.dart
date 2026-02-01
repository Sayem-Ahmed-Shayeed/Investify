import 'package:get/get.dart';

import '../model/chat_model.dart';

class ChatController extends GetxController {
  final conversations = <ChatConversation>[].obs;
  final currentMessages = <ChatMessage>[].obs;
  final messageText = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyConversations();
  }

  void _loadDummyConversations() {
    final dummyUser = ChatUser(
      id: '1',
      name: 'Jonathan V.',
      avatarUrl: null,
      isVerified: true,
      investorLevel: 'Tier 1',
    );

    final dummyMessages = [
      ChatMessage(
        id: '1',
        senderId: '1',
        content: "Hi, I'm interested in leading your seed round. Can we expedite the process?",
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        isMe: false,
        isRead: true,
      ),
      ChatMessage(
        id: '2',
        senderId: '1',
        content: "Please send the initial deposit via",
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        isMe: false,
        isRead: true,
        hasHighlightedText: true,
        highlightedText: 'Wire Transfer',
      ),
      ChatMessage(
        id: '3',
        senderId: 'me',
        content: "I can't do that. Let's stick to the VentureConnect escrow system.",
        timestamp: DateTime.now(),
        isMe: true,
        isRead: true,
      ),
    ];

    conversations.value = [
      ChatConversation(
        id: '1',
        otherUser: dummyUser,
        messages: dummyMessages,
        lastMessageTime: DateTime.now(),
        lastMessage: "I can't do that. Let's stick to the VentureConnect escrow system.",
        unreadCount: 0,
      ),
    ];
  }

  void loadConversation(String conversationId) {
    final conversation = conversations.firstWhereOrNull((c) => c.id == conversationId);
    if (conversation != null) {
      currentMessages.value = conversation.messages;
    }
  }

  void updateMessageText(String value) {
    messageText.value = value;
  }

  void sendMessage() {
    if (messageText.value.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      content: messageText.value.trim(),
      timestamp: DateTime.now(),
      isMe: true,
      isRead: false,
    );

    currentMessages.add(newMessage);
    messageText.value = '';
  }

  ChatUser? getCurrentChatUser(String conversationId) {
    final conversation = conversations.firstWhereOrNull((c) => c.id == conversationId);
    return conversation?.otherUser;
  }
}
