import 'package:flutter/material.dart';
import 'dart:async';
import 'UI/audioPlayerUi2.dart';
import '../../common/model/audioItem.dart';

class FocusPage extends StatefulWidget {
  @override
  _FocusPageState createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
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
                  style: TextStyle(
                    color: Colors.white,
                  ),
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
        return AudioPlayerUI2(
          audioAssetPath: audioItem.audioAssetPath,
          title: audioItem.title,
          artist: audioItem.artist,
          coverImageAssetPath: audioItem.coverImageAssetPath,
        );
      },
    );
  }
}
