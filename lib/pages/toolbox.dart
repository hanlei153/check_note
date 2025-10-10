import 'package:check_note/common/func/task_database.dart';
import 'package:flutter/material.dart';
import 'toolbox/kegelpage.dart';
import 'toolbox/focuspage.dart';
import 'toolbox/relaxpage.dart';
// import 'package:check_note/common/func/notificationService.dart';

class ToolboxPage extends StatefulWidget {
  const ToolboxPage({super.key});
  @override
  State<ToolboxPage> createState() => _ToolboxPageState();

  static Widget _buildFeatureCard(
      IconData icon, String label, BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolboxPageState extends State<ToolboxPage> {
  DateTime today = DateTime.now();
  bool isCheckIn = false;
  int checkInCount = 0;

  void debugPrintDatabase() async {
    final tasks = await DatabaseHelper().getAllTasks();
    final times = await DatabaseHelper().getAllNotificationTimes();
    final checkins = await DatabaseHelper().getAllCheckIn();

    print('Tasks:');
    for (var task in tasks) {
      print(task);
    }

    print('Notification Times:');
    for (var time in times) {
      print(time);
    }

    print('checkIns:');
    for (var checkin in checkins) {
      print(checkin);
    }
  }

  void hasCheckedInToday() async {
    bool checkInToday = await DatabaseHelper().hasCheckedInToday(today);
    int _checkInCount = await DatabaseHelper().getTotalCheckinCount();
    if (checkInToday) {
      setState(() {
        isCheckIn = true;
        checkInCount = _checkInCount;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    hasCheckedInToday();
    // debugPrintDatabase();
    // DatabaseHelper().clearCheckins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工具箱'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton(
              onPressed: () async {
                await DatabaseHelper().checkInToday(today);
                hasCheckedInToday();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isCheckIn ? '已签到' : '签到'),
                  Text(
                    '累计$checkInCount天',
                    style: TextStyle(fontSize: 10),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2, // 每行两个
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            ToolboxPage._buildFeatureCard(
                Icons.self_improvement, 'Kegel训练', context, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KegelPage()),
              );
            }),
            ToolboxPage._buildFeatureCard(Icons.psychology, '专注', context, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FocusPage()),
              );
            }),
            ToolboxPage._buildFeatureCard(Icons.spa, '放松', context, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RelaxPage()),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// 选择通知时间
Future<TimeOfDay?> pickTime(BuildContext context) async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 9, minute: 0),
    helpText: "请选择通知时间",
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
  );
  return pickedTime;
}
