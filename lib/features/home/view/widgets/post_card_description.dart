import 'package:flutter/material.dart';

import '../../../post_idea/model/post_idea_model.dart';

class PostCardDescription extends StatelessWidget {
  final PostIdeaModel post;

  const PostCardDescription({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      post.content,
      style: theme.textTheme.bodyMedium,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
