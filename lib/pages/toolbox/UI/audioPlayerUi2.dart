import 'package:flutter/material.dart';
import '../../../common/func/audioPlayer.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerUI2 extends StatefulWidget {
  final String audioAssetPath;
  final String? audioUrl;
  final String? title;
  final String? artist;
  final String? coverImageAssetPath;

  const AudioPlayerUI2({
    super.key,
    required this.audioAssetPath,
    this.audioUrl,
    this.title,
    this.artist,
    this.coverImageAssetPath,
  });

  @override
  State<AudioPlayerUI2> createState() => _AudioPlayerUI2State();
}

class _AudioPlayerUI2State extends State<AudioPlayerUI2> {
  final AudioPlayerService _audioService = AudioPlayerService();
  bool _isLoading = true;

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
      if (widget.audioUrl != null) {
        await _audioService.setAudioSource(widget.audioUrl!);
        await _audioService.setLoopMode(LoopMode.one);
      } else if (widget.audioAssetPath != null) {
        await _audioService.setAssetAudioSource(widget.audioAssetPath);
        await _audioService.setLoopMode(LoopMode.one);
      } else {
        throw Exception('没有提供音频文件');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error initializing audio: $e');
    }
  }

  Future<void> _play() async {
    await _audioService.play();
  }

  Future<void> _pause() async {
    await _audioService.pause();
  }

  Future<void> _setVolume(double value) async {
    await _audioService.setVolume(value);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    await _audioService.setSpeed(speed);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.secondary.withOpacity(0.8), // 浅黄色背景
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
          // 专辑封面和歌曲信息
          _buildHeader(),
          const SizedBox(height: 30),

          // 使用 StreamBuilder 监听播放状态和位置
          _buildPlayerControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // 专辑封面
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade300,
            image: widget.coverImageAssetPath != null
                ? DecorationImage(
                    image: AssetImage(widget.coverImageAssetPath!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: widget.coverImageAssetPath == null
              ? const Icon(Icons.music_note, size: 40, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 16),

        // 歌曲信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.artist ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.primary.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls() {
    return Column(
      children: [
        // 控制按钮
        _buildControlButtons(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildControlButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder<PlayerState>(
      stream: _audioService.playerStateStream,
      builder: (context, snapshot) {
        final isPlaying = _audioService.isPlaying;

        return Column(
          children: [
            Text(
              isPlaying ? '专注中' : '开始专注',
              style: TextStyle(fontSize: 30, color: colorScheme.primary.withOpacity(0.8),),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 播放速度
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
                              final nextIndex =
                                  (currentIndex + 1) % speeds.length;
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
                const SizedBox(width: 16),

                // 播放/暂停
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary, // 深绿色
                        Color(0xFF7DA683), // 种子色绿色
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
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (isPlaying) {
                              _pause();
                            } else {
                              _play();
                            }
                          },
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(width: 16),

                // 音量
                StreamBuilder<double>(
                  stream: _audioService.volumeStream,
                  builder: (context, snapshot) {
                    final volume = snapshot.data ?? 1.0;
                    return IconButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              _setVolume(volume > 0 ? 0.0 : 1.0);
                            },
                      icon: Icon(
                        volume > 0 ? Icons.volume_up : Icons.volume_off,
                        color: colorScheme.primary.withOpacity(0.8),
                        size: 28,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
