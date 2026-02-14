import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/theme/app_colors.dart';
import '../../post_idea/model/post_idea_model.dart';
import '../controller/post_detail_controller.dart';

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

/// Media Gallery Widget with auto-playing video
class PostDetailMediaGallery extends StatefulWidget {
  final PostDetailController controller;

  const PostDetailMediaGallery({super.key, required this.controller});

  @override
  State<PostDetailMediaGallery> createState() => _PostDetailMediaGalleryState();
}

class _PostDetailMediaGalleryState extends State<PostDetailMediaGallery> {
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<String, bool> _initializedVideos = {};

  @override
  void initState() {
    super.initState();
    _initializeVideos();
  }

  Future<void> _initializeVideos() async {
    for (final media in widget.controller.post.media) {
      if (media.type == 'video') {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(media.url),
        );
        _videoControllers[media.url] = controller;

        try {
          await controller.initialize();
          controller.setLooping(true);
          controller.setVolume(0);
          controller.play();
          if (mounted) {
            setState(() {
              _initializedVideos[media.url] = true;
            });
          }
        } catch (e) {
          debugPrint('Error initializing video: $e');
          _initializedVideos[media.url] = false;
        }
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.controller.post;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PageView.builder(
            controller: widget.controller.pageController,
            onPageChanged: widget.controller.onPageChanged,
            itemCount: post.media.length,
            itemBuilder: (context, index) {
              final media = post.media[index];

              if (media.type == 'video') {
                return _buildVideoPlayer(media.url, isDark);
              } else {
                return Image.network(
                  media.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
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
                  controller: widget.controller.pageController,
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

  Widget _buildVideoPlayer(String url, bool isDark) {
    final controller = _videoControllers[url];
    final isInitialized = _initializedVideos[url] ?? false;

    if (!isInitialized || controller == null) {
      return _buildLoadingWidget(isDark);
    }

    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          if (!controller.value.isPlaying)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: isDark
                    ? AppColors.primaryDark
                    : AppColors.primaryLight,
                bufferedColor: Colors.white.withValues(alpha: 0.3),
                backgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                final volume = controller.value.volume;
                controller.setVolume(volume > 0 ? 0 : 1);
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  controller.value.volume > 0
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(bool isDark) {
    return Container(
      color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              strokeWidth: 2,
            ),
            const SizedBox(height: 8),
            Text(
              'Loading video...',
              style: TextStyle(
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
          size: 64,
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
