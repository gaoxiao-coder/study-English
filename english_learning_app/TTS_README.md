# 单词发音功能使用说明

本功能实现了"点击单词播放发音"的核心逻辑，使用百度TTS语音API实现英式/美式发音切换。

## 目录结构

```
lib/
├── services/
│   ├── baidu_tts_service.dart    # 百度TTS语音服务
│   └── audio_player_service.dart # 音频播放器服务
└── widgets/
    └── word_card.dart            # 单词卡片组件（已更新）
android/
└── app/src/main/kotlin/com/example/english_learning_app/
    └── MainActivity.kt           # Android原生音频播放
```

## 1. 依赖安装命令

在项目根目录运行以下命令安装依赖：

```bash
cd english_learning_app
flutter pub get
```

或者在Android Studio中直接点击 "Packages get"。

## 2. API密钥配置

### 步骤1：申请百度TTS API密钥

1. 访问 [百度AI开放平台](https://ai.baidu.com/tech/speech/tts)
2. 注册/登录百度账号
3. 创建应用并开通"语音合成"服务
4. 获取 API Key 和 Secret Key

### 步骤2：替换API密钥

打开文件 `lib/services/baidu_tts_service.dart`，找到以下位置并替换：

```dart
// ==================== API密钥配置区域 ====================
// TODO: 请替换为您的百度AI开放平台API密钥
// 申请地址: https://ai.baidu.com/tech/speech/tts
static const String _apiKey = 'YOUR_BAIDU_API_KEY';       // ← 替换这里
static const String _secretKey = 'YOUR_BAIDU_SECRET_KEY'; // ← 替换这里
```

示例：
```dart
static const String _apiKey = 'M7G5FbKxxxxxxxxxxxxx';
static const String _secretKey = 'K8d9L2mNxxxxxxxxxxxxx';
```

## 3. 功能特性

### 3.1 发音类型切换

- **美式发音** (默认): 使用情感男声(per=3)
- **英式发音**: 使用普通女声(per=0)

在WordCard组件中使用：
```dart
// 美式发音
WordCard(
  word: word,
  accent: 'american', // 默认
)

// 英式发音
WordCard(
  word: word,
  accent: 'british',
)
```

### 3.2 播放状态显示

- **空闲状态**: 显示空心喇叭图标 (volume_up_outlined)
- **加载状态**: 显示圆形进度条
- **播放状态**: 显示实心喇叭图标 + 绿色高亮

### 3.3 错误处理

系统会自动处理以下错误类型：

| 错误类型 | 处理方式 | 用户提示 |
|---------|---------|---------|
| 网络错误 | 显示错误提示 | "网络连接失败，请检查网络设置" |
| API认证错误 | 显示错误提示 | "语音服务认证失败，请检查API密钥配置" |
| API调用错误 | 显示错误提示 | "语音服务暂时不可用，请稍后重试" |
| 请求超时 | 显示错误提示 | "请求超时，请检查网络连接后重试" |
| 参数错误 | 显示错误提示 | "参数错误: xxx" |

## 4. 代码使用示例

### 4.1 基本用法

```dart
import 'package:flutter/material.dart';
import 'models/word.dart';
import 'widgets/word_card.dart';

class WordLearningPage extends StatelessWidget {
  final Word currentWord = Word(
    id: '1',
    english: 'hello',
    chinese: '你好',
    phonetic: '/həˈloʊ/',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('单词学习')),
      body: Center(
        child: WordCard(
          word: currentWord,
          showAnswer: true,
          accent: 'american', // 可选：'british' 或 'american'
        ),
      ),
    );
  }
}
```

### 4.2 带错误处理的用法

```dart
WordCard(
  word: word,
  showAnswer: true,
  accent: 'american',
  onMastered: () {
    // 用户点击"已掌握"按钮
    print('用户掌握了该单词');
  },
  onNext: () {
    // 用户点击"未掌握"按钮
    print('用户需要继续学习');
  },
)
```

## 5. Android权限配置

确保AndroidManifest.xml中已添加网络权限：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 网络权限（必须） -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application>
        ...
    </application>
</manifest>
```

文件位置：`android/app/src/main/AndroidManifest.xml`

## 6. 测试步骤

1. **配置API密钥**：按照第2步替换API密钥
2. **安装依赖**：运行 `flutter pub get`
3. **运行应用**：连接设备并运行 `flutter run`
4. **测试发音**：点击单词卡片上的喇叭图标

## 7. 常见问题

### Q1: 点击喇叭没有反应？

1. 检查API密钥是否正确配置
2. 检查网络连接
3. 查看控制台错误信息

### Q2: 如何切换英式/美式发音？

在WordCard组件中设置 `accent` 参数：
```dart
WordCard(
  word: word,
  accent: 'british',  // 英式
  // accent: 'american', // 美式（默认）
)
```

### Q3: 播放时出现错误提示？

- **网络错误**：检查设备网络连接
- **认证错误**：检查API密钥是否正确
- **超时错误**：可能是网络不稳定，重试即可

### Q4: 如何自定义发音参数？

在 `baidu_tts_service.dart` 中修改以下参数：

```dart
'spd': '5',  // 语速，范围0-15
'pit': '5',  // 音调，范围0-15
'vol': '15', // 音量，范围0-15
```

## 8. 注意事项

1. **API配额**：百度TTS有每日调用限制，请注意配额使用
2. **网络要求**：需要稳定的网络连接
3. **Android版本**：最低支持Android 4.1 (API 16)
4. **iOS支持**：如需支持iOS，需要额外配置iOS原生代码

## 9. 扩展功能建议

1. **发音收藏**：添加收藏发音功能
2. **播放历史**：记录播放历史
3. **离线缓存**：缓存常用单词发音
4. **语速调节**：添加语速滑块控制
5. **发音对比**：支持英美发音对比

---

如有问题，请检查：
1. API密钥是否正确
2. 网络连接是否正常
3. 控制台错误日志
