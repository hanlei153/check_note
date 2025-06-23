import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/toolbox.dart';

class MainFramePage extends StatefulWidget {
  @override
  _MainFramePageState createState() => _MainFramePageState();
}

class _MainFramePageState extends State<MainFramePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    CheckNoteHomePage(),
    ToolboxPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: '工具箱',
          ),
        ],
      ),
    );
  }
}
