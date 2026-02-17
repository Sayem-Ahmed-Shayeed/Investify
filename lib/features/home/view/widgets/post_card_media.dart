import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/home/view/widgets/post_card_video_player.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../../post_idea/model/post_idea_model.dart';
import '../../controller/post_card_controller.dart';

class PostCardMedia extends StatelessWidget {
  final PostIdeaModel post;
  final PostCardController controller;

  const PostCardMedia({
    super.key,
    required this.post,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    final videos = post.media.where((m) => m.type == 'video').toList();
    final images = post.media.where((m) => m.type == 'image').toList();

    // No more eager initMedia() — videos init lazily on tap

    return Column(
      children: [
        if (videos.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: PostCardVideoPlayer(
                videoUrl: videos.first.url,
                controller: controller,
              ),
            ),
          ),

        if (videos.isNotEmpty && images.isNotEmpty) const SizedBox(height: 8),

        if (images.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: images.length == 1
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: images.first.url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => _buildMediaLoading(isDark),
                      errorWidget: (_, __, ___) =>
                          _buildMediaPlaceholder(isDark),
                    ),
                  )
                : SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CachedNetworkImage(
                              imageUrl: images[index].url,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  _buildMediaLoading(isDark),
                              errorWidget: (_, __, ___) =>
                                  _buildMediaPlaceholder(isDark),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildMediaLoading(bool isDark) {
    return Container(
      color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildMediaPlaceholder(bool isDark) {
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
