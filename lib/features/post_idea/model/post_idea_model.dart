import 'media_model.dart';

/// Model representing a post/idea
class PostIdeaModel {
  final String? id;
  final String content;
  final String? videoPitchPath; // Local path (before upload)
  final String? videoUrl; // Remote URL (after upload)
  final List<String> galleryImages; // Local paths (before upload)
  final List<MediaItem> media; // Remote media (after upload)
  final bool isDraft;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String? userId;
  final int likes;
  final int comments;
  final int views;
  final List<String> tags;

  PostIdeaModel({
    this.id,
    required this.content,
    this.videoPitchPath,
    this.videoUrl,
    this.galleryImages = const [],
    this.media = const [],
    this.isDraft = false,
    required this.createdAt,
    this.publishedAt,
    this.userId,
    this.likes = 0,
    this.comments = 0,
    this.views = 0,
    this.tags = const [],
  });

  /// Convert model to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'videoPitchPath': videoPitchPath,
      'videoUrl': videoUrl,
      'galleryImages': galleryImages,
      'media': media.map((m) => m.toJson()).toList(),
      'isDraft': isDraft,
      'createdAt': createdAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'userId': userId,
      'likes': likes,
      'comments': comments,
      'views': views,
      'tags': tags,
    };
  }

  /// Create model from local JSON data
  factory PostIdeaModel.fromJson(Map<String, dynamic> json) {
    return PostIdeaModel(
      id: json['id'] as String?,
      content: json['content'] as String? ?? '',
      videoPitchPath: json['videoPitchPath'] as String?,
      videoUrl: json['videoUrl'] as String?,
      galleryImages: List<String>.from(json['galleryImages'] ?? []),
      media:
          (json['media'] as List?)
              ?.map((m) => MediaItem.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      isDraft: json['isDraft'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      userId: json['userId'] as String?,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  /// Create model from API response
  factory PostIdeaModel.fromApiJson(Map<String, dynamic> json) {
    return PostIdeaModel(
      id: json['id'] as String? ?? json['_id'] as String?,
      content: json['caption'] as String? ?? '',
      media:
          (json['media'] as List?)
              ?.map((m) => MediaItem.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      isDraft: json['status'] == 'draft',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      userId: json['userId'] as String?,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  /// Create a copy with updated fields
  PostIdeaModel copyWith({
    String? id,
    String? content,
    String? videoPitchPath,
    String? videoUrl,
    List<String>? galleryImages,
    List<MediaItem>? media,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? userId,
    int? likes,
    int? comments,
    int? views,
    List<String>? tags,
  }) {
    return PostIdeaModel(
      id: id ?? this.id,
      content: content ?? this.content,
      videoPitchPath: videoPitchPath ?? this.videoPitchPath,
      videoUrl: videoUrl ?? this.videoUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      media: media ?? this.media,
      isDraft: isDraft ?? this.isDraft,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      userId: userId ?? this.userId,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      views: views ?? this.views,
      tags: tags ?? this.tags,
    );
  }

  /// Get all image URLs from media
  List<String> get imageUrls =>
      media.where((m) => m.type == 'image').map((m) => m.url).toList();

  /// Get video URL from media (first video)
  String? get videoMediaUrl {
    final videoMedia = media.where((m) => m.type == 'video').toList();
    return videoMedia.isNotEmpty ? videoMedia.first.url : null;
  }
}
