class PostIdeaModel {
  final String? id;
  final String content;
  final String? videoPitchPath;
  final List<String> galleryImages;
  final bool isDraft;
  final DateTime createdAt;
  final String? userId;

  PostIdeaModel({
    this.id,
    required this.content,
    this.videoPitchPath,
    this.galleryImages = const [],
    this.isDraft = false,
    required this.createdAt,
    this.userId,
  });

  /// Convert model to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'videoPitchPath': videoPitchPath,
      'galleryImages': galleryImages,
      'isDraft': isDraft,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  /// Create model from JSON data
  factory PostIdeaModel.fromJson(Map<String, dynamic> json) {
    return PostIdeaModel(
      id: json['id'] as String?,
      content: json['content'] as String? ?? '',
      videoPitchPath: json['videoPitchPath'] as String?,
      galleryImages: List<String>.from(json['galleryImages'] ?? []),
      isDraft: json['isDraft'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String?,
    );
  }

  /// Create a copy with updated fields
  PostIdeaModel copyWith({
    String? id,
    String? content,
    String? videoPitchPath,
    List<String>? galleryImages,
    bool? isDraft,
    DateTime? createdAt,
    String? userId,
  }) {
    return PostIdeaModel(
      id: id ?? this.id,
      content: content ?? this.content,
      videoPitchPath: videoPitchPath ?? this.videoPitchPath,
      galleryImages: galleryImages ?? this.galleryImages,
      isDraft: isDraft ?? this.isDraft,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
