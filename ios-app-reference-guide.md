# Nana iOS App：功能设计、架构与实现参考

整理日期：2026-10-19

参考项目：`/Users/apple/Desktop/Nana-master`

用途：供下一个会话理解 Nana，并据此在独立目录创建新的原生 iOS App。

本文基于工程配置、Swift 源码、资源组织和已有开发文档进行静态整理。没有编译、运行、启动模拟器、执行测试、验证线上接口或实际购买。本文中的“已实现”表示存在对应源码，不表示已通过运行验收。README 的部分功能状态落后于源码，以下以本次源码检查为准。

## 1. 给下一个会话的阅读说明

这是一份实现参考，不是要求新 App 完整复刻 Nana 的产品需求书。

- 先阅读第 2～4 节，理解产品定位、功能范围和能力边界。
- 阅读第 5～9 节，理解入口、状态、模型、网络、存储和系统能力。
- 按第 12～14 节规划新工程，替换品牌、服务、素材和商业配置。
- 需要查阅具体实现时使用第 15 节源码索引。
- 第 16 节提供可直接复制到新会话的启动提示词。
- 如果新会话无法读取 Nana 源码，可先基于本文规划和实现独立工程；不要声称已经检查不可访问的源码。

文中源码路径均相对于上述参考项目根目录。新项目的目录树和抽象名称属于建议，不代表 Nana 已按该结构实现。

## 2. 产品定位与功能结构

Nana 是以内容发现、直播房间外观、语音房和用户关系为核心的原生 iOS 社交 App。当前形态是：较完整的页面与本地交互，结合公开只读内容服务；真实账户后端、私信收发、RTC 和服务端钱包尚未闭环。

产品主链路：

```text
启动 → 账户入口 → 进入主页
                  ├─ 内容发现 → 视频 / 房间 → 作者主页 → 关注
                  ├─ 语音房 → 麦位 / 音乐 / 礼物 / 连麦面板
                  ├─ 消息 → 好友 / 通知 / 会话 / 通话入口
                  └─ 我的 → 资料 / 钱包 / 签到 / 等级 / 设置
```

设计上的留存与消费链路：签到积累活跃积分、等级展示、关注内容、金币购买、房间送礼。当前其中多项只在本机生效，不能据此推断真实多人社交和资金结算已经完成。

主导航实际显示为 `Live / Voice / Message / Me`。源码目录名称为 `Home / Gather / Inbox / Profile`。

## 3. 功能设计清单

### 3.1 账户与引导

| 功能 | 交互设计 | 当前实现 |
| --- | --- | --- |
| 启动页 | 全屏品牌图、加载动效、恢复已有状态 | 原生 SwiftUI 启动协调器 |
| 欢迎入口 | 邮箱登录、注册、Apple 登录、协议入口 | 已有页面与导航 |
| 邮箱登录 | 邮箱规范化、密码长度检查、错误提示 | 仅格式校验；可创建或恢复本地资料，不验证密码和邮箱所有权 |
| 邮箱注册 | 输入后进入资料完善 | 保存本地待完善身份；没有服务端注册 |
| Apple 登录 | 系统授权、取消及错误处理 | 真实 AuthenticationServices 授权；保留首次返回的姓名和邮箱 |
| 完善资料 | 昵称、性别、国家、生日、兴趣标签、头像 | 校验并保存本地账户资料 |
| 会话恢复 | 冷启动恢复、前台返回检查 | Apple 身份检查凭据状态，并处理撤销通知 |
| 切换与退出 | 退出后回到账户入口，保留可再次使用的本地资料 | 清除活动账户选择和当前私有快照 |
| 删除账户 | 确认、处理中状态、移除账户数据 | 删除本机账户相关数据；不等于远程注销或 Apple Token 撤销 |

重要限制：邮箱格式校验不能作为认证成功依据。新项目如需正式账户，必须接入真实身份验证；如只做本地体验，应使用明确的访客或本地模式，不沿用“任意合规密码进入账户”的逻辑作为正式登录。

### 3.2 Live：内容发现

- 推荐与关注内容切换。
- All、Chat、Music、Creative、Late night 等分类。
- 房间推荐轮播、作者入口、内容卡片和排行榜入口。
- 搜索用户、房间、动态，按年龄、地区、语言、性别筛选。
- 房间详情与独立视频播放页。
- 视频封面使用预先生成的图片，不在列表滚动时创建播放器或实时抽帧。
- 内置 17 个视频参与推荐，已由房间展示的视频避免重复出现。
- 刷新失败时保留已有内容；内置视频仍可使用，同时显示失败和重试状态。

