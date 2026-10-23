# Teto 会话交接：Phrases 舞句

日期：2026-10-23。给下一个会话用。界面文案是英文。这份文档是开发说明，不是应用资源。

## 1. 产品约束

- Teto 是舞蹈社交 iOS 应用。底部导航现在是 Live、Phrases、Voice、Chats、Me。Shorts 仍在 Live 里。
- UIKit + Swift 5。不用 SwiftUI。
- 应用内可见文字用英文。不要 demo、showcase、sample、mock、preview 这类展示用词。
- 钻石是唯一虚拟货币。未接通的发送、支付、另一台手机的同步，不能显示成已经成功。
- 新视频必须是真人跳舞，并登记作者、来源和许可。不能编造授权。
- 未经用户明确要求，不把编译说成上机验证。用户自己在模拟器里看过若干中间版本。

## 2. 新功能设计

Phrases 是和 Live、Voice、Chats 同级的一格，不是它们的子页面。一件事在这一格里做完：看单人教学或完整跟练视频，用动作拍选择八拍循环和慢速练习，让视频跟随练习节奏。

设计过程里否掉过这些方向：挂在短视频下的回应、把群聊和语音房捆成小组、约练习、语音房地板上换一支舞。用户要求它必须是独立导航项。

一支舞句有标题、舞种、作者和动作页。内置教程按整段视频的实际动作与讲解时间标注，每页最多八条，不强行把六步或华尔兹解释成八拍音乐。作者新建／分支支持 1–256 页，每页 1–8 行英文短句，并必须添加视频及真实起止时间；旧的纯文字舞句仍可编辑，保留 Slow、Steady、Quick 独立练习速度。内置教程可选 0.5x、0.75x、1x，源动作间隔随练习速度同比缩放。Learned 和 Keep 只记在这台手机上。

打开后有两条，样式和直播里的 Live / Shorts 选择栏相同：

- **Film**：中间整块等比铺满单人教学／跟练视频，超出边缘会裁切。下方有动作页切换、当前拍提示，以及 Loop 8 counts、Whole lesson、速度按钮；尾页不足八条时按钮显示实际数量。再下方是 Branch、More、Share。
- **Counts**：中间显示本页动作，编号从 1 到 8（尾页可更少），保留源视频时间。与 Film 共用由练习时钟掌握的位置、速度和循环选择。下方同样提供循环本页、整片学习和速度控制；单页循环只取实际动作，跳过讲解空档，整片学习保留讲解。切换 Film / Counts 不改变练习模式。新建的视频舞句与内置卡片使用相同练习功能；旧纯文字舞句保留独立击拍和 Slow、Steady、Quick。

作者行在选择栏上面。左边是头像、昵称、舞种。右边两个短按钮上下排列：Learned 在上，Keep 在下，宽度约 108，好把昵称留出来。按钮带图标。

动作页标记：当前这一组是长条，其它组是圆点。最多显示九个标记，随当前页移动；可用左右箭头遍历完整教程。标记整组居中，间距为 4 pt；圆点直径为 10 pt，长条为 28 × 10 pt。

主页是两列卡片，样子靠近语音房，不要直播标识。封面用这支舞自己的片子。第一行是舞种，第二行是作者头像和昵称。七张封面互不重复，七张头像也互不重复，并且不和直播、短视频、语音房共用。

## 3. 当前功能介绍

### 主页

`PhraseListController`。两列 `PhraseFigureCard`。封面来自 `DancePhraseCatalog.filmAsset` 对应的 `phrase-film-*.jpg`。点卡片进详情，点头像进舞者主页。长按可以编辑、删除、举报或拉黑。右下角加号写新句子。

### 详情

`PhraseDetailController`。默认停在 Film，进入页面后播放该舞句的视频；没有对应视频时显示缺少视频的英文提示。

- 内置 Film 默认从头以 1x 播放整片一次；作者可设置自己卡片的默认速度和整片／首段循环；用户可切换单页反复练习和 0.5x／0.75x 慢速。视频仍使用 `resizeAspectFill`，原文件没有重编码或改速。保留原音轨；慢速请求使用音高保持算法，听感仍待上机检查。没有视频时显示 `No dance video for this phrase.`
- `PhraseLessonClock` 是时间源：选定动作区间、速度与循环后，它向视频提供源时间和系统时钟锚点，并驱动 Counts 高亮。AVPlayer 的周期回调不再驱动内置动作拍。定位和预加载完成才启动练习时钟；失败／卡顿暂停双方并显示可重试的英文提示。
- 换页时，正在播放则开始新页循环，暂停时则定位到新页首个动作。切速保留当前动作位置；暂停后点击同一练习模式继续，整片播完再点从头开始。切换 Film / Counts 保留状态。离开详情或进入后台暂停，回来不自动恢复内置练习。
- 自己的句子第二排左边是 Edit，别人的是 Branch。More 里是删除，或举报和拉黑；视频舞句还提供 Film credits，内置片子列出真实作者、原始标题、来源、许可与修改说明，自建片子显示作者填写的署名和使用许可。Share 写入本机聊天，聊天里有 Open phrase。
- 舞者主页有 Phrases 列表。

