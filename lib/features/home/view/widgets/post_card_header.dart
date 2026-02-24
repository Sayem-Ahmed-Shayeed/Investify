import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/home/view/widgets/post_card_avatar.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../../post_idea/model/post_idea_model.dart';
import '../../controller/post_card_controller.dart';

class PostCardHeader extends StatelessWidget {
  final PostIdeaModel post;
  final PostCardController controller;
  final bool isOwnPost;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCardHeader({
    super.key,
    required this.post,
    required this.controller,
    this.isOwnPost = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        PostCardAvatar(post: post, controller: controller),
        const SizedBox(width: 12),

        Expanded(
          child: Obx(() {
            final userData = controller.userCache[post.userId];
            final userName = userData?['name'] ?? 'Loading...';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      size: 18,
                    ),
                  ],
                ),
              ],
            );
          }),
        ),

        if (isOwnPost)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit?.call();
              } else if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text('Edit Caption'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Delete Post',
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
