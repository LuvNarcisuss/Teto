# Teto 项目工作约束

本文件适用于整个仓库。GPT/Codex 及其他编码代理在修改代码、界面、文案、数据或素材前必须阅读并遵守。用户的最新明确要求优先；旧设计稿、参考代码和历史文档不能覆盖以下产品约束。

## 1. 产品定位

- Teto是面向舞蹈爱好者的 iOS 社交软件，核心是分享舞蹈、观看舞蹈视频、交流练舞经验和结识舞友。
- Live、Shorts、Voice、Chats、Me 的内容和交互都应服务于舞蹈社交，不得扩展成泛娱乐、购物、旅游、美食或宠物内容应用。
- 保持现有四个底部 Tab；Shorts 位于 Live 内。未经用户要求，不重做导航或引入无关功能。
- 当前主题为 Fresh Studio：奶白、常青绿、浅青柠。钻石是唯一虚拟货币，不再添加金币入口、余额或商品；历史设计稿中的金币内容已经失效。

## 2. 应用语言：全部英文

- 所有应用内可见文案必须使用自然、简洁的英文，不得出现中文或中英混排。
- 范围包括页面标题、按钮、导航、表单、占位文字、空状态、加载状态、报错、弹窗、通知、权限用途说明、无障碍标签、分享文案，以及内置昵称、简介、评论、房间名称和视频标题。
- 图片、视频字幕、封面、贴纸和水印中的可见文字同样必须检查；不能通过把中文做进图片或视频绕过限制。
- 新增用户输入或服务端内容入口时，要明确英文内容校验和呈现规则，不得直接把不符合要求的内容当作默认文案。不得擅自删除或改写用户已有的私人数据。
- 保持 `project.yml`、`Info.plist` 和 UIKit 界面中的英文语言配置。系统拥有的键盘、Photos 选择器和分享面板可能遵循设备语言；不得把它们宣称为已经受应用完全控制。
- 与用户的对话、开发文档和代码注释可以使用中文；这些内容不得作为应用资源或界面文案打包。

## 3. 禁止展示、演示性质的措辞

- 应用中不得出现“展示”“演示”及同义表述，也不得用英文换一种写法表达同样意思。
- 禁止把产品、页面、视频、账号或交互描述为 `demo`、`demonstration`、`showcase`、`sample`、`mock`、`mockup`、`prototype`、`exhibition`、`test mode`、`demo mode`，或使用 `preview`、`presentation`、`display` 等词包装展示/演示用途。大小写、复数和组合词同样检查。
- 不要使用“仅供演示”“示例内容”“模拟直播”等标签，也不要加“功能展示”“体验样例”等说明。采用实际业务文案，例如 `Dance`、`Practice`、`Freestyle`、`Share your dance`。
- 这是产品文案要求，不是伪造能力的许可。未接入的认证、开播、消息、支付、礼物发送等不得返回虚假成功；用准确英文表达当前可用操作或不可用状态。
- SwiftUI 的 `#Preview`、系统 API 标识符和不进入界面的兼容字段不属于产品文案。保留既有 `savedDemoVideoIDs` 序列化键以兼容旧收藏数据，不得为了关键词检查破坏数据迁移。

## 4. 视频素材：只保留跳舞

