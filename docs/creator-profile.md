# Creator profiles

> Current UIKit profile actions (2026-10-23): Message appears only for mutual follows. Before mutual following, Follow/Following fills the former Message space and Block retains its width. Mutual layout remains Following / Message / Block at quarter / half / quarter proportions. This supersedes the older unconditional Message behavior below. Existing saved chats/drafts remain accessible. See [media audit](media-uniqueness-2026-10-23.md).

## Entry and visual structure

Live's streamer avatar/name and Shorts' avatar/name/description open the same full-screen CreatorProfileView. The previous compact ShortsCreatorSheet is removed. Opening a profile pauses the underlying playback and comment flow; leaving it restores the originating player lifecycle. No nested playback continues behind a profile.

The supplied original is retained at `Design/References/Creators/profile-original.jpg`, outside the runtime target. The profile follows its cover-and-avatar header, white rounded information surface, Likes/Following/Followers row, biography, compact IP tag, wide pink Follow button, adjacent Message button and three-column video grid. At accessibility sizes the hero stacks and the grid becomes two columns. Native status and home areas are preserved, with 44-point actions and English accessibility labels. No screenshot graphics, unrelated shopping sections or Chinese text enter the app.

## Data

CreatorProfile has explicit optional statistics and IP region fields for future services. No source currently supplies these values; counts render as a dash and the region as `IP: Unavailable`. They are not inferred from video footage, simulated chats, device IP, or the user's follow action. No geolocation/IP lookup runs.

Bundled-film identities use their existing Pexels creator credit, with a stable ID prefixed `pexels:`. Titles and works come only from the shared dance catalog, grouped by creator. Each current bundled author has one actual film; tiles are not duplicated to fill the grid. The film cover is reused for the header/avatar when no dedicated portrait exists, and the original-film credit is retained. The generic biography describes the dance-film collection, not a verified personal history. No verified badge or remote account handle is invented.

Imported dance videos share the stable `local-owner` identity even when the user renames their profile; their biography/name come from LocalProfile. Only dance-classified videos enter the profile's works. Unknown non-catalog Live configurations retain a source-provided name/avatar and an empty works state. LiveRoomConfiguration.sourceVideoID explicitly maps known rooms to the matching author; it does not rely on parsing display names or room IDs.

## Interactions and persistence

- Follow is shared across Live, Shorts and the profile via AppStore. It saves in optional LocalLibrary.creatorState using the existing atomic repository. The optional field preserves decoding of old libraries. It does not increment an unsupported remote follower count or claim a remote relationship.
- Message opens a full-screen CreatorConversationView with the author avatar/name in the header, a chat-style scroll area, a private draft bubble and a bottom keyboard-aware composer. The former Form sheet is removed. Existing per-author drafts are loaded unchanged. Saving updates the draft bubble without closing the chat; the bubble is explicitly labeled Draft · Only you. It supports up to 2,000 English characters, error feedback and discard confirmation. Back returns to the author profile. Direct messaging is not connected; no outgoing delivered message, read receipt or automatic response is generated.
- Opening an author conversation now atomically registers it in Chats, keyed by the same stable creator ID used for drafts. Entries keep their avatar/name, latest local activity time and draft summary across launches. Chats search, pinning, Drafts filtering and the plus-button contact picker include these entries. Opening one reuses CreatorConversationView with a Back to chats action. Clearing a draft keeps the conversation. Existing drafts from versions without conversation records are surfaced automatically; known author metadata and media URLs are resolved from the current catalog, avoiding stale bundled-file paths. Registration/storage errors remain visible, and no unread messages are invented.
- Works use the existing ShortsFeedView/ShortVideoPage/ShortsPlayback in a full-screen cover with the selected ID, 1× autoplay and looping. Closing stops playback and returns to the profile. Tapping the author on a work returns to the already open profile, avoiding an indefinitely nested profile/player stack.
- Missing statistics, IP, imagery and works have explicit fallback states. Underlying videos pause during the profile, and the profile's own playback uses the existing sheet/background/exit lifecycle management.

## Source and replacement points

- `Features/Creators/CreatorProfile.swift`: identity, optional service fields and Codable local state. Supply real counts/region and a licensed avatar through this model when services exist.
- `Features/Creators/CreatorProfileView.swift`: page, statistics, grid, shared full-screen creator conversation and Preview.
- `Features/LiveRoom/LiveRoomChrome.swift`, `LiveRoomView.swift`, `LiveRoomModels.swift`: accessible author action, full-screen route and source-video mapping.
- `Features/Shorts/ShortsFeedView.swift`, `ShortVideoPage.swift`: full-screen profile route, shared follow state and return labels.
- `ShortsPanels.swift`, `ShortsInteractionStore.swift`: remove the old small creator sheet and separate session-follow storage.
- `Domain/LocalLibrary.swift`, `App/AppStore.swift`: backward-compatible local follows and message drafts.
- `Teto.xcodeproj/project.pbxproj`: register new Swift files through XcodeGen.

## Verification

Source/reference inspection, English string checks, project metadata regeneration and plist lint only. No build, typecheck, app launch, simulator, SwiftUI Preview execution or tests were run. Layout, keyboard/discard flows, persistent-state migration and nested playback dismissal remain to be checked on a device. Real author account services, statistics, IP region, public works feeds and direct-message delivery are not connected.
