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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  child: Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: message.isMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
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
}
