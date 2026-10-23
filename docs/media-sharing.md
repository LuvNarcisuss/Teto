# Live / Shorts 分享（2026-10-23）

Live、Shorts、Voice 共用 TetoScreen.showContentShare 底部面板：横向好友头像、Share link。
好友沿用 Voice 的已关注单人会话筛选；保存调用 sendChatMessage，遵守拉黑、未互关只能发送一条、英文校验和原子持久化规则。消息进入 Chats 本地待发送队列，不代表远程送达。

Share link 将 teto://live/{UUID} 或 teto://shorts/{UUID} 复制到剪贴板，语音房继续用 teto://party/{id}。这些是内部地址，不是公开网页，也没有新增系统级 URL Scheme / Universal Link 接入。本机聊天中的 Live / Shorts 地址提供打开按钮；不存在、已举报、已拉黑、待审核或场景不匹配的内容不可打开。个人导入素材不会随链接上传。

Shorts 分享次数在复制地址或好友消息成功保存后持久化；取消、失败不增加。Live 不写入 Shorts 分享计数。分享面板打开时 Shorts 暂停，关闭后恢复；直播维持播放。离开视频页面清理分享面板。

修改文件：TetoUIKit.swift、PartyControllers.swift、VideoFeedController.swift、ChatControllers.swift。
验证限于源码与语法解析；未编译、运行、启动模拟器或执行测试。真实设备布局、播放恢复和跨页面交互尚未运行验证。
