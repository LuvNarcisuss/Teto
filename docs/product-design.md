# teto — Product and visual specification

## Confirmed direction

Native SwiftUI dance-social frontend. Follow `../AGENTS.md` for mandatory product, language and media constraints. Four bottom navigation buttons: Live, Voice, Chats, Me. Include a sign-in entry, dance video playback and personal information. The user authorized an original design based on the reference architecture and requested app reference artwork. No backend is available. All app UI and the current reference board use English; assistant replies use Chinese.

The four requested navigation buttons are implemented as a native bottom TabView. The system status bar remains a system surface. The 2026-10-19 refresh adds a Live / Shorts title-bar switch inside the first tab, without adding a fifth bottom tab.

## Design system

Warm ivory, near-black ink, emerald primary actions and pale lime accents. Native SF rounded headings and icons, editorial photography, generous spacing, hairline borders and rounded 18–30 pt cards/buttons. Keep readable content inside native safe areas; only backgrounds extend behind them. Scrollable forms, keyboard dismissal and native focus preserve access to inputs. The main app uses light appearance; Shorts uses a dark media surface and dark navigation styling.

Current generated concept: `Design/References/teto-ui-refresh-en.png`; prompts: `Design/References/ui-refresh-prompts.txt`. Produced with the built-in image generation tool. The earlier English/Chinese concepts and their prompts remain preserved. See `ui-refresh.md` for internet references and implementation details.

The user's imported library starts empty. Live and Shorts share two dance films from `DanceVideoCatalog.swift`, plus user imports marked as dance. Runtime artwork uses the retained dance covers. Non-dance bundled videos, their covers and their original source videos have been deleted. Source credits remain accessible in video details; removed-media provenance is retained outside the app target.

App copy must follow `AGENTS.md`: English throughout, with no staging or demonstration labels. Older concept boards are historical references and cannot override these rules. Email entry opens the local library without authenticating an online account; no password is stored or transmitted.

## MVP flow and data sources

| Screen | Primary action | Data source | Boundary |
| --- | --- | --- | --- |
| Sign in | Any valid-format email and any nonempty password, or Explore locally | In-memory entry email; password discarded | Local entry only; no real authentication or mailbox verification |
| Live | Import, search, open video | Dance imports plus the two bundled dance films | Recorded dance playback; no feed endpoint or broadcast |
| Shorts | Swipe, play/pause, mute, seek, save, open details | Dance imports up to 180 seconds plus the two bundled dance films | One active player; silent bundled dance films, no public feed or fabricated online activity |
| Video detail | Play, save/unsave, rename, remove copy | AVPlayer and local library | Never uploads or deletes the Photos original |
| Voice | Browse topic templates, create/edit draft | Static layout templates and local room drafts | No remote participants, microphone session or RTC |
| Chats | Edit and save a thought | A single local message draft | No recipient, sent message, unread count or delivery receipt |
| Me | Edit name, biography, avatar symbol | Local profile | Not an online identity |

First complete code path: **Photos import → video list → detail playback → Save to favorites → atomic library write → Saved list → reload from disk on next launch**. Rename and deletion follow the same write-before-UI-update rule. Additional local flows cover room drafts, message drafts and profile editing.

## Implementation order used

1. Independent project, target, scheme, app identity placeholder and entry.
2. English visual reference, style primitives and bottom navigation.
3. Versioned local models, guarded loading and atomic persistence.
4. Photo-library import, cover generation, video cards, playback and favorites.
5. Voice templates/drafts, chat draft and editable local profile.
6. Explicit authentication/service boundaries, error/cancellation paths and source review.

## States and interaction rules

- Loading: initial library progress; import progress; player preparation; saving labels.
- Empty: no imported videos, no favorites, no search results, no room drafts, no conversations.
- Errors: corrupt/unsupported snapshot blocks writes; failed import cleans temporary/new media; save failures preserve input and old published state; playback errors allow retry.
- Cancellation: dismissing the Photos picker creates no entry; unsaved editor dismissal requires an explicit discard choice; departing playback pauses/releases the player.
- Permission boundary: PhotosPicker grants access only to a selected item. No camera/microphone/broad-photo permission is requested in this MVP. Missing selections or failed asset access never imply permission was granted. Camera/mic denial UX must be added with those capabilities if later requested.
- Accessibility: native controls and dynamic text, labels for icons and media, selected avatar/filter semantics. Video details remain manually played; Shorts autoplays muted with explicit pause and mute controls plus accessible progress adjustment. Device/dynamic-type/VoiceOver rendering is not yet validated.
- Localization: development language and app localization are English; SwiftUI locale is English. System-owned permission/picker UI can still follow the device's language.

## Future service contracts

Real accounts require registration/sign-in, verification, token renewal, logout and deletion contracts with Keychain storage. Public video requires feed/detail/upload and moderation contracts. Live and voice require room lifecycle plus streaming/RTC providers. Chat requires account-scoped conversations, delivery state and media upload. No endpoint, token, identity or entitlement has been invented. Add payments only after their actual business requirement and server authority are defined.
