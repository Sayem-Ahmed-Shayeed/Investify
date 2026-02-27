import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/sizes/size.dart';
import '../../model/chat_model.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.showAvatar,
  });

  final ChatMessage message;
  final bool showAvatar;

  Widget _buildStatusIndicator(MessageStatus status, ThemeData theme) {
    switch (status) {
      case MessageStatus.sending:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoActivityIndicator(radius: 6, animating: true),
            SizedBox(width: MySizes.spaceBetweenItem),
            Text(
              'Sending...',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        );
      case MessageStatus.sent:
      case MessageStatus.read:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: MySizes.small),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe && showAvatar)
            CircleAvatar(
              radius: MySizes.large,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.person,
                size: MySizes.iconSmall,
                color: theme.colorScheme.onSurface,
              ),
            )
          else if (!message.isMe)
            const SizedBox(width: MySizes.xxxl),
          if (!message.isMe) const SizedBox(width: MySizes.small),
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
                  padding: const EdgeInsets.all(MySizes.medium),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? theme.colorScheme.primary
                        : (isDark
                              ? theme.colorScheme.surfaceContainerHigh
                              : theme.colorScheme.surfaceContainerHighest),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(MySizes.roundedBoxCorner),
                      topRight: const Radius.circular(MySizes.roundedBoxCorner),
                      bottomLeft: Radius.circular(
                        message.isMe
                            ? MySizes.roundedBoxCorner
                            : MySizes.spaceBetweenItem,
                      ),
                      bottomRight: Radius.circular(
                        message.isMe
                            ? MySizes.spaceBetweenItem
                            : MySizes.roundedBoxCorner,
                      ),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: message.isMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: MySizes.spaceBetweenItem),
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
                    if (message.isMe) ...[
                      const SizedBox(width: MySizes.spaceBetweenItem),
                      _buildStatusIndicator(message.status, theme),
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
}
