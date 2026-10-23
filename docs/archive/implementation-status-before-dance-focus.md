# teto implementation status

> Historical record only. Follow `../../AGENTS.md` for current requirements. Earlier staging labels and non-dance media must not be restored; seven non-dance original downloads were deleted on 2026-10-19.

## Delivery scope

Native SwiftUI iOS frontend in `/Users/apple/Desktop/Teto`, independent of the Nana source at `/Users/apple/Desktop/Nana-master`. English app UI, Chinese assistant replies. iOS 17+ / iPhone baseline, four tabs: Live, Voice, Chats, Me. No backend is configured.

## Implemented in source

| Area | Files | Behavior |
| --- | --- | --- |
| Entry/navigation | `Teto/App/TetoApp.swift`, `AppRootView.swift`, `MainTabView.swift` | Guarded library load, local exploration entry, four native tabs, independent navigation stacks |
| Sign-in | `Features/Authentication/SignInView.swift` | Valid email format and any nonempty password enter the frontend demo; keyboard focus, inline validation, separate local-mode button; no credentials persisted |
| Live library | `Features/Live/VideoLibraryView.swift` | System video picker, empty/search/saved states, actual cover cards, detail navigation |
| Discovery/Shorts | `Features/Live/DiscoveryView.swift`, `Features/Shorts/ShortsFeedView.swift`, `Platform/Media/ShortsPlayback.swift` | Live / Shorts top switch; vertical paging of local clips up to 180 seconds; one player; pause, mute, progress, save, details, loading/error/retry and empty states |
| Video detail | `Features/Live/VideoDetailView.swift` | Full-screen aspect-fill AVPlayer background behind transparent navigation/tab bars; automatic 1× looping playback with floating play/pause and mute controls, no progress bar; controls/information hidden by default and revealed by tapping the video; favorite/unfavorite, rename, confirmed removal of app-owned copy |
| Immersive live room | `Features/LiveRoom/*.swift`, `Features/Live/VideoLibraryView.swift` | Three configurable reference scenes presented full screen; native safe-area HUD, independent local/HTTPS/cover player, comment/history input, product card, local interactions and native sheets/share. Explicit sample activity; session-only state. See `live-room.md` for assets, source inventory and unverified acceptance checks. |
| Voice | `Features/Voice/VoiceRoomsView.swift`, `VoiceRoomDetailView.swift` | Three topic layout templates, empty preview seats, create/edit/delete local drafts |
| Chats | `Features/Chats/ChatsView.swift` | Honest empty inbox and editable single local draft; no sending or fake received content |
| Profile | `Features/Profile/ProfileView.swift`, `ProfileEditorView.swift` | Local name, bio, symbol avatar, actual local counts, saved videos/room-draft navigation, sign-in sheet |
| Style | `DesignSystem/TetoStyle.swift`, `EditorialComponents.swift` | Ivory/ink/emerald/lime theme, dark Shorts surface, rounded typography, editorial images, filter chips, reusable cards, compact notices and buttons |
| Models/state | `Domain/LocalLibrary.swift`, `App/AppStore.swift` | Versioned snapshot, stable UUIDs, serialized UI mutations, explicit save errors |
| Storage | `Data/LocalLibraryRepository.swift` | Actor-isolated file work, atomic protected writes, corrupt-data protection, orphan-copy cleanup |
| Media | `Platform/Media/ImportedVideo.swift`, `LocalVideoPlayback.swift` | Bounded video copy, metadata validation, thumbnail generation, cancellation cleanup, playback lifecycle/error state |
| Configuration | `project.yml`, `Teto/Support/Info.plist`, `Teto.xcodeproj` | Independent target/scheme; English language; no Nana domain, SKU, entitlement, team or CI identity |
| Design | `Design/References/*`, `Resources/Assets.xcassets/CoastalStory.imageset`, `ListeningRoom.imageset`, `docs/ui-refresh.md` | Updated English five-screen concept, two original decorative assets, preserved earlier concepts and prompts, official product references |

Paths in the feature rows are relative to `Teto/` unless their `Teto/` prefix is included. All new Swift sources are registered through XcodeGen.

## First vertical flow