### 七支内置舞句

应用里的名字是虚构的，片子上的人不是会员。以下总数是动作提示数，不是把每个视频强行划成等时音乐拍。

| 舞句 | 舞种 | 动作 / 页数 | 作者 | 片子 | 大约时长 |
| --- | --- | --- | --- | --- | --- |
| Two-step flow | Hip-hop | 132 / 17 | Sable Quinn | phrase-film-hiphop | 5 分 37 秒 |
| Reach and turn | Contemporary | 37 / 5 | Rowan Hale | phrase-film-reach | 27 秒 |
| Balboa basics | Swing | 267 / 34 | Indigo Marsh | phrase-film-rehearsal | 3 分 23 秒 |
| Farmer footwork | House | 212 / 27 | Cassian Brooks | phrase-film-groove | 2 分 25 秒 |
| Six-step circle | Hip-hop | 87 / 11 | Maren Sol | phrase-film-street | 1 分 7 秒 |
| Waltz walkthrough | Ballet | 223 / 28 | Nia Adeyemi | phrase-film-ballet | 12 分 35 秒 |
| Solo Charleston | Jazz | 187 / 24 | Jules Hart | phrase-film-jazz | 6 分 51 秒 |

动作拍已改成按视频时间定位的动作／停留提示，讲解另列区间，不再使用原来的固定 64 条独立笔记。标注依据整片代表帧、快速段更密集帧和可用的英文数拍口令。时间为人工编辑估计，不是动作捕捉或逐帧精确谱；iOS 上仍待用户授权后校准。

### 数据

- 资料库版本仍是 1。`LocalLibrary.phraseBook` 可选，旧资料还能打开。
- 自写句子、Kept、Learned 存在本机。内置句子在 `DancePhraseCatalog`。旧 learned 数组保留，新的教程页用 `<phraseID>.timed-counts-v1` 保存标记，避免把旧八组已学标记错误套到新分页。旧纯文字分支保留自己的文字和速度，不自动迁移。新分支保存独立的 lesson 快照（媒体引用、封面、逐拍时间、讲解、署名及练习设置），不依赖父卡片继续存在。
- 标注原本：`Design/SourceMedia/PhraseSources/SoloLessons/counts-timelines.json`。同目录 `generate-counts-catalog.py` 生成现有 Swift catalog 的时间线字面量；这些开发文件不打包，无需新增 Xcode 资源引用。
- 新片子的画面分类是 `DanceSurface.phrase`，不会进 Live 或 Shorts 推荐。
- 来源登记：`Design/SourceMedia/PhraseSources/manifest.json`。当前视频为逐条核对的 CC BY 3.0／4.0；头像与旧参考素材仍为 Pexels License。`runtimeFilms` 是当前运行时清单，总登记 `Design/SourceMedia/manifest.json` 也包含七条 phrase 记录。

## 4. 项目进度

早期 Phrases 曾通过 generic iOS 编译，这是历史结果。2026-10-23 的默认 Film、圆点调整、单人教学素材替换、整段视频时间线和署名入口仅做源码／资源静态检查；本轮未编译、运行 App、启动模拟器或执行测试。

已完成：

- 第五个底部 Tab，以及 Phrases 图标。
- 列表、详情、编写、分支、删除、收藏、学会、分享、举报、拉黑。
- Film 播放独立视频，Counts 显示动作拍。每次八拍循环前完整显示 5、6、7、8 并播放节拍音，期间视频暂停；预备拍随慢速同比放慢。
- 八拍标记按当前组变成长条。
- 七支内置教程均由练习时钟控制视频和动作提示；页数按内容变化，最后一页不补虚构动作。自写／改写上限扩展到 256 页。
- 七支新视频和七张独立封面已放进 `Teto/Resources/DanceMedia/phrase-film-*`。

还没做，或还不能当成已经确认：

- 默认 Film、九个以内的移动页码标记、动作行滚动与长教程分页均未做本轮 iOS 运行验证。
- 人工动作时间标注并非逐帧测量。讲解与动作边界、快速重复动作节奏仍需在实际播放中校准。
- 等比铺满的裁切、音频／循环、精确定位、后台暂停、Film/Counts 保留位置及 Film credits 导航尚未上机确认。
- 不得把静态校验或旧版本的编译结果说成本轮已构建、测试或可以上线。
- 作者头像仍为原先七张 Phrases 专用肖像，没有和直播、语音房共用。

## 5. 遇到的问题

