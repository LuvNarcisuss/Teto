# 用户提供的 Teto Logo

直接采用用户上传的黑色轮廓、白黄渐变字面、青柠底色原图，不再使用本次自行设计的 Logo。

- `Teto-user-original.png`：上传原图，1024 × 1024。
- `TetoMark`、`TetoWordmark`：逐字节复制原图，保持原色渲染。
- `AppIcon`：仅移除完全不透明的 alpha 通道，所有 RGB 像素与原图一致。
- 欢迎/协议页：112pt 方形 Logo，保留练舞插画、现有配色、英文文案和滚动排版。
- 数据加载页：160pt 方形 Logo 和绿色加载指示；系统启动背景继续使用奶白。

`manifest.json` 保存来源及哈希。没有重新生成、重绘、裁切或调色。先将插画加入 StackView，再激活相对宽高约束，修正用户报告的 no-common-ancestor 异常来源。仅静态检查，未编译或运行 App。
