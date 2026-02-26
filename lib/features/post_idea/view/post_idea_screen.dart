import 'package:flutter/cupertino.dart';
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
          'New Pitch',
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
                padding: const EdgeInsets.all(MySizes.large),
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

                    // PDF Attachment Section
                    _buildPdfSection(context, controller),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Obx(
              () => ActionButtons(
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

  Widget _buildContentSection(
    BuildContext context,
    PostIdeaController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

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
            controller: controller.contentController,
            onChanged: controller.updateContent,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: ConstTexts.postPageHintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(MySizes.medium),
            ),
            style: theme.textTheme.bodyLarge,
          ),
          // Enhance Button
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: MySizes.medium,
              vertical: MySizes.small,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.isEnhancing.value
                      ? null
                      : controller.enhanceContent,
                  icon: controller.isEnhancing.value
                      ? SizedBox(
                          width: MySizes.large,
                          height: MySizes.large,
                          child: CupertinoActivityIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.auto_awesome,
                          size: MySizes.large,
                          color: theme.colorScheme.primary,
                        ),
                  label: Text(
                    controller.isEnhancing.value ? 'ENHANCING...' : 'ENHANCE',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MySizes.xxl,
                      vertical: MySizes.small,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MySizes.medium),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPitchVideoSection(
    BuildContext context,
    PostIdeaController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

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
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.videoPitchBytes.value != null) {
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
            onTap: controller.pickVideo,
          );
        }),
      ],
    );
  }

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

  /// Build the PDF attachment section
  Widget _buildPdfSection(BuildContext context, PostIdeaController controller) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final hasPdf = controller.pdfFileName.value != null;

      if (hasPdf) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2A38) : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.red.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red.shade400, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.pdfFileName.value!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: controller.removePdf,
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.outline,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      }

      return OutlinedButton.icon(
        onPressed: controller.pickPdf,
        icon: Icon(
          Icons.attach_file,
          color: isDark ? Colors.white70 : Colors.grey.shade700,
        ),
        label: Text(
          'Attach PDF (optional)',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey.shade700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.shade300,
          ),
        ),
      );
    });
  }
}
