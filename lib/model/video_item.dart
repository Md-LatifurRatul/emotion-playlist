class VideoItem {
  final String videoId;
  final String title;
  final String thumbnailUrl;

  VideoItem({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }
}