直播创建页设计包含封面、标题、简介、公开状态、标签和目标热度。当前可保存本地草稿，点击开始不会发布直播，也不会凭空创建在线房间。

### 3.3 Voice：语音房与房内互动

- 房间分类、关注房间、搜索、排行榜与创建入口。
- 创建表单包含房间名称、话题、目标热度、公开状态、标签和麦位数。
- 房间内包含主持人、麦位、观众、人物详情、聊天展示和礼物入口。
- 根据麦位容量布局座位；部分展示人物来自预录内容对应角色。
- 本地背景音乐：6 首内置音轨，支持切换、暂停、停止、音量和静音。
- 连麦面板：准备、排队、连接展示状态，带本地计时及控制按钮。

当前创建房间、房间消息发送、禁麦和踢人等在线操作没有写接口。连麦由本地状态推进，不会建立 RTC 连接；背景音乐也不表示已向其他用户广播。

### 3.4 用户关系、评论与内容安全

- 作者主页、公开图片查看、关注与取消关注。
- 评论列表、输入、草稿与本地追加；新增评论限制为非空且最多 500 字符。
- 对动态、房间、用户、会话和评论记录举报原因。
- 举报后按内容类型在本机隐藏对应内容；拉黑关联作者及相关展示内容。
- 黑名单查看与解除隐藏。
- 本地欢迎关注活动：从预录内容角色中选择人物，延时显示欢迎互动。

上述关注、评论、举报记录及欢迎活动不代表服务器已收到或其他用户已看到。欢迎活动不会授予真实互关、私信和通话权限。新项目建议将这类演示活动放入明确的开发演示模式。

### 3.5 Message：消息与通话

- 在线好友房间入口、好友列表、通知列表和通知详情。
- 会话列表、未读状态、本地隐藏或清理列表。
- 会话详情、文字草稿、照片及视频附件选择。
- 视频通话入口与互关限制提示。
- 本地相机预览、摄像头相关控制、权限失败与重试界面。

数据约束：

1. 私信只能来自与当前账户匹配的 `NanaAccountInboxSnapshot`。
2. 公开内容接口返回的示例会话不能成为当前用户的收件箱。
3. 真实账户关系数据结合本地关注状态决定互关能力；欢迎活动不参与授权。
4. 当前缺少私信传输服务，发送操作不会创建虚假的成功消息。
5. 视频通话仅预览本地相机，其他人不会被实际呼叫。
6. 切换账户或退出时清空私有快照；好友直播入口排除内置回放。

### 3.6 Me：个人中心与设置

| 子模块 | 设计与当前行为 |
| --- | --- |
| 个人资料 | 昵称、头像、生日、地区、性别、兴趣、简介；本地编辑保存 |
| 用户关系 | 好友、关注、粉丝、新关注；区分账户关系与本地欢迎活动 |
| 相册 | 本地添加、查看与删除照片 |
| 钱包 | 金币余额、商品档位、Apple 价格、购买流程 |
| 签到 | 按本地日期记录；每天一次，每次 10 活跃积分 |
| 等级 | 当前公式为 `1 + activityPoints / 200`，整数除法 |
| 商店与背包 | 礼物目录和相关展示入口，不应直接理解为完整在线库存系统 |
| 反馈 | 本地保存反馈记录；不代表提交给客服后台 |
| 隐私与通知 | 本地偏好设置、签到提醒等；开关本身不等于服务端权限控制 |
| 存储管理 | 缓存查看和清理、本地会话列表清理 |
| 账号与安全 | 账号入口、退出、删除本地账户、黑名单 |
| 信息与协议 | 关于、用户协议、隐私协议、社区规范 |

### 3.7 金币、购买与礼物

- 新本地账户创建时赠送 1,200 金币，记录在本机 Keychain。
- 配置了 9 档消耗型金币商品，基础金币为 500～50,000，另有各档赠送比例。
- 价格通过 `Product.products` 获取，使用 `displayPrice`；未获取到时显示查看价格，不把参考美元金额当作当前成交价。
- 使用 `Product.purchase` 发起真实 StoreKit 2 购买。
- 区分成功、待确认、取消和失败；仅经验证且未撤销的消耗型交易入账。
- 使用 `appAccountToken` 将交易关联到购买账户，防止切换账户后错误记账。
- 通过交易 ID 去重，监听交易更新并处理未完成交易。
- Release 拒绝 Xcode 本地测试交易；Apple Sandbox 交易仍可处理。
- 礼物数量、目录项、账户、余额均做检查；扣款与记录一起保存，成功落盘后才更新显示。

