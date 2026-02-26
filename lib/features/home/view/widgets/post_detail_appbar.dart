import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../controller/post_detail_controller.dart';

class PostDetailAppBar extends StatelessWidget {
  final PostDetailController controller;

  const PostDetailAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.inputFillDark
                  : AppColors.inputFillLight,
            ),
          ),
        ],
      ),
    );
  }
}
