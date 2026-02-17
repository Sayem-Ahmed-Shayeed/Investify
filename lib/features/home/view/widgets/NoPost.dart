import 'package:flutter/material.dart';

class NoPost extends StatelessWidget {
  const NoPost({super.key, required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.post_add, size: 64, color: theme.colorScheme.outline),
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
}
