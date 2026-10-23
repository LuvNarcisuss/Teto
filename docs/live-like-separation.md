# 直播点赞与 Liked 分离（2026-10-23）

直播入口改为 addLiveLike，使用独立的可选 liveLikes 本地计数字段；不会修改短视频 liked 集合。直播计数读取 liveLikeCount，短视频仍使用 toggleLike。个人中心 likedVideos 另外排除目录中 surface 为 live 的条目，其数量由同一个列表计算。

旧记录在读取时，将目录中明确归属 Live 的 liked 首次点赞和 bonusLikes 连续点赞迁移到 liveLikes，并原子写回。迁移后的直播记录不再出现在 Liked。未知或导入的历史 ID 没有原始入口信息，因此保留，避免猜测并误删真实短视频点赞。新字段缺失时兼容旧文件，不清空其他互动数据。

修改文件：AppStore.swift、VideoFeedController.swift、ShortsInteractionStore.swift、ShortsInteractionRepository.swift。修改前备份位于 Design/MigrationBackups/Teto-before-live-like-separation-20261023.zip。

已检查点赞调用链、快照读写与工程 plist；未编译、运行或执行测试。实际连续点赞、重启后迁移及 Liked 数量仍待运行验证。
