import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/home/view/widgets/thumbnail_video_player.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../controller/post_detail_controller.dart';

class PostDetailMediaGallery extends StatelessWidget {
  final PostDetailController controller;

  const PostDetailMediaGallery({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final post = controller.post;
    final isDark = Get.isDarkMode;

    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: post.media.length,
            itemBuilder: (context, index) {
              final media = post.media[index];

              if (media.type == 'video') {
                return ThumbnailVideoPlayer(
                  videoUrl: media.url,
                  thumbnailUrl: media.thumbnailUrl,
                  looping: true,
                  showControls: true,
                );
              } else {
                return CachedNetworkImage(
                  imageUrl: media.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => _buildPlaceholder(isDark),
                  errorWidget: (_, __, ___) => _buildPlaceholder(isDark),
                );
              }
            },
          ),

          if (post.media.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: controller.pageController,
                  count: post.media.length,
                  effect: WormEffect(
                    dotColor: isDark
                        ? AppColors.mutedDark
                        : AppColors.mutedLight,
                    activeDotColor: isDark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
          size: 48,
        ),
      ),
    );
  }
}
