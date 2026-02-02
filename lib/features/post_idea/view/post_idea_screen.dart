import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/utils/constants/const_texts.dart';
import 'package:investify/utils/sizes/size.dart';

import '../controller/post_idea_controller.dart';
import 'widgets/action_buttons.dart';
import 'widgets/add_photo_button.dart';
import 'widgets/gallery_image_item.dart';
import 'widgets/section_card.dart';

/// Main screen for creating new investment idea posts
class PostIdeaScreen extends StatelessWidget {
  const PostIdeaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostIdeaController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          'New Update',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,

        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content Input Section
                    _buildContentSection(context, controller),
                    const SizedBox(height: 24),

                    // Pitch Video Section
                    _buildPitchVideoSection(context, controller),
                    const SizedBox(height: 24),

                    // Gallery/Deck Section
                    _buildGallerySection(context, controller),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Obx(
              () => ActionButtons(
                onSaveDraft: controller.saveDraft,
                onPublish: controller.publishPost,
                isPublishing: controller.isPublishing.value,
                isSavingDraft: controller.isSavingDraft.value,
                uploadStatus: controller.uploadStatus.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the content text input section
  Widget _buildContentSection(
    BuildContext context,
    PostIdeaController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A38) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: controller.updateContent,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: ConstTexts.postPageHintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(RomRomSizes.medium),
            ),
            style: theme.textTheme.bodyLarge,
          ),
          // Enhance Button
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: RomRomSizes.medium,
              vertical: RomRomSizes.small,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement AI enhance feature
                  Get.snackbar(
                    'Coming Soon',
                    'AI enhancement feature coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: Icon(
                  Icons.auto_awesome,
                  size: RomRomSizes.large,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  'ENHANCE',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),

                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RomRomSizes.xxl,
                    vertical: RomRomSizes.small,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RomRomSizes.medium),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the pitch video upload section
  Widget _buildPitchVideoSection(
    BuildContext context,
    PostIdeaController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.videocam, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'PITCH VIDEO',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              'MAX 5 MIN',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.videoPitchBytes.value != null) {
            // Show selected video
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.video_file,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.videoPitchFileName.value ?? 'Video',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Video selected',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: controller.removeVideo,
                    icon: const Icon(Icons.close),
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
            );
          }

          return SectionCard(
            icon: Icons.cloud_upload_outlined,
            title: 'Upload Video Pitch',
            subtitle: 'MP4, MOV up to 50MB',
            onTap: controller.pickVideo,
          );
        }),
      ],
    );
  }

  /// Build the gallery/deck section
  Widget _buildGallerySection(
    BuildContext context,
    PostIdeaController controller,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'GALLERY / DECK',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Add Photo Button
                AddPhotoButton(onTap: controller.pickImages),
                const SizedBox(width: 8),

                // Gallery Images
                ...List.generate(
                  controller.galleryImages.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GalleryImageItem(
                      imagePath: controller.galleryImages[index],
                      onRemove: () => controller.removeImage(index),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
