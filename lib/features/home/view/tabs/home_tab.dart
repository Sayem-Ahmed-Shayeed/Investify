import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../post_idea/model/post_idea_model.dart';
import '../../controller/home_feed_controller.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(HomeFeedController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshPosts(),
          ),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value && controller.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
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
              // Load more indicator
              if (index >= controller.posts.length) {
                controller.loadMorePosts();
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
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

/// Card widget for displaying a single post
class PostCard extends StatelessWidget {
  final PostIdeaModel post;
  final VoidCallback onLike;

  const PostCard({super.key, required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasVideo = post.media.any((m) => m.type == 'video');
    final hasImages = post.media.any((m) => m.type == 'image');
    final videoMedia = post.media.where((m) => m.type == 'video').toList();
    final imageMedia = post.media.where((m) => m.type == 'image').toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and timestamp
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              'User',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              _formatTimestamp(post.publishedAt ?? post.createdAt),
              style: theme.textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Show post options menu
              },
            ),
          ),

          // Caption
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(post.content, style: theme.textTheme.bodyMedium),
            ),

          const SizedBox(height: 8),

          // Video player
          if (hasVideo && videoMedia.isNotEmpty)
            VideoPlayerWidget(videoUrl: videoMedia.first.url),

          // Image gallery
          if (hasImages && imageMedia.isNotEmpty)
            SizedBox(
              height: 200,
              child: imageMedia.length == 1
                  ? Image.network(
                      imageMedia.first.url,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageMedia.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 16 : 4,
                            right: index == imageMedia.length - 1 ? 16 : 4,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageMedia[index].url,
                              width: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 200,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Like button
                TextButton.icon(
                  onPressed: onLike,
                  icon: const Icon(Icons.favorite_border),
                  label: Text('${post.likes}'),
                ),
                // Comment button
                TextButton.icon(
                  onPressed: () {
                    // TODO: Open comments
                  },
                  icon: const Icon(Icons.comment_outlined),
                  label: Text('${post.comments}'),
                ),
                // Share button
                TextButton.icon(
                  onPressed: () {
                    // TODO: Share post
                  },
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                ),
                const Spacer(),
                // Views count
                Row(
                  children: [
                    const Icon(Icons.visibility_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text('${post.views}', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

/// Video player widget with play/pause controls
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_hasError) {
      return Container(
        height: 200,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(height: 8),
              Text('Failed to load video', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 200,
        color: theme.colorScheme.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          // Play/pause overlay
          AnimatedOpacity(
            opacity: _controller.value.isPlaying ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          // Progress indicator
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: theme.colorScheme.primary,
                bufferedColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                backgroundColor: Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
