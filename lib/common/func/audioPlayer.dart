import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 是否已释放资源
  bool _disposed = false;

  // 播放状态流
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  // 播放位置流
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  // 总时长流
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  // 缓冲位置流
  Stream<Duration?> get bufferedPositionStream =>
      _audioPlayer.bufferedPositionStream;

  // 播放速度流
  Stream<double> get speedStream => _audioPlayer.speedStream;

  // 音量流
  Stream<double> get volumeStream => _audioPlayer.volumeStream;

  // 错误流
  Stream<dynamic> get errorStream =>
      _audioPlayer.playbackEventStream.map((event) => event);

  // 初始化音频播放器
  Future<void> initialize() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await session.setActive(true);
    } catch (e) {
      print('Error configuring audio session: $e');
    }
  }

  // 播放 assets 音频
  Future<void> setAssetAudioSource(String assetPath) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.asset(assetPath));
    } catch (e) {
      print('Error setting asset audio source: $e');
      rethrow;
    }
  }

  // 设置音频源(网络)
  Future<void> setAudioSource(String audioUrl) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
    } catch (e) {
      print('Error setting audio source: $e');
      rethrow;
    }
  }

  // 播放
  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
      rethrow;
    }
  }

  // 暂停
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing audio: $e');
      rethrow;
    }
  }

  // 停止
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio: $e');
      rethrow;
    }
  }

  // 跳转到指定位置
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
      rethrow;
    }
  }

  // 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting volume: $e');
      rethrow;
    }
  }

  // 设置播放速度 (0.5 - 2.0)
  Future<void> setSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed.clamp(0.5, 2.0));
    } catch (e) {
      print('Error setting speed: $e');
      rethrow;
    }
  }

  // 循环模式
  Future<void> setLoopMode(LoopMode loopMode) async {
    try {
      await _audioPlayer.setLoopMode(loopMode);
    } catch (e) {
      print('Error setting loop mode: $e');
      rethrow;
    }
  }

  // 获取当前播放状态
  PlayerState get currentState => _audioPlayer.playerState;

  // 获取当前播放位置
  Duration get currentPosition => _audioPlayer.position;

  // 获取总时长
  Duration? get duration => _audioPlayer.duration;

  // 获取当前音量
  double get currentVolume => _audioPlayer.volume;

  // 获取当前播放速度
  double get currentSpeed => _audioPlayer.speed;

  // 获取循环模式
  LoopMode get currentLoopMode => _audioPlayer.loopMode;

  // 释放资源
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _audioPlayer.dispose();
  }

  // 检查是否正在播放
  bool get isPlaying => _audioPlayer.playing;

  // 检查是否暂停
  bool get isPaused =>
      _audioPlayer.playerState.processingState == ProcessingState.ready &&
      _audioPlayer.playerState.playing == false;

  // 检查是否停止
  bool get isStopped =>
      _audioPlayer.playerState.processingState == ProcessingState.idle;

  // 检查是否加载中
  bool get isLoading =>
      _audioPlayer.playerState.processingState == ProcessingState.loading;

  // 检查是否缓冲中
  bool get isBuffering =>
      _audioPlayer.playerState.processingState == ProcessingState.buffering;

  // 检查是否完成
  bool get isCompleted =>
      _audioPlayer.playerState.processingState == ProcessingState.completed;
}
