import 'package:flutter/material.dart';
import '../../../common/func/audioPlayer.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerUI extends StatefulWidget {
  final String audioAssetPath;
  final String? audioUrl;
  final String? title;
  final String? artist;
  final String? coverImageAssetPath;

  const AudioPlayerUI({
    super.key,
    required this.audioAssetPath,
    this.audioUrl,
    this.title,
    this.artist,
    this.coverImageAssetPath,
  });

  @override
  State<AudioPlayerUI> createState() => _AudioPlayerUIState();
}

class _AudioPlayerUIState extends State<AudioPlayerUI> {
  final AudioPlayerService _audioService = AudioPlayerService();
  bool _isLoading = true;
  bool _loadError = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _initializeAudio() async {
    try {
      await _audioService.initialize();

      if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
        await _audioService.setAudioSource(widget.audioUrl!);
      } else if (widget.audioAssetPath.isNotEmpty) {
        await _audioService.setAssetAudioSource(widget.audioAssetPath);
      } else {
        throw Exception('没有提供音频文件');
      }

      await _audioService.setLoopMode(LoopMode.one);

      setState(() {
        _isLoading = false;
        _loadError = false;
      });
    } catch (e) {
      print('Error initializing audio: $e');
      setState(() {
        _isLoading = false;
        _loadError = true;
      });
    }
  }

  Future<void> _seek(double value, Duration duration) async {
    final position =
        Duration(milliseconds: (value * duration.inMilliseconds).toInt());
    await _audioService.seek(position);
  }

  Future<void> _seekRelative(int seconds) async {
    final currentPosition = _audioService.currentPosition;
    final duration = _audioService.duration;

    if (duration != null) {
      // 计算新的位置
      final newPosition = currentPosition + Duration(seconds: seconds);

      // 限制范围：不能小于0，也不能超过duration
      final safePosition = newPosition < Duration.zero
          ? Duration.zero
          : (newPosition > duration ? duration : newPosition);

      await _audioService.seek(safePosition);
    }
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    setState(() {
      _playbackSpeed = speed;
    });
    await _audioService.setSpeed(speed);
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError) {
      return Center(
        child: Text(
          '加载音频失败，请检查文件路径',
          style: TextStyle(color: colorScheme.error),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.secondary.withOpacity(0.8),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: 30),
          _buildPlayerControls(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // 专辑封面
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.primary.withOpacity(0.1),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.coverImageAssetPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.coverImageAssetPath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.music_note,
                          size: 40,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.music_note,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ),
        ),
        const SizedBox(width: 16),

        // 歌曲信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title ?? '未知歌曲',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.artist ?? '未知艺术家',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls(BuildContext context) {
    return Column(
      children: [
        _buildProgressBar(context),
        const SizedBox(height: 20),
        _buildControlButtons(context),
        const SizedBox(height: 20),
        _buildExtendedControls(context),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<Duration?>(
      stream: _audioService.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: _audioService.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: colorScheme.primary,
                    inactiveTrackColor: colorScheme.primary.withOpacity(0.2),
                    thumbColor: colorScheme.primary,
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (value) => _seek(value, duration),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary.withOpacity(0.6),
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

  Widget _buildControlButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<PlayerState>(
      stream: _audioService.playerStateStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data?.playing ?? false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 16),

            // 后退10秒
            IconButton(
              onPressed: () => _seekRelative(-10),
              icon: Icon(
                Icons.replay_10,
                size: 32,
                color: colorScheme.primary.withOpacity(0.8),
              ),
            ),

            // 播放/暂停按钮
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    const Color(0xFF7DA683),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () =>
                    isPlaying ? _audioService.pause() : _audioService.play(),
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                padding: const EdgeInsets.all(16),
              ),
            ),

            // 前进10秒
            IconButton(
              onPressed: () => _seekRelative(10),
              icon: Icon(
                Icons.forward_10,
                size: 32,
                color: colorScheme.primary.withOpacity(0.8),
              ),
            ),

            const SizedBox(width: 16),
          ],
        );
      },
    );
  }

  Widget _buildExtendedControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 音量控制
        StreamBuilder<double>(
          stream: _audioService.volumeStream,
          builder: (context, snapshot) {
            final volume = snapshot.data ?? 1.0;
            return Row(
              children: [
                Icon(Icons.volume_down,
                    size: 20, color: colorScheme.primary.withOpacity(0.6)),
                const SizedBox(width: 12),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      activeTrackColor: colorScheme.primary,
                      inactiveTrackColor: colorScheme.primary.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: volume,
                      onChanged: _audioService.setVolume,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.volume_up,
                    size: 20, color: colorScheme.primary.withOpacity(0.6)),
              ],
            );
          },
        ),

        // 播放速度控制
        StreamBuilder<double>(
          stream: _audioService.speedStream,
          builder: (context, snapshot) {
            final speed = snapshot.data ?? 1.0;
            return GestureDetector(
              onTap: _isLoading
                  ? null
                  : () {
                      final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
                      final currentIndex = speeds.indexOf(speed);
                      final nextIndex = (currentIndex + 1) % speeds.length;
                      _setPlaybackSpeed(speeds[nextIndex]);
                    },
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Text(
                  '${speed}x',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary.withOpacity(0.8),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
