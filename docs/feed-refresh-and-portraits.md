# Feed refresh and photographed avatars

Updated: 2026-10-20

## Discovery and viewing history

Live discovery and Shorts support native pull-to-refresh with a refresh indicator. Refresh only changes local ordering; it does not request a server feed. Unknown/unwatched videos rank first, with newer media collections ahead of older ones and randomized ties. Watched clips rank oldest-first, keeping recently watched clips at the end. Refresh avoids the previous lead clip when another equally eligible unseen clip exists. Clips are not duplicated within a feed.

A clip counts as watched after roughly two seconds of active playback. Paused, loading, failed, backgrounded and obscured playback does not count. The history is shared between Live and Shorts, persisted atomically in Application Support/Teto/video-viewing-history.json and capped at 2,000 entries. The renamed storage folder is migrated from an existing version-1 library within the same sandbox; different bundle identifiers use separate app containers. A storage failure keeps in-session ranking usable. No account, backend, analytics or tracking service is involved.

A newly opened Shorts discovery view re-ranks from the current history. Opening a search result or returning from a panel preserves the selected clip. Refresh goes to the first newly ranked clip. Saved/creator collections retain their explicit order and do not offer recommendation refresh. Blocking and Shorts duration limits still apply. All-watched libraries eventually reuse the least recently watched clips.

Main implementation: AppStore.swift, VideoRecommendations.swift, VideoViewingHistory.swift, DanceFeedRefresh.swift, VideoLibraryView.swift, ShortsFeedView.swift, ShortVideoPage.swift and LiveRoomView.swift.

## Wallet and call screens

WalletView explains in English that diamonds fund Live gifts, while ordinary chats and floating comments are free. No charging logic was added to chats or comments, and no payment service was connected.

ChatCallView no longer shows explanatory disconnected/local-preview captions or control-only accessibility hints. It retains names, controls and actionable camera permission/error messages. Video uses the local camera only; voice, microphone and speaker controls remain frontend state. No network call, connected state, successful call or elapsed-call timer was added.

## Portraits

Eight photographed assets replace generated default portraits in chats, parties, Live avatar components, calls and the default personal avatar. Existing creator avatars derived from dance video frames and user-selected avatars are preserved. Legacy avatar identifiers map to Portrait1–Portrait8 so persisted conversations remain compatible. Full image bytes are preserved and SwiftUI handles circular cropping; the old 1.65x zoom was removed.

Original downloads and attribution: Design/SourcePortraits/manifest.json and Portrait1.jpg–Portrait8.jpg. Runtime replacements: Teto/Resources/Assets.xcassets/Portrait1.imageset through Portrait8.imageset. These source files are not AI-generated or AI-edited by this project. They come from Pexels photographers rather than scraped social-platform profiles; platform search did not establish reusable-image permission. Do not describe the subjects as actual Teto members, endorsers or holders of any particular nationality. App names/conversations remain fictional frontend data.

## Verification boundary

Source review, resource JSON/image integrity and project references only. No compilation, app launch, simulator or tests were performed, as requested. Pull gesture with paging, playback transitions, history across device restarts, Dynamic Type and camera behavior still require device validation.
