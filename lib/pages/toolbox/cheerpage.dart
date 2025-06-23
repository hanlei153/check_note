import 'package:flutter/material.dart';
import 'dart:async';

class CheerPage extends StatefulWidget {
  @override
  _CheerPageState createState() => _CheerPageState();
}

class _CheerPageState extends State<CheerPage> {
  String text = '已经加油啦~';
  bool isDisplay = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('加油打气页')),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isDisplay = true;
                  });
          
                  // 设置在2秒后渐隐
                  Timer(Duration(milliseconds: 200), () {
                    setState(() {
                      isDisplay = false;
                    });
                  });
                },
                child: Text('加 油'),
              ),
              SizedBox(height: 24),
              AnimatedOpacity(
                opacity: isDisplay ? 1.0 : 0.0,
                duration: Duration(milliseconds: 600),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
