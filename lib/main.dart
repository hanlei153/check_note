import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'mainframePage.dart';
import 'common/app_imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN', null);

  // // 设置状态栏和导航栏透明
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent, // 状态栏透明
  //   systemNavigationBarColor: Colors.transparent, // 导航栏透明
  //   systemNavigationBarDividerColor: Colors.transparent, // 导航栏分割线透明
  //   statusBarIconBrightness: Brightness.light, // 状态栏图标颜色（白色）
  //   systemNavigationBarIconBrightness: Brightness.light, // 导航栏图标颜色（白色）
  // ));
  await NotificationService.initializeAndSchedule();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initGlobalDeviceType(context);
      print('设备类型: $globalDeviceType');
    });
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'Check Note',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF7DA683), // 主色：绿色
            primary: Color(0xFF234631), // 主色深色（按钮等）
            secondary: Color(0xFFFFF5CC), // 浅黄色作为点缀色
          ),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'), // 中文
          Locale('en', 'US'), // 英文（可选）
        ],
        locale: const Locale('zh', 'CN'),
        home: MainFramePage(),
      );
    });
  }
}
