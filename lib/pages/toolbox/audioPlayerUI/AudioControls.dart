import '../../../common/app_imports.dart';

class TabletAudioControls extends StatelessWidget {
  final VoidCallback onPlayPauseToggle;
  final bool isPlaying;

  const TabletAudioControls({
    super.key,
    required this.onPlayPauseToggle,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent, // 去掉背景色
            border: Border.all(
                color: Colors.black, // 黑色边框
                width: 3),
          ),
          child: Center(
            child: IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black, size: 2.8.w),
              onPressed: onPlayPauseToggle,
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent, // 去掉点击波纹
              highlightColor: Colors.transparent, // 去掉点击高亮
            ),
          ),
        ),
      ],
    );
  }
}

class PhoneAudioControls extends StatelessWidget {
  final VoidCallback onPlayPauseToggle;
  final bool isPlaying;
  final double progress; // 0.0 ~ 1.0

  const PhoneAudioControls({
    super.key,
    required this.onPlayPauseToggle,
    required this.isPlaying,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final double size = 8.w; // 整体大小

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🔹 黑色进度条覆盖
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: size * 0.08, // 进度条粗细按比例
              backgroundColor: Colors.grey, // 灰色底圈
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 29, 29, 29)),
            ),
          ),

          // 🔹 中间播放/暂停图标
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: const Color.fromARGB(255, 29, 29, 29),
              size: size * 0.8, // 图标大小
            ),
            onPressed: onPlayPauseToggle,
            padding: EdgeInsets.zero,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