当前钱包是设备本地账本，送礼是本地扣款和记录。缺少服务端余额权威来源、跨设备恢复、远端收礼确认与完整退款处理。真实购买代码存在不等于商品已配置成功或购买已验收。新项目不能直接沿用 Nana 商品 ID、赠币规则和本地扣费逻辑作为完整商业系统。

Teto 不使用本节的 StoreKit 2。Teto 的钻石内购只用 StoreKit 1：`SKProductsRequest`、`SKPaymentQueue`、`SKPayment`。不要改回 `Product.products`、`Product.purchase`、`Transaction`、`displayPrice` 或 `appAccountToken`。成交价用 `SKProduct` 的本地化价格；没取到时界面写 See price。只在交易保存到本机 `wallet-v1.json` 之后调用 `finishTransaction`。礼物按本地余额扣钻，并在当前全屏画面播放特效；不要写成远端已经收到打赏。不要把 Nana 的 1,200 金币或 Keychain 账本搬进 Teto。

## 4. 能力边界总表

| 类别 | Nana 当前内容 | 新项目应如何理解 |
| --- | --- | --- |
| 原生页面与本地能力 | 导航、资料编辑、照片、播放、筛选、草稿、签到、隐藏内容 | 可参考交互和实现结构 |
| 真实系统集成 | Apple 授权、StoreKit、相机、本地通知 | 代码已接入系统 API，仍需新项目独立配置和验收 |
| 公开只读服务 | 初始化、首页、房间、详情、搜索、钱包、素材等 | 已有客户端；本次未验证线上状态 |
| 本地业务覆盖层 | 关注、评论、举报记录、反馈、礼物记录 | 仅本机生效，不代表服务端成功 |
| 演示展示 | 预录房间、预设聊天、礼物氛围、观众、欢迎关注、连麦计时 | 不得作为实时社交或在线人数依据 |
| 未接入能力 | 正式邮箱认证、私信收发、开播、RTC、服务端举报、在线钱包闭环 | 需要真实服务；没有服务时显示未接入状态 |

## 5. 技术架构

### 5.1 技术选型

| 范围 | 当前方案 |
| --- | --- |
| 平台 | iOS 17+，iPhone，竖屏 |
| 语言 | 工程配置为 Swift 5 |
| UI | SwiftUI；必要处用 UIViewRepresentable 包装 UIKit 能力 |
| 状态 | Combine、ObservableObject、@Published、@StateObject、@EnvironmentObject |
| 导航 | NavigationStack、自定义底部栏、sheet、fullScreenCover |
| 并发 | async/await、Task、取消处理、@MainActor 状态更新 |
| 网络 | URLSession、Codable、类型化错误 |
| 安全存储 | Security / Keychain |
| 媒体 | AVFoundation、PhotosUI、ImageIO、UIKit |
| 身份 | AuthenticationServices |
| 购买 | Nana 参考工程为 StoreKit 2。Teto 只用 StoreKit 1，见 3.7 末段 |
| 通知 | UserNotifications |
| 协议页面 | WebKit；不是 Web 主业务架构 |
| 工程与发布 | XcodeGen 的 project.yml、Xcode 工程、Codemagic 配置 |

项目主要依赖 Apple 原生框架，没有以 Flutter、React Native 或 Web 容器实现主界面，也没有现成 RTC 依赖可直接复用。

### 5.2 当前分层

```text
NanaHarbor/
├── NanaApp.swift
├── Features/
│   ├── AccountAccess/   账户入口、Apple 授权、资料完善、会话
│   ├── Root/            主导航外壳
│   ├── Home/            首页、搜索、视频、直播房间、草稿、礼物等
│   ├── Gather/          语音房列表、创建与麦位展示
│   ├── Inbox/           消息、好友、相册、相机预览
│   └── Profile/         个人中心、钱包、签到、等级、设置
├── Shared/
│   ├── Models/          业务模型
│   ├── Content/         内容状态、缓存、个人操作覆盖层
│   ├── Networking/      只读客户端与认证边界占位
│   ├── Commerce/        StoreKit、金币账本
│   ├── Components/      卡片、头像、素材、媒体选择等
│   └── Theme/           颜色、字体、背景、通用样式
├── Assets.xcassets/
└── Support/             Info.plist、entitlements、启动资源
```

架构更接近“按功能组织 View + 共享 Store + 服务客户端 + Codable 模型”，不是每个页面独立 ViewModel 的严格 MVVM。三个核心 Store 的职责如下：

