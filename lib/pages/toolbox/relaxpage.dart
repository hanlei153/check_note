import 'package:flutter/material.dart';
import 'dart:async';
import 'UI/audioPlayerUi.dart';
import '../../common/model/audioItem.dart';

class RelaxPage extends StatefulWidget {
  @override
  _RelaxPageState createState() => _RelaxPageState();
}

class _RelaxPageState extends State<RelaxPage> {
  String? _currentlyPlayingId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
        appBar: AppBar(title: Text('relax时刻')),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 每行显示2个
            crossAxisSpacing: 16, // 水平间距
            mainAxisSpacing: 16, // 垂直间距
            childAspectRatio: 1.0, // 宽高比，可以根据需要调整
          ),
          itemCount: _audioItems.length,
          itemBuilder: (context, index) {
            final audioItem = _audioItems[index];
            final isPlaying = _currentlyPlayingId == audioItem.id;

            return GestureDetector(
              onTap: () {
                _showAudioPlayerBottomSheet(context, audioItem);
              },
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
                  style: TextStyle(color: Colors.white, ),
                ),
              ),
            );
          },
        ));
  }

  void _showAudioPlayerBottomSheet(BuildContext context, AudioItem audioItem) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AudioPlayerUI(
          audioAssetPath: audioItem.audioAssetPath,
          title: audioItem.title,
          artist: audioItem.artist,
          coverImageAssetPath: audioItem.coverImageAssetPath,
        );
      },
    );
  }
}
