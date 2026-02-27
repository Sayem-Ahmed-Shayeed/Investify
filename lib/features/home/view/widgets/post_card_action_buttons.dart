import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/controller/auth_controller.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../../chat/controller/chat_controller.dart';
import '../../../chat/view/chat_detail_screen.dart';
import '../../../post_idea/model/post_idea_model.dart';
import '../../controller/post_card_controller.dart';

class PostCardActions extends StatelessWidget {
  final PostIdeaModel post;
  final PostCardController controller;
  final bool isOwnPost;

  const PostCardActions({
    super.key,
    required this.post,
    required this.controller,
    this.isOwnPost = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;
    final currentUserId = AuthController().getCurrentUserId();
    final postedBy = post.userId;
    final chatController = Get.find<ChatController>();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => controller.onSeeMore(post),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark
                    ? AppColors.cardBorderDark
                    : AppColors.cardBorderLight,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'See More',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        if (!isOwnPost)
          Flexible(
            child: OutlinedButton(
              onPressed: () {
                final roomId = ChatController.buildRoomId(
                  currentUserId!,
                  postedBy!,
                );
                chatController.createRoom(
                  sender: currentUserId,
                  receiver: postedBy,
                );
                Get.to(
                  () => ChatDetailScreen(
                    roomID: roomId,
                    senderUid: currentUserId,
                    receiverUid: postedBy,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.buttonDark
                    : AppColors.buttonLight,
                foregroundColor: isDark
                    ? AppColors.buttonTextDark
                    : AppColors.buttonTextLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Connect',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.buttonTextDark
                          : AppColors.buttonTextLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: isDark
                        ? AppColors.buttonTextDark
                        : AppColors.buttonTextLight,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
