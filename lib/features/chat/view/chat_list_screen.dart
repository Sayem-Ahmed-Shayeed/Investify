import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/widgets/role_badge.dart';

import '../controller/chat_controller.dart';
import '../model/chat_model.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ChatController>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(() {
              final conversations = controller.conversations;
              if (conversations.isEmpty) {
                return _buildEmptyState(theme);
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: MySizes.containerPadding,
                ),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  return _buildConversationTile(
                    context,
                    theme,
                    conversations[index],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: MySizes.containerPadding),
          Text(
            'No conversations yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: MySizes.small),
          Text(
            'Start connecting with investors',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    ThemeData theme,
    ChatConversation conversation,
  ) {
    final user = conversation.otherUser;
    final timeStr = _formatTime(conversation.lastMessageTime);

    return GestureDetector(
      onTap: () {
        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        Get.to(
          () => ChatDetailScreen(
            roomID: conversation.id,
            senderUid: currentUid,
            receiverUid: user.id,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: MySizes.medium),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: MySizes.xxl,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          color: theme.colorScheme.onSurface,
                          size: MySizes.xl,
                        )
                      : null,
                ),
                if (conversation.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        conversation.unreadCount.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: MySizes.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              user.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: MySizes.spaceBetweenItem),
                            RoleBadge(
                              isInvestor: user.isInvestor,
                              size: MySizes.iconSmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        timeStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MySizes.spaceBetweenItem),
                  Text(
                    conversation.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
