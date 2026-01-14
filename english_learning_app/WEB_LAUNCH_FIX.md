# Flutter Web启动问题解决方案

## 问题1: Edge浏览器启动失败

错误信息：`Failed to launch browser. Make sure you are using an up-to-date Chrome or Edge.`

### 解决方案

1. **关闭所有Edge浏览器窗口**
   - 确保没有Edge浏览器正在运行
   - 打开任务管理器，检查是否有残留的Edge进程

2. **清理临时文件**
   ```bash
   flutter clean
   ```

3. **重新获取依赖**
   ```bash
   flutter pub get
   ```

4. **尝试使用Chrome而不是Edge**
   ```bash
   flutter run -d chrome
   ```

5. **如果仍有问题，使用web-server模式**
   ```bash
   flutter run -d web-server
   ```

6. **检查系统权限**
   - 确保以管理员身份运行命令提示符/PowerShell

## 问题2: Web模式语音播放

已修复`audio_player_service.dart`以支持Web平台。

### 运行步骤

1. 启动应用：
   ```bash
   cd english_learning_app
   flutter run -d web-server
   ```

2. 在浏览器中打开显示的URL（通常是 `http://localhost:xxxx`）

3. 点击单词旁边的喇叭图标测试语音播放

## 注意事项

- Web模式下语音播放依赖浏览器的音频支持
- 确保浏览器允许自动播放音频
- 首次播放可能需要用户交互才能播放音频
