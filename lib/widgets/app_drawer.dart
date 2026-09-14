import '../common/app_imports.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _loadReminderTime();
  }

  Future<void> _loadReminderTime() async {
    final time = await DatabaseHelper().getNotificationTime();
    if (mounted) {
      setState(() => _reminderTime = time);
    }
  }

  Future<void> _selectReminderTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: '设置每日提醒时间',
      cancelText: '取消',
      confirmText: '保存',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (selectedTime == null || !mounted) {
      return;
    }

    await DatabaseHelper().saveNotificationTime(selectedTime);
    await NotificationService.scheduleDailyNotification();

    if (!mounted) {
      return;
    }

    setState(() => _reminderTime = selectedTime);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('每日提醒已设置为 ${_formatTime(selectedTime)}')),
    );
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return '未设置';
    }
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                '设置',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('每日提醒时间'),
              subtitle: Text(_formatTime(_reminderTime)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectReminderTime,
            ),
          ],
        ),
      ),
    );
  }
}
