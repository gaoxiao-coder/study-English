import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  /// 重置学习进度
  Future<void> _resetProgress(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重置'),
        content: const Text('确定要重置所有学习进度吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('确定重置'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      /// 重置所有单词的掌握状态和复习次数
      final words = await StorageService.loadWords();
      for (var i = 0; i < words.length; i++) {
        words[i] = words[i].copyWith(
          isMastered: false,
          reviewCount: 0,
        );
      }
      await StorageService.saveWords(words);
      
      /// 重置设置中的学习进度
      context.read<AppSettings>().resetProgress();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('学习进度已重置'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// 重置应用数据（包括所有设置）
  Future<void> _resetAllData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('警告'),
        content: const Text('确定要重置所有数据吗？这将清除所有学习进度和设置。此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('确定重置'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearAllData();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('所有数据已重置，请重启应用'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<AppSettings>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// 外观设置
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '外观',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('深色模式'),
                      subtitle: const Text('切换深色/浅色主题'),
                      value: settings.isDarkMode,
                      onChanged: (value) {
                        settings.setDarkMode(value);
                      },
                      secondary: Icon(
                        settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              /// 学习设置
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '学习',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.school),
                      title: const Text('学习次数'),
                      trailing: Text(
                        '${settings.totalStudySessions} 次',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.quiz),
                      title: const Text('测试次数'),
                      trailing: Text(
                        '${settings.totalTestSessions} 次',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.star),
                      title: const Text('最高正确率'),
                      trailing: Text(
                        '${settings.bestAccuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.check_circle),
                      title: const Text('已掌握单词'),
                      trailing: Text(
                        '${settings.masteredCount} 个',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              /// 关于信息
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '关于',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('版本'),
                      trailing: const Text(
                        '1.0.0',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('单词总数'),
                      trailing: const Text(
                        '100',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              /// 危险操作
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '危险操作',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Colors.orange),
                      title: const Text('重置学习进度'),
                      subtitle: const Text('清除所有单词的掌握状态'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _resetProgress(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('重置所有数据'),
                      subtitle: const Text('清除所有数据，需要重启应用'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _resetAllData(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              /// 提示信息
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '建议每天学习10-20个单词，并定期进行测试以巩固记忆。',
                          style: TextStyle(
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