- `NanaSessionStore`：本地账户、活动身份、资料、Apple 状态、退出和删除。
- `NanaContentStore`：公开内容、刷新状态、筛选、个人操作、私信快照、缓存与安全过滤。
- `NanaCoinStore`：商品、购买状态、交易归属、金币余额和礼物账本。

### 5.3 启动、导航与生命周期

`NanaApp` 创建 `NanaEntryCoordinator`，协调器拥有三个 `@StateObject` 并向子树注入。

```text
启动图 → 恢复本地会话
  ├─ 有活动资料 → 四个主 Tab
  ├─ 有待完善身份 → 资料完善
  └─ 无身份 → 欢迎 / 登录 / 注册

账户作用域变化
  → 重置钱包与内容状态
  → 读取该账户本地数据
  → 配置提醒
  → 刷新 bootstrap 和素材清单

回到前台
  → 检查 Apple 凭据状态
  → 刷新公开内容
  → 恢复允许的本地展示活动
```

页面内部用 `@State` 管理弹窗、选中对象、输入与局部状态；跨页面业务状态放入 Store。系统权限、文件处理和交易逻辑由专门对象承担。

## 6. 业务模型与数据所有权

| 模型 | 主要用途与关系 |
| --- | --- |
| NanaAccountProfile | 当前本地账户；含身份来源、Apple ID、个人资料 |
| NanaProfile | 公开用户；由房间、动态、会话通过用户 ID 关联 |
| NanaLiveRoom | 房间、主持人、分类、麦位容量、媒体来源和状态 |
| NanaRoomSeat | 房间中的麦位、位置、成员、角色与静音状态 |
| NanaPost | 作者动态、正文、分类、封面和展示统计 |
| NanaConversation / NanaMessage | 会话及其消息 |
| NanaAccountInboxSnapshot | 属于单个账户的关系、直播好友、会话与消息快照 |
| NanaGift / NanaRoomGiftReceipt | 礼物目录及本地赠送收据 |
| NanaWalletSnapshot | 公开接口中的钱包展示结构，不等于本机购买账本 |
| NanaSearchFilter | 内容类型、年龄、地区、语言、性别筛选 |
| NanaContentSnapshot | 公开内容聚合快照 |
| NanaPersonalState | 本地关注、评论、屏蔽、举报、草稿、照片、偏好和签到 |

可复用的数据所有权原则：

1. 公开目录数据、账户私有数据、设备偏好和演示数据分开管理。
2. 用稳定业务 ID 关联实体，不使用显示名称作为身份依据。
3. 私有数据应用前检查账户归属，切换账户后丢弃旧请求结果。
4. 新项目的服务端统计与本地操作状态分别建模，避免把本地演示数字作为真实统计。
5. 新增可选字段时考虑旧缓存兼容；缓存版本与迁移策略需明确。

## 7. 网络与缓存实现

### 7.1 当前服务合同

源码配置的 API Origin 为 `https://lantern.nanacc.top`，路径前缀为 `/harbortide/v1`。这是 Nana 配置记录，不应自动用于新项目，也不表示本次已验证可访问。

当前仅声明以下 GET 路由：

```text
bootstrap
home/feed
rooms
rooms/room-aurora
profiles/profile-ava
posts/post-echoes
search
conversations
conversations/conversation-ava/messages
wallet
gifts
assets/manifest
```

部分详情路径是已发布合同中的固定值，不能把它们误认为任意 ID 的通用接口。

响应由 `NanaAPIEnvelope<Value>` 包装，包含 `schemaVersion`、`requestID`、`data` 和可选 `meta`。当前接受 `schemaVersion == "1.0"`。

### 7.2 请求与错误处理

- GET 请求携带 `nanaReleaseVersion`，声明接受 JSON。
- 公开合同没有认证头，不伪造 Token。
- 请求超时 8 秒，会话资源超时 12 秒。
- 对允许重试的错误最多尝试 3 次，两次等待分别为 500 毫秒与 1 秒。
- 限制读取响应体大小为 8 MiB，并检查 HTTP 状态和解码结果。
- 对断网、超时、服务错误、无权限、结构不兼容等映射为本地可展示错误。
- 不把原始响应、凭据或敏感内容输出到日志和界面。
- 当前公开接口 401 只代表内容获取失败，不能擅自注销本地身份。

新项目若有正式会话，应单独设计认证失效与 Token 刷新规则，不能直接照搬“401 不处理登录”的行为。

### 7.3 刷新与持久化

每个端点维护 `idle / loading / loaded(Date) / failed(Error)` 状态。同一端点的并发刷新复用进行中的 Task。完整解码后再更新对应数据片段，避免半更新。

