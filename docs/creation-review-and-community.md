# 创建、审核队列与社区数据调整

## 创建流程

Live 顶部视频按钮进入 LiveCreationView，Shorts 对应按钮进入 ShortVideoCreationView；资料库、短视频空状态、Chats 发布入口统一进入短视频表单。点击创建不自动启动 Photos 选择器。

- 直播：标题、介绍、舞种、可选封面、舞蹈及素材使用权确认；不直接开启摄像头或推流。
- 短视频：标题、介绍、舞种、显式选择视频；校验最长 3 分钟、250 MB，英文标题最多 80 字符、介绍最多 500 字符。
- 点击 Submit for review 后，素材与 CreationSubmission 原子保存到原有 library-v1.json / Media；成功保存才出现 Pending review。
- Me 新增 Pending review 数量入口，包含直播、短视频列表与详情，可移除提交，保留 Photos 原文件。2026-10-22 起，这个入口改到 Works、Liked、Saved、About 同一排，位于 Saved 和 About 之间，不再是钱包下方的单独按钮。点开后在这一页列出待提交内容。
- pending 数据不进入 Live/Shorts 推荐、搜索结果、作者作品或点赞收藏列表。旧个人作品和互动记录保留。
- 新 submissions 为可选字段，旧版资料库可继续读取。启动清理保留已引用的直播封面和短视频；导入或快照保存失败时清除本次新副本，不覆盖旧数据。

## 服务边界

没有审核后端。状态模型是 awaitingSubmission，详情明确 Waiting to submit；不会声称已上传、审核通过、公开发布或成功开播。后续应由上传/审核服务推进状态，不应使用计时器自动通过。

## 互动和举报

- 内置作品点赞/收藏基数稳定分配在 10–29，用户点赞/收藏后加 1，取消后减 1；分享基数 10–30。按视频 ID 固定，不随刷新变化。
- 自己的新作品基数为 0，不预填他人的评论或互动。
- 短视频、收藏和作者主页继续读取同一个 ShortsInteractionStore，不迁移或删除用户既有点赞、收藏、评论、回复。
- Shorts 普通评论、回复和弹幕列表显示旗帜举报按钮。Live 与语音房可长按评论选择 Report comment；Live 同时提供 VoiceOver 操作。
- 举报复用原因表单、附言和现有本地保存机制；包含评论正文、作者、所属视频/房间及评论标识；新增 Comment 内容类型兼容旧举报。没有举报接口，仍准确显示未提交状态，不生成虚假受理结果。
- 举报面板打开后暂停直播/语音房自动追加，关闭后恢复。

## 语音房

8 个内置房间人数分别为 4、6、3、5、8、4、7、10，共 47 个独立成员身份。房间外显示成员数量，成员面板、头像组、评论作者和右侧席位使用同一份名单。刷新只改变房间顺序，不随机把同一身份放入多个房间。

每个房间独占一张人像和一张生活照；其余成员使用名字字母头像，不复用别人的照片。来源、许可记录保持不变。内置名单不是实时在线数据，私人房间草稿仍为空成员，不凭空添加访客。

## 主要修改文件

- Teto/Features/Creation/CreationSubmission.swift、CreationViews.swift：新页面与状态模型。
- Teto/App/AppStore.swift、Teto/Domain/LocalLibrary.swift、Teto/Data/LocalLibraryRepository.swift：队列保存、素材生命周期和推荐隔离。
- Features/Live/DiscoveryView.swift、VideoLibraryView.swift、Features/Shorts/ShortsFeedView.swift、Features/Parties/PartySheets.swift：创建入口。
- Features/Profile/ProfileView.swift：待审核入口。
- Features/Shorts/ShortsInteractionStore.swift、ShortsPanels.swift：小数量基数和举报。
- Features/Safety/ContentSafety.swift、ContentSafetyViews.swift：评论举报类型与表单复用。
- Features/LiveRoom/CommentFeedView.swift、LiveRoomView.swift：直播评论举报与暂停。
- Features/Parties/PartyModels.swift、PartyComponents.swift、VoicePartyRoomView.swift：独立成员、人数和语音房举报。
- Teto.xcodeproj/project.pbxproj：两个新增 Swift 文件的工程引用；通过 xcodegen 同步，未改部署版本或签名。

## 检查与未验证项

仅检查源码、资源引用、差异和工程元数据。静态清单确认 47 个成员姓名不重复、16 张分配图片的资源名与文件内容均不重复、PhotosPicker 只存在于新建表单中；Xcode 工程 plist 结构检查通过。未编译、未运行 App、未启动模拟器、未执行 Preview 或测试。需要在获得运行授权后验证：Photos/iCloud 导入、存储不足、杀进程后恢复、取消与重复提交、键盘和大字号、举报面板开关、双列卡片适配。当前检查不代表编译或运行通过。

修改前源码备份：/private/tmp/teto-before-creation-review.zip。

## 用户主页计数补充

作者主页 Likes / Saves / Following / Followers 的内置基数统一为约 10–30，按作者 ID 稳定分配；取消原先成千上万的计算。主页新增 Saves 指标，大字号下四项自动排成两列。通过 AppStore 叠加本机对该作者作品的点赞、收藏，以及对作者的关注；取消操作会扣回，仍从原有持久化状态读取，不清空已有数据。

Me 的 Liked(n)、Saved(n) 继续使用实际视频条数，不伪造或把较小条数抬高到 10。自己的作者页不使用虚构基数：Likes/Saves 取已有操作，Following 统计本机关注，尚无服务提供的 Followers 为 0。

文件：CreatorProfile.swift（基数）、CreatorProfileView.swift（指标布局）、AppStore.swift（本地操作叠加）。仅源码检查，未编译、运行或执行测试。备份 /private/tmp/teto-before-profile-counts.zip。

## 作者获赞与收藏改为作品合计（替代上一节的独立基数规则）

作者主页 Likes 和 Saves 现在遍历该作者所有作品，逐项读取 ShortsInteractionStore.counts(for:) 后求和，不再叠加作者级随机基数或旧资料中的获赞字段。作者作品网格与汇总共用 creatorWorks(for:)，不受首页随机排序、筛选或短视频时长限制影响；待审核提交不计入。关注和粉丝仍沿用小数量规则。

点赞、取消点赞、收藏和取消收藏仍通过原有原子保存更新共享状态。主页订阅 AppStore，AppStore 转发 ShortsInteractionStore 变更，收藏来自当前 library 快照；主页与作品无独立缓存或第二次增减。重启后从同一批持久化标记重新计算。

直播首页的首张大卡、网格卡及首页 Saved 筛选卡均关闭时长和播放小三角，也不再向 VoiceOver 播报时长。独立收藏/个人视频资料库保留原有时长信息。

修改文件：AppStore.swift、CreatorProfile.swift、CreatorProfileView.swift、VideoLibraryView.swift。完成源码差异和调用链检查；未编译、运行或测试。备份 /private/tmp/teto-before-aggregate-profile-totals.zip。
