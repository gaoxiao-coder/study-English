import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../models/word.dart';
import '../services/storage_service.dart';
import '../utils/word_level_data_util.dart';
import '../widgets/word_card.dart';

class WordLearningScreen extends StatefulWidget {
  final bool isTestMode;
  final int startIndex;
  final String level;

  const WordLearningScreen({
    Key? key,
    this.isTestMode = false,
    this.startIndex = 0,
    this.level = 'junior_high',
  }) : super(key: key);

  @override
  State<WordLearningScreen> createState() => _WordLearningScreenState();
}

class _WordLearningScreenState extends State<WordLearningScreen> {
  PageController _pageController = PageController();
  List<Word> _words = [];
  int _currentIndex = 0;
  bool _showAnswer = false;

  bool _isTestMode = false;
  List<Word> _testQuestions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  List<String> _testOptions = [];
  String? _selectedOption;
  bool _showTestResult = false;

  String _currentLevel = 'junior_high';

  @override
  void initState() {
    super.initState();
    _isTestMode = widget.isTestMode;
    _currentIndex = widget.startIndex;
    _currentLevel = widget.level;
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      List<Word> words;
      
      if (_isTestMode) {
        final levelWords = await WordLevelDataUtil.getWordsByLevel(_currentLevel).timeout(
          const Duration(seconds: 10),
        );
        final masteryData = await StorageService.loadLevelMasteryData(_currentLevel);
        
        words = levelWords.where((w) {
          final isLearned = w.reviewCount > 0;
          final isMastered = masteryData[w.english] ?? false;
          return isLearned || isMastered;
        }).toList();
        
        if (words.isEmpty) {
          words = levelWords.take(10).toList();
        }
      } else {
        final levelWords = await WordLevelDataUtil.getWordsByLevel(_currentLevel).timeout(
          const Duration(seconds: 10),
        );
        final masteryData = await StorageService.loadLevelMasteryData(_currentLevel);
        
        words = levelWords.map((word) {
          final isMastered = masteryData[word.english] ?? false;
          return word.copyWith(isMastered: isMastered);
        }).toList();
      }
      
      if (!mounted) return;
      
      setState(() {
        if (_isTestMode) {
          _testQuestions = words;
          if (_testQuestions.isNotEmpty) {
            _testQuestions.shuffle();
            if (_testQuestions.length > 10) {
              _testQuestions = _testQuestions.sublist(0, 10);
            }
          }
          _generateTestOptions();
        } else {
          _words = words;
          if (_currentIndex >= _words.length) {
            _currentIndex = 0;
          }
          _pageController = PageController(initialPage: _currentIndex);
        }
      });
      
      if (!_isTestMode && _words.isNotEmpty) {
        await _updateWordReviewStatus(_words[_currentIndex]);
        if (mounted) {
          context.read<AppSettings>().incrementStudySessions();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _words = [];
      });
    }
  }

  Future<void> _updateWordReviewStatus(Word word) async {
    await StorageService.saveWordMasteryByLevel(
      _currentLevel,
      word.english,
      word.isMastered,
    );
  }

  void _generateTestOptions() {
    if (_testQuestions.isEmpty) return;
    
    final currentQuestion = _testQuestions[_currentQuestionIndex];
    final allWords = _testQuestions;
    
    final wrongOptions = allWords
        .where((w) => w.id != currentQuestion.id)
        .toList()
      ..shuffle();
    
    _testOptions = [
      currentQuestion.chinese,
      ...wrongOptions.take(3).map((w) => w.chinese),
    ]..shuffle();
    
    _selectedOption = null;
    _showTestResult = false;
  }

  void _checkAnswer(String selectedOption) {
    final currentQuestion = _testQuestions[_currentQuestionIndex];
    final isCorrect = selectedOption == currentQuestion.chinese;
    
    setState(() {
      _selectedOption = selectedOption;
      _showTestResult = true;
      if (isCorrect) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _testQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _showTestResult = false;
        _generateTestOptions();
      });
    } else {
      _showTestSummary();
    }
  }

  void _showTestSummary() {
    final accuracy = (_correctAnswers / _testQuestions.length * 100);
    context.read<AppSettings>().incrementTestSessions();
    context.read<AppSettings>().updateBestAccuracy(accuracy);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('测试完成'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '正确率: ${accuracy.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '正确: $_correctAnswers / ${_testQuestions.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }

  void _revealAnswer() {
    setState(() {
      _showAnswer = true;
    });
  }

  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('恭喜'),
          content: const Text('你已经学完所有单词！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('返回首页'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isTestMode) {
      return _buildTestMode();
    } else {
      return _buildLearningMode();
    }
  }

  Widget _buildLearningMode() {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('单词学习 - ${_getLevelName(_currentLevel)}'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: Colors.orange[300],
                ),
                const SizedBox(height: 24),
                const Text(
                  '该等级暂无单词数据',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getLevelName(_currentLevel),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回选择'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('单词学习 - ${_getLevelName(_currentLevel)}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_currentIndex + 1} / ${_words.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (!_showAnswer) {
            _revealAnswer();
          }
        },
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) async {
            setState(() {
              _currentIndex = index;
              _showAnswer = false;
            });
            await StorageService.saveWordMasteryByLevel(
              _currentLevel,
              _words[index].english,
              _words[index].isMastered,
            );
          },
          itemCount: _words.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: WordCard(
                  word: _words[index],
                  showAnswer: _showAnswer,
                  onMastered: _nextWord,
                  onNext: _nextWord,
                  level: _currentLevel,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextWord,
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget _buildTestMode() {
    if (_testQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('单词测试'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: Colors.orange[300],
                ),
                const SizedBox(height: 24),
                const Text(
                  '暂无可测试的单词',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getLevelName(_currentLevel),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '请先学习该等级的单词，或选择其他等级',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回选择'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = _testQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('单词测试 - ${_getLevelName(_currentLevel)}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_currentQuestionIndex + 1} / ${_testQuestions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 16),
                
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          '请选择正确的中文释义',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentQuestion.english,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentQuestion.phonetic,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                ..._testOptions.map((option) {
                  final isSelected = _selectedOption == option;
                  final isCorrect = option == currentQuestion.chinese;
                  
                  Color? buttonColor;
                  if (_showTestResult) {
                    if (isSelected && isCorrect) {
                      buttonColor = Colors.green;
                    } else if (isSelected && !isCorrect) {
                      buttonColor = Colors.red;
                    } else if (!isSelected && isCorrect) {
                      buttonColor = Colors.green.withValues(alpha: 0.3);
                    }
                  } else {
                    buttonColor = Colors.blue;
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showTestResult ? null : () => _checkAnswer(option),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          child: Text(
                            option,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                
                const SizedBox(height: 16),
                
                if (_showTestResult)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentQuestionIndex < _testQuestions.length - 1
                            ? '下一题 →'
                            : '查看结果',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLevelName(String level) {
    switch (level) {
      case 'junior_high':
        return '初中词汇';
      case 'high_school':
        return '高中词汇';
      case 'cet4':
        return '大学四级';
      case 'daily':
        return '日常沟通';
      default:
        return '未知等级';
    }
  }
}
