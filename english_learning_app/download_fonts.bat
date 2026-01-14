@echo off
echo ============================================
echo Noto Sans SC 字体下载脚本
echo ============================================

echo 正在创建字体目录...
mkdir fonts

echo 正在下载 Noto Sans SC 字体...
echo 请访问: https://fonts.google.com/noto/specimen/Noto+Sans+SC
echo 
echo 或者使用以下直接下载链接：
echo 
echo Regular: https://github.com/googlefonts/noto-cjk/raw/main/Sans/OTF/SimplifiedChinese/NotoSansSC-Regular.otf
echo Medium: https://github.com/googlefonts/noto-cjk/raw/main/Sans/OTF/SimplifiedChinese/NotoSansSC-Medium.otf
echo Bold: https://github.com/googlefonts/noto-cjk/raw/main/Sans/OTF/SimplifiedChinese/NotoSansSC-Bold.otf
echo.
echo 请手动下载这些文件并保存到 fonts/ 目录：
echo - NotoSansSC-Regular.otf -> assets/fonts/NotoSansSC-Regular.ttf
echo - NotoSansSC-Medium.otf -> assets/fonts/NotoSansSC-Medium.ttf  
echo - NotoSansSC-Bold.otf -> assets/fonts/NotoSansSC-Bold.ttf
echo.
echo 替代方案：
echo 如果无法下载，可以使用系统自带的中文字体
echo 修改 lib/main.dart 中的 fontFamily 为 'Microsoft YaHei' 或 'PingFang SC'

echo ============================================
echo 字体配置完成！
echo ============================================
pause