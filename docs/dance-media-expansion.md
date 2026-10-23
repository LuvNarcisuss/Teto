# 舞蹈素材扩充 · 2026-10-20

新增 10 段实际舞蹈视频，内置总数由 2 增至 12。Live 列表、搜索、直播间和 Shorts 共用 DanceVideoCatalog，因此无需新增入口。保留原有两段 ID、收藏数据及用户导入内容。

| 标题 | 作者 | 时长 | 来源 |
| --- | --- | --- | --- |
| Hip hop in motion | cottonbro studio | 40.72s | [Pexels 7958175](https://www.pexels.com/video/a-young-man-dancing-to-hip-hop-music-7958175/) |
| Crew rhythm | ANTONI SHKRABA production | 11.44s | [Pexels 8688877](https://www.pexels.com/video/people-dancing-hip-hop-8688877/) |
| Own the eight-count | Polina Tankilevitch | 3.92s | [Pexels 3873100](https://www.pexels.com/video/a-young-woman-dancing-hip-hop-3873100/) |
| Move together | cottonbro studio | 10.24s | [Pexels 10264814](https://www.pexels.com/video/two-women-dancing-hip-hop-10264814/) |
| Partnered lines | MART PRODUCTION | 23.68s | [Pexels 8462487](https://www.pexels.com/video/man-and-woman-dancing-ballet-8462487/) |
| Studio joy | Kampus Production | 22.48s | [Pexels 8956471](https://www.pexels.com/video/a-woman-dancing-in-a-studio-8956471/) |
| Practice partners | MART PRODUCTION | 15.04s | [Pexels 7480483](https://www.pexels.com/video/man-and-woman-dancing-together-7480483/) |
| After-dark groove | Tima Miroshnichenko | 10.64s | [Pexels 5805069](https://www.pexels.com/video/vertical-video-of-a-woman-dancing-5805069/) |
| Contemporary flow | Antoni Shkraba | 28.84s | [Pexels 7571002](https://www.pexels.com/video/woman-dancing-in-a-studio-7571002/) |
| Contemporary floorwork | MART PRODUCTION | 19.60s | [Pexels 7322867](https://www.pexels.com/video/ballerinas-dancing-on-a-dance-studio-7322867/) |

运行时新增视频合计约 27.6 MiB（另有封面）。使用 H.264/yuv420p、最长边 1280px、原始帧率和时长、1×速度；沿用无音轨策略，不加入未授权音乐。原始下载文件位于 Design/SourceMedia，压缩文件和封面位于 Teto/Resources/DanceMedia。

来源页面均标明 Pexels License，许可页面：https://www.pexels.com/license/ 。作者作为影片来源署名，不表示作者或画面人物使用/代言本 App。原始下载 URL、文件 SHA-256、编码参数、时长与审阅时间点已写入 manifest.json。

每段检查了 5%、25%、50%、75%、95% 时间点；联系图位于 Design/SourceMedia/Review-2026-10-20。确认被选画面为舞蹈动作，未发现非英文字幕或水印。一段候选因背景出现非英文疏散标识被排除，项目未保存该候选视频。代表帧检查不等于逐帧审核。

资源检查包括编码格式、时长/帧数、文件哈希、封面、目录唯一 ID 和 Xcode 资源引用。未编译、运行 App、启动模拟器或执行测试/SwiftUI Preview。真实直播与网络服务接入状态不变。

## 第二批扩充与推荐顺序 · 2026-10-20

本次再新增 12 段，内置总数达到 24 段。应用每次启动分别为 Live / Shorts 生成随机顺序：本批 12 段在前，上批 10 段随后，最早 2 段最后；批次内部随机。默认情况下首条内置素材不同。排序存在 AppStore 生命周期内，收藏、点赞和切换页面不会重新洗牌；用户新导入的舞蹈仍保持原有置顶行为。收藏和作者作品显式播放列表不受 Shorts 推荐排序影响。

原有 ID、收藏键和本地媒体数据目录不变。修改涉及 DanceVideoCatalog、AppStore、ShortsFeedView、ShortsInteractionStore、资源目录、来源登记和 Xcode 工程引用。

| 标题 | 作者 | 时长 | 来源 |
| --- | --- | --- | --- |
| Urban footwork | Yaroslav Shuraev | 50.04s | [Pexels 8027525](https://www.pexels.com/video/woman-doing-breakdance-8027525/) |
| Street power | Allan Mas | 6.20s | [Pexels 5362370](https://www.pexels.com/video/young-guy-doing-break-dance-on-the-street-5362370/) |
| Under the bridge | Kampus Production | 24.00s | [Pexels 8715155](https://www.pexels.com/video/a-woman-doing-break-dance-on-the-street-8715155/) |
| Court session | Marc Espejo | 35.38s | [Pexels 6548168](https://www.pexels.com/video/a-man-dancing-6548168/) |
| Studio chemistry | Shuttercraftsman | 17.76s | [Pexels 31889677](https://www.pexels.com/video/dynamic-dance-routine-in-modern-studio-setting-31889677/) |
| Together on the beat | Kampus Production | 23.24s | [Pexels 8956295](https://www.pexels.com/video/women-dancing-in-the-studio-8956295/) |
| Follow the feeling | Pavel Danilyuk | 52.22s | [Pexels 6939884](https://www.pexels.com/video/a-woman-dancing-in-the-dance-studio-6939884/) |
| A shared rhythm | KoolShooters | 12.80s | [Pexels 7689096](https://www.pexels.com/video/couple-dancing-together-7689096/) |
| Salsa in the sunshine | RDNE Stock project | 10.72s | [Pexels 8249922](https://www.pexels.com/video/woman-wearing-floral-dress-dancing-with-a-man-8249922/) |
| Glitter and groove | Mikhail Nilov | 23.72s | [Pexels 6834067](https://www.pexels.com/video/a-woman-dancing-in-the-studio-6834067/) |
| Ballet practice | Budgeron Bach | 9.32s | [Pexels 5138501](https://www.pexels.com/video/a-ballet-class-going-on-in-a-dance-studio-5138501/) |
| Street crew energy | Tima Miroshnichenko | 9.64s | [Pexels 5561275](https://www.pexels.com/video/people-dancing-outdoors-5561275/) |

本批运行时视频约 44.6 MiB。保留原始帧率、帧数和 1× 时间轴；H.264/yuv420p，最长边1280px，无音轨，不添加音乐。代表帧检查覆盖每段5%、25%、50%、75%、95%时间点，审阅联系图在 Review-2026-10-20-B；排除了一段动作不够明确的摄影棚候选。许可、作者、原文件映射、SHA256记录在manifest。未编译、运行App、启动模拟器或执行测试。

最终静态核对：24 个唯一 ID、24 个视频及封面与 Xcode 引用一致；新增 12 段源文件/运行时 SHA256 一致，帧率、帧数及时长保持；31889677 原文件缺少 nb_frames 元数据，实际解码读取为 444 帧，与运行时相符。project.pbxproj 和 Info.plist 的 plutil 检查通过。

## 直播与短视频分开，并补头像和语音房封面 · 2026-10-21

此前 Live 与 Shorts 共用同一份目录，只是各自洗牌。现在每段内置影片只进入一个入口：竖屏片段在 Shorts，横屏片段在 Live。用户在本机导入并标成舞蹈的视频只出现在 Shorts。收藏、作者作品和观看记录仍可按原 ID 找到对应影片，不会把同一段放进两个发现流。

本批新增 15 段，内置总数 39。Shorts 17 段，Live 22 段。新片 `collectionGeneration` 为 3，仍按较新的批次靠前。编码保持 H.264/yuv420p、最长边 1280px、原始帧率和帧数、1× 速度、无音轨。代表帧为每段 5%、25%、50%、75%、95%。审阅联系图在 `Design/SourceMedia/Review-2026-10-21`。未收入的候选和原因写在同目录 `rejected.json`。许可仍是 Pexels License。作者、下载地址、原文件和运行时文件的 SHA-256 写在 `manifest.json`。

| 入口 | 标题 | 作者 | 来源 |
| --- | --- | --- | --- |
| Shorts | Rooftop freestyle | cottonbro studio | [Pexels 2795746](https://www.pexels.com/video/hip-hop-dancing-2795746/) |
| Shorts | Crosswalk session | cottonbro studio | [Pexels 4734692](https://www.pexels.com/video/a-man-and-woman-are-standing-on-a-street-4734692/) |
| Shorts | Bucket hat groove | Yaroslav Shuraev | [Pexels 8027892](https://www.pexels.com/video/woman-doing-hiphop-dance-8027892/) |
| Shorts | Night crew | ANTONI SHKRABA production | [Pexels 8688884](https://www.pexels.com/video/stylish-woman-dancing-8688884/) |
| Shorts | Street tango | Sol Pinto | [Pexels 13521639](https://www.pexels.com/video/dancing-tango-on-city-street-13521639/) |
| Live | Loft session | cottonbro studio | [Pexels 10264579](https://www.pexels.com/video/woman-dancing-in-hip-hop-style-10264579/) |
| Live | Loft partners | cottonbro studio | [Pexels 10264810](https://www.pexels.com/video/two-women-dancing-hip-hop-style-10264810/) |
| Live | Salsa floor | E CG | [Pexels 19851286](https://www.pexels.com/video/salsa-colorful-shoes-19851286/) |
| Live | Three and a count | Polina Tankilevitch | [Pexels 3873074](https://www.pexels.com/video/young-women-dancing-3873074/) |
| Live | Lifted arms | Pavel Danilyuk | [Pexels 6939802](https://www.pexels.com/video/dancers-practicing-in-the-studio-6939802/) |
| Live | Warm room | KoolShooters | [Pexels 7324086](https://www.pexels.com/video/women-dancing-in-a-studio-7324086/) |
| Live | Cypher night | Ekaterina Antipova | [Pexels 7405378](https://www.pexels.com/video/woman-hip-hop-dance-7405378/) |
| Live | Hoodie phrase | Antoni Shkraba | [Pexels 7569650](https://www.pexels.com/video/people-dancing-in-the-studio-7569650/) |
| Live | Mural phrase | ArtHouse Studio | [Pexels 7667010](https://www.pexels.com/video/female-performers-dancing-in-studio-7667010/) |
| Live | Mosaic steps | RDNE Stock project | [Pexels 8249626](https://www.pexels.com/video/a-man-and-a-woman-dancing-beside-mosaic-artwork-8249626/) |

人物头像改为一人一张。聊天、语音房、评论和影片作者如果是同一个人，用同一张照片；不同的人不再轮流共用原来的 8 张。本机账号使用单独的 `PortraitLocal`。语音房 8 张卡片各用一张舞蹈照片，不再使用咖啡、公园或鞋子。用户自己保存的房间从另外 4 张舞蹈照片里取封面，不占用那 8 张卡片。来源在 `Design/SourcePortraits/manifest.json` 和 `Design/SourceCovers/manifest.json`。页面上没有读到作者名的照片，作者字段保持为空，不补写人名。

未编译、未运行 App、未启动模拟器、未执行测试。
