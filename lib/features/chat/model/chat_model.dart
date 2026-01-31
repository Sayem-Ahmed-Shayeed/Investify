class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final bool isRead;
  final bool hasHighlightedText;
  final String? highlightedText;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.isRead = false,
    this.hasHighlightedText = false,
    this.highlightedText,
  });
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

class ScamAlert {
  final String id;
  final String title;
  final String riskLevel;
  final String description;
  final String safetyTipsUrl;

  const ScamAlert({
    required this.id,
    required this.title,
    required this.riskLevel,
    required this.description,
    this.safetyTipsUrl = '',
  });
}
