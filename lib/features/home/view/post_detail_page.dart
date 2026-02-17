import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../utils/theme/app_colors.dart';
import '../../post_idea/model/post_idea_model.dart';
import '../controller/post_detail_controller.dart';
import 'widgets/thumbnail_video_player.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final post = Get.arguments as PostIdeaModel;
    final controller = Get.put(PostDetailController(post));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldBackgroundDark
          : AppColors.scaffoldBackgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            PostDetailAppBar(controller: controller),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.media.isNotEmpty)
                      PostDetailMediaGallery(controller: controller),
                    PostDetailCompanyInfo(controller: controller),
                    const PostDetailFinancials(),
                    PostDetailAbout(controller: controller),
                    PostDetailFounders(controller: controller),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            PostDetailBottomBar(controller: controller),
          ],
        ),
      ),
    );
  }
}

/// App Bar Widget
class PostDetailAppBar extends StatelessWidget {
  final PostDetailController controller;

  const PostDetailAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Row(
            children: [
              Obx(() {
                final isSaved = controller.isSaved.value;
                return IconButton(
                  onPressed: controller.toggleSaved,
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isDark ? AppColors.iconDark : AppColors.iconLight,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.inputFillDark
                        : AppColors.inputFillLight,
                  ),
                );
              }),
              const SizedBox(width: 8),
              IconButton(
                onPressed: controller.onShare,
                icon: Icon(
                  Icons.share,
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
        ],
      ),
    );
  }
}

/// Media Gallery Widget with click-to-play video
class PostDetailMediaGallery extends StatelessWidget {
  final PostDetailController controller;

  const PostDetailMediaGallery({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final post = controller.post;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

/// Company Info Widget
class PostDetailCompanyInfo extends StatelessWidget {
  final PostDetailController controller;

  const PostDetailCompanyInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
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
            child: Obx(() {
              final userData = controller.userData.value;
              final name = userData?['name'] ?? 'S';
              final profileImageUrl = userData?['profileImageUrl'];

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    profileImageUrl != null &&
                        profileImageUrl.toString().isNotEmpty
                    ? Image.network(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholder(name, isDark),
                      )
                    : _buildPlaceholder(name, isDark),
              );
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() {
              final userData = controller.userData.value;
              final name = userData?['name'] ?? 'Loading...';
              final bio = userData?['bio'] ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.verified,
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        size: 20,
                      ),
                    ],
                  ),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      bio,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String name, bool isDark) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'S',
        style: TextStyle(
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Financials Widget
class PostDetailFinancials extends StatelessWidget {
  const PostDetailFinancials({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY FINANCIALS',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _FinancialCard(label: 'Target Raise', value: '\$2M'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinancialCard(label: 'Valuation (Cap)', value: '\$15M'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FinancialCard(label: 'Min Ticket', value: '\$25k'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinancialCard(label: 'Runway', value: '18 Mo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final String label;
  final String value;

  const _FinancialCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// About Section Widget
class PostDetailAbout extends StatelessWidget {
  final PostDetailController controller;

  const PostDetailAbout({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final isExpanded = controller.isAboutExpanded.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.post.content,
                  maxLines: isExpanded ? null : 4,
                  overflow: isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: controller.toggleAboutExpanded,
                  child: Text(
                    isExpanded ? 'Show less' : 'Read more',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// Founders Section Widget
class PostDetailFounders extends StatelessWidget {
  final PostDetailController controller;

  const PostDetailFounders({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Founders',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final userData = controller.userData.value;
            final name = userData?['name'] ?? 'Founder';
            final profileImageUrl = userData?['profileImageUrl'];

            return SizedBox(
              width: 100,
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child:
                          profileImageUrl != null &&
                              profileImageUrl.toString().isNotEmpty
                          ? Image.network(
                              profileImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholder(name, isDark),
                            )
                          : _buildPlaceholder(name, isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'CEO & Founder',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String name, bool isDark) {
    return Container(
      color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'F',
          style: TextStyle(
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Bottom Bar Widget
class PostDetailBottomBar extends StatelessWidget {
  final PostDetailController controller;

  const PostDetailBottomBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.calendar_today,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.inputFillDark
                  : AppColors.inputFillLight,
              padding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.onInvestNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.buttonDark
                    : AppColors.buttonLight,
                foregroundColor: isDark
                    ? AppColors.buttonTextDark
                    : AppColors.buttonTextLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Invest Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.buttonTextDark
                      : AppColors.buttonTextLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