- 列表卡片高度一度是 0，页面像空白，点不到。原因是自定义卡片没有可用高度，内层又挡住了点击。后来改成语音房式封面卡片。
- 卡片曾经带直播的 Living 标识。用户要求改成语音房卡片：不要直播标识，第一行舞种，第二行头像和昵称。
- Film / Counts 一点就崩：`-[__SwiftValue step]: unrecognized selector`。`PhraseFigureView` 的 `CADisplayLink` 曾把 `step` 发给错误对象。详情页已不再使用模拟小人。`CADisplayLink` 的目标已改到 `clock`。
- 选择栏文案曾显示成 Figure。现为 Film 和 Counts。
- 八拍标记因为横向栈把多出来的宽度给了最后一项，看起来永远是前三个圆点、最后一个长条。现按当前八拍切换长条和圆点。
- 舞句曾先限四个、再限八个八拍。两者均已失效：2026-10-23 按整段教学时间线扩展，编辑器和校验允许 1–256 页。
- 用户要求从 YouTube、TikTok 找教学片。当时未确认具体视频的再分发许可，因此没有打包；不能把平台名称当作一概允许或禁止再分发的判断依据。当时选择了 Pexels 库存舞蹈。此记录已被 2026-10-23 单人教学重选取代：现在逐条核对明确 CC BY 的来源，并提供 App 内署名。

## 6. 接下来先看哪里

以下是用户明确允许上机验证后再执行的检查，不代表已经执行。

1. 模拟器打开 Phrases，确认七张封面不同、没有直播标识、点卡片能进详情。
2. 进入详情，确认默认选中 Film 并播放真人舞蹈视频，下方可直接选择八拍循环、整片学习和速度；切换 Film / Counts 不崩溃。
3. 点 Counts，确认当前动作按练习时钟高亮、讲解不空数拍、换页定位正确、最后一页只显示实际动作；标记随页移动，第一排三个按钮各占三分之一。
4. 检查 Loop 8 counts 的动作区间循环（跳过讲解）、Whole lesson 的完整教学、0.5x／0.75x／1x 切速、视频末尾重新开始、快速翻页、后台暂停和 Film/Counts 保留状态。重点检查定位／预加载中取消，以及短尾页的循环边界。
5. 用旧资料库确认收藏、旧私人分支和 learned 数据保留；检查新视频卡片／分支的本地保存、封面、完整时间线、默认速度、初始循环设置及不足八行的中间页。
6. 检查每轮 5–8 四个完整预备拍、期间视频冻结、8 后启动动作、慢速缩放，以及准备期间暂停／换页／后台取消。
7. 从 Photos 选择视频、拖动定位、逐拍标记、换页编辑、替换视频重标、封面抽帧、取消、保存失败、重启和共享视频引用删除均需上机确认。

## 7. 关键文件

- `Teto/Features/Phrases/PhraseListController.swift`
- `Teto/Features/Phrases/PhraseDetailController.swift`
- `Teto/Features/Phrases/PhraseFigure.swift`
- `Teto/Features/Phrases/PhraseEditorController.swift`
- `Teto/Features/Phrases/PhrasePulse.swift`
- `Teto/Domain/DancePhrase.swift`
- `Teto/Domain/DancePhraseCatalog.swift`
- `Teto/Domain/DanceVideoCatalog.swift`
- `Teto/Domain/PhraseBook.swift`
- `Teto/App/AppStore+Phrases.swift`
- `Teto/App/TetoApplication.swift`
- `Teto/Resources/DanceMedia/phrase-film-*`
- `Design/SourceMedia/PhraseSources/manifest.json`
- `docs/superpowers/specs/2026-10-22-phrases-design.md`
- `docs/superpowers/plans/2026-10-22-phrases.md`

设计文档和实现方案写于功能早期。界面以后又改过。下一个会话以这份交接和当前源码为准，不要把早期方案里的「语音房地板」或「四个八拍上限」当成现状。

## 8. 单人教学／跟练素材重选（2026-10-23，历史过程）

