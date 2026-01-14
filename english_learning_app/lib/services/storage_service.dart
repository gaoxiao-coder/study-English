import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';
import '../models/app_settings.dart';

/// 本地存储服务
class StorageService {
  static const String _wordsKey = 'words_data';
  static const String _settingsKey = 'app_settings';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _levelMasteryKey = 'level_mastery_data';

  /// 保存单词列表
  static Future<bool> saveWords(List<Word> words) async {
    final prefs = await SharedPreferences.getInstance();
    final wordsJson = words.map((word) => word.toJson()).toList();
    return await prefs.setString(_wordsKey, json.encode(wordsJson));
  }

  /// 加载单词列表
  static Future<List<Word>> loadWords() async {
    final prefs = await SharedPreferences.getInstance();
    final wordsString = prefs.getString(_wordsKey);
    
    if (wordsString == null) {
      return [];
    }
    
    try {
      final wordsJson = json.decode(wordsString) as List;
      return wordsJson.map((json) => Word.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 加载指定等级的单词列表（从JSON文件获取词汇，合并本地掌握状态）
  static Future<List<Word>> loadWordsByLevel(String level) async {
    final allWords = await loadWords();
    return allWords.where((word) => word.level == level).toList();
  }

  /// 保存应用设置
  static Future<bool> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_settingsKey, json.encode(settings.toJson()));
  }

  /// 加载应用设置
  static Future<AppSettings?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_settingsKey);
    
    if (settingsString == null) {
      return null;
    }
    
    try {
      final settingsJson = json.decode(settingsString);
      return AppSettings.fromJson(settingsJson);
    } catch (e) {
      return null;
    }
  }

  /// 检查是否首次启动
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_isFirstLaunchKey) ?? false);
  }

  /// 设置已首次启动
  static Future<bool> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_isFirstLaunchKey, true);
  }

  /// 清除所有数据（用于重置）
  static Future<bool> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  /// 保存单个单词的掌握状态
  static Future<bool> updateWordMastery(String wordId, bool isMastered) async {
    final words = await loadWords();
    final index = words.indexWhere((w) => w.id == wordId);
    
    if (index != -1) {
      words[index] = words[index].copyWith(isMastered: isMastered);
      return await saveWords(words);
    }
    
    return false;
  }

  /// 增加单词复习次数
  static Future<bool> incrementWordReviewCount(String wordId) async {
    final words = await loadWords();
    final index = words.indexWhere((w) => w.id == wordId);
    
    if (index != -1) {
      words[index] = words[index].copyWith(
        reviewCount: words[index].reviewCount + 1,
      );
      return await saveWords(words);
    }
    
    return false;
  }

  /// 保存指定等级的单词掌握状态
  /// key格式: level_xxx_word_xxx (例如: level_cet4_word_1)
  static Future<bool> saveWordMasteryByLevel(String level, String wordId, bool isMastered) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${level}_${wordId}';
    return await prefs.setBool(key, isMastered);
  }

  /// 获取指定等级单词的掌握状态
  static Future<bool?> getWordMasteryByLevel(String level, String wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${level}_${wordId}';
    return prefs.getBool(key);
  }

  /// 保存整个等级的掌握状态数据
  static Future<bool> saveLevelMasteryData(String level, Map<String, bool> masteryData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(masteryData);
    return await prefs.setString('${_levelMasteryKey}_$level', jsonString);
  }

  /// 加载整个等级的掌握状态数据
  static Future<Map<String, bool>> loadLevelMasteryData(String level) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_levelMasteryKey}_$level');
    
    if (jsonString == null) {
      return {};
    }
    
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      return Map<String, bool>.from(data);
    } catch (e) {
      return {};
    }
  }

  /// 获取指定等级已掌握单词数量
  static Future<int> getMasteredCountByLevel(String level) async {
    final masteryData = await loadLevelMasteryData(level);
    return masteryData.values.where((isMastered) => isMastered).length;
  }

  /// 重置指定等级的掌握状态
  static Future<bool> resetLevelMastery(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove('${_levelMasteryKey}_$level');
  }
}
