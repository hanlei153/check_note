import '../common/app_imports.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  TimeOfDay? _reminderTime;
  String _notificationTitle = NotificationService.defaultTitle;
  String _notificationBody = NotificationService.defaultBodyTemplate;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final time = await DatabaseHelper().getNotificationTime();
    final copy = await DatabaseHelper().getNotificationCopy();
    if (mounted) {
      setState(() {
        _reminderTime = time;
        _notificationTitle = copy?['title'] ?? NotificationService.defaultTitle;
        _notificationBody =
            copy?['bodyTemplate'] ?? NotificationService.defaultBodyTemplate;
      });
    }
  }

  Future<void> _editNotificationCopy() async {
    final titleController = TextEditingController(text: _notificationTitle);
    final bodyController = TextEditingController(text: _notificationBody);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('设置提醒文案'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: '通知标题',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                maxLength: 120,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '通知正文',
                  helperText: '使用 {count} 显示未完成事项数量',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (shouldSave != true || !mounted) return;

    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标题和正文不能为空')),
      );
      return;
    }

    await DatabaseHelper()
        .saveNotificationCopy(title: title, bodyTemplate: body);
    await NotificationService.scheduleDailyNotification();

    if (!mounted) return;
    setState(() {
      _notificationTitle = title;
      _notificationBody = body;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('提醒文案已保存')),
    );
  }

  Future<void> _selectReminderTime() async {
    await NotificationService.requestPermissions();
    if (!mounted) return;

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
            ListTile(
              leading: const Icon(Icons.edit_note_outlined),
              title: const Text('提醒文案'),
              subtitle: Text(
                '$_notificationTitle · $_notificationBody',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _editNotificationCopy,
            ),
          ],
        ),
      ),
    );
  }
}