- 用户明确：继续 App 内播放；只有一位舞者跳舞，完整跟练即可，有英文讲解更好；保留不同舞种，不换成同一老师的 Hip-hop 系列。
- 七段运行时视频与对应封面已替换，来自七个不同教学／编舞来源。原始文件和署名证据在 `Design/SourceMedia/PhraseSources/SoloLessons/`，该目录不打包进 App。运行时保持原有 `phrase-film-*` 文件名、七个舞句 ID 和视频 UUID，收藏和分支数据未重置。
- Two-step：VincaniTV 的五项 Breaking 技巧，保留完整主要讲解，去掉片头赞助和片尾；英文讲解有来源字幕。
- Contemporary：Frontiers 2018 舞句学习研究的完整第一段，编舞 Jenny Coogan、舞者 Robin Jung；CC BY 4.0。原视频静音，未把研究的独立英文口述强行配上画面。
- Swing：Lainey Silver 的 Balboa Uphold 基础，完整英文数拍与三个速度的单人练习，原作者明确未配音乐。对应卡片按实际内容标为 Swing。
- House：Streetz Ahead 的 Farmer 分解、变化与最后连续练习，保留英文动作标题，去掉片头片尾。画面为一位老师，含为看清脚步而拍摄的近景。
- Six-step：Neil Sweeney 的六步分解，来源是 Wikimedia Commons 的无音轨版本；保留英文步骤标题与完整六步练习，去掉开头／结尾画中画。
- Ballet：Vina Castelli 的 Waltz of the Flowers 慢速走位教学。画面只有一位跳舞老师；镜子会映出老师及偶尔静止的摄影者，不能描述成画面完全没有第二个人。保留原手持镜头和完整教程。
- Jazz：GoldMinka 的 Solo Charleston 四步分解和完整组合，英文讲解有来源字幕；去掉频道片头与片尾。
- Film 最初使用完整画幅留边；用户随后明确要求铺满，当前已改为 `resizeAspectFill`，等比裁切边缘。More → Film credits 提供真实作者、来源链接、CC 许可、裁切／转码说明；Film 本身仍播放本地文件，不跳外链。独立许可媒体的使用权在服务条款中保留。
- 当时 Counts 为八组独立练习笔记；这条历史状态已失效，当前整段时间线与练习主时钟见第 2–4 节。旧私人分支保留原数据。
- 已做代表帧、可见英文文字、封面唯一性、来源许可、原始／运行时映射、时长与帧率、H.264 完整解码及源码资源引用检查。帧率检查区分标称帧率与因原片时间戳导致的微小平均值差异。未逐帧人工查看，也未把文件解码表述成 iOS 播放验证。
- Frontiers 第二段仍是未使用备选；旧 Pexels 参考素材只在来源目录作为历史记录，当前 Film 以 `runtimeFilms` 为准。
- 本轮未编译、运行 App、启动模拟器或执行测试。上机待确认内容见第 4 节。

## 9. Counts 主导练习的最新修正（2026-10-23）

- 用户明确：视频应跟随节奏拍，考虑初学者重复一个八拍或慢速学习。当前源码已把视频时钟驱动改为练习时钟驱动，提供单页循环与 0.5x／0.75x／1x。
- 七支教程的完整动作／讲解标注与 Learned 页键未变。循环一页只播放该页动作，Whole lesson 保留整片讲解；不把非等时动作标注伪称为统一音乐拍。
- `PhraseLessonClock` 与 AVPlayer 使用同一 host-clock 锚点；等待定位／预加载时不空走拍。前台恢复不自动开播，旧请求完成回调不能恢复已经取消的播放。
- 方案：`docs/superpowers/specs/2026-10-23-counts-led-practice-design.md`。仅完成源码／资源静态检查；手工时间标注精度、慢速音画同步、循环衔接与界面布局仍待用户授权后上机确认。

## 10. 完整作者创建与每轮预备拍（2026-10-23）

- 新建／分支页可以选择一段单人英文舞蹈视频（最多 30 分钟／250 MB），播放和拖动检查，使用当前帧设置封面。每条动作可填写英文文字、视频开始／结束秒数，也可暂停后使用 Mark start / Mark end。每条动作前的讲解间隔和结尾都有可编辑的英文提示。
- 作者设置默认 0.5x／0.75x／1x、整片或首段循环，以及 40–180 BPM 的预备拍速度；预备拍随播放速率缩放。完整视频播放与每轮循环首次开始都有 5–8，内部跨讲解间隔定位不重复插入。Film 中央显示大数字，Counts 顶部显示准备状态；音频无法启动会有英文提示，不声称有声成功。
- 新卡片沿用同一个详情、封面卡片、作者资料、Keep、Learned、本地分享及分支路径。作者名／头像来自个人资料，不新增虚构作者字段。视频署名由作者填写，内置素材分支保留不可删改的来源署名。
- `DancePhrase.lesson` 是可选兼容字段；新视频与封面先写入 App 自有 Media 目录，资料库原子保存成功后再清理无人引用的旧文件。不同分支可共享文件引用，删除父卡片不删除仍被引用的媒体。Photos 原片不删除，未保存临时文件单独清理。
- 新导入仅供本机舞句使用，不自动加入 Live／Shorts 或伪装为服务器发布。英文／单人舞蹈／使用许可由作者确认，文本字段静态校验；没有自动视频内容识别或人工审核通过的承诺。
- 实现方案与静态检查记录见 `docs/superpowers/plans/2026-10-23-phrase-authoring.md` 及同名前缀 progress 文档。未编译、类型检查、测试、运行 App 或启动模拟器。
