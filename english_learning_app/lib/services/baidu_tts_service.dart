import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:js' as js;

class WebSpeechService {
  static final WebSpeechService _instance = WebSpeechService._internal();
  factory WebSpeechService() => _instance;
  WebSpeechService._internal();

  bool get isSupported => kIsWeb;

  bool speak(String text, {String accent = 'american'}) {
    try {
      final bool result = js.context.callMethod('speakWithWebSpeech', [text, accent]);
      return result;
    } catch (e) {
      debugPrint('Web Speech API调用失败: $e');
      return false;
    }
  }

  void stop() {
    try {
      js.context.callMethod('stopWebSpeech', []);
    } catch (e) {
      debugPrint('停止语音失败: $e');
    }
  }
}

class BaiduTTSService {
  static const String _apiKey = 'W6UTjUNyQJ8LzGpNqHsl4Rwp';
  static const String _secretKey = 'HWg8aSewAUwqpxSKJdE0Rp4UY5Ky6fcN';
  static const String _tokenUrl = 'https://aip.baidubce.com/oauth/2.0/token';
  static const String _ttsUrl = 'https://tsn.baidubce.com/text2audio';
  static const int _britishVoice = 0;
  static const int _americanVoice = 3;
  static String? _cachedToken;
  static DateTime? _tokenExpiry;

  static Future<String> _getAccessToken() async {
    if (_cachedToken != null && _tokenExpiry != null) {
      if (DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
        return _cachedToken!;
      }
    }
    
    try {
      final params = {
        'grant_type': 'client_credentials',
        'client_id': _apiKey,
        'client_secret': _secretKey,
      };
      
      final response = await http.post(
        Uri.parse(_tokenUrl),
        body: params,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw TTSException(
          'Token请求失败: HTTP ${response.statusCode}',
          ErrorType.networkError,
        );
      }
      
      final jsonResponse = json.decode(response.body);
      
      if (jsonResponse.containsKey('error')) {
        throw TTSException(
          'Token认证失败: ${jsonResponse['error_description'] ?? jsonResponse['error']}',
          ErrorType.authError,
        );
      }
      
      final token = jsonResponse['access_token'] as String;
      final expiresIn = jsonResponse['expires_in'] as int;
      
      _cachedToken = token;
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
      
      return token;
      
    } on http.ClientException catch (e) {
      throw TTSException(
        '网络连接失败: ${e.message}',
        ErrorType.networkError,
      );
    } on TimeoutException {
      throw TTSException(
        'Token请求超时，请检查网络连接',
        ErrorType.timeout,
      );
    } on FormatException {
      throw TTSException(
        'Token响应格式解析失败',
        ErrorType.parsingError,
      );
    } catch (e) {
      throw TTSException(
        '未知错误: $e',
        ErrorType.unknown,
      );
    }
  }
  
  static Future<Uint8List> synthesizeSpeech({
    required String text,
    String accent = 'american',
  }) async {
    if (kIsWeb) {
      throw TTSException(
        'Web平台请使用Web Speech API',
        ErrorType.invalidParams,
      );
    }

    if (text.isEmpty) {
      throw TTSException('文本内容不能为空', ErrorType.invalidParams);
    }
    
    if (text.length > 1024) {
      throw TTSException('文本长度不能超过1024个字符', ErrorType.invalidParams);
    }
    
    if (accent != 'british' && accent != 'american') {
      throw TTSException('不支持的发音类型: $accent，仅支持british或american', ErrorType.invalidParams);
    }
    
    try {
      final token = await _getAccessToken();
      final per = accent == 'british' ? _britishVoice : _americanVoice;
      
      final params = {
        'tok': token,
        'tex': text,
        'per': per.toString(),
        'spd': '5',
        'pit': '5',
        'vol': '15',
        'aue': '3',
        'rate': '16000',
      };
      
      final response = await http.post(
        Uri.parse(_ttsUrl),
        body: params,
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        throw TTSException(
          'TTS请求失败: HTTP ${response.statusCode}',
          ErrorType.networkError,
        );
      }
      
      final contentType = response.headers['content-type'];
      
      if (contentType?.contains('application/json') == true || 
          response.body.startsWith('{')) {
        try {
          final jsonResponse = json.decode(response.body);
          throw TTSException(
            'TTS服务错误: ${jsonResponse['err_msg'] ?? jsonResponse['error_msg']}',
            ErrorType.apiError,
          );
        } catch (e) {
          throw TTSException(
            'TTS响应解析失败',
            ErrorType.parsingError,
          );
        }
      }
      
      return response.bodyBytes;
      
    } on http.ClientException catch (e) {
      throw TTSException(
        '网络连接失败: ${e.message}',
        ErrorType.networkError,
      );
    } on TimeoutException {
      throw TTSException(
        'TTS请求超时，请检查网络连接',
        ErrorType.timeout,
      );
    } on TTSException {
      rethrow;
    } catch (e) {
      throw TTSException(
        '未知错误: $e',
        ErrorType.unknown,
      );
    }
  }
  
  static Future<String> getAudioUrl({
    required String text,
    String accent = 'american',
  }) async {
    if (kIsWeb) {
      throw TTSException(
        'Web平台不支持此功能',
        ErrorType.invalidParams,
      );
    }

    if (text.isEmpty) {
      throw TTSException('文本内容不能为空', ErrorType.invalidParams);
    }
    
    try {
      final token = await _getAccessToken();
      final per = accent == 'british' ? _britishVoice : _americanVoice;
      
      final params = {
        'tok': token,
        'tex': text,
        'per': per.toString(),
        'spd': '5',
        'pit': '5',
        'vol': '15',
        'aue': '3',
      };
      
      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      return '$_ttsUrl?$queryString';
      
    } catch (e) {
      throw TTSException(
        '生成音频URL失败: $e',
        ErrorType.unknown,
      );
    }
  }
  
  static void clearTokenCache() {
    _cachedToken = null;
    _tokenExpiry = null;
  }
}

enum ErrorType {
  networkError,
  authError,
  apiError,
  timeout,
  parsingError,
  invalidParams,
  audioPlayError,
  unknown,
}

class TTSException implements Exception {
  final String message;
  final ErrorType type;
  
  TTSException(this.message, this.type);
  
  @override
  String toString() {
    return 'TTSException: $message (类型: ${type.name})';
  }
  
  String getUserFriendlyMessage() {
    switch (type) {
      case ErrorType.networkError:
        return '网络连接失败，请检查网络设置';
      case ErrorType.authError:
        return '语音服务认证失败，请检查API密钥配置';
      case ErrorType.apiError:
        return '语音服务暂时不可用，请稍后重试';
      case ErrorType.timeout:
        return '请求超时，请检查网络连接后重试';
      case ErrorType.parsingError:
        return '数据处理错误，请联系开发者';
      case ErrorType.invalidParams:
        return '参数错误: $message';
      case ErrorType.audioPlayError:
        return '音频播放失败';
      case ErrorType.unknown:
        return '发生未知错误: $message';
    }
  }
  
  bool isRetryable() {
    return type == ErrorType.networkError ||
           type == ErrorType.timeout ||
           type == ErrorType.apiError;
  }
}
