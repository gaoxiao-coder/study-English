import 'package:flutter/material.dart';

/// 应用设置数据模型
class AppSettings with ChangeNotifier {
  /// 深色模式开关
  bool isDarkMode;
  
  /// 学习进度（已掌握单词数）
  int masteredCount;
  
  /// 总学习次数
  int totalStudySessions;
  
  /// 总测试次数
  int totalTestSessions;
  
  /// 最高正确率
  double bestAccuracy;

  AppSettings({
    this.isDarkMode = false,
    this.masteredCount = 0,
    this.totalStudySessions = 0,
    this.totalTestSessions = 0,
    this.bestAccuracy = 0.0,
  });

  /// 切换深色模式
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  /// 设置深色模式
  void setDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  /// 更新已掌握单词数
  void updateMasteredCount(int count) {
    masteredCount = count;
    notifyListeners();
  }

  /// 增加学习次数
  void incrementStudySessions() {
    totalStudySessions++;
    notifyListeners();
  }

  /// 增加测试次数
  void incrementTestSessions() {
    totalTestSessions++;
    notifyListeners();
  }

  /// 更新最高正确率
  void updateBestAccuracy(double accuracy) {
    if (accuracy > bestAccuracy) {
      bestAccuracy = accuracy;
      notifyListeners();
    }
  }

  /// 重置学习进度
  void resetProgress() {
    masteredCount = 0;
    totalStudySessions = 0;
    totalTestSessions = 0;
    bestAccuracy = 0.0;
    notifyListeners();
  }

  /// 从JSON创建对象
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] ?? false,
      masteredCount: json['masteredCount'] ?? 0,
      totalStudySessions: json['totalStudySessions'] ?? 0,
      totalTestSessions: json['totalTestSessions'] ?? 0,
      bestAccuracy: (json['bestAccuracy'] ?? 0.0).toDouble(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'masteredCount': masteredCount,
      'totalStudySessions': totalStudySessions,
      'totalTestSessions': totalTestSessions,
      'bestAccuracy': bestAccuracy,
    };
  }
}
