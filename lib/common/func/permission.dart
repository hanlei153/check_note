import 'package:permission_handler/permission_handler.dart';

Future<void> checkAndRequestNotificationPermission() async {
  // 检查当前权限状态
  var status = await Permission.notification.status;

  if (status.isGranted) {
    // 权限已经授予
    print("notification permission granted.");
  } else if (status.isDenied) {
    // 请求权限
    PermissionStatus result = await Permission.notification.request();
    if (result.isGranted) {
      print("notification permission granted after request.");
    } else {
      print("notification permission denied.");
    }
  }
}