账户切换时取消旧请求并更新 generation；异步结果返回后必须仍属于当前 generation 才能应用。

```text
接口数据 → 类型校验 → 更新公开快照 → 应用本地个人状态 → 通知 View → 保存缓存
读取失败 → 保留已有内容 → 更新失败状态 → 页面提供重试
```

存储组织：

| 存储 | 内容 |
| --- | --- |
| Keychain 账户记录 | 本地资料、活动账户选择、待完善身份、Apple 首次返回资料 |
| Keychain 金币账本 | 余额、已处理交易、购买账户 Token、礼物收据 |
| Application Support/NanaReadCache | 按账户摘要命名的公开读取缓存 |
| Application Support/NanaPersonalData | 按账户隔离的个人操作和相关文件 |
| 内存私信快照 | 当前账户私有会话和关系；退出时清空 |
| Bundle 资源 | 随包图片、视频、封面、切图和音乐 |

Keychain 使用设备本地可访问性配置，不提供跨设备业务同步。账户作用域使用邮箱规范化结果或 Apple ID 摘要，Apple 与邮箱入口隔离；缓存目录再对作用域做摘要。摘要用于命名和隔离，不等同于对文件内容加密。

## 8. 原生媒体、权限与资源

### 8.1 素材组织

- `NanaHarbor/Assets.xcassets`：App 图标、入口插画和语义化界面素材。
- `assets/photos`：原始界面切图，保留原件。
- `assets/voice-room-slices`：语音房相关切图。
- `pics`：人物及内容图片。
- `videos` 与 `videos/covers`：内置视频和预生成封面。
- `assets/room-music`：6 首本地背景音乐。
- `garden-gpt-image-2/prompt`：设计生成记录，不属于运行时资源。

`NanaAssetLibrary` 将素材键映射到允许的 Bundle 文件。接口的 `bundlePath` 不作为任意文件路径使用；未知素材保留占位。

### 8.2 播放与权限

- 视频详情创建播放器，离开页面或进入后台时暂停；列表使用封面。
- 每个房间一个本地音乐播放器，切歌替换原播放，避免叠加多个实例。
- 媒体选择通过系统照片选择器与相机包装组件完成。
- 按用户操作请求需要的相机、麦克风权限，不在启动时统一申请所有权限。
- 选择的视频复制到临时文件管理，清理临时副本，不删除用户原片。
- 取消、拒绝权限、导入失败和离开页面都需要独立处理。

新项目如果启用联网媒体，需新增可信 URL、下载缓存、失败重试和容量策略；Nana 的 Bundle 解析器并不是完整远程媒体库。

### 8.3 UI 实现约定

- 当前视觉为深色背景、紫色与粉色强调、圆角卡片、自定义插画和切图。
- 颜色、字体、间距、圆角集中在 `NanaPalette` / `NanaType`，新项目应替换为自己的设计系统。
- 背景全屏 aspect fill 并忽略安全区；交互内容单独处理安全区和键盘避让。
- 使用自定义底栏和弹层时，确保按钮触达、滚动底部留白、关闭入口及读屏标签。
- 轮播考虑后台、弹窗、拖动、减少动态效果和 VoiceOver 等暂停条件。
- 添加覆盖文字前检查素材是否已含文字、按钮或 Logo，避免重复。
- 进行视觉修改前，按项目约定评估可用的 Taste、Design、Garden 指导；本次只编写文档，未修改视觉。

## 9. 工程与发布组织

- `project.yml` 为 XcodeGen 工程定义，记录源文件、资源、平台、权限、签名能力和构建设置。
- 仓库保留 `Nana.xcodeproj` 和共享 Scheme。
- `AppInfo.plist` 包含相机、麦克风、照片用途说明及竖屏配置。
- `Nana.entitlements` 包含 Sign in with Apple 能力声明；开发者后台与签名仍须匹配。
- `codemagic.yaml` 已描述签名、递增构建号、生成 IPA 和上传流程；不自动提交 App Store 审核。
- `docs` 保存上架文案、内购清单、发布准备、素材记录与构建说明，不作为 App 资源打包。
- `scripts` 包含封面生成、房间音乐生成及发布资源审查工具。

历史发布文档记录的随包源资源约 142 MB，其中视频及封面约 98 MB；这是 2026-09-23 的记录，不是本次重新测量，也不是 IPA 或 App Store 下载大小。新项目应按内容需求重新决定内置与远程资源比例。

## 10. 值得复用的实现模式

