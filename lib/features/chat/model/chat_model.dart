enum MessageStatus { sending, sent, read }

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final bool isRead;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.isRead = false,
    this.status = MessageStatus.sent,
  });

  // Add copyWith method for updating message status
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? isMe,
    bool? isRead,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
    );
  }
}

class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isVerified;
  final String? investorLevel;

  const ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isVerified = false,
    this.investorLevel,
  });
}

class ChatConversation {
  final String id;
  final ChatUser otherUser;
  final List<ChatMessage> messages;
  final DateTime lastMessageTime;
  final String lastMessage;
  final int unreadCount;

  const ChatConversation({
    required this.id,
    required this.otherUser,
    required this.messages,
    required this.lastMessageTime,
    required this.lastMessage,
    this.unreadCount = 0,
  });
}
