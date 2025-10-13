import '../../../common/app_imports.dart';
import 'AudioHeader.dart';
import 'AudioControls.dart';
import 'audioProgressBar.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerUI extends StatefulWidget {
  final String audioAssetPath;
  final String? audioUrl;
  final String? title;
  final String? artist;
  final String? coverImageAssetPath;
  final VoidCallback? onCompleted;

  const AudioPlayerUI({
    super.key,
    required this.audioAssetPath,
    this.audioUrl,
    this.title,
    this.artist,
    this.coverImageAssetPath,
    this.onCompleted,
  });

  @override
  State<AudioPlayerUI> createState() => _AudioPlayerUIState();
}

class _AudioPlayerUIState extends State<AudioPlayerUI> {
  final AudioPlayerService _audioService = AudioPlayerService();

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    // 监听播放状态流
    _audioService.playerStateStream.listen((state) {
      final processingState = state.processingState;
      final isPlaying = state.playing;
      if (isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
      if (processingState == ProcessingState.completed) {
        // 播放完成
        if (widget.onCompleted != null) {
          widget.onCompleted!();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant AudioPlayerUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.audioAssetPath != oldWidget.audioAssetPath ||
        widget.audioUrl != oldWidget.audioUrl) {
      _initializeAudio();
    }
  }

  Future<void> _initializeAudio() async {
    await _audioService.initialize();
    if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
      await _audioService.setAudioSource(widget.audioUrl!);
      await _audioService.play();
    } else {
      await _audioService.setAssetAudioSource(widget.audioAssetPath);
      await _audioService.play();
    }
    await _audioService.setLoopMode(LoopMode.one);
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
  }

  Future<void> _seek(double value, Duration duration) async {
    final position =
        Duration(milliseconds: (value * duration.inMilliseconds).toInt());
    await _audioService.seek(position);
  }

  Future<void> _seekRelative(int seconds) async {
    final current = _audioService.currentPosition;
    final duration = _audioService.duration ?? Duration.zero;
    final newPos = current + Duration(seconds: seconds);

    // 限制范围
    final safePos = newPos < Duration.zero
        ? Duration.zero
        : (newPos > duration ? duration : newPos);

    await _audioService.seek(safePos);
  }

  Future<void> _setSpeed(double speed) async {
    await _audioService.setSpeed(speed);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左边专辑封面
        Container(
          padding: EdgeInsets.only(left: 0.3.w),
          width:
              globalDeviceType == CustomDeviceType.tablet ? 15.w : 63.w, // 明确宽度
          child: AudioHeader(
              title: widget.title,
              artist: widget.artist,
              coverImageAssetPath: widget.coverImageAssetPath,
              isPlaying: _isPlaying),
        ),

        SizedBox(width: 1.w),
        if (globalDeviceType == CustomDeviceType.tablet)
          SizedBox(
              width: 63.w,
              child: AudioProgressBar(
                audioService: _audioService,
                onSeek: _seek,
              )),
        SizedBox(width: 1.w),
        SizedBox(
          width: globalDeviceType == CustomDeviceType.tablet ? 16.w : 28.w,
          child: globalDeviceType == CustomDeviceType.tablet
              ? TabletAudioControls(
                  onPlayPauseToggle: _togglePlayPause,
                  isPlaying: _isPlaying,
                )
              : StreamBuilder<Duration?>(
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

                        return PhoneAudioControls(
                          isPlaying: _isPlaying,
                          progress: progress,
                          onPlayPauseToggle: () {
                            _isPlaying
                                ? _audioService.pause()
                                : _audioService.play();
                          },
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
