import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/theme/app_colors.dart';
import '../../auth/controller/auth_controller.dart';
import '../../home/view/widgets/post_card.dart';
import '../controller/profile_controller.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final profileController = Get.put(ProfileController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    authController.fetchUserProfile();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldBackgroundDark
          : AppColors.scaffoldBackgroundLight,
      body: RefreshIndicator(
        onRefresh: () => profileController.refreshMyPosts(),
        child: CustomScrollView(
          slivers: [
            // Profile header
            SliverToBoxAdapter(
              child: ProfileHeader(
                authController: authController,
                profileController: profileController,
              ),
            ),

            // Posts section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'My Posts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Posts list
            Obx(() {
              if (profileController.isLoading.value &&
                  profileController.posts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (profileController.hasError.value &&
                  profileController.posts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load your posts',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => profileController.fetchMyPosts(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (profileController.posts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text('No posts yet', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          'Your published posts will appear here',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = profileController.posts[index];
                  return PostCard(
                    post: post,
                    onLike: () {},
                    isOwnPost: true,
                    onEdit: () => profileController.editPost(post),
                    onDelete: () => profileController.deletePost(post.id!),
                  );
                }, childCount: profileController.posts.length),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

/// Profile Header Widget
class ProfileHeader extends StatelessWidget {
  final AuthController authController;
  final ProfileController profileController;

  const ProfileHeader({
    super.key,
    required this.authController,
    required this.profileController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          ProfileAvatar(authController: authController),
          const SizedBox(width: 16),

          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    authController.cachedUserName.value.isNotEmpty
                        ? authController.cachedUserName.value
                        : 'User',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authController.getCurrentUserEmail,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Post count
          Obx(() => ProfilePostCount(count: profileController.posts.length)),
        ],
      ),
    );
  }
}

/// Profile Avatar Widget
class ProfileAvatar extends StatelessWidget {
  final AuthController authController;

  const ProfileAvatar({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final imageUrl = authController.cachedProfileImageUrl.value;
      final name = authController.cachedUserName.value;

      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 72,
                  height: 72,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(name, isDark),
                )
              : _buildPlaceholder(name, isDark),
        ),
      );
    });
  }

  Widget _buildPlaceholder(String name, bool isDark) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Profile Post Count Widget
class ProfilePostCount extends StatelessWidget {
  final int count;

  const ProfilePostCount({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            ),
          ),
          Text('Posts', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