1. **入口协调器统一生命周期**：集中处理恢复、账户切换、全局弹层和前后台事件。
2. **按业务组织 Features**：页面、局部组件与业务上下文相邻。
3. **明确数据来源**：公开内容、账户私信、本地个人操作与演示内容分离。
4. **状态驱动页面**：加载、空、失败、缓存可用、未接入分别表达。
5. **异步结果防串号**：账户作用域、取消任务和 generation 检查共同保证隔离。
6. **交易先落盘后更新 UI**：验证、去重、归属确认、持久化、结束交易按顺序完成。
7. **媒体资源受控解析**：使用已知资源键，统一占位和封面缓存。
8. **统一安全过滤**：拉黑与隐藏规则覆盖首页、搜索、房间、人物和消息入口。
9. **不伪造服务端成功**：未接入的发送、发布、认证明确返回不可用状态。
10. **文档与发布资源分开**：开发记录和生成提示不随包发布。

## 11. 不宜直接复制的部分与改进方向

### 11.1 产品与服务限制

- 邮箱入口只做格式校验：应替换为真实认证或明确的本地模式。
- 固定详情接口：只适合现有发布合同，新项目按真实合同设计可参数化路由。
- 预设关注、观众、聊天和连麦：不作为正式产品真实活动，建议隔离到开发演示模式。
- 本地评论、举报和反馈：对用户说明作用范围，联网后增加提交状态、重试和回执。
- 本地金币与扣费：不能作为跨设备付费业务的最终账本；购买与消费均需建立一致性策略。
- 权限相关 UI 偏好：本地开关不能替代服务器端访问控制。

### 11.2 代码组织限制

当前 `YourShoreView.swift` 约 2,600 行、`WarmThreadsView.swift` 约 1,360 行、`NanaContentStore.swift` 约 1,110 行，包含多项职责。它们适合作为实现参考，不适合作为新项目继续扩张的单文件模板。

新项目建议：

- 钱包、签到、个人编辑、关系、相册和设置分别建文件或功能目录。
- 将公开读取、关系、私信、安全、个人文件从单一 ContentStore 中按需求拆开。
- 对账户、消息、钱包和媒体等有真实替换需求的服务定义协议，通过构造器注入。
- 初期避免创建没有使用场景的大量空协议与通用层；按功能落地后再抽取。
- 使用清晰业务名称，避免将 `WaterlineWelcomeView`、`YourShoreView` 等隐喻名称迁移到新工程。
- 同步维护功能状态表，避免 README 与源码行为发生漂移。

当前检查到的工程配置没有测试目标。本次未验证构建和运行行为；后续应在用户授权后安排有意义的验证，不能用本文替代验收。

## 12. 新项目推荐目录与职责

下面是可按新业务裁剪的建议结构。只有新 App 确实需要直播、消息或购买时才引入对应模块。

```text
NewApp/
├── App/
│   ├── AppEntry.swift
│   ├── AppCoordinator.swift
│   └── MainTabView.swift
├── Features/
│   ├── Authentication/
│   ├── Discovery/
│   ├── Rooms/
│   ├── Messaging/
│   ├── Profile/
│   ├── Wallet/
│   └── Settings/
├── Domain/
│   └── Models/
├── Data/
│   ├── Networking/
│   ├── Repositories/
│   └── Persistence/
├── Platform/
│   ├── AppleSignIn/
│   ├── Purchases/
│   ├── Media/
│   └── Notifications/
├── DesignSystem/
│   ├── Theme/
│   └── Components/
├── Resources/
└── Support/
docs/
scripts/
project.yml
```

建议数据流：`View → 功能 Store / ViewModel → Repository → 网络或本地存储`。系统媒体和购买由 Platform 服务提供。导航协调器只协调身份、路由和生命周期，不承担全部业务。

不必为了套用命名而重写原生能力，也不必保留 Nana 的四个 Tab；导航由新产品核心任务决定。

## 13. 新 App 创建与实施顺序

### 阶段 1：确定范围

明确产品定位、目标用户、主任务、页面设计、最低 iOS 版本和 MVP 范围。列出功能的实际数据来源：真实服务、设备本地或开发演示。确定是否需要登录、消息、音视频、付费及用户内容管理。

已有信息足够时直接推进工程与基础页面；缺失真实接口或业务规则时先记录缺口，不编造接口、凭据和成功结果。

### 阶段 2：建立独立工程

创建新的目录、Target、Scheme、Bundle ID 和资源命名空间。建立原生 SwiftUI 入口、主题、主导航和状态展示组件。只迁移已确认适用的实现，不批量复制整个 Nana 工程后单纯改名。

