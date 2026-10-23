# Teto — Dancing T

> 历史方案：用户已选择更简洁的「律动 t」。当前资源及来源见 `Design/Brand/Teto-Rhythm-2026-10-20/`；下文描述的是此前版本，不再对应运行时图标。

2026-10-20 更新的品牌标识。以舒展手臂、弯曲双腿和流动躯干表达舞蹈，整体暗含 T 的轮廓；浅青柠圆点形成头部与节奏重心。当前版本替代此前普通小写 t 加横向曲线的标识。

## 配色与使用

- 常青绿 `#126B58`：桌面图标底色，与应用主色呼应。
- 奶白 `#FAFBF7`：舞者主体，在深色背景上保持清晰。
- 浅青柠 `#DDF4A6`：头部强调色，与应用强调色呼应。
- AppIcon 使用完整、不透明正方形，系统负责桌面圆角遮罩；不把圆角烘焙进源图。
- 界面 Logo 采用绿色圆角徽记与原生圆润粗体 `Teto` 字标组合。字标使用系统字体，保持 Dynamic Type 支持；组合标识的无障碍名称为英文 `Teto`。透明底生成尝试存在边缘杂点，未采用、未打包；最终徽记与桌面图标共享干净的原图。
- 欢迎页和登录页使用共享 `TetoBrandLockup`；加载页使用同一桌面图标图形。
- 保留图形比例和四周留白，不添加文字水印、额外装饰或动画。

色值为设计目标；AI 原始栅格图包含抗锯齿与轻微像素色差，并非精确矢量色板。

## 文件与来源

- `app-icon-original.png`：内置 image_gen 生成的 1254 × 1254 原图。
- 运行时 AppIcon：`Teto/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png`。
- 运行时加载图标：`Teto/Resources/Assets.xcassets/TetoMark.imageset/TetoMark.png`。
- 运行时 Logo 组合：`Teto/DesignSystem/TetoStyle.swift` 中的 `TetoBrandLockup`，读取 `TetoMark`，与系统字体字标组合。
- `provenance.json`：完整生成提示、来源位置、导出方法与检查范围。

品牌文件留在 Design 目录，不作为用户内容或舞蹈视频。当前品牌设计使用 AI 生成图形与系统字体，没有引入第三方图片或字体。

## 检查范围

仅检查资源、源码与工程配置，并查看生成图像和缩小至 64 × 64 的桌面图标。确认图像无文字、水印或禁止文案，舞者在小尺寸下仍可辨识。

未编译、运行 App、启动模拟器、执行测试或 SwiftUI Preview。不同设备、大字体及摄影背景上的实际组合效果仍未经过运行验证。
