import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controller/auth_controller.dart';
import '../../home/view/tabs/home_tab.dart';
import '../controller/profile_controller.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final profileController = Get.put(ProfileController());
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => profileController.refreshMyPosts(),
        child: CustomScrollView(
          slivers: [
            // Profile header
            SliverToBoxAdapter(
              child: _buildProfileHeader(theme, authController),
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
              // Loading state
              if (profileController.isLoading.value &&
                  profileController.posts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Error state
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

              // Empty state
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

              // Posts list
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = profileController.posts[index];
                  return PostCard(
                    post: post,
                    onLike: () {}, // Display only — no actions
                  );
                }, childCount: profileController.posts.length),
              );
            }),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, AuthController authController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Obx(() {
            final imageUrl = authController.cachedProfileImageUrl.value;
            return CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? Icon(
                      Icons.person,
                      size: 36,
                      color: theme.colorScheme.onPrimaryContainer,
                    )
                  : null,
            );
          }),
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Post count
          Obx(
            () => Column(
              children: [
                Text(
                  '${profileController.posts.length}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Posts', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ProfileController get profileController => Get.find<ProfileController>();
}
