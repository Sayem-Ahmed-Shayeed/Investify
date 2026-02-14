/// Model representing a comment on a post
class CommentModel {
  final String? id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfileImageUrl;
  final String content;
  final DateTime createdAt;

  CommentModel({
    this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userProfileImageUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String? ?? json['_id']?.toString(),
      postId: json['postId']?.toString() ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'User',
      userProfileImageUrl: json['userProfileImageUrl'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userProfileImageUrl': userProfileImageUrl,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
