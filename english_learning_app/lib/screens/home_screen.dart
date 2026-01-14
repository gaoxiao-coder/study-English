import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../models/word.dart';
import '../services/storage_service.dart';
import '../utils/word_level_data_util.dart';
import 'word_learning_screen.dart';
import 'settings_screen.dart';

/// 首页
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Word> _words = [];
  int _masteredCount = 0;
  int _totalWords = 0;
  
  late TabController _tabController;
  
  /// 当前选中的单词等级
  String _currentLevel = 'junior_high';
  
  /// 等级名称映射
  final Map<String, String> _levelNames = {
    'junior_high': '初中词汇',
    'high_school': '高中词汇',
    'cet4': '大学四级',
    'daily': '日常沟通',
  };

  /// Tab索引到等级key的映射
  final List<String> _levelKeys = ['junior_high', 'high_school', 'cet4', 'daily'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _levelKeys.length, vsync: this);
    _tabController.index = _levelKeys.indexOf(_currentLevel);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 加载数据
  Future<void> _loadData() async {
    final words = await StorageService.loadWords();
    final settings = await StorageService.loadSettings();
    
    if (mounted) {
      setState(() {
        _words = words;
        _masteredCount = words.where((w) => w.isMastered).length;
        _totalWords = words.length;
      });
    }
  }

  /// 根据当前等级加载词汇数据
  Future<void> _loadWordsByLevel(String level) async {
    final levelWords = await WordLevelDataUtil.getWordsByLevel(level);
    final masteryData = await StorageService.loadLevelMasteryData(level);
    
    setState(() {
      _currentLevel = level;
      _tabController.index = _levelKeys.indexOf(level);
      _totalWords = levelWords.length;
      _masteredCount = masteryData.values.where((v) => v).length;
    });
  }

  /// 切换等级
  void _onLevelChanged(int index) {
    final selectedLevel = _levelKeys[index];
    _loadWordsByLevel(selectedLevel);
  }

  /// 刷新数据
  Future<void> _refreshData() async {
    await _loadData();
    await _loadWordsByLevel(_currentLevel);
    if (mounted) {
      context.read<AppSettings>().updateMasteredCount(_masteredCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final masteredPercentage = _totalWords > 0 
        ? (_masteredCount / _totalWords * 100).toInt() 
        : 0;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 欢迎标题
                Text(
                  '欢迎回来！',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '继续你的英语学习之旅',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                /// 单词等级选择Tab栏
                _buildWordLevelTabs(),
                const SizedBox(height: 24),

                /// 学习进度卡片
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '学习进度',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$_masteredCount/$_totalWords',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        /// 进度条
                        LinearProgressIndicator(
                          value: _totalWords > 0 ? _masteredCount / _totalWords : 0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        
                        Text(
                          '已掌握 $masteredPercentage% 的单词',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                /// 快捷操作按钮
                Text(
                  '快捷操作',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    /// 开始学习按钮
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.school,
                        label: '开始学习',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordLearningScreen(
                                level: _currentLevel,
                              ),
                            ),
                          ).then((_) => _refreshData());
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    /// 单词测试按钮
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.quiz,
                        label: '单词测试',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordLearningScreen(
                                level: _currentLevel,
                                isTestMode: true,
                              ),
                            ),
                          ).then((_) => _refreshData());
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    /// 设置按钮
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.settings,
                        label: '设置',
                        color: Colors.grey,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          ).then((_) => _refreshData());
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    /// 继续学习按钮（仅当有未掌握单词时显示）
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.play_arrow,
                        label: '继续学习',
                        color: Colors.green,
                        onTap: () {
                          final unmasteredWords = _words.where((w) => !w.isMastered).toList();
                          if (unmasteredWords.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WordLearningScreen(
                                  level: _currentLevel,
                                  startIndex: _words.indexOf(unmasteredWords.first),
                                ),
                              ),
                            ).then((_) => _refreshData());
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                /// 统计信息
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '学习统计',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildStatItem(
                          context,
                          icon: Icons.school,
                          label: '学习次数',
                          value: '${settings.totalStudySessions} 次',
                        ),
                        const SizedBox(height: 12),
                        
                        _buildStatItem(
                          context,
                          icon: Icons.quiz,
                          label: '测试次数',
                          value: '${settings.totalTestSessions} 次',
                        ),
                        const SizedBox(height: 12),
                        
                        _buildStatItem(
                          context,
                          icon: Icons.star,
                          label: '最高正确率',
                          value: '${settings.bestAccuracy.toStringAsFixed(1)}%',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 单词等级选择Tab栏
  Widget _buildWordLevelTabs() {
    final currentIndex = _levelKeys.indexOf(_currentLevel);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择词库',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
            dividerColor: Colors.transparent,
            isScrollable: false,
            onTap: (index) {
              _onLevelChanged(index);
              setState(() {});
            },
            tabs: const [
              Tab(text: '初中词汇'),
              Tab(text: '高中词汇'),
              Tab(text: '大学四级'),
              Tab(text: '日常沟通'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 100,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: _levelKeys.map((level) {
              return _buildLevelCard(
                _levelNames[level] ?? level,
                _getLevelIcon(level),
                _getLevelColor(level),
                level,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 获取等级对应的图标
  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'junior_high':
        return Icons.school;
      case 'high_school':
        return Icons.book;
      case 'cet4':
        return Icons.grade;
      case 'daily':
        return Icons.chat;
      default:
        return Icons.school;
    }
  }

  /// 获取等级对应的颜色
  Color _getLevelColor(String level) {
    switch (level) {
      case 'junior_high':
        return Colors.blue;
      case 'high_school':
        return Colors.green;
      case 'cet4':
        return Colors.orange;
      case 'daily':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  /// 构建等级卡片
  Widget _buildLevelCard(String title, IconData icon, Color color, String level) {
    final isSelected = _currentLevel == level;
    
    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected ? color.withOpacity(0.1) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _onLevelChanged(_levelKeys.indexOf(level)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : null,
                      ),
                    ),
                    FutureBuilder<int>(
                      future: StorageService.getMasteredCountByLevel(level),
                      builder: (context, snapshot) {
                        return Text(
                          '已掌握 ${snapshot.data ?? 0} 个单词',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
