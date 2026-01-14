/// 单词数据模型
class Word {
  final String id;
  final String english;
  final String chinese;
  final String phonetic;
  /// 单词所属等级：junior_high(初中)、high_school(高中)、cet4(大学四级)、daily(日常沟通)
  final String level;
  bool isMastered;
  int reviewCount;

  Word({
    required this.id,
    required this.english,
    required this.chinese,
    required this.phonetic,
    this.level = 'junior_high',
    this.isMastered = false,
    this.reviewCount = 0,
  });

  /// 从JSON创建对象
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      english: json['english'],
      chinese: json['chinese'],
      phonetic: json['phonetic'],
      level: json['level'] ?? 'junior_high',
      isMastered: json['isMastered'] ?? false,
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'english': english,
      'chinese': chinese,
      'phonetic': phonetic,
      'level': level,
      'isMastered': isMastered,
      'reviewCount': reviewCount,
    };
  }

  /// 复制对象并更新指定字段
  Word copyWith({
    String? id,
    String? english,
    String? chinese,
    String? phonetic,
    String? level,
    bool? isMastered,
    int? reviewCount,
  }) {
    return Word(
      id: id ?? this.id,
      english: english ?? this.english,
      chinese: chinese ?? this.chinese,
      phonetic: phonetic ?? this.phonetic,
      level: level ?? this.level,
      isMastered: isMastered ?? this.isMastered,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  /// 获取等级显示名称
  String get levelDisplayName {
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

/// 内置100个基础英语词汇
class WordData {
  static List<Word> getInitialWords() {
    return [
      Word(id: '1', english: 'apple', chinese: '苹果', phonetic: '/ˈæpl/'),
      Word(id: '2', english: 'banana', chinese: '香蕉', phonetic: '/bəˈnɑːnə/'),
      Word(id: '3', english: 'orange', chinese: '橙子', phonetic: '/ˈɔːrɪndʒ/'),
      Word(id: '4', english: 'cat', chinese: '猫', phonetic: '/kæt/'),
      Word(id: '5', english: 'dog', chinese: '狗', phonetic: '/dɔːɡ/'),
      Word(id: '6', english: 'book', chinese: '书', phonetic: '/bʊk/'),
      Word(id: '7', english: 'pen', chinese: '钢笔', phonetic: '/pen/'),
      Word(id: '8', english: 'pencil', chinese: '铅笔', phonetic: '/ˈpensl/'),
      Word(id: '9', english: 'teacher', chinese: '老师', phonetic: '/ˈtiːtʃər/'),
      Word(id: '10', english: 'student', chinese: '学生', phonetic: '/ˈstuːdnt/'),
      Word(id: '11', english: 'school', chinese: '学校', phonetic: '/skuːl/'),
      Word(id: '12', english: 'home', chinese: '家', phonetic: '/hoʊm/'),
      Word(id: '13', english: 'family', chinese: '家庭', phonetic: '/ˈfæməli/'),
      Word(id: '14', english: 'father', chinese: '父亲', phonetic: '/ˈfɑːðər/'),
      Word(id: '15', english: 'mother', chinese: '母亲', phonetic: '/ˈmʌðər/'),
      Word(id: '16', english: 'brother', chinese: '兄弟', phonetic: '/ˈbrʌðər/'),
      Word(id: '17', english: 'sister', chinese: '姐妹', phonetic: '/ˈsɪstər/'),
      Word(id: '18', english: 'friend', chinese: '朋友', phonetic: '/frend/'),
      Word(id: '19', english: 'love', chinese: '爱', phonetic: '/lʌv/'),
      Word(id: '20', english: 'happy', chinese: '快乐', phonetic: '/ˈhæpi/'),
      Word(id: '21', english: 'sad', chinese: '悲伤', phonetic: '/sæd/'),
      Word(id: '22', english: 'big', chinese: '大', phonetic: '/bɪɡ/'),
      Word(id: '23', english: 'small', chinese: '小', phonetic: '/smɔːl/'),
      Word(id: '24', english: 'good', chinese: '好', phonetic: '/ɡʊd/'),
      Word(id: '25', english: 'bad', chinese: '坏', phonetic: '/bæd/'),
      Word(id: '26', english: 'yes', chinese: '是', phonetic: '/jes/'),
      Word(id: '27', english: 'no', chinese: '不', phonetic: '/noʊ/'),
      Word(id: '28', english: 'hello', chinese: '你好', phonetic: '/həˈloʊ/'),
      Word(id: '29', english: 'goodbye', chinese: '再见', phonetic: '/ˌɡʊdˈbaɪ/'),
      Word(id: '30', english: 'thank', chinese: '谢谢', phonetic: '/θæŋk/'),
      Word(id: '31', english: 'please', chinese: '请', phonetic: '/pliːz/'),
      Word(id: '32', english: 'sorry', chinese: '对不起', phonetic: '/ˈsɑːri/'),
      Word(id: '33', english: 'water', chinese: '水', phonetic: '/ˈwɔːtər/'),
      Word(id: '34', english: 'food', chinese: '食物', phonetic: '/fuːd/'),
      Word(id: '35', english: 'eat', chinese: '吃', phonetic: '/iːt/'),
      Word(id: '36', english: 'drink', chinese: '喝', phonetic: '/drɪŋk/'),
      Word(id: '37', english: 'sleep', chinese: '睡觉', phonetic: '/sliːp/'),
      Word(id: '38', english: 'run', chinese: '跑步', phonetic: '/rʌn/'),
      Word(id: '39', english: 'walk', chinese: '走路', phonetic: '/wɔːk/'),
      Word(id: '40', english: 'talk', chinese: '说话', phonetic: '/tɔːk/'),
      Word(id: '41', english: 'listen', chinese: '听', phonetic: '/ˈlɪsn/'),
      Word(id: '42', english: 'read', chinese: '阅读', phonetic: '/riːd/'),
      Word(id: '43', english: 'write', chinese: '写', phonetic: '/raɪt/'),
      Word(id: '44', english: 'watch', chinese: '看', phonetic: '/wɑːtʃ/'),
      Word(id: '45', english: 'play', chinese: '玩', phonetic: '/pleɪ/'),
      Word(id: '46', english: 'work', chinese: '工作', phonetic: '/wɜːrk/'),
      Word(id: '47', english: 'study', chinese: '学习', phonetic: '/ˈstʌdi/'),
      Word(id: '48', english: 'morning', chinese: '早晨', phonetic: '/ˈmɔːrnɪŋ/'),
      Word(id: '49', english: 'afternoon', chinese: '下午', phonetic: '/ˌæftərˈnuːn/'),
      Word(id: '50', english: 'evening', chinese: '晚上', phonetic: '/ˈiːvnɪŋ/'),
      Word(id: '51', english: 'today', chinese: '今天', phonetic: '/təˈdeɪ/'),
      Word(id: '52', english: 'tomorrow', chinese: '明天', phonetic: '/təˈmɔːroʊ/'),
      Word(id: '53', english: 'yesterday', chinese: '昨天', phonetic: '/ˈjestərdeɪ/'),
      Word(id: '54', english: 'week', chinese: '周', phonetic: '/wiːk/'),
      Word(id: '55', english: 'month', chinese: '月', phonetic: '/mʌnθ/'),
      Word(id: '56', english: 'year', chinese: '年', phonetic: '/jɪr/'),
      Word(id: '57', english: 'time', chinese: '时间', phonetic: '/taɪm/'),
      Word(id: '58', english: 'money', chinese: '钱', phonetic: '/ˈmʌni/'),
      Word(id: '59', english: 'car', chinese: '汽车', phonetic: '/kɑːr/'),
      Word(id: '60', english: 'bus', chinese: '公交车', phonetic: '/bʌs/'),
      Word(id: '61', english: 'train', chinese: '火车', phonetic: '/treɪn/'),
      Word(id: '62', english: 'plane', chinese: '飞机', phonetic: '/pleɪn/'),
      Word(id: '63', english: 'ship', chinese: '船', phonetic: '/ʃɪp/'),
      Word(id: '64', english: 'city', chinese: '城市', phonetic: '/ˈsɪti/'),
      Word(id: '65', english: 'country', chinese: '国家', phonetic: '/ˈkʌntri/'),
      Word(id: '66', english: 'world', chinese: '世界', phonetic: '/wɜːrld/'),
      Word(id: '67', english: 'sun', chinese: '太阳', phonetic: '/sʌn/'),
      Word(id: '68', english: 'moon', chinese: '月亮', phonetic: '/muːn/'),
      Word(id: '69', english: 'star', chinese: '星星', phonetic: '/stɑːr/'),
      Word(id: '70', english: 'rain', chinese: '雨', phonetic: '/reɪn/'),
      Word(id: '71', english: 'snow', chinese: '雪', phonetic: '/snoʊ/'),
      Word(id: '72', english: 'wind', chinese: '风', phonetic: '/wɪnd/'),
      Word(id: '73', english: 'hot', chinese: '热', phonetic: '/hɑːt/'),
      Word(id: '74', english: 'cold', chinese: '冷', phonetic: '/koʊld/'),
      Word(id: '75', english: 'warm', chinese: '温暖', phonetic: '/wɔːrm/'),
      Word(id: '76', english: 'cool', chinese: '凉爽', phonetic: '/kuːl/'),
      Word(id: '77', english: 'red', chinese: '红色', phonetic: '/red/'),
      Word(id: '78', english: 'blue', chinese: '蓝色', phonetic: '/bluː/'),
      Word(id: '79', english: 'green', chinese: '绿色', phonetic: '/ɡriːn/'),
      Word(id: '80', english: 'yellow', chinese: '黄色', phonetic: '/ˈjeloʊ/'),
      Word(id: '81', english: 'black', chinese: '黑色', phonetic: '/blæk/'),
      Word(id: '82', english: 'white', chinese: '白色', phonetic: '/waɪt/'),
      Word(id: '83', english: 'beautiful', chinese: '美丽', phonetic: '/ˈbjuːtɪfl/'),
      Word(id: '84', english: 'ugly', chinese: '丑陋', phonetic: '/ˈʌɡli/'),
      Word(id: '85', english: 'important', chinese: '重要', phonetic: '/ɪmˈpɔːrtnt/'),
      Word(id: '86', english: 'easy', chinese: '容易', phonetic: '/ˈiːzi/'),
      Word(id: '87', english: 'difficult', chinese: '困难', phonetic: '/ˈdɪfɪkəlt/'),
      Word(id: '88', english: 'new', chinese: '新', phonetic: '/nuː/'),
      Word(id: '89', english: 'old', chinese: '旧', phonetic: '/oʊld/'),
      Word(id: '90', english: 'young', chinese: '年轻', phonetic: '/jʌŋ/'),
      Word(id: '91', english: 'right', chinese: '右边/正确', phonetic: '/raɪt/'),
      Word(id: '92', english: 'left', chinese: '左边', phonetic: '/left/'),
      Word(id: '93', english: 'start', chinese: '开始', phonetic: '/stɑːrt/'),
      Word(id: '94', english: 'stop', chinese: '停止', phonetic: '/stɑːp/'),
      Word(id: '95', english: 'help', chinese: '帮助', phonetic: '/help/'),
      Word(id: '96', english: 'learn', chinese: '学习', phonetic: '/lɜːrn/'),
      Word(id: '97', english: 'teach', chinese: '教', phonetic: '/tiːtʃ/'),
      Word(id: '98', english: 'give', chinese: '给', phonetic: '/ɡɪv/'),
      Word(id: '99', english: 'take', chinese: '拿', phonetic: '/teɪk/'),
      Word(id: '100', english: 'make', chinese: '制作', phonetic: '/meɪk/'),
    ];
  }
}
