class SongModel {
  final String title;
  final String artist;
  final String mood;
  final String audioUrl;
  final String coverpage;

  SongModel({
    required this.title,
    required this.artist,
    required this.mood,
    required this.audioUrl,
    required this.coverpage,
  });

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      title: map['title'] as String,
      artist: map['artist'] as String,
      mood: map['mood'] as String,
      audioUrl: map['audio_url'] as String,
      coverpage: map['cover_url'] as String,
    );
  }
}
