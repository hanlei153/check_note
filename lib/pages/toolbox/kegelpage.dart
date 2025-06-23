import 'package:flutter/material.dart';
import 'dart:async';

class KegelPage extends StatefulWidget {
  @override
  _KegelPageState createState() => _KegelPageState();
}

class _KegelPageState extends State<KegelPage>
    with SingleTickerProviderStateMixin {
  bool _isRunning = false;
  String _action = '夹紧'; // 初始动作
  Timer? _switchTimer;
  late AnimationController _progressController;
  int _cycleCount = 1; // 循环次数计数器

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _switchTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _toggleCycle() {
    if (_isRunning) {
      _stopCycle();
    } else {
      _startCycle();
    }
  }

  void _startCycle() {
    setState(() {
      _isRunning = true;
      _action = '夹紧';
      _cycleCount = 1; // 每次启动重置计数
    });

    _progressController.forward(from: 0);
    _switchTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        if (_action == '放松') {
          _cycleCount += 1; // 夹紧 → 放松 → 夹紧，视为一个完整循环
        }
        _action = _action == '夹紧' ? '放松' : '夹紧';
      });
      _progressController.forward(from: 0);
    });
  }

  void _stopCycle() {
    _switchTimer?.cancel();
    _progressController.stop();
    setState(() {
      _isRunning = false;
      _action = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kegel训练控制器')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _action,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '循环次数：$_cycleCount',
              style: TextStyle(fontSize: 22, color: Colors.grey[700]),
            ),
            SizedBox(height: 40),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressController.value,
                  minHeight: 16,
                );
              },
            ),
            SizedBox(height: 60),
            ElevatedButton.icon(
              icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
              label: Text(_isRunning ? '暂停' : '开始'),
              onPressed: _toggleCycle,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
