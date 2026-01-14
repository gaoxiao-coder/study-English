import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/storage_service.dart';

/// 单词卡片组件
class WordCard extends StatefulWidget {
  final Word word;
  final bool showAnswer;
  final VoidCallback? onMastered;
  final VoidCallback? onNext;
  /// 当前学习的等级（用于按等级存储掌握状态）
  final String? level;

  const WordCard({
    Key? key,
    required this.word,
    this.showAnswer = false,
    this.onMastered,
    this.onNext,
    this.level,
  }) : super(key: key);

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
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
            /// 英文单词
            Text(
              widget.word.english,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
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
            const SizedBox(height: 24),
            
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
}
