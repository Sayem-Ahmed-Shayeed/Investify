import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/home/view/widgets/post_card_avatar.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../../post_idea/model/post_idea_model.dart';
import '../../controller/post_card_controller.dart';

class PostCardHeader extends StatelessWidget {
  final PostIdeaModel post;
  final PostCardController controller;

  const PostCardHeader({
    super.key,
    required this.post,
    required this.controller,
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
      ],
    );
  }
}
