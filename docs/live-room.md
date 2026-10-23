> 素材数量更新（2026-10-20）：现有 24 段内置舞蹈视频；下文历史记录中的“两段/两部”仅描述当时状态。当前清单及验证范围见 [dance-media-expansion.md](dance-media-expansion.md)。

# Dance rooms

## Current entry and architecture

Open a video in **Live** to enter a full-screen dance room. **Shorts** uses the same dance catalog. There is no separate commerce/art scene selector. The existing SwiftUI/ObservableObject architecture, iOS 16 deployment target, Swift 5 language mode, Bundle ID and signing settings are unchanged.

The room has an English streamer/follow capsule, people entry, dance style, practice/community sheets, a translucent comment feed and a bottom comment/like/gift/share bar. Native system bars remain native; the app does not draw a fake status bar or Home Indicator. The video layer remains full screen behind safe-area controls. There is no persistent central pause button or progress bar. Playback defaults to 1×, loops, and starts muted.

All built-in app text is English. User-authored profile names, imported titles, drafts and comments remain the user's content; they are not destructively rewritten. System-owned Photos/share/keyboard interfaces can follow the device's language settings.

## Media

`Teto/Domain/DanceVideoCatalog.swift` is the shared source for both feeds:

| Runtime asset | Dance film | Source author | Duration |
| --- | --- | --- | --- |
| `Resources/DanceMedia/dance-studio.mp4` | Find your rhythm | Ivan S / Pexels | 14.16 s |
| `Resources/DanceMedia/dance-seaside.mp4` | Freestyle by the sea | Kampus Production / Pexels | 19.96 s |

Both existing dance films and their covers were retained without re-encoding, including original speed. The seven other bundled films (coffee, city, cooking, sunset, guitar, cat and beach walk) and their covers were removed from the runtime resources and catalog. The seven non-dance original download files were also deleted from the project on 2026-10-19. Only the two dance originals remain in the source directory. Active licensing/hash metadata is in `Design/SourceMedia/manifest.json`; removed entries are in `retired-media.json`.

Login/profile/voice/empty-feed artwork now uses a dance cover instead of the earlier coastal/listening-room imagery. Creator credits and source links remain available in video details/playback options.

To replace media, configure `LiveRoomMedia.source` as `.local(URL)`, `.remote(HTTPS_URL)` or `.coverOnly`. Optional `coverURL` and `coverAsset` supply the fallback. `LiveVideoScaling` selects fill or fit. Current sources are bundled recordings, not realtime streams. No new download or service endpoint was introduced.

## English comment loop

`DanceCommentScript` in `LiveRoomModels.swift` contains 152 authored dance-specific lines and fictional handles. Lengths are mixed: one-word reactions, two- and three-word notes, medium lines, and longer practice comments. The 96-line figure described the script before 2026-10-22. The first five appear on entry, then the rest repeat in order at a new random rate of 1–5 comments for each one-second cycle, evenly spaced within that cycle (actual timing depends on scheduling and UI work). Each insertion receives a new stable UUID. The video source and player instance are independent of comment updates and are not restarted by the loop.

These lines are locally authored atmosphere, not messages fetched from online accounts. No online viewer total, real account identity, comment delivery receipt, purchase or payment confirmation is generated. This provenance is recorded in the implementation rather than repetitive labels over the video.

`LiveRoomStore.setCommentLoopActive` owns one cancellable task. It stops while the room is backgrounded, dismissed, loading or failed, manually paused, covered by a sheet, or accepting keyboard input. VoiceOver/Reduce Motion also suspend automatic comments. Cursor position is retained while paused. **Playback → Chat flow** lets the user disable the loop. Scrolling into history continues to hold the reader's position and exposes a new-message button. History is capped at 200 entries.

Manual comments use the local service boundary and carry no delivered indicator. Follow/like state remains local. Gift selection can be changed, but delivery is unavailable and no charge is reported. The share button opens the native share sheet. Online messaging, live broadcasting, voice RTC, account verification and purchases remain unconnected.

## Import compatibility

`LocalVideo.isDance` is an optional metadata field, so older version-1 snapshots still decode. New imports use the **Add a dance video** entry and are categorized as dance based on the user's selection intent; there is no automatic visual classifier. Live and Shorts only include the curated dance catalog and imports marked as dance. The Live Saved filter uses that same subset.

Older uncategorized imports and their favorites remain accessible in the personal library; no unknown personal video is silently deleted. Their detail page provides **Add to dance feed**. Marking it uses the existing atomic snapshot save flow. The old `savedDemoVideoIDs` JSON key is retained solely for favorite-data compatibility and is never rendered as UI text. Existing IDs for the two retained films are unchanged.

## Changed code

- `Domain/DanceVideoCatalog.swift` replaces `DemoVideoCatalog.swift` and contains only dance clips.
- `Domain/LocalLibrary.swift`, `App/AppStore.swift`: optional dance membership, filtered discovery, preserved collection access and in-memory email naming.
- `Features/LiveRoom/LiveRoomModels.swift`: dance configuration, media model and comment script. The script later grew from 96 lines to 152 on 2026-10-22; the 96-line note describes only that earlier state.
- `LiveRoomStore.swift`: local actions and cancellable comment loop.
- `LiveRoomView.swift`, `LiveRoomChrome.swift`, `LiveRoomSheets.swift`, `LiveVideoView.swift`, `BottomActionBarView.swift`, `CommentFeedView.swift`: English dance UI, playback options and lifecycle wiring.
- Removed `FeaturedProductCardView.swift` and `LiveRoomScenePicker.swift`, plus unused product/campaign/ranking/exhibition routes and models.
- `Features/Live/VideoLibraryView.swift`, `VideoDetailView.swift`, `Features/Shorts/ShortsFeedView.swift`, `Features/Authentication/SignInView.swift`, `Features/Profile/ProfileView.swift`, `Features/Voice/*.swift`: English production-facing copy and dance framing.
- `DesignSystem/EditorialComponents.swift`: dance cover artwork support.
- `Resources/DanceMedia/*`, active/retired media manifests and regenerated `Teto.xcodeproj/project.pbxproj`.

## Verification boundary

Performed: read source, inspected the two retained covers and source metadata, scanned built-in Swift/Info.plist text for Chinese and retired staging labels, inspected source/resource references, regenerated Xcode metadata, and checked the project/Info.plist format. Reference screenshots are preserved outside the app target. No compiler, type checker, app, simulator, preview or test was executed.

Compilation, actual device layout/keyboard behavior, comment timing/scrolling, media playback, accessibility behavior and migration of real saved libraries still require runtime verification. Source review and a valid project file do not establish a successful build.
