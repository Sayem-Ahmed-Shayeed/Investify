import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/utils/theme/app_colors.dart';

import '../../../sandbox/controller/sandbox_controller.dart';
import '../../../post_idea/view/widgets/section_card.dart';
import '../../../post_idea/view/widgets/add_photo_button.dart';

/// Sandbox tab — submit content for AI review before posting
class SandboxTab extends StatelessWidget {
  const SandboxTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SandboxController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldBackgroundDark
          : AppColors.scaffoldBackgroundLight,
      body: Obx(() {
        if (controller.isLoadingStatus.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isPending.value) {
          return RefreshIndicator(
            onRefresh: controller.refreshStatus,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: _buildPendingState(context, controller),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshStatus,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(RomRomSizes.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(theme),
                      const SizedBox(height: 20),

                      // Caption Section
                      _buildCaptionSection(context, controller),
                      const SizedBox(height: 24),

                      // Pitch Video Section
                      _buildVideoSection(context, controller),
                      const SizedBox(height: 24),

                      // Gallery Section
                      _buildGallerySection(context, controller),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Submit Button
              _buildSubmitButton(context, controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPendingState(
    BuildContext context,
    SandboxController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RomRomSizes.large),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon / pulse effect
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AI Review in Progress',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your content is currently being analyzed by our AI models. Please wait for the feedback email.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: controller.isLoadingStatus.value
                    ? null
                    : controller.refreshStatus,
                icon: controller.isLoadingStatus.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Check Status'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RomRomSizes.roundedBoxCorner),
      ),
      child: Row(
        children: [
          Icon(
            Icons.science_outlined,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Content Review',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get AI feedback on your post before publishing. You\'ll receive an email with suggestions within 5-7 minutes.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionSection(
    BuildContext context,
    SandboxController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'CAPTION',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2A38) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: TextField(
            onChanged: controller.updateCaption,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe your investment idea or product...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(RomRomSizes.medium),
            ),
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection(
    BuildContext context,
    SandboxController controller,
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
              'PRODUCT VIDEO',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              'OPTIONAL',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.videoPitchBytes.value != null)
          Container(
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
          )
        else
          SectionCard(
            icon: Icons.cloud_upload_outlined,
            title: 'Upload Video',
            subtitle: 'MP4, MOV up to 50MB',
            onTap: controller.pickVideo,
          ),
      ],
    );
  }

  Widget _buildGallerySection(
    BuildContext context,
    SandboxController controller,
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
              'PRODUCT IMAGES',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              AddPhotoButton(onTap: controller.pickImages),
              const SizedBox(width: 8),
              ...List.generate(controller.galleryImages.length, (index) {
                final img = controller.galleryImages[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          img['bytes'] as Uint8List,
                          width: RomRomSizes.galleryItemSize,
                          height: RomRomSizes.galleryItemSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: RomRomSizes.closeButtonPadding,
                        right: RomRomSizes.closeButtonPadding,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: RomRomSizes.closeButtonSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    SandboxController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(RomRomSizes.large),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.cardBorderDark
                : AppColors.cardBorderLight,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : controller.submitForReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.buttonDark
                  : AppColors.buttonLight,
              foregroundColor: isDark
                  ? AppColors.buttonTextDark
                  : AppColors.buttonTextLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  RomRomSizes.roundedButtonCorner,
                ),
              ),
              disabledBackgroundColor:
                  (isDark ? AppColors.buttonDark : AppColors.buttonLight)
                      .withValues(alpha: 0.5),
            ),
            child: controller.isSubmitting.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark
                              ? AppColors.buttonTextDark
                              : AppColors.buttonTextLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        controller.uploadStatus.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.buttonTextDark
                              : AppColors.buttonTextLight,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Submit for AI Review',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.buttonTextDark
                              : AppColors.buttonTextLight,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