### 阶段 3：完成一个纵向功能闭环

先实现一个“列表 → 详情 → 核心操作 → 状态保存或服务回执”的完整流程。覆盖加载、空数据、失败、重试和返回。确认数据层与页面连接后，再扩展其他页面。

### 阶段 4：账户与账户隔离

若需要账户，接入真实认证和恢复机制；明确退出、切换、删除、缓存与私有数据处理。若后端未就绪，保留清晰的未接入界面或经产品确认的本地模式，不将校验通过视为认证成功。

### 阶段 5：媒体与在线业务

按需加入图片、视频、上传、私信、RTC 或房间管理。实现取消、前后台、权限拒绝、重复操作和弱网状态。发布成功、消息送达和连接建立必须来自真实服务结果。

### 阶段 6：购买与消费

如果需要付费，先确定商品、权益、账户归属和服务端账本规则，再实现 StoreKit。明确购买待确认、重复交易、退款、账户删除与切换等状态；消费不能仅靠本地余额判断。

### 阶段 7：验证与发布准备

维护功能状态表与未接入清单。依据新会话明确授权进行编译、模拟器、真机、自动化测试和购买验证；未执行的检查如实记录。完成独立签名、权限说明、商品配置、协议与发布资源检查后再进入发布流程。

## 14. 新项目替换清单与验收参考

### 14.1 必须独立配置的内容

| 项目 | 处理要求 |
| --- | --- |
| 名称与身份 | App 名称、Target、Scheme、Bundle ID、显示名称、版本与构建号 |
| 签名与能力 | Team、证书、Provisioning Profile、Apple 登录等能力 |
| 服务 | API Origin、路由、版本字段、响应合同、认证及错误规则 |
| 安全存储 | Keychain service/account、缓存目录、账户作用域与迁移策略 |
| 商业配置 | 商品 ID、档位、赠送规则、权益、账本和收据处理 |
| 内容资源 | 图标、启动图、页面图、图片、视频、音频及可使用范围 |
| 协议与联系方式 | 新业务对应的用户协议、隐私说明、支持与反馈渠道 |
| CI/CD | App Store Connect 应用、集成、签名、构建变量、通知收件人 |
| 演示内容 | 移除 Nana 用户身份、固定房间、统计及欢迎活动，或明确隔离为开发数据 |

不得把 Nana 的域名、商品 ID、App Store 应用 ID、签名标识、通知邮箱或原有业务内容当作新项目默认值。不得复制凭据到源码、文档、日志或 UserDefaults。

### 14.2 建议在获准后验证的行为

- 启动、无账户、资料未完成、正常恢复、退出、账户切换与删除。
- 认证失败、取消、过期、Apple 凭据撤销与安全存储失败。
- 首次空数据、接口失败、有缓存失败、重试、快速切换账户及迟到响应。
- 搜索和筛选结果、屏蔽后所有相关入口的一致性。
- 媒体权限拒绝、导入取消、后台暂停、临时文件清理和播放资源释放。
- 私信与通话数据来源正确；未连接服务时不显示伪造成功。
- 购买取消、待确认、验证失败、重复交易、跨账户归属、保存失败与退款策略。
- 键盘出现时按钮可触达，小屏、大字体、VoiceOver 和减少动态效果。
- App 资源中没有开发文档、提示词、临时文件和不需要的素材。

以上是后续验收参考，不是本次已执行的测试清单，也不构成自动构建或运行授权。

## 15. 源码阅读索引

按项目根目录定位以下文件；不需要一次复制所有实现。

