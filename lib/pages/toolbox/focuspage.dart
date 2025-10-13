import 'dart:async';
import 'package:check_note/pages/toolbox/audioPlayerUI/AudioPlayerUi.dart';
import 'package:sizer/sizer.dart';

import '../../common/app_imports.dart';

class FocusPage extends StatefulWidget {
  @override
  _FocusPageState createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  AudioItem? selectedAudioItem;

  final List<AudioItem> _audioItems = [
    AudioItem(
      id: '1',
      audioAssetPath: 'assets/audios/春雨.mp3',
      coverImageAssetPath: 'assets/images/春雨.png',
      title: '春雨',
      artist: 'AI',
    ),
    AudioItem(
      id: '2',
      audioAssetPath: 'assets/audios/春雨鸟鸣.MP3',
      coverImageAssetPath: 'assets/images/春雨鸟鸣.png',
      title: '春雨鸟鸣',
      artist: 'AI',
    ),
    AudioItem(
      id: '3',
      audioAssetPath: 'assets/audios/春雨轻雷.MP3',
      coverImageAssetPath: 'assets/images/春雨轻雷.png',
      title: '春雨轻雷',
      artist: 'AI',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Focus时刻')),
        body: Stack(children: [
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  globalDeviceType == CustomDeviceType.tablet ? 4 : 2, // 每行显示2个
              crossAxisSpacing: 16, // 水平间距
              mainAxisSpacing: 16, // 垂直间距
              childAspectRatio: 1.0, // 宽高比，可以根据需要调整
            ),
            itemCount: _audioItems.length,
            itemBuilder: (context, index) {
              final audioItem = _audioItems[index];
              return GestureDetector(
                onTap: () => setState(() {
                  selectedAudioItem = audioItem;
                }),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: audioItem.coverImageAssetPath != null
                        ? DecorationImage(
                            image: AssetImage(audioItem.coverImageAssetPath!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey.shade300,
                  ),
                  child: Text(
                    audioItem.title,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          if (selectedAudioItem != null)
            Positioned(
              bottom: 1.h,
              left: globalDeviceType == CustomDeviceType.tablet
                  ? (100.w - 97.w) / 2
                  : (100.w - 96.w) / 2,
              child: Container(
                padding: const EdgeInsets.all(5),
                width:
                    globalDeviceType == CustomDeviceType.tablet ? 97.w : 96.w,
                height: globalDeviceType == CustomDeviceType.tablet
                    ? 7.h
                    : 5.0.h, // 根据设备类型调整高度
                decoration: BoxDecoration(
                  color: Colors.white, // 背景色
                  borderRadius: BorderRadius.circular(30), // 圆角半径，可自定义
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AudioPlayerUI(
                  key: ValueKey(selectedAudioItem!.id),
                  audioAssetPath: selectedAudioItem!.audioAssetPath,
                  title: selectedAudioItem!.title,
                  artist: selectedAudioItem!.artist,
                  coverImageAssetPath: selectedAudioItem!.coverImageAssetPath,
                ),
              ),
            ),
        ]));
  }

  void _showAudioPlayerBottomSheet(BuildContext context, AudioItem audioItem) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AudioPlayerUI(
          key: ValueKey(audioItem.id),
          audioAssetPath: audioItem.audioAssetPath,
          title: audioItem.title,
          artist: audioItem.artist,
          coverImageAssetPath: audioItem.coverImageAssetPath,
        );
      },
    );
  }
}
