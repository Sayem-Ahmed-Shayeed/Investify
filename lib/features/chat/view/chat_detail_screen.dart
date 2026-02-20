import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:investify/features/auth/services/user_service.dart';
import 'package:investify/features/chat/view/widgets/chatInput.dart';
import 'package:investify/features/chat/view/widgets/chat_bubble.dart';
import 'package:investify/utils/sizes/size.dart';

import '../controller/chat_controller.dart';
import '../model/chat_model.dart';

class ChatDetailScreen extends StatefulWidget {
  final String roomID;
  final String senderUid;
  final String receiverUid;

  const ChatDetailScreen({
    super.key,
    required this.roomID,
    required this.senderUid,
    required this.receiverUid,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final ChatController _chatController;
  ChatUser? _receiver;

  @override
  void initState() {
    super.initState();
    _chatController = Get.find<ChatController>();
    _chatController.listenToMessages(widget.roomID);
    _loadReceiver();
  }

  Future<void> _loadReceiver() async {
    final data = await UserService().getUserById(widget.receiverUid);
    if (data != null && mounted) {
      setState(() {
        _receiver = ChatUser(
          id: widget.receiverUid,
          name: data['name'] as String? ?? 'Unknown',
          avatarUrl: data['profileImageUrl'] as String?,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => _buildMessagesList(context, theme, _chatController),
            ),
          ),
          ChatInput(roomID: widget.roomID),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    final receiver = _receiver;

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
            backgroundImage: receiver?.avatarUrl != null
                ? NetworkImage(receiver!.avatarUrl!)
                : null,
            child: receiver?.avatarUrl == null
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
                      receiver?.name ?? 'Loading...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (receiver?.isVerified == true) ...[
                      const SizedBox(width: RomRomSizes.spaceBetweenItem),
                      Icon(
                        Icons.verified,
                        size: RomRomSizes.iconSmall,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                if (receiver?.investorLevel != null)
                  Text(
                    'Investor Level: ${receiver!.investorLevel}',
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
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(message: message, showAvatar: !message.isMe);
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
}