| 关注点 | 相对路径 |
| --- | --- |
| 项目工作约定 | `AGENTS.md` |
| 工程定义 | `project.yml` |
| 应用入口 | `NanaHarbor/NanaApp.swift` |
| 入口与生命周期 | `NanaHarbor/Features/AccountAccess/NanaEntryCoordinator.swift` |
| 主 Tab | `NanaHarbor/Features/Root/NanaHarborShellView.swift` |
| 账户状态与 Keychain | `NanaHarbor/Features/AccountAccess/NanaSessionStore.swift` |
| Apple 授权 | `NanaHarbor/Features/AccountAccess/AppleSignInService.swift` |
| 输入校验 | `NanaHarbor/Features/AccountAccess/AccountEntryDraft.swift` |
| 首页与播放入口 | `NanaHarbor/Features/Home/WaterlineWelcomeView.swift` |
| 搜索与筛选 | `NanaHarbor/Features/Home/NanaDiscoveryViews.swift` |
| 独立视频播放 | `NanaHarbor/Features/Home/NanaVideoDetailView.swift` |
| 房间主界面 | `NanaHarbor/Features/Home/NanaLiveRoomView.swift` |
| 开播草稿 | `NanaHarbor/Features/Home/NanaLiveCreationView.swift` |
| 房间列表与创建 | `NanaHarbor/Features/Gather/HarborGatheringView.swift` |
| 语音房麦位 | `NanaHarbor/Features/Gather/NanaVoiceRoomDetailView.swift` |
| 本地连麦展示 | `NanaHarbor/Features/Home/NanaVoiceConnectionView.swift` |
| 本地房间氛围 | `NanaHarbor/Features/Home/NanaRoomReplayActivityView.swift` |
| 背景音乐 | `NanaHarbor/Features/Home/NanaRoomMusicView.swift` |
| 评论与举报界面 | `NanaHarbor/Features/Home/NanaPostDiscussionViews.swift` |
| 消息、好友与相册 | `NanaHarbor/Features/Inbox/WarmThreadsView.swift` |
| 通话界面与本地相机 | `NanaHarbor/Features/Inbox/NanaVideoCallView.swift`、`NanaLocalCallCamera.swift`（同目录） |
| 个人中心、钱包和设置 | `NanaHarbor/Features/Profile/YourShoreView.swift` |
| 业务模型 | `NanaHarbor/Shared/Models/NanaLiveModels.swift` |
| 内容状态与本地覆盖层 | `NanaHarbor/Shared/Content/NanaContentStore.swift` |
| 公开读取服务 | `NanaHarbor/Shared/Networking/NanaAServiceClient.swift` |
| 未接入认证的边界 | `NanaHarbor/Shared/Networking/NanaAuthenticationBoundary.swift` |
| StoreKit 与金币账本 | `NanaHarbor/Shared/Commerce/NanaCoinStore.swift` |
| 素材解析 | `NanaHarbor/Shared/Components/NanaAssetLibrary.swift` |
| 通用界面组件 | `NanaHarbor/Shared/Components/NanaLiveComponents.swift` |
| 媒体选择与权限 | `NanaHarbor/Shared/Components/NanaMediaSourcePicker.swift` |
| 主题与基础样式 | `NanaHarbor/Shared/Theme/NanaPalette.swift` |
| 发布流程与商品文档 | `docs/codemagic-build.md`、`docs/coin-pack-catalog.md`、`docs/release-readiness.md` |

## 16. 可直接复制到下一个会话的提示词

```text
请以 Nana 作为原生 iOS 实现参考，在独立目录创建一个新的 iOS App。

先阅读参考文档：
/Users/apple/Desktop/Nana-master/docs/ios-app-reference-guide.md

参考项目源码：
/Users/apple/Desktop/Nana-master

新 App 的名称、用途、目标目录和设计素材以我在本会话提供的信息为准。
如果缺少决定工程位置或核心功能所必需的信息，请集中提出少量明确问题；
可以继续完成不依赖答案的需求梳理和架构规划。

实现要求：
1. 使用原生 SwiftUI，按新业务组织页面、状态、模型与服务。
2. 参考 Nana 的入口协调、按账户隔离、状态驱动界面、媒体封装和交易处理思路。
3. 区分 Nana 已实现能力、仅本地生效的行为、演示内容和未接入服务。
4. 不把邮箱格式校验作为认证成功；不伪造消息送达、开播、通话、举报提交或支付成功。
5. 不修改 Nana 原项目。仅迁移新 App 需要的实现，并使用清晰业务命名。
6. 不沿用 Nana 的域名、商品 ID、签名标识、App Store ID、CI 通知邮箱和品牌内容。
7. 按我提供的设计和素材建立新主题，保留原始素材，检查图中已有文字和 Logo。
8. 先列出 MVP 页面、数据来源、接口缺口和实施顺序，然后推进已明确授权的实现。
9. 所有重要页面考虑加载、空、失败、重试、未接入、权限拒绝与键盘状态。
10. 未经我明确要求，不编译、运行、启动模拟器或执行测试；允许源码和资源静态检查。
11. 交付时说明已实现、仅本地、待接入和未验证内容，不把代码完成等同于上线可用。

如果参考路径不可访问，请明确说明，并使用我提供的这份文档继续规划，
不要假设已经读取参考源码，也不要自行创建另一个聊天。
```

将本文单独交给新会话即可传递产品与架构上下文；需要复用具体代码时，再提供原项目访问权限或所需源码。创建新工程、运行验证和发布是独立动作，应按新会话的实际要求推进。
