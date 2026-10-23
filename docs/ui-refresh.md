> 素材数量更新（2026-10-20）：现有 24 段内置舞蹈视频；下文历史记录中的“两段/两部”仅描述当时状态。当前清单及验证范围见 [dance-media-expansion.md](dance-media-expansion.md)。

> Historical UI record. The current dance-only English implementation supersedes the room/content descriptions below; see [current handoff](live-room.md).

> Historical layout record. Current behavior is documented in `live-room.md` and `shorts-layout.md`; `../AGENTS.md` overrides the older content and labeling described below. Only two dance films remain. Non-dance videos and their original downloads have been deleted.

# teto UI refresh — 2026-10-19

## Scope

The first bottom tab now has a **Live / Shorts** title switch. The bottom navigation remains **Live, Voice, Chats, Me**. English remains the app language. The existing demo sign-in accepts any valid-format email and any nonempty password; no backend was added.

The visual refresh replaces large placeholder-led layouts with photographic focal points, stronger heading hierarchy, compact filters, restrained borders and consistent spacing. Ivory and emerald remain the brand colors; Shorts uses a dark media surface. Login, Live, Voice, Chats and Me share the same visual components.

## Public product references

Official sources inspected for design ideas:

- [YouTube: design principles for putting creators center stage](https://blog.youtube/inside-youtube/design-principles-use-put-creators-center-stage/) — content emphasis, condensed metadata and restrained action density informed the media cards and Shorts controls.
- [YouTube Shorts experience updates](https://blog.youtube/news-and-events/youtube-shorts-experience-updates-features/) — playback/mute access and a cleaner viewing surface informed the control layout.
- [Spotify: Home feeds for discovery](https://newsroom.spotify.com/2022-08-09/spotifys-new-home-feeds-make-discovering-your-new-favorites-easy/) — separate content categories informed the top-level Live / Shorts switch and compact topic filters.

These are adaptations of general interaction principles, not copied branding, assets or pixel-identical app screens.

## Shorts behavior

Shorts filters user imports to videos of at most 180 seconds and now includes nine bundled Pexels demo clips. Optional demo favorite IDs extend the existing version-1 snapshot without rewriting imported videos. Import limits stay at 250 MB and 30 minutes; longer imported videos appear in Live, and the success notice explains where to find them.

The feed pages vertically across the full screen, including behind the top title bar, bottom tab bar and system safe areas. An outer geometry reader captures the original safe-area insets; an inner media viewport ignores container safe areas. Those original insets are applied only to the HUD, preserving existing button/text positions. Every page uses the full viewport height so its media and overlays move together when paging. Only the current clip owns a player; it starts muted, loops, and offers pause/play, mute, scrubbing, local favorite persistence and details. Portrait and landscape have separate control arrangements. Loading and playback errors include feedback and retry. Backgrounding, leaving the page or tab, local save/import work and app notices pause playback. Shorts uses aspect-fill rendering, cropping excess edges without distortion. The video layer clips to its bounds and does not intercept touches. Default playback stays at 1×.

Navigation and tab-bar backgrounds are hidden in Shorts, with light foreground controls over the video. A subtle existing video gradient supports readability without an opaque bar surface. The first tab tracks its navigation path so video details also retain transparent bars. The Live list, Voice, Chats and Me root pages retain their normal surfaces. The empty-feed illustration also extends behind the bars while its controls stay in the safe area. Changed files for the Shorts full-screen adjustment: `ShortsFeedView.swift`, `DiscoveryView.swift`, `MainTabView.swift`, `VideoDetailView.swift` and this document. Runtime layout and native bar transparency across iOS versions remain unverified; no app build, run or tests were performed.

## Live video detail full-screen playback

Opening a Live video now places its cover and aspect-fill AVPlayerLayer behind the entire detail page, including the navigation bar, tab bar and system safe areas. The fixed background remains in place while the foreground content scrolls. The former 340-point player area is retained as a transparent playback-control area, preserving the following title, duration, favorite, attribution and imported-video actions in their existing content order and spacing. Buttons use outlined transparent surfaces; light text and a video gradient support readability. Excess video edges are cropped, without stretching.

`LocalVideoPlayback.swift` supplies play/pause, mute and automatic looping. Entering the detail starts playback when ready at 1×; reaching the end seeks to the start and plays again at 1×. The detail has no playback progress bar or scrubbing controls. Playback pauses on backgrounding, leaving the detail, editing, removal confirmation or an app notice; pending autoplay and loop callbacks respect that pause. Returning from the background does not override a pause. Shorts keeps its separate playback controls. The shared `VideoPlaybackSurface` in `ShortsPlayback.swift` renders both detail and Shorts backgrounds. Source changes: `VideoDetailView.swift`, `LocalVideoPlayback.swift`, `ShortsPlayback.swift`, `ShortsFeedView.swift` and `MainTabView.swift`. No backend or live-streaming capability was added. Only source inspection was performed; compilation, device layout, bar transparency and playback interaction remain unverified.

The empty-state fallback offers Photos import over a decorative coastal image. Bundled demo clips now populate discovery even before import. Favorites use the same atomic write-before-publish flow as the existing detail page. Local profile information is shown only on user imports; demo clips show the original Pexels author and stock-footage label. No fake comment, share, follower, like or viewer counts were added. See `implementation-status.md` and `Design/SourceMedia/manifest.json` for provenance and changed files.

## Live playback overlay visibility

Video details start with the playback controls and information hidden once loading completes. A full-viewport transparent button reveals the existing foreground layout without pausing playback. Tapping the empty video-control area hides it again; dedicated controls keep their own actions. The scroll view remains laid out to preserve control positions and scroll offset, but hidden content cannot receive touches or accessibility focus. The video gradient lightens while overlays are hidden. Loading, errors/retry and missing-video feedback remain visible. Navigation and tab controls stay available. The reveal button has an English accessibility label, and the opacity transition respects Reduce Motion. Automatic 1× looping and the absence of a progress bar are unchanged.

Changed file: `Teto/Features/Live/VideoDetailView.swift`. Source inspection only; tap routing, VoiceOver, layout and playback remain unverified on a running device.

## Source and resource inventory

New Swift files:

- `Teto/Features/Live/DiscoveryView.swift`: title switch and shared import entry.
- `Teto/Features/Shorts/ShortsFeedView.swift`: paged feed, empty state, controls and lifecycle wiring.
- `Teto/Platform/Media/ShortsPlayback.swift`: single-player state, looping, mute, seeking and failures.
- `Teto/DesignSystem/EditorialComponents.swift`: decorative image cropping, headers, filters, circular actions and hero cards.

Updated Swift files:

- `Teto/App/MainTabView.swift`: selected tab tracking and Shorts bar appearance.
- `Teto/App/AppStore.swift`: import notice explains Live/Shorts availability.
- `Teto/DesignSystem/TetoStyle.swift`: palette, typography, borders and compact states.
- `Teto/Features/Authentication/SignInView.swift`: photographic entry and focused field styling; demo logic preserved.
- `Teto/Features/Live/VideoLibraryView.swift`: editorial onboarding, search/filter controls and media cards.
- `Teto/Features/Voice/VoiceRoomsView.swift`: photographic room preview and compact draft cards.
- `Teto/Features/Chats/ChatsView.swift`: composed empty state and compact private draft entry.
- `Teto/Features/Profile/ProfileView.swift`: cover, avatar, collections, actual recent videos and grouped settings.

Resources and project:

- `Teto/Resources/Assets.xcassets/CoastalStory.imageset`: original generated coastal still, 1024 × 1536.
- `Teto/Resources/Assets.xcassets/ListeningRoom.imageset`: original generated listening-room still, 1024 × 1536.
- `Design/References/teto-ui-refresh-en.png`: five-screen generated concept; first two screens are pages of the same Live tab.
- `Design/References/ui-refresh-prompts.txt`: exact artwork and concept prompts, including navigation correction.
- `Teto.xcodeproj/project.pbxproj`: regenerated source registration from `project.yml`.
- `README.md`, `docs/product-design.md`, `docs/implementation-status.md`: updated feature and verification records.

Original generated images and older design boards were preserved. Runtime imagery is decorative. The concept board conveys composition and art direction; some generated typography, secondary labels and icon details differ from the actual SwiftUI source. It is not a runtime screenshot.

## Verification boundary

Source, resource JSON and Xcode project metadata were inspected. Project generation does not compile or launch the app. No build, typecheck, simulator, app launch or tests were performed, as requested.

Compilation, real-device layout, large text, VoiceOver, paging behavior, player interruptions and navigation transitions remain unverified. Online accounts, public feeds, actual streaming, RTC, messaging and payments remain disconnected. This work requires no backend to use its local flows.