- Live 和 Shorts 必须使用实际有人跳舞的素材，允许编舞、练舞、舞蹈教学、自由舞、舞台舞蹈、舞蹈对练等内容。
- 咖啡、城市风景、烹饪、日落、单独弹吉他、宠物、海边散步等非舞蹈视频必须删除；配上音乐或舞蹈标题不能把非舞蹈内容变成合格素材。
- 清理范围包括工程内原视频、运行时副本、对应视频封面、资源引用、目录条目和默认推荐数据。非舞蹈视频不能藏在 `Design/SourceMedia` 或其他归档目录继续保留。可以保留不进入应用的来源和删除记录。
- 当前已检查并允许的内置视频共 12 段：原有 `dance-studio.mp4`、`dance-seaside.mp4`，以及 2026-10-20 新增的 `dance-hiphop-solo.mp4`、`dance-crew-rhythm.mp4`、`dance-white-studio.mp4`、`dance-hiphop-duet.mp4`、`dance-ballet-duet.mp4`、`dance-studio-joy.mp4`、`dance-practice-partners.mp4`、`dance-purple-groove.mp4`、`dance-contemporary-flow.mp4`、`dance-ballet-class.mp4`。作者、来源、许可、原文件映射与代表帧检查记录以 `Design/SourceMedia/manifest.json` 为准；后续新增仍须按下列检查要求执行。
- 新增素材前必须检查实际画面，不能仅凭文件名、网页标题或 `isDance` 标记判断。检查代表性时间点和可见文字；仅有静态图不能代替视频素材。
- Live 和 Shorts 共用 `Teto/Domain/DanceVideoCatalog.swift`，运行时视频及封面位于 `Teto/Resources/DanceMedia/`，来源登记在 `Design/SourceMedia/manifest.json`。
- 新素材必须记录作者、来源、许可、原始文件与运行时文件映射；不得编造授权。保持正确宽高比和原始播放速度，不拉伸、不随意加速。
- 用户导入入口应明确要求舞蹈视频；非舞蹈或未分类内容不得自动进入推荐流。当前 `isDance` 仅代表分类状态，不代表已经完成视觉识别或内容审核。
- 上述删除授权针对项目提供的素材，不授权删除设备相册、个人资料库或用户原文件。处理存量私人内容时保留数据，采用分类/过滤及明确的用户删除操作。

## 5. 工程边界

- 按用户 2026-10-22 的要求，最低系统为 iOS 16。界面仍按 2026-10-20 的要求使用 UIKit + Swift 5、AVFoundation；不使用 SwiftUI、UIHostingController 或 Objective-C 源文件。保留同一工程和本地数据格式，不迁移 Flutter 或 React Native。应用自有图标使用 image 模型生成的透明位图，统一由 TetoIcon 加载；不得退回 SF Symbols 或代码绘制图标。系统拥有的键盘、分享面板及 Photos 控件不在自有图标替换范围内。此前 iOS 17+ 的最低系统要求已失效。
- 应用显示名称为 `Teto`。源码位于 `Teto/`；工程文件为 `Teto.xcodeproj`，定义以 `project.yml` 为准；Target/Scheme 为 `teto`。按用户 2026-10-23 的要求，Bundle ID 为 `com.teto.dance`（此前 `im.seex.sao2-neiku-30` 已失效），本地数据目录为 Application Support/Teto；同一沙盒内按数据格式迁移旧目录，不跨 Bundle ID 迁移。此前占位 Bundle ID `com.example.teto` 已失效，钻石内购必须跟当前 Bundle ID 的商店商品走。
- 必要时使用 `xcodegen generate --spec project.yml --project . --no-env` 同步工程元数据。
- 保持本地保存的原子写入、收藏 ID 和旧资料库兼容性；不要以素材清理为由重置用户数据。
- 不虚构服务地址、账号、签名团队、购买商品 ID、在线人数、送达回执或交易结果。当前服务接入情况以 `docs/implementation-status.md` 为准。
- `Design/References/`、`docs/archive/` 和参考指南仅作为历史资料，不得把其中的旧文案、非舞蹈视频要求或中文设计图直接引入运行时。

## 6. 每次交付前检查

1. 静态检查改动涉及的界面字符串、内置数据、权限说明、无障碍文案和素材可见文字，确认英文和禁用措辞要求。
2. 检查 Live/Shorts 的目录、推荐数据、视频和封面，只引用舞蹈内容；被删除资源不能残留在 Xcode 引用中。
3. 新增/替换素材时同步来源登记；规则或行为变化时同步当前文档，历史记录注明已失效。
4. 遵循本项目已有验证约定：未经用户明确要求，不编译、不运行 App、不启动模拟器、不执行 SwiftUI Preview 或测试；允许源码、资源和工程配置静态检查。
5. 交付时准确说明改动和已做检查；静态检查不能表述为构建成功、运行验证通过或可上线。