import '../../../common/app_imports.dart';

class AudioExtendedControls extends StatelessWidget {
  final AudioPlayerService audioService;
  final Function(double) onSpeedChange;

  const AudioExtendedControls({
    super.key,
    required this.audioService,
    required this.onSpeedChange,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        StreamBuilder<double>(
          stream: audioService.volumeStream,
          builder: (context, snapshot) {
            final volume = snapshot.data ?? 1.0;
            return Row(
              children: [
                const Icon(Icons.volume_down, size: 20),
                Expanded(
                  child: Slider(
                    value: volume,
                    onChanged: audioService.setVolume,
                    activeColor: colorScheme.primary,
                    inactiveColor: colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                const Icon(Icons.volume_up, size: 20),
              ],
            );
          },
        ),
        StreamBuilder<double>(
          stream: audioService.speedStream,
          builder: (context, snapshot) {
            final speed = snapshot.data ?? 1.0;
            return GestureDetector(
              onTap: () {
                final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
                final current = speeds.indexOf(speed);
                final next = (current + 1) % speeds.length;
                onSpeedChange(speeds[next]);
              },
              child: Text(
                '${speed}x',
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ],
    );
  }
}
