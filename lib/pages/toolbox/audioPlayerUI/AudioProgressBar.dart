import '../../../common/app_imports.dart';

class AudioProgressBar extends StatelessWidget {
  final AudioPlayerService audioService;
  final Function(double, Duration) onSeek;

  const AudioProgressBar({
    super.key,
    required this.audioService,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<Duration?>(
      stream: audioService.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: audioService.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 5.sp,
                    thumbShape:
                        RoundSliderThumbShape(enabledThumbRadius: 6.sp),
                    overlayShape:
                        RoundSliderOverlayShape(overlayRadius: 10.sp),
                    activeTrackColor: colorScheme.primary,
                    inactiveTrackColor: colorScheme.primary.withOpacity(0.2),
                    thumbColor: colorScheme.primary,
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (value) => onSeek(value, duration),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _format(position, colorScheme),
                      style: TextStyle(
                        fontSize: 11.sp, // 这里改成你想要的大小
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _format(duration, colorScheme),
                      style: TextStyle(
                        fontSize: 11.sp, // 这里改成你想要的大小
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _format(Duration d, ColorScheme colorScheme) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }
}