1. Choose **Sign in** with any valid-format email and any nonempty password to enter Demo mode, or choose **Explore locally**. Neither path authenticates a real account.
2. Open **Live → Import a video** and select a real video from Photos.
3. A temporary copy is validated (at most 250 MB and 30 minutes, with a video track), copied into Application Support and given a JPEG cover.
4. The library snapshot is saved atomically before the item is published to the UI.
5. Open the card to play the local copy in a full-screen AVPlayer background with transparent SwiftUI controls; playback starts automatically at 1× and loops, without a progress bar.
6. Select **Save to favorites**. Saved state changes only after the snapshot write succeeds.
7. Find the same item under **Saved** or **Me → Saved videos**. The next launch loads the same snapshot.

This flow is implemented, not runtime-verified. The user's imported library and conversations start empty; Live and Shorts now include nine explicitly labeled Pexels demo clips at the user's request. There are no fictional viewers, fabricated incoming messages or simulated network successes.

## Storage and failures

- `Application Support/Teto/library-v1.json`: profile, video metadata/favorites, voice-room drafts, message draft; schema version 1.
- Optional `savedDemoVideoIDs` persists favorites for bundled stock clips. Missing values decode as nil in existing version-1 snapshots. Bundled clips remain outside the imported-video array, so loading does not seed, overwrite or duplicate user media. Profile Videos counts and recent imports exclude demo clips; Saved includes actual favorites from either source.
- `Application Support/Teto/Media/<UUID>.<extension>` and `<UUID>.jpg`: app-owned movie copies and generated covers.
- JSON, video and cover files use protection until first user authentication. No credentials, password hashes or authentication tokens are stored here.
- Corrupt or unsupported snapshots show an error and prevent writes instead of silently resetting data.
- An import failure or cancellation removes its temporary copy and any uncommitted media. Successful library writes precede UI success.
- Removal commits metadata first, then attempts file cleanup. A later successful library load retries orphan media cleanup within the app-owned Media folder.
- Abrupt process termination may leave OS-temporary import files until normal iOS temporary-file cleanup. This does not modify Photos originals.
- Failed form saves retain editor input; edited forms prevent interactive dismissal and offer explicit cancellation/discard.
- Playback pauses when the view disappears or app becomes inactive, and releases its item/observers when leaving the view. Video details autoplay when ready in the foreground and loop at 1×, without a progress bar. Pausing or leaving prevents pending readiness/loop callbacks from restarting playback. Shorts autoplays and loops only the selected foreground clip, muted by default; manual pause survives background/foreground transitions. Tab switches, save/import busy state and app notices pause the feed. No background audio feature is added.

## Service boundary

Only local functions and native system media APIs are connected. At the user's explicit request, the sign-in form now enters a labeled frontend Demo mode after email-format validation and a nonempty password; any password content is accepted. This does not verify a password or mailbox, issue a token or authenticate an online account. The demo email is held in memory for profile display and resets when the process restarts. Passwords are cleared on entry/exit and never persisted or transmitted. Changing demo email keeps the same device-local library; there are no distinct accounts. Real email authentication/registration, Apple sign-in, public feed, uploads, live streaming, voice RTC, messaging, calls, notifications, moderation, remote account deletion and commerce remain unimplemented. No service endpoint is invented. A room draft never opens a room. A message draft never becomes a delivered message. There is no teto cloud/account synchronization.

The Photos picker grants selected-item access. No camera, microphone or broad Photos permission is requested. Future camera/RTC work requires its own permission-denied, cancellation and recovery handling.

## Design assets

`Design/References/teto-ui-refresh-en.png` is the current concept reference, created with the built-in image generation tool. It is concept art, not a screenshot of compiled software. The older English and Chinese boards remain preserved. Two separate original decorative images, CoastalStory and ListeningRoom, are now bundled at their original generated resolution. They are not playable clips or live-room imagery. All current app strings are English. Prompts, boards and documents remain outside the app source/resource root. See `ui-refresh.md` for the complete changed-file inventory and concept limitations.

## Verification actually performed

### Bundled demonstration media — 2026-10-19

