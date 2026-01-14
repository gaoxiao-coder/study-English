import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/app_settings.dart';
import 'models/word.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  // 初始化应用
  await _initializeApp();
  
  runApp(const MyApp());
}

/// 初始化应用数据
Future<void> _initializeApp() async {
  final isFirstLaunch = await StorageService.isFirstLaunch();
  
  if (isFirstLaunch) {
    /// 首次启动：保存初始单词数据
    final initialWords = WordData.getInitialWords();
    await StorageService.saveWords(initialWords);
    await StorageService.setFirstLaunchComplete();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSettings?>(
      future: StorageService.loadSettings(),
      builder: (context, snapshot) {
        final settings = snapshot.data ?? AppSettings();
        
        return ChangeNotifierProvider.value(
          value: settings,
          child: Consumer<AppSettings>(
            builder: (context, settings, child) {
              return MaterialApp(
                title: '英语学习App',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  fontFamily: 'NotoSansSC', 
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue,
                    brightness: Brightness.light,
                  ),
                  cardTheme: const CardThemeData(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  fontFamily: 'NotoSansSC', 
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue,
                    brightness: Brightness.dark,
                  ),
                  cardTheme: const CardThemeData(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                home: const HomeScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
