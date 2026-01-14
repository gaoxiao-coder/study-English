# 英语学习App

一个功能完整的英语学习移动应用，使用Flutter跨平台框架开发，支持iOS和Android平台。

## 功能特性

### 核心功能
- **单词学习**：内置100个基础英语词汇，包含英文、中文释义和音标
- **单词测试**：随机抽取已学习单词进行测试，支持单选题形式
- **学习进度追踪**：实时记录学习进度，显示已掌握单词数量和百分比
- **数据本地存储**：使用SharedPreferences持久化存储学习数据

### 界面功能
- **首页**：显示学习进度统计、快捷操作入口、学习统计信息
- **单词学习页**：卡片式单词展示，支持滑动切换，标记掌握状态
- **设置页**：深色/浅色模式切换，学习进度查看和重置

### 特色功能
- 深色/浅色主题切换
- 单词复习次数统计
- 测试正确率记录
- 学习次数和测试次数统计
- 学习进度可重置

## 项目结构

```
english_learning_app/
├── lib/
│   ├── main.dart                      # 应用入口
│   ├── models/                        # 数据模型
│   │   ├── word.dart                  # 单词模型和初始数据
│   │   └── app_settings.dart          # 应用设置模型
│   ├── screens/                       # 页面
│   │   ├── home_screen.dart           # 首页
│   │   ├── word_learning_screen.dart  # 单词学习页/测试页
│   │   └── settings_screen.dart       # 设置页
│   ├── widgets/                       # 自定义组件
│   │   └── word_card.dart             # 单词卡片组件
│   └── services/                      # 服务层
│       └── storage_service.dart       # 本地存储服务
├── pubspec.yaml                       # 项目配置文件
└── README.md                          # 项目说明文档
```

## 环境要求

### 开发环境
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode（用于模拟器运行）
- VS Code（推荐）或 Android Studio（IDE）

### 系统要求
- Windows / macOS / Linux（开发）
- iOS 12.0+ / Android 5.0+（运行）

## 安装步骤

### 1. 安装Flutter SDK

#### Windows
```bash
# 1. 下载Flutter SDK压缩包
# 访问 
# 下载最新稳定版并解压到指定目录

# 2. 添加环境变量
# 将 flutter/bin 添加到系统 PATH

# 3. 验证安装
flutter doctor
```

#### macOS
```bash
# 1. 使用Homebrew安装
brew install --cask flutter

# 2. 验证安装
flutter doctor
```

#### Linux
```bash
# 1. 下载并解压Flutter SDK
# 访问 https://flutter.dev/docs/get-started/install/linux
# 下载最新稳定版并解压到指定目录

# 2. 添加环境变量到 ~/.bashrc 或 ~/.zshrc
export PATH="$PATH:/path/to/flutter/bin"

# 3. 验证安装
source ~/.bashrc
flutter doctor
```

### 2. 配置开发工具

```bash
# 运行flutter doctor检查环境
flutter doctor

# 根据提示安装缺失的工具
# 例如：
# - Android SDK
# - Android Studio
# - Xcode（仅macOS）
# - VS Code Flutter插件
```

### 3. 克隆或创建项目

```bash
# 如果项目已存在，进入项目目录
cd english_learning_app
```

### 4. 安装依赖

```bash
# 安装Flutter依赖包
flutter pub get
```

## 运行应用

### 使用VS Code

1. 打开VS Code
2. 安装Flutter和Dart插件
3. 打开项目文件夹 `english_learning_app`
4. 按 `F5` 或点击"Run > Start Debugging"
5. 选择目标设备（模拟器或真机）

### 使用命令行

```bash
# 查看可用设备
flutter devices

# 运行应用（默认设备）
flutter run

# 指定设备运行
flutter run -d <device-id>

# 例如：
flutter run -d chrome          # 运行在Chrome浏览器（Web）
flutter run -d windows         # 运行在Windows桌面
flutter run -d macos           # 运行在macOS桌面
flutter run -d emulator-5554   # 运行在Android模拟器
```

### 使用Android Studio

1. 打开Android Studio
2. 选择"Open an Existing Project"
3. 选择 `english_learning_app` 目录
4. 等待项目索引完成
5. 点击运行按钮（绿色三角形）

## 依赖包说明

项目依赖的核心包（在 `pubspec.yaml` 中配置）：

