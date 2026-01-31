/// Model representing a media item (image or video)
class MediaItem {
  final String url;
  final String type; // 'image' or 'video'
  final String? thumbnailUrl;
  final int order;

  MediaItem({
    required this.url,
    required this.type,
    this.thumbnailUrl,
    this.order = 0,
  });

  /// Empty media item (for null safety)
  factory MediaItem.empty() => MediaItem(url: '', type: 'image');

  Map<String, dynamic> toJson() => {
    'url': url,
    'type': type,
    'thumbnailUrl': thumbnailUrl,
    'order': order,
  };

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? 'image',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }
}
