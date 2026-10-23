# Teto

A native UIKit iOS app for people who love dance. The app's built-in interface is English; Codex replies remain Chinese.

Read [AGENTS.md](AGENTS.md) before changing this project. It defines the required English UI, prohibited staging copy and dance-only media policy.

## Current experience

- The app name is **Teto**, with the `teto` target/scheme, `com.teto.dance` bundle identifier and Application Support/Teto storage. See the project identity notes below for migration limits.
- Me > Wallet offers nine diamond packs. A purchase uses StoreKit 1 and the store product ID for that pack. Diamonds are added on this device after the transaction is saved. Live gifts still do not send or spend diamonds.

- Each cold launch starts with Welcome, then One-tap sign in. The User Agreement checkbox starts unchecked; consent is saved before opening the main tabs. The same agreement is available in Me > Settings.

- Four main tabs: **Live, Voice, Chats, Me**; Live also has a **Shorts** switch. Voice opens a dance party discovery page using the original four-tab navigation with a transparent background.
- The shared catalog contains 46 dance videos across Live, Shorts and Phrases. Source and license records are in `Design/SourceMedia/manifest.json`.
- Live opens an immersive dance room with translucent controls, English comments, follow/like actions, gift selection and native sharing.
- A 152-line authored English comment sequence cycles at a randomly selected rate of 1–5 comments per second. Lines mix one-word reactions, two- and three-word notes, and longer practice comments. It pauses with room/player lifecycle, editing and accessibility needs, and can be switched off in Playback. The earlier 96-line count described the script before 2026-10-22.
- Full-screen video, default 1× looping playback, native safe areas and keyboard-aware input.
- Dance imports, local favorites, profile editing, room drafts and message drafts use the existing local persistence flow.
- Chat voice/video buttons open full-screen call layouts. Video can show the device camera and switch lenses; it does not connect a call, record, capture audio or transmit media.

## Service boundary

There is no connected backend. One-tap entry opens the local library after explicit agreement acceptance without verifying an online account. No email, phone number or password is requested. Room comments include locally authored atmosphere; they are not received from online accounts. No live viewer count, delivered message, successful gift delivery or transaction is fabricated. Native sharing and local file/media operations use real platform APIs.

## Project and records

- Open `Teto.xcodeproj`; target/scheme: `teto`.
- iOS 16+, Swift 5 language mode, UIKit and AVFoundation.
- Source configuration: `project.yml`. Generate metadata only with `xcodegen generate --spec project.yml --project . --no-env`.
- [Chat call screens and camera lifecycle](docs/chat-call-screens.md)
- [Dance inbox, conversations and local drafts](docs/dance-chats.md)
- [Dance party discovery, assets and integration](docs/party-discovery.md)
- [Shorts layout, floating comments and toolbar changes](docs/shorts-layout.md)
- [Dance room implementation, file changes and media replacement](docs/live-room.md)
- [Welcome, one-tap entry and User Agreement](docs/welcome-and-agreement.md)
- [Wallet, recharge tiers, live gifts and brand rename](docs/wallet-and-gifts.md)
- [Current implementation status](docs/implementation-status.md)
- [Active media provenance](Design/SourceMedia/manifest.json)
- [Archived reference-stage records](docs/archive/)

No Nana source, account, or domain is used. Bundle ID is `com.teto.dance`. Diamond product IDs are the nine store IDs in `WalletCatalog`. The original seven IDs are unchanged. Signing team is `JPTS6M4T5B`.

## Validation

Source/resource inspection and project metadata checks only. Do not compile, run, launch a simulator or execute tests without an explicit user request. Runtime behavior and successful compilation remain unverified.

## Clone with media

Video files use Git LFS. Install Git LFS before cloning, then fetch the media:

```sh
git lfs install
git clone https://github.com/LuvNarcisuss/Teto.git
cd Teto
git lfs pull
```

Open `Teto.xcodeproj` after the media download finishes. This repository contains source code, Xcode metadata, runtime resources, design originals and documentation. It does not contain a signed IPA. Local signing credentials, build output and Xcode user state are excluded from Git.

## Project identity

The project is `Teto.xcodeproj`; its target, shared scheme and executable are `teto`. The app display name is `Teto` and the bundle identifier is `com.teto.dance`. Source types, resource filenames and component APIs use the new brand throughout.

Local data now lives in Application Support/Teto. Before creating a fresh library, the app checks for one previous app-owned version-1 library in its current sandbox and moves that complete directory. Ambiguous or unreadable libraries stop loading instead of being overwritten. Changing the bundle identifier creates a separate iOS app container, so data from an existing installation under another identifier is not automatically transferred.

Rename validation was limited to source, resource references and project metadata. No build, simulator, app launch or tests were performed.

## Persistent video interactions

Shorts, saved-video playback and creator-video playback share one interaction store keyed by video UUID. Likes, full comment threads (including their original IDs and reply targets), and completed-share increments are atomically written to Application Support/Teto/shorts-interactions-v1.json. Existing saved-video state remains in library-v1.json. Both are loaded before entering the app. Missing interaction files initialize an empty state; unreadable files are preserved and stop loading rather than being silently replaced.

A like/comment/reply is reflected as successful only after its write completes. A failed comment write preserves the draft and reply target. Read-only seeded discussions are included in the next interaction write; reopening a saved discussion does not insert those comments again. The personal page has Works, Liked, Saved and About tabs; liked/saved videos use the same playback and discussion data as discovery. Removed or blocked videos are excluded from those lists.

These are device-local records, not server messages or account synchronization. Source and project-reference review only; relaunch, forced termination, failure recovery and cross-entry behavior still require device verification. No app execution, compilation or tests were performed.
