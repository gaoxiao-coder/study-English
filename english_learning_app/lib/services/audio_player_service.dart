import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'baidu_tts_service.dart';
import 'dart:js' as js;

abstract class AudioPlayerPlatform {
  Future<bool> play(Uint8List audioData);
  Future<void> stop();
  void setOnCompletion(VoidCallback callback);
  void setOnError(VoidCallback callback);
}

class NativeAudioPlayer implements AudioPlayerPlatform {
  static const MethodChannel _channel = MethodChannel('audio_player');
  VoidCallback? onComplete;
  VoidCallback? onError;

  NativeAudioPlayer() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCompletion':
        onComplete?.call();
        break;
      case 'onError':
        onError?.call();
        break;
    }
    return null;
  }

  @override
  Future<bool> play(Uint8List audioData) async {
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
    await tempFile.writeAsBytes(audioData);

    final result = await _channel.invokeMethod('play', {
      'path': tempFile.path,
    });

    return result == true;
  }

  @override
  Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }

  @override
  void setOnCompletion(VoidCallback callback) {
    onComplete = callback;
  }

  @override
  void setOnError(VoidCallback callback) {
    onError = callback;
  }
}

class WebAudioPlayer implements AudioPlayerPlatform {
  VoidCallback? onComplete;
  VoidCallback? onError;

  WebAudioPlayer();

  @override
  Future<bool> play(Uint8List audioData) async {
    try {
      final base64Audio = String.fromCharCodes(audioData);
      final dataUrl = 'data:audio/mp3;base64,$base64Audio';

      js.context.callMethod('playAudioFromBase64', [dataUrl]);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      js.context.callMethod('stopAudio', []);
    } catch (e) {
      debugPrint('停止播放失败: $e');
    }
  }

  @override
  void setOnCompletion(VoidCallback callback) {
    onComplete = callback;
  }

  @override
  void setOnError(VoidCallback callback) {
    onError = callback;
  }
}

AudioPlayerPlatform _createAudioPlayer() {
  if (kIsWeb) {
    return WebAudioPlayer();
  } else {
    return NativeAudioPlayer();
  }
}

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal() {
    _platform = _createAudioPlayer();
    _platform.setOnCompletion(_handleCompletion);
    _platform.setOnError(_handleError);
  }

  late final AudioPlayerPlatform _platform;
  final List<VoidCallback> _onPlaybackStateChanged = [];
  bool _isPlaying = false;
  bool _isLoading = false;
  TTSException? _lastError;

  void _handleCompletion() {
    _setPlaying(false);
  }

  void _handleError() {
    _setPlaying(false);
    _setLoading(false);
    _lastError = TTSException('音频播放错误', ErrorType.audioPlayError);
  }

  void addPlaybackStateListener(VoidCallback callback) {
    if (!_onPlaybackStateChanged.contains(callback)) {
      _onPlaybackStateChanged.add(callback);
    }
  }

  void removePlaybackStateListener(VoidCallback callback) {
    _onPlaybackStateChanged.remove(callback);
  }

  void _notifyStateChanged() {
    for (final callback in _onPlaybackStateChanged) {
      callback();
    }
  }

  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  TTSException? get lastError => _lastError;

  void clearError() {
    _lastError = null;
  }

  Future<bool> playAudio(Uint8List audioData) async {
    if (_isPlaying) {
      await stop();
    }

    try {
      _setLoading(true);
      _lastError = null;

      final result = await _platform.play(audioData);

      if (result) {
        _setPlaying(true);
        return true;
      } else {
        throw TTSException('音频播放失败', ErrorType.audioPlayError);
      }
    } on PlatformException catch (e) {
      _lastError = TTSException(
        '平台播放错误: ${e.message}',
        ErrorType.audioPlayError,
      );
      return false;
    } on TTSException {
      _lastError = null;
      rethrow;
    } catch (e) {
      _lastError = TTSException(
        '音频播放未知错误: $e',
        ErrorType.audioPlayError,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> playWord({
    required String word,
    String accent = 'american',
  }) async {
    try {
      if (_isPlaying) {
        await stop();
      }

      _setLoading(true);
      _lastError = null;

      final audioData = await BaiduTTSService.synthesizeSpeech(
        text: word,
        accent: accent,
      );

      return await playAudio(audioData);
    } on TTSException catch (e) {
      _lastError = e;
      _notifyStateChanged();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> stop() async {
    try {
      await _platform.stop();
    } on PlatformException catch (e) {
      debugPrint('停止播放失败: ${e.message}');
    } finally {
      _setPlaying(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _notifyStateChanged();
    }
  }

  void _setPlaying(bool playing) {
    if (_isPlaying != playing) {
      _isPlaying = playing;
      _notifyStateChanged();
    }
  }

  void setOnCompletion(VoidCallback callback) {
    _platform.setOnCompletion(callback);
  }

  void setOnError(VoidCallback callback) {
    _platform.setOnError(callback);
  }

  void dispose() {
    stop();
    _onPlaybackStateChanged.clear();
  }
}