- `flutter` - Flutter SDK
- `shared_preferences: ^2.2.2` - 本地数据持久化存储
- `provider: ^6.1.1` - 状态管理

## 开发说明

### 代码规范

1. **命名规范**
   - 类名：大驼峰命名法（PascalCase）
   - 变量和方法名：小驼峰命名法（camelCase）
   - 私有成员：以下划线开头

2. **注释规范**
   - 所有公共类和方法添加文档注释
   - 关键逻辑添加行内注释
   - 注释使用中文，便于理解

3. **代码结构**
   - 遵循MVC架构模式
   - Model层：数据模型
   - View层：UI组件和页面
   - Service层：业务逻辑和数据处理

### 关键功能模块说明

#### 1. 数据模型层（models/）

**word.dart**
- `Word` 类：单个单词的数据模型
- `WordData` 类：包含100个基础词汇的静态数据

**app_settings.dart**
- `AppSettings` 类：应用设置数据模型，继承自ChangeNotifier
- 管理深色模式、学习进度等设置状态

#### 2. 页面层（screens/）

**home_screen.dart**
- 首页界面
- 显示学习进度、统计信息
- 提供快捷操作入口

**word_learning_screen.dart**
- 单词学习和测试界面
- 支持两种模式：学习模式和测试模式
- 使用PageView实现滑动切换单词

**settings_screen.dart**
- 设置界面
- 主题切换
- 学习进度查看和重置

#### 3. 组件层（widgets/）

**word_card.dart**
- 可复用的单词卡片组件
- 显示单词英文、中文、音标
- 提供标记掌握状态功能

#### 4. 服务层（services/）

**storage_service.dart**
- 本地存储服务
- 封装SharedPreferences操作
- 提供单词数据、设置的存取方法

### 自定义开发

#### 添加新单词

编辑 `lib/models/word.dart` 文件，在 `WordData.getInitialWords()` 方法中添加：

```dart
Word(
  id: '101',
  english: 'example',
  chinese: '例子',
  phonetic: '/ɪɡˈzæmpl/',
),
```

#### 修改主题颜色

编辑 `lib/main.dart` 文件，修改 `ColorScheme.fromSeed` 的 `seedColor` 参数：

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.green, // 改为你喜欢的颜色
  brightness: Brightness.light,
),
```

#### 修改测试题目数量

编辑 `lib/screens/word_learning_screen.dart` 文件，修改题目数量：

```dart
if (_testQuestions.length > 20) { // 改为你想要的题目数量
  _testQuestions = _testQuestions.sublist(0, 20);
}
```

## 构建发布版本

### Android APK

```bash
# 构建APK
flutter build apk

# 构建APK并安装到设备
flutter install

# APK文件位置：build/app/outputs/flutter-apk/
```

### Android App Bundle

```bash
# 构建AAB（推荐用于发布到Google Play）
flutter build appbundle

# AAB文件位置：build/app/outputs/bundle/release/
```

### iOS

```bash
# 构建iOS应用（需要macOS和Xcode）
flutter build ios

# 使用Xcode打开项目进行打包
open ios/Runner.xcworkspace
```

### Web应用

```bash
# 构建Web应用
flutter build web

# Web应用文件位置：build/web/
```

## 常见问题

### 1. 运行时提示依赖缺失

```bash
# 重新安装依赖
flutter clean
flutter pub get
```

### 2. 模拟器无法启动

- 确保已安装Android SDK或Xcode
- 运行 `flutter doctor` 检查配置
- 尝试创建新的模拟器

### 3. 应用闪退

- 查看控制台错误日志
- 确保设备满足最低系统要求
- 尝试在真机上运行

### 4. 数据丢失

- 学习数据存储在本地SharedPreferences中
- 卸载应用会清除所有数据
- 可以使用设置中的"重置学习进度"功能

## 技术栈

- **框架**：Flutter 3.0+
- **语言**：Dart 3.0+
- **状态管理**：Provider
- **本地存储**：SharedPreferences
- **UI设计**：Material Design 3

## 许可证

本项目仅供学习和参考使用。

## 作者

由OpenCode AI助手创建

## 更新日志

### v1.0.0 (2024-01-14)
- 初始版本发布
- 实现100个基础词汇学习
- 支持单词测试功能
- 深色/浅色主题切换
- 学习进度追踪
- 数据本地存储

## 联系方式

如有问题或建议，请通过GitHub Issues反馈。
