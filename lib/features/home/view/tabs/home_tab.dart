import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../controller/home_feed_controller.dart';
import '../widgets/post_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(HomeFeedController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldBackgroundDark
          : AppColors.scaffoldBackgroundLight,
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value && controller.posts.isEmpty) {
          return const Center(child: CupertinoActivityIndicator());
        }

        // Error state
        if (controller.hasError.value && controller.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load posts',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchPosts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (controller.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.post_add,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text('No posts yet', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Be the first to share an idea!',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        // Posts list
        return RefreshIndicator(
          onRefresh: () => controller.refreshPosts(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount:
                controller.posts.length +
                (controller.hasMorePages.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.posts.length) {
                controller.loadMorePosts();
                return const Center(child: CupertinoActivityIndicator());
              }

              final post = controller.posts[index];
              return PostCard(
                post: post,
                onLike: () => controller.toggleLike(post.id!),
              );
            },
          ),
        );
      }),
    );
  }
}
