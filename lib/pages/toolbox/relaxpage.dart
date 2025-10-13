import 'dart:async';
import 'audioPlayerUI/AudioPlayerUi.dart';

import '../../common/app_imports.dart';

class RelaxPage extends StatefulWidget {
  @override
  _RelaxPageState createState() => _RelaxPageState();
}

class _RelaxPageState extends State<RelaxPage> {
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
      audioAssetPath: 'assets/audios/告白气球.mp3',
      coverImageAssetPath: 'assets/images/周杰伦.png',
      title: '告白气球',
      artist: '周杰伦的床边故事',
    ),
    AudioItem(
      id: '2',
      audioAssetPath: 'assets/audios/青花瓷.mp3',
      coverImageAssetPath: 'assets/images/周杰伦2.png',
      title: '青花瓷',
      artist: '我很忙',
    ),
    AudioItem(
      id: '3',
      audioAssetPath: 'assets/audios/七里香.mp3',
      coverImageAssetPath: 'assets/images/周杰伦3.png',
      title: '七里香',
      artist: '七里香',
    ),
    AudioItem(
      id: '4',
      audioAssetPath: 'assets/audios/晴天.mp3',
      coverImageAssetPath: 'assets/images/周杰伦4.png',
      title: '晴天',
      artist: '叶惠美',
    ),
    AudioItem(
      id: '5',
      audioAssetPath: 'assets/audios/稻香.mp3',
      coverImageAssetPath: 'assets/images/周杰伦5.png',
      title: '稻香',
      artist: '	魔杰座',
    ),
    AudioItem(
      id: '6',
      audioAssetPath: 'assets/audios/一路向北.mp3',
      coverImageAssetPath: 'assets/images/周杰伦3.png',
      title: '一路向北',
      artist: '	J III MP3 Player',
    ),
    AudioItem(
      id: '7',
      audioAssetPath: 'assets/audios/兰亭序.mp3',
      coverImageAssetPath: 'assets/images/周杰伦4.png',
      title: '兰亭序',
      artist: '	魔杰座',
    ),
    AudioItem(
      id: '8',
      audioAssetPath: 'assets/audios/东风破.mp3',
      coverImageAssetPath: 'assets/images/周杰伦.png',
      title: '东风破',
      artist: '叶惠美',
    ),
    AudioItem(
      id: '9',
      audioAssetPath: 'assets/audios/发如雪.mp3',
      coverImageAssetPath: 'assets/images/周杰伦2.png',
      title: '发如雪',
      artist: '	十一月的萧邦',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Relax时刻')),
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
}
