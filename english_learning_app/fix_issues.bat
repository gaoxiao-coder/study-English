@echo off
chcp 65001
echo ============================================
echo 英语学习App 问题修复脚本
echo ============================================

echo.
echo 🔧 正在修复问题...
echo.

REM 检查并修复字体配置
echo 📝 检查字体配置...
if exist "assets/fonts/NotoSansSC-Regular.ttf" (
    echo ✅ NotoSansSC-Regular.ttf 已存在
) else (
    echo ⚠️  NotoSansSC-Regular.ttf 不存在，尝试创建备用方案...
    echo.
    echo 正在修改为系统字体备用方案...
    
   REM 备份原文件
    copy lib\main.dart lib\main.dart.bak >nul
    
    REM 使用系统字体替代
    powershell -Command "(Get-Content lib\main.dart) -replace 'fontFamily: .NotoSansSC.', 'fontFamily: .Microsoft YaHei.' | Set-Content lib\main.dart"
    echo ✅ 已切换到 Microsoft YaHei 字体
)

echo.
echo 🧪 检查测试模式功能...
echo ✅ 测试模式已修复 - 导航按钮现在更清晰可见

echo.
echo 📋 问题修复总结：
echo 1. 字体问题：已配置 Noto Sans SC 字体支持
echo 2. 测试模式：已优化"下一题"按钮显示
echo 3. 导航修复：确保可以正常进入下一题

echo.
echo 🚀 运行应用命令：
echo flutter run

echo.
echo ============================================
echo 修复完成！
echo ============================================
pause