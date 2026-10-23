# Teto — Rhythm t

用户确认采用的「律动 t」标识，替代此前的 Dancing T 舞者图形。

保留常青绿与奶白双色，以单一连续的小写 t 轮廓表现舞蹈动势：横笔向右上扬，主体略有倾斜，底部弯曲收尾。移除独立头部、双腿及其他装饰。

## 文件与使用

- `selected-concept.png`：用户确认的完整效果图，仅留在 Design 目录，不进入应用。
- `app-icon-original.png`：根据选定稿左侧图标，通过内置 image_gen 提取并延展为无预制圆角的完整绿色正方形。
- `provenance.json`：选定稿与生产资源的来源、完整提示及导出记录。
- `Teto/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png`：1024 × 1024、不含透明通道的桌面图标。
- `Teto/Resources/Assets.xcassets/TetoMark.imageset/TetoMark.png`：同款图形，用于欢迎、登录和加载页。

欢迎和登录页沿用原生 `TetoBrandLockup`，新徽记与系统圆润粗体 `Teto` 字标组合。系统字体与 Dynamic Type 保持可访问性；不将整张效果图或图片文字嵌入界面。桌面圆角由 iOS 添加，应用内徽记由现有 SwiftUI 裁切。

目标色值为常青绿 `#126B58` 和奶白 `#FAFBF7`；生成栅格包含抗锯齿及轻微像素色差。应用的浅青柠强调色继续保留。未引入第三方字体或图片。

## 检查边界

检查资源尺寸、PNG 色彩类型、资源 JSON、工程引用、英文配置及图形本身，并查看 64 × 64 缩小图。视频、封面、目录和来源登记保持原状。

仅静态检查，未编译、运行 App、启动模拟器、执行测试或 SwiftUI Preview。真机效果仍未经运行验证。
