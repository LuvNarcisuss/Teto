# UIKit migration — 2026-10-20

## Current implementation

Teto now uses UIKit + Swift in the existing iOS 16+ target. The entry point is `Teto/App/TetoApplication.swift`; four native navigation stacks share a floating capsule tab dock. No UIHostingController, SwiftUI imports, or Objective-C source files are part of this target.

The native controllers cover welcome/consent, Live discovery, full-screen Live and Shorts, Voice discovery and room chat, Chats and conversations, voice/video call screens, creator and personal profiles, collections, creation/review queues, wallet/gifts, settings, local agreements, reporting, and blocking. UIKit layout and navigation are newly implemented; exact visual parity and device behavior still need runtime review.

The existing AppStore, library repository, social stores, catalog IDs, and atomic storage format remain. Likes, saves, comments, replies, creator conversations, follow state, reports, blocked creators and pending works use the existing local data interfaces. Creator likes/saves continue to aggregate all their works. Existing media and product ID mappings have not been replaced.

## Image-model icons

42 individual transparent PNG icons were generated with OpenAI's built-in image model, using evergreen, lime, ivory and coral accents. Search, camera/create, settings, four tabs, playback, moderation, messages, call controls, diamonds and gifts are included.

- Runtime assets: `Teto/Resources/Assets.xcassets/TetoIcon-*.imageset`.
- Original full-resolution drawings and exact prompts: `Design/GeneratedIcons/Teto-UIKit-20261020/manifest.json` and adjacent PNGs.
- Native loader: `Teto/DesignSystem/TetoIcons.swift`. The forward arrow mirrors the generated back arrow.
- Each icon has 64/128/192-pixel PNGs for 1x/2x/3x. Packaging only resizes the original artwork; transparency is retained.
- The existing accepted Teto logo and wordmark are retained. App-owned buttons use the generated assets; Apple-owned keyboards, Photos picker, permission and share sheets retain system controls.

## Functional boundaries

Camera capture is local AVFoundation capture, with permission-denied and interruption handling; voice/video pages do not establish remote calls. File selection uses PHPicker. Playback uses AVPlayerLayer, 1x looping, and stable player ownership. No service-backed live broadcast is introduced.

Account entry persists local agreement consent. It is not remote identity verification. Messages are local conversation records/outbox entries, not delivery confirmations. The mutual-follow rule remains enforced by the existing store. Refresh uses the existing local recommendation and room services. Scripted dance discussions remain bounded and stop when covered or inactive.

Creation saves pending local submissions and does not claim server approval. Wallet purchase and gift actions keep the existing service boundary and do not credit balances or claim transactions when the service is unavailable. Local reports do not claim remote submission. No credentials, new service domains or signing teams were added.

## Validation and limitations

Only source, syntax-formatting, asset JSON, project/plist and reference inspections were performed. XcodeGen regenerates project metadata only. No Swift compilation/type-checking, app launch, simulator, preview or automated tests were performed, as requested.

Compilation, device layout, accessibility sizes, camera permission transitions, keyboard behavior, media playback, modal lifecycle and persistence across an actual relaunch remain unverified. This document is not a build-success or release-readiness claim.

## Files and recovery

`docs/uikit-migration-files.json` lists the replaced SwiftUI files and native replacements. The source/configuration snapshot preceding this migration is at `Design/MigrationBackups/Teto-before-UIKit-20261020.zip`. Media binaries are unchanged and were not duplicated into the snapshot. Historical UI inventories elsewhere in the documentation describe the previous implementation.
