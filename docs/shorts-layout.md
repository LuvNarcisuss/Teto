# Dance Shorts layout

## Screen and entry points

The supplied screenshot is preserved unchanged at `Design/References/Shorts/layout-original.jpg`, outside the runtime target. Only its spatial hierarchy is followed; no screenshot text, system bars or non-dance footage is embedded.

- The native top toolbar retains Live / Shorts. The left video icon now opens the existing Photos video picker on both sections. The former right plus button is removed. Both Live and Shorts have an icon-only search button at the top right, with plain button styling and the shared toolbar background hidden on iOS 26+. The 44-point hit target is retained without a visible border or capsule.
- Search filters the available dance clips by title, creator and description. Selecting a Shorts result moves to that clip; selecting a Live result opens its dance room after the search sheet dismisses. The duplicate in-content search button is removed from the Live homepage, while personal-library search is retained. No online search endpoint is used.
- Full-screen media continues behind transparent native bars, with safe-area controls and a soft bottom gradient.
- Lower left: floating-comment entry, creator name, then the video description. Descriptions use English dance copy and hashtags.
- Lower right: avatar, like, comments, favorite, share, then an ellipsis More button. More uses the same report/block actions as Live, with playback controls retained. Controls have English labels, minimum 44-point targets and VoiceOver names; the rail scrolls in landscape and accessibility text sizes.
- Tap the video to pause/resume; a central play symbol appears only while paused. The bottom position slider remains available. Default playback is 1× and looping. A long-press menu and VoiceOver actions retain mute/unmute and next/previous controls without adding extra permanent icons.

## Saved-video playback

Saved collections (including a library's Saved filter) open the selected video in a full-screen cover using the same ShortsFeedView, ShortVideoPage and ShortsPlayback components. An explicit collection ID bypasses the public discovery feed's three-minute limit. Only the tapped video is in this playback session. It starts automatically, loops at 1×, and retains the existing pause, seek, comments, creator, favorite and share controls. No navigation bar or tab bar overlays this cover; the back button and content respect system safe areas, while the video fills the screen.

Back stops the player before dismissing the cover, returning to the existing collection and its filter state. Removing a favorite updates its button and the underlying list without interrupting the current video. A missing collection item has an unavailable state with the back button still accessible. Playback pauses while inactive or covered by a panel and releases player observations on exit. Runtime behavior has not been verified.

## Floating comments

`ScrollingCommentsView.swift` owns a separate engine and draws text with Canvas inside a 30 fps TimelineView. Every line moves right-to-left at 96 points per second, independent of text length. Five portrait lanes (two landscape lanes) occupy the upper video region below the toolbar. A lane cannot be reused until the previous line's trailing edge plus a 40-point gap has cleared its entry position.

The shared `DanceCommentScript` first grew from 24 to 96 English dance phrases. On 2026-10-22 it became 152 lines, adding one-word reactions, two- and three-word notes, and longer practice comments among the existing medium lines. The 96-line count describes only the earlier expansion. Shorts cycles the shared list and attempts a random 1–5 insertions per second, evenly spaced within each second. Occupied lanes apply backpressure rather than allow overlapping text. The existing Live comment feed also uses the expanded phrase list, keeping its random 1–5 per-second behavior.

The floating-comment composer accepts up to 80 characters. A submitted line is recorded in the session comment list and queued ahead of automatic phrases, then shown with a pale green tint when playback resumes. The queue is capped at 10 entries and ordinary comments at 200 per video. Ordinary comments allow up to 200 characters. The Floating comments switch stops automatic moving text. Changing clips, pausing, opening a sheet/picker, leaving the tab or backgrounding the app cancels active movement; playback resumes with fresh lanes. Reduce Motion and VoiceOver suppress moving text, while submitted comments remain readable in the comments sheet.

Only the overlay redraws at animation cadence. It does not create AVPlayer instances, alter playback speed or restart the source.

## Interaction boundaries

Like and comment state belong to the current Shorts session. Creator follows and favorites use AppStore's atomic disk persistence. The avatar, name and description open a full-screen CreatorProfileView shared with Live; see `creator-profile.md`. Share opens the native share sheet with the clip title/description; it does not claim an online video URL or completed delivery. Upload entry still imports a dance clip locally and reports that nothing was uploaded. There is no backend, verified account, network comment subscription, public publishing or fabricated engagement count.

The automatic comment phrases are authored content, not messages received from real accounts. All built-in text is English and has no staging labels. User content and system-owned pickers retain their normal behavior.

## Changed files

- `Features/Live/DiscoveryView.swift`: left video-picker entry, icon-only right search for both sections, and Live search result routing.
- `Features/Live/DanceSearchView.swift`: shared local search sheet.
- `Features/Live/VideoLibraryView.swift`: remove duplicate homepage search control.
- `Features/Shorts/ShortsFeedView.swift`: page routing, search selection, sheets and lifecycle coordination.
- `Features/Shorts/ShortVideoPage.swift`: screenshot-inspired layout, caption, action rail and playback controls.
- `Features/Shorts/ShortsInteractionStore.swift`: session interactions, comments, floating-comment events and descriptions.
- `Features/Shorts/ScrollingCommentsView.swift`: constant-speed, collision-aware text layer.
- `Features/Shorts/ShortsPanels.swift`: comment composer/list and creator sheet.
- `Features/LiveRoom/LiveRoomModels.swift`: 72 added English phrases (96 total at that time; the script is 152 lines as of 2026-10-22).
- Regenerated `Teto.xcodeproj/project.pbxproj` to include the new files; current implementation documentation updated.

## Verification

Source/resource checks and Xcode project metadata generation only. No compilation, typecheck, simulator, app launch, SwiftUI preview or tests were run, in accordance with the user's instruction. Actual rendering, gesture interaction, keyboard, animation smoothness, playback lifecycle and small-screen/large-font layout still need device verification.
