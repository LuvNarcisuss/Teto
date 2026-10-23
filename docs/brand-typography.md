# Teto 品牌字标与标题

当前图标使用 Design/Brand/Logo-v6 的青绿色流动背景版本；AppIcon 与 TetoMark 为相同的 1024 × 1024 不透明图像。

Teto 字标仍由 image_gen 生成，原稿与提示词位于 Design/Brand/Wordmark-v1。Assets 中的 TetoWordmark 保留原始透明度，采用 template 渲染。

界面文字不再使用 Avenir Next 或系统字体。2026-10-21 起，全部界面文字使用自绘字体 Teto Rhythm：正文为 `TetoRhythm-Text`，标题为更斜、更重的 `TetoRhythm-Display`。笔形是圆头、前倾的丝带，和字标同一方向。生成脚本在 `Design/Brand/Type/build_rhythm.py`，运行时文件在 `Teto/Resources/Fonts/`，协议页副本在 `Agreements/`。`TetoTheme.font` 统一取这两套字，并跟随 Dynamic Type。系统键盘、相册选择器和系统分享面板仍使用系统自己的文字。

2026-10-22 重绘了数字 6。下半是一个圆，上半是开口的钩，钩不再收回到圆的另一侧。旧笔形会把 6 看成 8。两套字体已按脚本重新生成，协议页副本与运行时文件相同。

未编译、运行或测试。仍需在设备上确认小字号、长标题和大字体下的可读性。
