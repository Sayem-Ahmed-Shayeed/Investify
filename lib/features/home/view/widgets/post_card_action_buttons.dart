import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/theme/app_colors.dart';
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
                // TODO: make a room and then throw them in chats.
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

        const SizedBox(width: 12),

        if (!isOwnPost)
          Obx(() {
            final isSaved = controller.isSaved.value;
            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.inputFillDark
                    : AppColors.inputFillLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppColors.cardBorderDark
                      : AppColors.cardBorderLight,
                ),
              ),
              child: IconButton(
                onPressed: controller.toggleSaved,
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved
                      ? (isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight)
                      : (isDark ? AppColors.iconDark : AppColors.iconLight),
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(10),
              ),
            );
          }),
      ],
    );
  }
}
