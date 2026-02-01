import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:investify/utils/sizes/size.dart';

import '../controller/chat_controller.dart';
import '../model/chat_model.dart';

class ChatDetailScreen extends StatelessWidget {
  final String conversationId;

  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ChatController>();
    controller.loadConversation(conversationId);
    final user = controller.getCurrentChatUser(conversationId);

    return Scaffold(
      appBar: _buildAppBar(context, theme, user),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => _buildMessagesList(context, theme, controller)),
          ),
          _buildMessageInput(context, theme, controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    ChatUser? user,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: theme.colorScheme.onSurface,
          size: RomRomSizes.xxxl,
        ),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: RomRomSizes.xl,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage: user?.avatarUrl != null
                ? NetworkImage(user!.avatarUrl!)
                : null,
            child: user?.avatarUrl == null
                ? Icon(
                    Icons.person,
                    color: theme.colorScheme.onSurface,
                    size: RomRomSizes.xl,
                  )
                : null,
          ),
          const SizedBox(width: RomRomSizes.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user?.name ?? 'Unknown',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (user?.isVerified == true) ...[
                      const SizedBox(width: RomRomSizes.spaceBetweenItem),
                      Icon(
                        Icons.verified,
                        size: RomRomSizes.iconSmall,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                if (user?.investorLevel != null)
                  Text(
                    'Investor Level: ${user!.investorLevel}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessagesList(
    BuildContext context,
    ThemeData theme,
    ChatController controller,
  ) {
    final messages = controller.currentMessages;
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: RomRomSizes.containerPadding,
        vertical: RomRomSizes.medium,
      ),
      itemCount: messages.length + 1, // +1 for date header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildDateHeader(theme, messages.first.timestamp);
        }
        final message = messages[index - 1];
        final showAvatar =
            !message.isMe &&
            (index == 1 ||
                messages[index - 2].isMe ||
                _isDifferentTime(
                  messages[index - 2].timestamp,
                  message.timestamp,
                ));
        return _buildMessageBubble(context, theme, message, showAvatar);
      },
    );
  }

  bool _isDifferentTime(DateTime a, DateTime b) {
    return a.difference(b).inMinutes.abs() > 2;
  }

  Widget _buildDateHeader(ThemeData theme, DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final timeStr = DateFormat('h:mm a').format(date);
    final headerText = isToday
        ? 'Today $timeStr'
        : DateFormat('MMM d, h:mm a').format(date);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: RomRomSizes.medium),
        padding: const EdgeInsets.symmetric(
          horizontal: RomRomSizes.medium,
          vertical: RomRomSizes.spaceBetweenItem,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RomRomSizes.xl),
        ),
        child: Text(
          headerText,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ThemeData theme,
    ChatMessage message,
    bool showAvatar,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: RomRomSizes.small),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe && showAvatar)
            CircleAvatar(
              radius: RomRomSizes.large,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.person,
                size: RomRomSizes.iconSmall,
                color: theme.colorScheme.onSurface,
              ),
            )
          else if (!message.isMe)
            const SizedBox(width: RomRomSizes.xxxl),
          if (!message.isMe) const SizedBox(width: RomRomSizes.small),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(RomRomSizes.medium),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? theme.colorScheme.primary
                        : (isDark
                              ? theme.colorScheme.surfaceContainerHigh
                              : theme.colorScheme.surfaceContainerHighest),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(
                        RomRomSizes.roundedBoxCorner,
                      ),
                      topRight: const Radius.circular(
                        RomRomSizes.roundedBoxCorner,
                      ),
                      bottomLeft: Radius.circular(
                        message.isMe
                            ? RomRomSizes.roundedBoxCorner
                            : RomRomSizes.spaceBetweenItem,
                      ),
                      bottomRight: Radius.circular(
                        message.isMe
                            ? RomRomSizes.spaceBetweenItem
                            : RomRomSizes.roundedBoxCorner,
                      ),
                    ),
                  ),
                  child: _buildMessageContent(theme, message),
                ),
                const SizedBox(height: RomRomSizes.spaceBetweenItem),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(message.timestamp),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    if (message.isMe && message.isRead) ...[
                      const SizedBox(width: RomRomSizes.spaceBetweenItem),
                      Icon(
                        Icons.done_all,
                        size: RomRomSizes.iconSmall,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme, ChatMessage message) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = message.isMe
        ? (isDark ? Colors.black : Colors.white)
        : theme.colorScheme.onSurface;

    if (message.hasHighlightedText && message.highlightedText != null) {
      return RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          children: [
            TextSpan(text: '${message.content} '),
            TextSpan(
              text: message.highlightedText,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: ' to this external account...'),
          ],
        ),
      );
    }

    return Text(
      message.content,
      style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    ThemeData theme,
    ChatController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(RomRomSizes.containerPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RomRomSizes.containerPadding,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(RomRomSizes.xxl),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: controller.updateMessageText,
                        decoration: InputDecoration(
                          hintText: 'Type a secure message...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: RomRomSizes.medium,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Icon(
                      Icons.lock_outline,
                      size: RomRomSizes.iconSmall,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: RomRomSizes.medium),
            Container(
              padding: const EdgeInsets.all(RomRomSizes.medium),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                size: RomRomSizes.iconMedium,
                color: theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
