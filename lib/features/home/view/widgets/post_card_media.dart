import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/home/view/widgets/post_card_video_player.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final pdfs = post.media.where((m) => m.type == 'pdf').toList();

    return Column(
      children: [
        if (videos.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: PostCardVideoPlayer(
                videoUrl: videos.first.url,
                thumbnailUrl: videos.first.thumbnailUrl,
                controller: controller,
              ),
            ),
          ),

        if (videos.isNotEmpty && images.isNotEmpty) const SizedBox(height: 8),

        if (images.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: images.length == 1
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: CachedNetworkImage(
                      imageUrl: images.first.url,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      placeholder: (_, __) => _buildMediaPlaceholder(isDark),
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
                                  _buildMediaPlaceholder(isDark),
                              errorWidget: (_, __, ___) =>
                                  _buildMediaPlaceholder(isDark),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),

        if (pdfs.isNotEmpty) ...[
          if (images.isNotEmpty || videos.isNotEmpty) const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _openPdf(pdfs.first.url),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red.shade400,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'View PDF Attachment',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                  Icon(Icons.open_in_new, color: Colors.red.shade400, size: 18),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openPdf(String url) async {
    final uri = Uri.parse(url);
    print(url);
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      } catch (e) {
        debugPrint("Falling back to browser: $e");
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e2) {
          debugPrint("Browser fallback also failed: $e2");
        }
      }
    } else {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint("Could not open PDF: $e");
      }
    }
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
