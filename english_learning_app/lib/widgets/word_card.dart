import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../services/storage_service.dart';
import '../services/audio_player_service.dart';
import '../services/baidu_tts_service.dart';

/// 单词卡片组件
/// 包含单词显示、发音播放、掌握状态管理功能
class WordCard extends StatefulWidget {
  final Word word;
  final bool showAnswer;
  final VoidCallback? onMastered;
  final VoidCallback? onNext;
  /// 当前学习的等级（用于按等级存储掌握状态）
  final String? level;
  /// 发音类型：'british' 或 'american'
  final String accent;
  
  const WordCard({
    Key? key,
    required this.word,
    this.showAnswer = false,
    this.onMastered,
    this.onNext,
    this.level,
    this.accent = 'american',
  }) : super(key: key);
  
  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  // 音频播放器服务实例
  final AudioPlayerService _audioPlayer = AudioPlayerService();
  
  // 播放状态标记
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    
    // 注册播放状态监听器
    _audioPlayer.addPlaybackStateListener(_onPlaybackStateChanged);
    
    // 设置播放完成回调
    _audioPlayer.setOnCompletion(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
        });
      }
    });
    
    // 设置错误回调
    _audioPlayer.setOnError(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
          _errorMessage = _audioPlayer.lastError?.getUserFriendlyMessage();
        });
      }
    });
  }
  
  @override
  void dispose() {
    // 移除监听器
    _audioPlayer.removePlaybackStateListener(_onPlaybackStateChanged);
    // 释放资源
    _audioPlayer.dispose();
    super.dispose();
  }
  
  /// 播放状态变化回调
  void _onPlaybackStateChanged() {
    if (mounted) {
      setState(() {
        _isPlaying = _audioPlayer.isPlaying;
        _isLoading = _audioPlayer.isLoading;
      });
    }
  }
  
  /// 点击喇叭图标触 发发音
  void _playPronunciation() async {
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }
    
    if (kIsWeb) {
      final webSpeech = WebSpeechService();
      final success = webSpeech.speak(
        widget.word.english,
        accent: widget.accent,
      );
      
      if (success) {
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = '语音播放失败，请检查浏览器设置';
          });
        }
      }
      return;
    }
    
    final success = await _audioPlayer.playWord(
      word: widget.word.english,
      accent: widget.accent,
    );
    
    if (!success && mounted) {
      setState(() {
        _errorMessage = _audioPlayer.lastError?.getUserFriendlyMessage();
      });
    }
  }
  
  /// 标记为已掌握
  void _markAsMastered() async {
    final level = widget.level ?? widget.word.level;
    await StorageService.saveWordMasteryByLevel(level, widget.word.english, true);
    if (widget.onMastered != null) {
      widget.onMastered!();
    }
  }
  
  /// 标记为未掌握
  void _markAsNotMastered() async {
    final level = widget.level ?? widget.word.level;
    await StorageService.saveWordMasteryByLevel(level, widget.word.english, false);
    if (widget.onNext != null) {
      widget.onNext!();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 英文单词行（包含单词和发音按钮）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// 英文单词
                Expanded(
                  child: Text(
                    widget.word.english,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                /// 发音按钮（喇叭图标）
                _buildPronunciationButton(),
              ],
            ),
            
            const SizedBox(height: 12),
            
            /// 音标
            Text(
              widget.word.phonetic,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            /// 错误提示信息
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            /// 中文释义（根据showAnswer显示/隐藏）
            AnimatedOpacity(
              opacity: widget.showAnswer ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                widget.word.chinese,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            
            /// 学习进度显示
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.word.isMastered ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: widget.word.isMastered ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.word.isMastered ? '已掌握' : '未掌握',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.refresh,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '复习 ${widget.word.reviewCount} 次',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            
            /// 操作按钮（仅在显示答案时显示）
            if (widget.showAnswer) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /// 未掌握按钮
                  ElevatedButton.icon(
                    onPressed: _markAsNotMastered,
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text('未掌握'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  
                  /// 已掌握按钮
                  ElevatedButton.icon(
                    onPressed: _markAsMastered,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('已掌握'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 构建发音按钮
  Widget _buildPronunciationButton() {
    // 根据状态显示不同的图标和动画
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: _isLoading ? null : _playPronunciation,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: _getButtonIcon(),
        ),
        style: IconButton.styleFrom(
          backgroundColor: _isLoading 
            ? Colors.grey.withValues(alpha: 0.2)
            : Theme.of(context).primaryColor.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  /// 根据状态返回对应的图标组件
  Widget _getButtonIcon() {
    // 加载中状态
    if (_isLoading) {
      return SizedBox(
        key: const ValueKey('loading'),
        width: 24,
        height: 24,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }
    
    // 播放中状态
    if (_isPlaying) {
      return Icon(
        Icons.volume_up,
        key: const ValueKey('playing'),
        color: Theme.of(context).primaryColor,
        size: 28,
      );
    }
    
    // 空闲状态
    return Icon(
      Icons.volume_up_outlined,
      key: const ValueKey('idle'),
      color: Theme.of(context).primaryColor,
      size: 24,
    );
  }
}
