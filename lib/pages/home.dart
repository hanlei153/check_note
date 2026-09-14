import 'package:table_calendar/table_calendar.dart';

import '../common/app_imports.dart';

class CheckNoteHomePage extends StatefulWidget {
  const CheckNoteHomePage({super.key, required this.onOpenDrawer});

  final VoidCallback onOpenDrawer;

  @override
  State<CheckNoteHomePage> createState() => _CheckNoteHomePageState();
}

class _CheckNoteHomePageState extends State<CheckNoteHomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Task> _tasks = [];
  Set<DateTime> _eventDays = {};
  bool isShowBanner = true;
  @override
  void initState() {
    super.initState();
    _refreshCheckInStatus();
    _loadTasksForDay(_selectedDay);
    _loadAllDateTasks();
    // checkAndRequestNotificationPermission();
  }

  void _loadTasksForDay(DateTime day) async {
    final dateStr = _formatDate(day);
    final tasks = await DatabaseHelper().getTasksByDate(dateStr);
    setState(() {
      _selectedDay = day;
      _tasks = tasks;
    });
  }

  void _loadAllDateTasks() async {
    final allDateTasks = await DatabaseHelper().getAllTasks();
    setState(() {
      _eventDays = allDateTasks.map((task) {
        final date = DateTime.parse(task['date']);
        return DateTime(date.year, date.month, date.day);
      }).toSet();
    });
  }

  Future<void> _copyTaskToDates(Task task, Set<DateTime> dates) async {
    final sortedDates = dates.toList()..sort();
    final copiedItems = sortedDates
        .map(
          (date) => Task(
            date: _formatDate(date),
            name: task.name,
            details: task.details,
          ),
        )
        .toList();

    await DatabaseHelper().insertTasks(copiedItems);
    await NotificationService.scheduleDailyNotification();
    _loadAllDateTasks();
    if (dates.any((date) => isSameDay(date, _selectedDay))) {
      _loadTasksForDay(_selectedDay);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已复制到 ${sortedDates.length} 个日期')),
    );
  }

  Future<Set<DateTime>?> _showMultiDatePicker() {
    final selectedDates = <DateTime>{};
    var focusedDay = DateTime.now();

    return showDialog<Set<DateTime>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '选择复制日期',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TableCalendar<void>(
                  locale: 'zh_CN',
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  focusedDay: focusedDay,
                  rowHeight: 42,
                  daysOfWeekHeight: 28,
                  availableCalendarFormats: const {
                    CalendarFormat.month: '月',
                  },
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Color(0xFF234631),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Color(0xFF234631),
                    ),
                  ),
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF234631),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0x807DA683),
                      shape: BoxShape.circle,
                    ),
                    outsideTextStyle: TextStyle(color: Color(0xFFBDBDBD)),
                    weekendTextStyle: TextStyle(color: Color(0xFF424242)),
                  ),
                  selectedDayPredicate: (day) => selectedDates.contains(
                    DateTime(day.year, day.month, day.day),
                  ),
                  onPageChanged: (day) => focusedDay = day,
                  onDaySelected: (selectedDay, newFocusedDay) {
                    final date = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                    );
                    setDialogState(() {
                      focusedDay = newFocusedDay;
                      if (!selectedDates.add(date)) {
                        selectedDates.remove(date);
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: selectedDates.isEmpty
                          ? null
                          : () => Navigator.pop(
                                dialogContext,
                                Set<DateTime>.from(selectedDates),
                              ),
                      child: Text('复制（${selectedDates.length}）'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime today = DateTime.now();
  bool isCheckIn = false;
  int checkInCount = 0;

  Future<void> _refreshCheckInStatus() async {
    final checkedInToday = await DatabaseHelper().hasCheckedInToday(today);
    final totalCheckInCount = await DatabaseHelper().getTotalCheckinCount();

    if (!mounted) return;
    setState(() {
      isCheckIn = checkedInToday;
      checkInCount = totalCheckInCount;
    });
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Widget _buildDayCell(DateTime day,
      {bool isToday = false, bool isSelected = false}) {
    final hasEvent = _hasEventForDay(day);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: 35,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF234631)
            : isToday
                ? const Color(0xFF7DA683).withOpacity(0.5)
                : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
            child: Text('${day.day}'),
          ),
          if (hasEvent)
            Transform.translate(
              offset: const Offset(0, 12),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 35,
                  color:
                      isSelected ? Colors.white : Color.fromARGB(255, 0, 0, 0),
                  height: 0.1,
                ),
                child: Text('·'),
              ),
            ),
        ],
      ),
    );
  }

  bool _hasEventForDay(DateTime day) {
    // 例如：判断该日期是否在打卡列表中
    return _eventDays.contains(DateTime(day.year, day.month, day.day));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: '打开设置',
          onPressed: widget.onOpenDrawer,
        ),
        title: Text('Check Note'),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 20),
            child: ElevatedButton(
                onPressed: () => _showAddTaskDialog(), child: Text('新增打卡')),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          children: [
            if (isShowBanner)
              Container(
                padding:
                    EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  color: Color.fromARGB(
                      255, 213, 238, 217), // 背景色，推荐使用你的 secondary 色
                  borderRadius: BorderRadius.circular(12), // 圆角
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2), // 轻微阴影
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isCheckIn ? '今天好像已经签到过啦！' : "今天签到了吗？",
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                    // 占位符
                    Spacer(flex: 1),

                    ElevatedButton(
                      onPressed: () async {
                        await DatabaseHelper().checkInToday(today);
                        await _refreshCheckInStatus();
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
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isShowBanner = false;
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            TableCalendar(
              locale: 'zh_CN',
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              daysOfWeekVisible: true,
              availableGestures: AvailableGestures.all,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                titleCentered: true,
                leftChevronVisible: true,
                rightChevronVisible: true,
                formatButtonVisible: false,
              ),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected; // 更新选中日期
                  _focusedDay = focused; // 更新焦点日期，控制当前页面显示
                });
                _loadTasksForDay(selected); // 加载对应日期打卡项
                _loadAllDateTasks(); // 刷新所有日期的打卡项状态
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _buildDayCell(day);
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildDayCell(day, isToday: true);
                },
                selectedBuilder: (context, day, focusedDay) {
                  return _buildDayCell(day, isSelected: true);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (_, index) {
                  final task = _tasks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: GestureDetector(
                      onLongPress: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                padding: EdgeInsets.all(20),
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('修改打卡项'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _showEditDialog(task);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.copy),
                                      title: Text('复制打卡项'),
                                      onTap: () async {
                                        Navigator.pop(context); // 关闭菜单
                                        final pickedDates =
                                            await _showMultiDatePicker();
                                        if (pickedDates != null &&
                                            pickedDates.isNotEmpty) {
                                          await _copyTaskToDates(
                                            task,
                                            pickedDates,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      child: Dismissible(
                        key: Key(task.id.toString()),
                        direction: DismissDirection.endToStart, // 右滑删除（从右向左滑）
                        background: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          bool? isConfirm = await _confirmDialog(task.id);
                          return isConfirm ==
                              true; // 只有返回 true 时才会触发 onDismissed
                        },
                        onDismissed: (_) {
                          _loadTasksForDay(_selectedDay);
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (task.details.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            task.details,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Checkbox(
                                  value: task.done,
                                  onChanged: (value) async {
                                    final updated = Task(
                                      id: task.id,
                                      date: task.date,
                                      name: task.name,
                                      details: task.details,
                                      done: value ?? false,
                                    );
                                    await DatabaseHelper().updateTask(updated);
                                    await NotificationService
                                        .scheduleDailyNotification();
                                    _loadTasksForDay(_selectedDay);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDialog(int? taskid) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('删除打卡项'),
            content: Text('确认删除该打卡项吗'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // 取消
                },
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (taskid != null) {
                    await DatabaseHelper().deleteTask(taskid);
                    await NotificationService.scheduleDailyNotification();
                    Navigator.of(context).pop(true); // 确认删除
                  } else {
                    Navigator.of(context).pop(false); // 无效ID，不删除
                  }
                },
                child: Text('确认'),
              ),
            ],
          );
        });
  }

  void _showEditDialog(Task task) {
    final nameController = TextEditingController(text: task.name);
    final detailsController = TextEditingController(text: task.details);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('编辑打卡项',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '打卡项名称',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '打卡项详情',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('取消'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        final newDetails = detailsController.text.trim();

                        if (newName.isEmpty) return;

                        final updatedTask = Task(
                          id: task.id,
                          date: task.date,
                          name: newName,
                          details: newDetails,
                          done: task.done,
                        );

                        await DatabaseHelper().updateTask(updatedTask);
                        await NotificationService.scheduleDailyNotification();
                        Navigator.of(context).pop();
                        _loadTasksForDay(_selectedDay);
                      },
                      child: Text('保存'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTaskDialog() {
    final nameController = TextEditingController();
    final detailsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许内容撑满高度
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('新增打卡项',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '打卡项名称',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '打卡项详情',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('取消'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final task = Task(
                          date: _formatDate(_selectedDay),
                          name: name,
                          details: detailsController.text.trim(),
                        );
                        await DatabaseHelper().insertTask(task);
                        await NotificationService.scheduleDailyNotification();
                        Navigator.pop(context);
                        _loadTasksForDay(_selectedDay);
                        _loadAllDateTasks();
                      },
                      child: Text('添加'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
