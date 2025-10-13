import 'package:table_calendar/table_calendar.dart';

import '../common/app_imports.dart';

class CheckNoteHomePage extends StatefulWidget {
  @override
  _CheckNoteHomePageState createState() => _CheckNoteHomePageState();
}

class _CheckNoteHomePageState extends State<CheckNoteHomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Task> _tasks = [];
  bool isShowBanner = true;
  @override
  void initState() {
    super.initState();
    _loadTasksForDay(_selectedDay);
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

  void _copyTaskToDate(Task task, DateTime date) async {
    final copiedItem = Task(
      date: _formatDate(date),
      name: task.name,
      details: task.details,
    );

    await DatabaseHelper().insertTask(copiedItem);
    // 可选：显示提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("已复制到 ${date.toLocal().toString().split(' ')[0]}")),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: AppBar(
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
                      "今天任务完成了吗？",
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            isShowBanner = false;
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 15,
                        ))
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
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF234631), // 深绿色圆圈
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFF7DA683).withOpacity(0.5), // 浅绿色圆圈
                  shape: BoxShape.circle,
                ),
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
                                        DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != null) {
                                          _copyTaskToDate(task, picked);
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
                        Navigator.pop(context);
                        _loadTasksForDay(_selectedDay);
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