The user requested downloadable social-style footage for Live/Shorts. This delivery uses Pexels author-provided public downloads rather than claiming downloads from Douyin or YouTube. [Pexels License](https://www.pexels.com/license/) permits free use and modification, including app use; no endorsement by depicted people is implied. Footage is presented as stock demos, not teto users or real broadcasts.

| Asset | Source / author | Bundled format |
| --- | --- | --- |
| Find your rhythm | [Woman Recording Herself Dancing](https://www.pexels.com/video/woman-recording-herself-dancing-7677198/) — Ivan S | 14.16 s, 720 × 1280, H.264 MP4 |
| A little coffee break | [A Person Taking a Cup of Coffee](https://www.pexels.com/video/a-person-taking-a-cup-of-coffee-5269588/) — 宇航 钱, shown in English as Yuhang Qian | 7.16 s, 720 × 1280, H.264 MP4 |
| Moving with the sea | [Woman Dancing By the Sea](https://www.pexels.com/video/woman-dancing-by-the-sea-8713941/) — Kampus Production | 19.96 s, 1280 × 720, H.264 MP4 |

The collection was expanded from three to nine clips with six portrait videos. All playback still defaults to 1×; resizing and frame-rate conversion do not accelerate the footage.

| Added asset | Source / author | Bundled duration |
| --- | --- | --- |
| City afterglow | [Original video](https://www.pexels.com/video/vertical-video-view-of-buildings-over-looking-the-city-5828438/) — Charles Parker | 11.01 s |
| Made with a little love | [Original video](https://www.pexels.com/video/a-person-cooking-on-electric-stove-6822626/) — cottonbro studio | 15.08 s |
| Stay for the sunset | [Original video](https://www.pexels.com/video/a-vertical-video-of-a-beach-sunset-5849514/) — Maysaa Mousa | 14.37 s |
| A few quiet chords | [Original video](https://www.pexels.com/video/close-up-view-of-person-playing-guitar-7722398/) — Alena Darmel | 10.40 s |
| A quiet little companion | [Original video](https://www.pexels.com/video/video-of-a-black-cat-13590000/) — Marsel Sharipov | 20.20 s |
| Take the scenic way | [Original video](https://www.pexels.com/video/vertical-video-of-a-woman-along-the-seashore-6004275/) — Peggy Anke | 13.41 s |

This expansion updates `DemoVideoCatalog.swift`, adds six original videos, six bundled MP4s and six covers, extends `Design/SourceMedia/manifest.json`, and regenerates project resource references. The existing navigation, UI layout, 1× playback defaults and favorite IDs were preserved.

All bundled versions are silent. Original public download files are preserved in `Design/SourceMedia/` (outside the app target). `manifest.json` records source and download URLs, author, license link, retrieval date, original/bundled SHA-256, encoding changes and measured metadata. Bundled MP4s total 19,586,038 bytes, excluding JPEG covers. Details show attribution plus source/license links. Demo clips can be favorited but not renamed or deleted from the read-only app bundle.

Changed files: new `Teto/Domain/DemoVideoCatalog.swift`; updated `Domain/LocalLibrary.swift`, `App/AppStore.swift`, `Features/Live/VideoLibraryView.swift`, `Features/Live/VideoDetailView.swift`, `Features/Shorts/ShortsFeedView.swift`, `Features/Profile/ProfileView.swift`; new media resources; regenerated Xcode project; updated README/design/status documentation. The previously reverted navigation change was not reapplied.

Media was resized with ffmpeg and inspected with ffprobe; extracted covers were visually inspected. This is resource processing/inspection, not an app build or runtime test. Device decoding, navigation, persistence and UI behavior remain unverified.

- Read Nana reference documentation and selected entry/state/network/draft source files without modifying them.
- Inspected the new Swift source for state ownership, save order, import cleanup, empty/error paths and unavailable-service boundaries.
- Checked relevant SDK declarations directly for FileRepresentation importing, asynchronous thumbnail generation and the Application Support URL API. No compiler was invoked.
- Generated the Xcode project and shared scheme using XcodeGen.
- Checked plist/project metadata format and source/resource references statically.
- Inspected the generated English design image; preserved both original outputs and saved the final prompt.

**Not performed:** compilation, type checking, running the app, simulator launch, automated tests, device tests, API calls, account login, RTC or purchases. Source inspection is not evidence that compilation or runtime acceptance passes.

## Remaining external integration and validation

- Developer-owned Bundle ID (current value is `com.example.teto`), signing team and release metadata. An opaque 1024 × 1024 app icon is now provided in `AppIcon.appiconset` and explicitly configured in `project.yml`.
- Real backend contracts for whichever online capabilities are required next; no repeated product clarification is needed for routine local implementation.
- Once explicitly authorized: verify small/large screens, large text and VoiceOver; Photos cancellation/iCloud failures/unsupported videos; player/background lifecycle; save failures and cold-launch restoration; draft discard and local deletion; English on a non-English device. System-owned picker UI may still use the device language.
- No App Store readiness or successful build claim is made.
