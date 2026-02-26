import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/sizes/size.dart';
import '../../controller/chat_controller.dart';

class ChatInput extends StatefulWidget {
  final String roomID;

  const ChatInput({super.key, required this.roomID});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ChatController>();

    return Container(
      padding: const EdgeInsets.all(MySizes.containerPadding),
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
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(MySizes.xxl),
                ),
                child: TextField(
                  controller: _textController,
                  onChanged: controller.updateMessageText,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: MySizes.large,
                      vertical: MySizes.medium,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(width: MySizes.medium),
            Obx(() {
              final sending = controller.isSending.value;
              return GestureDetector(
                onTap: sending
                    ? null
                    : () {
                        controller.sendMessage(widget.roomID);
                        _textController.clear();
                      },
                child: Container(
                  padding: const EdgeInsets.all(MySizes.medium),
                  decoration: BoxDecoration(
                    color: sending
                        ? theme.colorScheme.primary.withValues(alpha: 0.6)
                        : theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: sending
                      ? SizedBox(
                          width: MySizes.iconMedium,
                          height: MySizes.iconMedium,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.send,
                          size: MySizes.iconMedium,
                          color: theme.brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
