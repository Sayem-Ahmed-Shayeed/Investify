import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/services/user_service.dart';
import 'package:investify/features/chat/view/widgets/chatInput.dart';
import 'package:investify/features/chat/view/widgets/chat_bubble.dart';
import 'package:investify/services/firestore_service.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/widgets/role_badge.dart';

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
    _chatController.setCurrentRoom(receiverUid: widget.receiverUid);
    _chatController.listenToMessages(widget.roomID);
    _loadReceiver();

    // Auto-scroll to bottom when screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatController.scrollToBottom();
    });
  }

  Future<void> _loadReceiver() async {
    final data = await UserService().getUserById(widget.receiverUid);
    final isInvestor = await FirestoreService().isUserInvestor(widget.receiverUid);
    if (data != null && mounted) {
      setState(() {
        _receiver = ChatUser(
          id: widget.receiverUid,
          name: data['name'] as String? ?? 'Unknown',
          avatarUrl: data['profileImageUrl'] as String?,
          isInvestor: isInvestor,
          isVerified: true,
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
          size: MySizes.xxxl,
        ),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: MySizes.xl,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage: receiver?.avatarUrl != null
                ? NetworkImage(receiver!.avatarUrl!)
                : null,
            child: receiver?.avatarUrl == null
                ? Icon(
                    Icons.person,
                    color: theme.colorScheme.onSurface,
                    size: MySizes.xl,
                  )
                : null,
          ),
          const SizedBox(width: MySizes.medium),
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
                    const SizedBox(width: MySizes.spaceBetweenItem),
                    RoleBadge(
                      isInvestor: receiver?.isInvestor ?? false,
                      size: MySizes.iconSmall,
                    ),
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
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: MySizes.containerPadding,
        vertical: MySizes.medium,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(message: message, showAvatar: !message.isMe);
      },
    );
  }
}
