import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/comment_controller.dart';
import '../../model/comment_model.dart';

class CommentBottomSheet extends StatelessWidget {
  final String postId;
  final int initialCommentCount;
  final ValueChanged<int>? onCommentCountChanged;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.initialCommentCount,
    this.onCommentCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Put a unique controller instance for this bottom sheet flow
    // Tagging it ensuring separate controllers per sheet if needed, though mainly one open at a time
    final controller = Get.put(CommentController(), tag: postId);

    // Initialize fetching
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.init(postId);
    });

    final textController = TextEditingController();
    final scrollController = ScrollController();

    // Load more listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreComments();
      }
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Comments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // We could show count here if passed reactively, but simplest is static "Comments" title
                // or updated via parent callback which updates PostCard but not necessarily this sheet unless observed
              ],
            ),
          ),

          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),

          // Comments List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.comments.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.comments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No comments yet',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Be the first to comment!',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount:
                    controller.comments.length +
                    (controller.hasMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.comments.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _CommentTile(
                    comment: controller.comments[index],
                    controller: controller,
                    onDeleted: (count) => onCommentCountChanged?.call(count),
                  );
                },
              );
            }),
          ),

          // Input Area
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: bottomInset > 0 ? 8 : 16,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => controller.isSending.value
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            onPressed: () async {
                              final content = textController.text;
                              if (content.trim().isNotEmpty) {
                                textController
                                    .clear(); // Clear immediately for UX
                                final count = await controller.addComment(
                                  content,
                                );
                                if (count != null) {
                                  onCommentCountChanged?.call(count);
                                  // Scroll to top
                                  if (scrollController.hasClients) {
                                    scrollController.animateTo(
                                      0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                } else {
                                  // Restore text if failed? Optional.
                                  textController.text = content;
                                }
                              }
                            },
                            icon: Icon(
                              Icons.send_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final CommentController controller;
  final ValueChanged<int>? onDeleted;

  const _CommentTile({
    required this.comment,
    required this.controller,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwn = controller.isMyComment(comment);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            backgroundImage: comment.userProfileImageUrl != null
                ? NetworkImage(comment.userProfileImageUrl!)
                : null,
            child: comment.userProfileImageUrl == null
                ? Icon(Icons.person, size: 18, color: theme.colorScheme.primary)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          comment.userName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(comment.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.content, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          if (isOwn)
            IconButton(
              onPressed: () => _confirmDelete(context),
              icon: Icon(
                Icons.close,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              final count = await controller.deleteComment(comment.id!);
              if (count != null) {
                onDeleted?.call(count);
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dateTime.day}/${dateTime.month}';
  }
}
