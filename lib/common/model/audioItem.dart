class AudioItem {
  final String id;
  final String audioAssetPath;
  final String? audioUrl;
  final String? coverImageAssetPath;
  final String title;
  final String artist;
  final Duration? duration;

  AudioItem({
    required this.id,
    required this.audioAssetPath,
    this.audioUrl,
    this.coverImageAssetPath,
    required this.title,
    required this.artist,
    this.duration,
  });
}