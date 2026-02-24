import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/home/view/widgets/post_card_action_buttons.dart';
import 'package:investify/features/home/view/widgets/post_card_description.dart';
import 'package:investify/features/home/view/widgets/post_card_header.dart';
import 'package:investify/features/home/view/widgets/post_card_media.dart';
import 'package:investify/utils/sizes/size.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../../post_idea/model/post_idea_model.dart';
import '../../controller/post_card_controller.dart';

class PostCard extends StatelessWidget {
  final PostIdeaModel post;
  final VoidCallback onLike;
  final bool isOwnPost;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    this.isOwnPost = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Get.put(PostCardController(), tag: post.id);

    controller.fetchUserProfile(post.userId ?? '');

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: RomRomSizes.spaceBetweenElements,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(RomRomSizes.spaceBetweenElements),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(RomRomSizes.spaceBetweenElements),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostCardHeader(
            post: post,
            controller: controller,
            isOwnPost: isOwnPost,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          const SizedBox(height: RomRomSizes.spaceBetweenElements),

          if (post.media.isNotEmpty)
            PostCardMedia(post: post, controller: controller),
          if (post.media.isNotEmpty)
            const SizedBox(height: RomRomSizes.spaceBetweenElements),

          PostCardDescription(post: post),

          const SizedBox(height: RomRomSizes.spaceBetweenElements),

          PostCardActions(
            post: post,
            controller: controller,
            isOwnPost: isOwnPost,
          ),
        ],
      ),
    );
  }
}
