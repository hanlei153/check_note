import '../../../common/app_imports.dart';

class AudioHeader extends StatefulWidget {
  final String? title;
  final String? artist;
  final String? coverImageAssetPath;
  final bool isPlaying;

  const AudioHeader({
    super.key,
    this.title,
    this.artist,
    this.coverImageAssetPath,
    required this.isPlaying,
  });

  @override
  State<AudioHeader> createState() => _AudioHeaderState();
}

class _AudioHeaderState extends State<AudioHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _clipRRectController;

  @override
  void initState() {
    super.initState();
    _clipRRectController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    if (widget.isPlaying) _clipRRectController.repeat();
  }

  @override
  void dispose() {
    _clipRRectController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AudioHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      widget.isPlaying ? _clipRRectController.repeat() : _clipRRectController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: globalDeviceType == CustomDeviceType.tablet ? 3.5.w : 8.w,
          height: globalDeviceType == CustomDeviceType.tablet ? 3.5.w : 8.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.coverImageAssetPath != null
              ? RotationTransition(
                  turns: _clipRRectController,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      widget.coverImageAssetPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.music_note,
                        size: 2.8.w,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                )
              : Icon(Icons.music_note, size: 2.8.w, color: colorScheme.primary),
        ),
        SizedBox(width: 2.w),
        Expanded(
            child: globalDeviceType == CustomDeviceType.tablet
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title ?? '未知歌曲',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        widget.artist ?? '未知艺术家',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Text(
                        widget.title ?? '未知歌曲',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        widget.artist == null ? '未知艺术家' : '- ${widget.artist}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  )),
      ],
    );
  }
}
