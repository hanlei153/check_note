import 'toolbox/kegelpage.dart';
import 'toolbox/focuspage.dart';
import 'toolbox/relaxpage.dart';
// import 'package:check_note/common/func/notificationService.dart';

import '../common/app_imports.dart';

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

  @override
  void initState() {
    super.initState();
    // debugPrintDatabase();
    // DatabaseHelper().clearCheckins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工具箱'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          // crossAxisCount: 2, // 每行两个
          crossAxisCount: globalDeviceType == CustomDeviceType.tablet ? 4 : 2,
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
