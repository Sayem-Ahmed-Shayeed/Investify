import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../../post_idea/model/post_idea_model.dart';
import '../../controller/post_card_controller.dart';

class PostCardAvatar extends StatelessWidget {
  final PostIdeaModel post;
  final PostCardController controller;

  const PostCardAvatar({
    super.key,
    required this.post,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: Obx(() {
        final userData = controller.userCache[post.userId];
        final profileImageUrl = userData?['profileImageUrl'];
        final userName = userData?['name'] ?? 'S';

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child:
              profileImageUrl != null && profileImageUrl.toString().isNotEmpty
              ? Image.network(
                  profileImageUrl,
                  fit: BoxFit.cover,
                  width: 48,
                  height: 48,
                  errorBuilder: (_, __, ___) =>
                      _buildPlaceholder(userName, isDark),
                )
              : _buildPlaceholder(userName, isDark),
        );
      }),
    );
  }

  Widget _buildPlaceholder(String name, bool isDark) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'S',
        style: TextStyle(
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
