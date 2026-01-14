import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word.dart';

class WordLevelDataUtil {
  static const String _jsonPath = 'assets/data/word_levels_full.json';
  static Map<String, dynamic>? _cachedData;
  static bool _isInitialized = false;
  static final Completer<void> _initCompleter = Completer<void>();

  static Future<void> init() async {
    if (_isInitialized) {
      return _initCompleter.future;
    }
    
    if (!_initCompleter.isCompleted) {
      try {
        final String jsonString = await rootBundle.loadString(_jsonPath);
        _cachedData = json.decode(jsonString) as Map<String, dynamic>;
        _isInitialized = true;
        _initCompleter.complete();
      } catch (e) {
        _initCompleter.completeError(e);
        rethrow;
      }
    }
    
    return _initCompleter.future;
  }

  static Word _createWordFromJson(Map<String, dynamic> wordJson, String level, int index) {
    return Word(
      id: '${level}_${index}',
      english: wordJson['word'] ?? '',
      chinese: wordJson['meaning'] ?? '未找到释义',
      phonetic: wordJson['phonetic'] ?? '',
      level: level,
    );
  }

  static Future<List<Word>> getJuniorHighWords() async {
    await init();
    final levelData = _cachedData?['初中词汇'] as List<dynamic>? ?? [];
    return levelData.asMap().entries.map((entry) {
      return _createWordFromJson(entry.value as Map<String, dynamic>, 'junior_high', entry.key);
    }).toList();
  }

  static Future<List<Word>> getHighSchoolWords() async {
    await init();
    final levelData = _cachedData?['高中词汇'] as List<dynamic>? ?? [];
    return levelData.asMap().entries.map((entry) {
      return _createWordFromJson(entry.value as Map<String, dynamic>, 'high_school', entry.key);
    }).toList();
  }

  static Future<List<Word>> getCET4Words() async {
    await init();
    final levelData = _cachedData?['大学四级'] as List<dynamic>? ?? [];
    return levelData.asMap().entries.map((entry) {
      return _createWordFromJson(entry.value as Map<String, dynamic>, 'cet4', entry.key);
    }).toList();
  }

  static Future<List<Word>> getDailyWords() async {
    await init();
    final levelData = _cachedData?['日常沟通'] as List<dynamic>? ?? [];
    return levelData.asMap().entries.map((entry) {
      return _createWordFromJson(entry.value as Map<String, dynamic>, 'daily', entry.key);
    }).toList();
  }

  static Future<List<Word>> getWordsByLevel(String level) async {
    try {
      await init();
      List<dynamic>? levelData;
      
      switch (level) {
        case 'junior_high':
          levelData = _cachedData?['初中词汇'] as List<dynamic>?;
          break;
        case 'high_school':
          levelData = _cachedData?['高中词汇'] as List<dynamic>?;
          break;
        case 'cet4':
          levelData = _cachedData?['大学四级'] as List<dynamic>?;
          break;
        case 'daily':
          levelData = _cachedData?['日常沟通'] as List<dynamic>?;
          break;
        default:
          return [];
      }
      
      if (levelData == null || levelData.isEmpty) {
        return [];
      }
      
      return levelData.asMap().entries.map((entry) {
        return _createWordFromJson(entry.value as Map<String, dynamic>, level, entry.key);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static List<String> getAllLevels() {
    return ['junior_high', 'high_school', 'cet4', 'daily'];
  }

  static void clearCache() {
    _cachedData = null;
    _isInitialized = false;
  }
}
