> Current UI architecture (2026-10-20): UIKit + Swift. See [UIKit migration](uikit-migration.md) for current source entry points, generated icons, service boundaries and unverified items. Earlier SwiftUI file inventories below are historical and have been superseded.

## 2026-10-23 — Codemagic missing shared scheme

The first configuration check failed because `Teto.xcodeproj/xcshareddata/xcschemes/teto.xcscheme` existed locally but was excluded from Git by a machine-wide `*.xcscheme` ignore rule. The previous local-only check missed this omission. Replaying the check against the committed project files reproduced exit code 1 at the shared-scheme check. The shared scheme is now included in the repository, with a repository ignore exception to keep it tracked. The preflight now prints specific errors for a missing project, missing shared scheme or mismatched Bundle ID. Validation uses the committed/staged project snapshot and static scheme-target references; no compilation, app execution, simulator, tests or cloud build was performed. Subsequent signing, archive and App Store delivery remain unverified.

## 2026-10-23 — Runtime media compression

Runtime videos and images now total 191,984,945 bytes, down from 374,632,718 bytes (48.7%). All 46 videos use HEVC/hvc1 with the original dimensions, frame counts and presentation timestamps; existing audio payloads and packet timing are unchanged. Of 340 images, 302 became smaller and 38 retained their bytes. All 177 protected logo/icon assets retain identical decoded RGBA pixels. Design originals, catalog identities and practice cues remain unchanged. Earlier H.264 runtime and byte-identical logo-copy descriptions are superseded. Full media decoding, representative visual comparisons and static source/metadata checks only; no app build, app execution, simulator, tests or measured IPA size. See [runtime media compression](runtime-media-compression.md).

## 2026-10-23 — Teto Codemagic App Store configuration

The root `codemagic.yaml` now targets `Teto.xcodeproj` / `teto`, bundle ID `com.teto.dance`, Apple app ID `6826151569`, the `Teto` App Store Connect integration and Xcode `26.5`. The earlier Unison/Runner identifiers and `ios/` working directories were template values and are superseded. The user-supplied notification recipient is preserved.

The workflow fetches runtime Git LFS videos, applies App Store signing profiles, queries the highest TestFlight build number across versions, and supplies the next number as `CURRENT_PROJECT_VERSION` during archive. Authentication/query failures stop the workflow instead of silently choosing a potentially duplicate number. Exported IPA artifacts are uploaded by `publishing.app_store_connect.auth: integration`; automatic TestFlight beta review and App Store review remain disabled. The Codemagic integration and matching distribution signing identities must already be configured in the service. No workflow was started, no signing was attempted, and no IPA upload was performed during this change. Validation is limited to YAML parsing, shell syntax, source paths and project metadata.

## 2026-10-23 — Teto agreement contact email

At the user’s request, every email address in both bundled agreements and their existing Google Docs copies now uses `18781461148@163.com` (three occurrences in Terms of Service and one in Privacy Policy). Document IDs and application URLs are unchanged. The existing content-hash acceptance version reflects the updated local text; prior acceptance receipts are preserved. Local source inspection and cloud readback only; no build, typecheck, tests, app launch, or simulator.

## 2026-10-23 — Teto agreement names and online links

The local and Google Drive agreement titles and app references use Teto. The Drive folder is now named `Teto`. Five corrupted English words left by an earlier replacement were repaired in both copies: `Identities` / `identities`, `compatibility`, and `incompatible`. The existing Google documents were edited in place, preserving their IDs and links.

`AgreementDocument.onlineURL` now points to the uploaded Terms of Service and Privacy Policy. All entry/settings routes use `AgreementController`, which requests the online document in a nonpersistent WKWebView. HTTP errors, network navigation failures, and Google sign-in redirects fall back to the bundled agreement with a `Saved copy` label. Main-frame navigation is restricted to the selected document. Bundled files and the existing content-hash acceptance format remain; corrected source text changes the next acceptance hash without rewriting prior receipts.

The Drive documents still have owner-only permissions as of the latest metadata read. Public read-only sharing remains outstanding; these URLs must not yet be described as public. Network failure and sign-in fallback code has been statically inspected, not run. Permission pages that return HTTP 200 without a sign-in redirect are not detected by this fallback. Anonymous HTTP verification was blocked by DNS resolution. No build, typecheck, tests, app launch, or simulator was run.

Links:
- Terms: https://docs.google.com/document/d/1PBHnF3UNjCBkEuzOyETCUOWgMEz4eiPfGj_PooGJM4c
- Privacy: https://docs.google.com/document/d/1BGNLMpwOFa8_6Fz3S4zv9xkKELYTBEx3KXi3DLVBSj0
- Folder: https://drive.google.com/drive/folders/1A7Z0kj43At5g8brPAj3n5zZNvphT7t_T

## 2026-10-23 — User-provided logo and entry constraint correction

The user's supplied lime-background Teto logo is now the sole runtime brand artwork. AppIcon preserves all 1024 × 1024 RGB pixels and omits only the fully opaque alpha channel; TetoMark and TetoWordmark are exact file copies. There is no generated replacement, recoloring or crop. Original-color asset rendering replaces the old template setting. The entry mark uses a 112-point square, and the data-loading mark uses a 160-point square, with view-level corner clipping. The Fresh Studio entry layout and two-dancer illustration remain. Source and hashes: `Design/Brand/User-Logo-2026-10-23/manifest.json`.

The reported no-common-ancestor exception came from activating the dance illustration's height-to-stack-width constraint before adding that image view to the stack. The image is now added first, then the constraint is activated. Existing logo/loading/scroll constraints were inspected for the same ordering issue. Static source/resource inspection only; no build, typecheck, tests, App execution or simulator. The fix has not been verified at runtime. The earlier generated-logo selection and claim of completed layout checks below are superseded by this correction.

## 2026-10-23 — Fresh Rhythm entry artwork (generated logo superseded)

The installed icon and in-app Teto mark now use ivory/lime Teto lettering with an evergreen enamel outline and two rhythm droplets on a lime square. The transparent wordmark and new two-dancer illustration carry the same palette into Welcome and the agreement entry screen. This supersedes Logo-v6, Wordmark-v1, the earlier Rhythm t identity, and the earlier 160-point entry icon description. Exact built-in image-generation prompts, original artwork, packaged mappings and replaced assets are recorded in `Design/Brand/Fresh-Rhythm-2026-10-23/manifest.json`.

Entry uses a centered, width-limited scroll layout, the existing handwritten typeface, English headings and lime Get started / Let's dance controls. Text can grow vertically; controls remain inside safe areas, and compact/landscape layouts can scroll. The agreement checkbox remains unchecked initially, links do not accept terms, and successful atomic agreement persistence is still required before entering the app. The reminder now says Agree and continue. No online authentication was added. The actual data-loading screen has the matching wordmark and evergreen activity indicator; the system launch screen has the same ivory background.

Source/resource inspection only: PNG dimensions/alpha, asset references, plist syntax, changed strings, existing agreement gates and catalog/cover references. No build, compiler/typecheck, tests, App execution or simulator. `layout.html` is a static design study, not a UIKit screenshot or runtime verification. Device layout, Dynamic Type, VoiceOver and system launch appearance remain unverified. Navigation, media catalogs, videos, covers, identifiers and persisted data formats were not changed.

## 2026-10-23 — Bundle identifier changed to com.teto.dance

At the user’s request, `project.yml` and both Debug/Release target configurations in `Teto.xcodeproj/project.pbxproj` now use `com.teto.dance`. `Info.plist` continues to resolve `CFBundleIdentifier` from `$(PRODUCT_BUNDLE_IDENTIFIER)`. This supersedes the earlier `im.seex.sao2-neiku-30` identity in historical notes below. Current README, project constraints and wallet documentation were synchronized.

The target/scheme, signing settings, StoreKit product IDs and Application Support/Teto data format were preserved. Existing installations under a different bundle identifier do not automatically transfer their local data. Apple Developer registration, provisioning and App Store Connect product availability for the new identifier remain unverified; no remote configuration was changed.

Static configuration and plist checks only. No build, typecheck, tests, App execution or simulator.

## 2026-10-23 — Distinct media, member mosaics, and mutual profile actions

Chats now renders each group as a rounded-square mosaic of its actual member photographs (up to nine distinct assets), including locally created groups. The same helper is used by the inbox, group conversation title and shared contact components. A group no longer borrows its first member's full avatar. An empty legacy group uses the existing group mark instead of the local owner's photograph. Individual people retain their consistent circular portrait across screens. Existing membership arrays, chat IDs, drafts and saved records remain unchanged. No generated image was added.

Seven film-credit accounts previously fell back to `PortraitLocal`. They now have independent real photographs, `Portrait72`–`Portrait78`, with photographer, Pexels page, license, download, runtime mapping and hashes in `Design/SourcePortraits/manifest.json`. These are account artwork, not photographs of the credited filmmakers. No video or cover needed replacement after this audit.

Profiles show Message only for mutual follows, using the same incoming relationship IDs as Chats. Both an unfollowed profile and a one-way followed profile show a wide Follow/Following button plus Block. Block keeps its existing quarter width; Follow absorbs the removed Message control and spacing. Mutual profiles retain the original quarter/half/quarter Following/Message/Block layout. The Message handler checks mutual state again. Existing inbox access and the one-message greeting policy are unchanged.

This supersedes the non-mutual Message layout in the 2026-10-22 profile-actions note. Source/resource checks only: no build, typecheck, tests, App execution or simulator. Media inventory and visual-review scope: [media audit](media-uniqueness-2026-10-23.md).

## 2026-10-23 — Phrase authoring and repeating preparation counts

Authors can now create video-backed phrases with the same Film/Counts, looping, slow playback, cover cards, local Keep/Learned/share and branching paths as catalog lessons. The editor selects a single-person English dance video through Photos (up to 30 minutes / 250 MB), plays/scrubs it, extracts a chosen cover frame, and accepts per-action start/end times plus instruction-gap text. It also exposes video credits, default 0.5x/0.75x/1x speed, whole lesson or first-section loop, and 40–180 BPM preparation tempo. Creator name/avatar come from the existing profile. User video content and permission confirmation is attestation, not automated moderation or online publication.

Every page-loop restart includes four complete preparation counts, 5/6/7/8, with visual numbers and synthesized clicks. Video source time remains fixed until count 8 finishes. Preparation intervals scale with the selected rate; internal disjoint action ranges do not add another count-in. Pausing, leaving, changing speed/page or backgrounding cancels pending preparation. Both video lessons and legacy text-only loop playback use recurring preparation counts.

Optional `DancePhrase.lesson` preserves old snapshots. New lesson data captures media references, full action timing, partial section sizes, instruction text, source attribution and practice settings. New branches retain independent metadata snapshots and shared file references, so deleting a parent does not remove media still used by a saved child. New media stays outside Live/Shorts and submission feeds. Files are imported before the atomic library save; failed saves clean up only new app-owned files. Orphan scanning includes phrase videos/covers. Original Photos items are untouched. Legacy text-only phrases remain editable.

Only static source, resource and compatibility checks were performed. No build, typecheck, tests, App execution or simulator. Photos transfer, cover extraction, long editor layout, persistence failures, countdown audio and on-device timing remain unverified. Details and review record: [authoring plan](superpowers/plans/2026-10-23-phrase-authoring.md).

## 2026-10-23 — Phrases solo lessons

This note and [the Phrases handoff](phrases-session-handoff.md) supersede the early fixed-eights and practice-figure descriptions. Phrases remains the fifth tab between Live and Voice. Film is selected on entry and starts the bundled lesson at 1x. The practice transport now owns the action/instruction timeline and supplies both Counts and video with a shared host-clock anchor; AVPlayer progress does not advance Counts. Up to eight action cues form a section; teaching pauses do not advance an invented beat grid. The seven lessons have 5–34 sections. Authored/edited phrases support 1–256 sections with 1–8 lines each and retain their independent practice clock. The current pip is 28 × 10 pt, other dots are 10 pt, and spacing is 4 pt; a moving window shows at most nine pips.

All seven films and covers now use separately reviewed CC BY sources across Hip-hop, Contemporary, Swing, House, Ballet and Jazz. Five retain English instruction. The contemporary phrase has a silent original track; the six-step lesson uses English step labels without audio. The ballet film has one dancing instructor, with occasional stationary camera-operator reflections. Film now uses aspect-fill at the user's later request, preserving proportions while cropping edges to fill its frame. More > Film credits provides author, source, license and modification information; Film playback itself stays local. Source records are in `Design/SourceMedia/PhraseSources/manifest.json` under `runtimeFilms`. The seven videos total about 180 MiB. Original phrase IDs, video UUIDs, portraits, saved records and the Live/Shorts catalog were retained.

Film and Counts retain the selected section, position, loop mode and speed when switching. Both expose Loop 8 counts (actual size for a partial page), Whole lesson and 0.5x / 0.75x / 1x controls. Section loops play only that page's action intervals, skipping instruction gaps; whole-lesson playback preserves all instruction and finishes once. Counts numbers restart at 1 for each page. Slow playback scales the original relative action timing instead of inventing a uniform musical beat grid. Pausing and changing speed retain position. Changing section while playing begins the selected loop; while paused it positions the video without starting. Leaving/backgrounding pauses, and returning requires an explicit restart. Legacy text-only edits keep their independent practice clock. New video branches snapshot their parent lesson and expose its editable action times; their local videos and default settings use the same transport. Existing annotations, media bytes, learned keys and saved data are unchanged.

The practice clock waits for a ready player, exact seek and preroll, then supplies source time, rate and a host-clock anchor to AVPlayer. Canceled preparations are generation-guarded. Failure, preparation timeout or playback stall pauses the lesson and offers a retry through the practice controls. AVPlayer host synchronization requires automatic stall waiting to be disabled; implementation follows [Apple's synchronization API](https://developer.apple.com/documentation/avfoundation/avplayer/setrate(_:time:athosttime:)) and [preroll readiness requirements](https://developer.apple.com/documentation/avfoundation/avplayer/preroll(atrate:completionhandler:)). Audio uses a time-domain pitch-preserving algorithm for requested slow playback; its quality is not runtime-verified.

Timing authoring is recorded in `Design/SourceMedia/PhraseSources/SoloLessons/counts-timelines.json`; a local generator emits Swift literals in the existing catalog file. Review used full-film contact sheets at 0.5–2 s intervals, denser 0.25–0.5 s views for selected rapid passages, and available English count calls. These are manual editorial timestamps, not frame-accurate beat measurements. Static coverage, bounds, English text, generated-data equality, resource hashes and compatibility paths were inspected. No build, typecheck, app launch, simulator session or test execution was performed. On-device synchronization, seek/loop behavior, layout, aspect-fill cropping and credits navigation remain unverified.

## 2026-10-22 — Full screen so the app can install

The signed target includes iPhone and iPad, and the supported orientations are portrait plus both landscapes. `UIRequiresFullScreen` is now set, so installation no longer stops on the requirement that every orientation be supported. Upside-down stays off. Static source inspection only. No app launch.

## 2026-10-23 — Two packs complete the wallet grid

The wallet grid now has nine packs. The original seven product IDs, diamond amounts, and reference prices are unchanged, and they still use the same StoreKit 1 purchase flow. Added packs: 16,800 diamonds at $29.99 (`mwkqplvxbtdrjcsn`) and 42,600 diamonds at $69.99 (`hycnfrwzqmkplvtd`). Both IDs are 16 lowercase letters. Static source inspection only. No app launch.

## 2026-10-23 — A finished purchase no longer blocks gifts

A purchased, restored, failed, or already-saved transaction always releases the purchase that is waiting, including one that was already in the payment queue. Gifts no longer wait on that purchase. The live gift sheet can spend diamonds while the wallet can open another pack. Static source inspection only. No app launch.

## 2026-10-23 — Simulator gift balance

A simulator build whose wallet file is still empty starts with 400 diamonds so gifts can be tried. The seed is compiled out of device builds. A device wallet is not written or reset by this path. Spending on the simulator is saved in that simulator’s own `wallet-v1.json`.

## 2026-10-23 — Local gifts spend diamonds and play on the film

Send a gift no longer returns a fixed failure. When the balance covers the quantity, those diamonds are removed from `wallet-v1.json` and the gift plays on the full-screen video or party. The sheet balance updates. A short balance says that nothing was spent. The effect is local to this device. Static source inspection only. No app launch.

## 2026-10-23 — StoreKit configuration restored on the Xcode 26 scheme

Xcode 26 rewrote the shared `teto` scheme and dropped the StoreKit configuration. A payment sent with only a product ID then failed in about a second with “Purchase did not go through,” and the payment sheet did not open. The configuration again points at `Teto/Resources/TetoDiamonds.storekit`. Continue waits for that product, then adds `SKPayment` for the returned `SKProduct`. Diamonds are still added only after the purchased transaction is saved. Static source inspection only. No app launch.

## 2026-10-22 — Diamond product IDs and purchase availability

Wallet purchases request only the seven store product IDs in `WalletCatalog`. The 16,800 and 42,600 packs are gone because those product IDs are not in the purchase catalog. Tapping a pack waits for the StoreKit 1 product request, then starts `SKPayment` when that product comes back. The message "This package is not available. You have not been charged." is shown only after the request finishes without that product. Diamonds are still added only after the purchased or restored transaction is saved, and `finishTransaction` runs only after that save. The shared `teto` scheme points Xcode Run at `Teto/Resources/TetoDiamonds.storekit`. Xcode resolves that path from `xcshareddata`, as `../../Teto/Resources/TetoDiamonds.storekit`. A copy also sits where a scheme-folder relative path resolves. Opening the installed app from the home screen does not use this file. At that time the signed bundle identifier was `im.seex.sao2-neiku-30` (superseded by the 2026-10-23 bundle identity update above); the earlier `com.example.teto` value is retired. Static source inspection only. No app launch. The nine-package note below is superseded for the two removed packs and for the immediate unavailable result.

## 2026-10-22 — Diamond purchases through StoreKit 1

Wallet diamond packages use StoreKit 1. The package button and the confirmation use the store price after it has loaded. Until then the button says See price, and the confirmation says the App Store shows the price before you pay. Catalog USD amounts stay reference values. Diamonds are added only after a purchased or restored transaction for one of the nine package IDs is saved on this device. The transaction is finished only after that save. The same transaction is not added twice. A canceled purchase, a package the store does not offer, and a purchase that does not go through each say that you have not been charged. A purchase waiting for approval does not add diamonds and is not finished. If the save fails, the transaction stays unfinished and can be added the next time the app opens. The balance and the activity list are stored in Application Support/Teto/wallet-v1.json. Signing out keeps that balance. Deleting the account removes the file with the rest of the local library. An unfinished transaction can still be added after that deletion. Gift sending still does not spend diamonds or claim that a gift was delivered. The package IDs qlrpflukqugckska and zhkxxppfqwqfwhcp still have to be registered before those two packages can sell. Static source inspection and a compiler typecheck only. No app launch. This does not establish that the products are registered or that a purchase was accepted. Any earlier note that purchases are unconnected is superseded by this note.

## 2026-10-22 — iOS 16 deployment

The `teto` deployment version is iOS 16.0 in `project.yml` and in the project and target Debug/Release settings. This supersedes the earlier iOS 17+ baseline. Agreement links on the entry screen use the iOS 16 text interaction on iOS 16, and the iOS 17 text-item action on newer systems. Live, Voice, and Phrases lists still run under the tab dock: iOS 17 uses the keyboard layout guide, and iOS 16 follows the keyboard from the screen bottom. `StoreKit1Purchasing.swift` is in the teto target, so the wallet can call it. Signing uses the existing team `JPTS6M4T5B` at both the project and the teto target. The call preview uses `videoRotationAngle` on iOS 17 and `videoOrientation` on iOS 16. Static source inspection only. No build or device check.

## 2026-10-22 — Phrase practice figure

Phrase cards and the phrase page show a drawn practice figure. The figure eases from one count to the next on that phrase's tempo. On a card it keeps moving while the card is on screen, with no click. On the phrase page it follows the click, and it keeps the shown eight moving when the click is off. The studio clips used to write the counts stay outside the app. They are not the Live or Shorts films, and they do not play on the card or the page. Phrase authors and portraits are separate from Live, Shorts, and chats. The phrase library in the phrases tab note still applies. Any earlier reading that a phrase card plays a Live or Shorts film is superseded by this note. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Home mark on root tabs

The Teto mark sits at the top left of Phrases, Voice, Chats, and Me, in the same place as on Live. A pushed page still uses Back. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Voice create control

The Voice list no longer has a refresh control beside Create. Pull to refresh still reloads the rooms. Create is a 52-point lime circle at the lower right, the same size and place as Create on Live. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Clear live line frames

A live line bubble has no fill. The rounded white outline stays, and the lime name and white words stay as they are. The filled live bubble is superseded by this note. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Phrases tab (historical)

The four-eights and film/figure behavior below is superseded by the 2026-10-23 Phrases solo lessons note. Its compilation result applies only to that earlier revision.

Phrases is a fifth dock tab between Live and Voice. A phrase is one to four eights of counts. This eight repeats the eight on screen. From the start plays the whole phrase once. Keeps, learned marks, and phrases written on this device stay in the local library. Seven catalog phrases ship with the app. Share writes a pending chat line on this device. That line has Open phrase, which opens the phrase when it is still on this device. A dancer profile lists that person's phrases. A report hides the phrase until it is removed in Settings. The count and the click stay on the open page, with the current count brought into view. The click stops when the page closes. The project compiled for a generic iOS device. The app was not launched. Phrase cards that played a live film are superseded by the 2026-10-22 phrase practice figure note.

## 2026-10-22 — Profiles from room cards

A live card's portrait opens that dancer. The rest of the card still opens the room. A voice card's portraits open those dancers. The rest of the card still opens the room. Inside a voice room, a seat portrait opens that dancer, including the signed-in dancer. VoiceOver can use Open profile on the same controls. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Live lines wrap

A live line wraps inside its bubble. A short line stays on one line. A longer line uses a second line, and can use a third. The bubble keeps the height of those words, so they stay visible. The stack still stops near one third of the screen and still keeps at most seven bubbles. Older lines leave when a new line needs the room. The live text field accepts up to 50 characters in English. The single-line live bubble in the live line bubbles note is superseded by this note. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Profile cover, live playback, and voice gifts

A dancer profile keeps the round portrait and no longer shows the wide photo above it. A live room keeps playing when a profile, More, Share, gifts, or search opens. A short video still pauses for those. The live text field has a Send control on its right. A voice room has a gift control on the right of Send. Gifts there can be addressed to one dancer or to everyone in the room. Sending a gift still does not spend diamonds or claim that a gift was delivered. The earlier note that only the gift page leaves a live film playing is superseded by this one. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Live line bubbles

Live lines above the field arrive at one to three each second. Each line is its own bubble. The name is lime and the words are white. The filled bubble is superseded by the 2026-10-22 clear live line frames note. The stack stops at one third of the screen and keeps up to seven bubbles, so five to seven can sit there together. The earlier rate of three to five plain lines is superseded by this note. A line that stayed on one row and cut off extra words is superseded by the 2026-10-22 live lines wrap note. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Report note, live covers, and gifts

Saving a report still keeps it on this device and does not submit it. The form closes, and a short note reading Report saved stays for three seconds. That note replaces the older line that a save shows no success card.

A home live card loops the first second of its dance video, muted, while the card is on screen. It does not play the rest of the film. Reported cards stay still. Opening the room still plays the film.

In a live room, lines sit at the lower left, just above the text field. The rate of three to five plain lines is superseded by the live line bubbles note. The speaker control is gone, and the text field uses that width. Like, gift, and share stay. Opening gifts shows the gift page. The earlier sentence that only that page leaves the film playing is superseded by the 2026-10-22 profile and live playback note. Sending a gift still does not spend diamonds or claim that a gift was delivered.

The full-length home-card loop and the live-room speaker in the 2026-10-21 notes are superseded by this note. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Profile photo

Edit profile shows the current portrait and a Change photo control. The control opens the system photo picker for one image. Saving keeps that photo on this device, next to the library, and uses it on Me, on the signed-in dancer's profile, on that dancer's live and short-video portrait, in a voice-room seat, and on comments signed You. The original photo in Photos is left unchanged. No photo-library permission is requested. Cancelling the picker leaves the saved portrait as it was. A photo that cannot be read asks for another photo. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Reported cards in two columns

Settings > Reported places each saved item in two columns. Large text uses one column. A live card, a voice card, a short-video cover, and a comment note share that grid and use the same proportion as the home video grid. The cards stay still. A long press still removes that report. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Chat covers the dock, and profile actions

Live, Shorts, Voice, Chats, and Me keep the floating dock on the home page. A page pushed on that tab, including a friend chat, covers the dock, and the message field uses the home-indicator inset. Returning to the home page shows the dock again. Switching to a tab that is still inside a pushed page keeps the dock covered. The comment sheet still sits over the dock on home Shorts.

A person chat no longer uses a follow plus. Profile sits to the right of Video call, and Voice call stays to its left. Profile opens that dancer. A catalog friend uses the conversation id, name, portrait, and story line. A creator chat opens the saved creator.

The following layout is historical and superseded by the 2026-10-23 mutual profile-actions note. Under the biography, three actions share one row. Before a follow, Follow takes half the row and keeps its icon and the word Follow. Message and Block each take a quarter and keep only an icon. After a follow, Following takes a quarter and shows a check with no title. Message takes half and keeps its icon and the word Message. Block stays a quarter with only its icon. Block asks first, then hides that person's videos, rooms, and chats, and returns to the page behind the profile. A follow or message while that person is blocked says to unblock them from Blocked in Settings. Message opened from the chat returns to that chat. The older profile follow circle in the 2026-10-21 rooms note is superseded by this row. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Reports and blocks hide local content

Save report writes the report on this device and closes the form. It does not submit the report. A live video, short video, or voice room then leaves that page, and the list behind it refreshes without that item. On home Shorts the film is removed from the current feed. A reported comment or voice-room line is removed from that list only. Settings has Reported beside Blocked. Blocked is a user list with a portrait and a name. Reported shows a still live card, a still voice-room card, or a still short-video cover, in two columns. Those cards do not play. A comment report stays as a short note in that same grid so it can be removed. The single-column layout is superseded by the 2026-10-22 two-column note. A long press, or the VoiceOver action, removes that report and the item can show again. Nothing is deleted.

Block still asks first. A saved block hides that creator's live videos and short videos, and hides voice rooms that include that person. Chats with that creator stay hidden. The page returns to the list behind it. Settings > Blocked lists those people. A long press, or the VoiceOver action Unblock, brings their videos and rooms back. Likes, favorites, comments, and drafts stay on the device. Blocking the signed-in profile is still refused. A voice-room block uses the room host's own id, and a video block uses the film creator's id. Those ids are not matched by name.

A failed save stays on the form and says the report was not saved. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Reports stay on the page

Superseded by the note above. Saving a report now leaves the reported video or voice room and hides it until the report is removed in Settings.

## 2026-10-22 — Floating tab dock and hollow search

The search mark is the same evergreen ring and lime handle, with the lens left empty so the page shows through. The Live / Voice / Chats / Me dock keeps its rounded outline. Its fill is a thin blur with a light veil, so the page behind it still shifts the glass and the tab titles stay readable. Its selection mark is a clear glass bubble. A tap moves that bubble in one spring, without a second held pose. Dragging it widens the bubble slightly between tabs. The Live list and the Voice list are pinned to the bottom of the page, so the cards pass under the dock the same way Shorts and Chats already do. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Pending review chip

On Me, Wallet stays above the collection row. Pending review is no longer a separate button under Wallet. It is a chip in that row, between Saved and About. Choosing it lists the waiting submissions on the same page. Removing one still leaves the original photos and videos unchanged. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-22 — Liked count and the six

Me Liked uses one list for the number and the tiles under it. That list has one entry for each liked video. The Teto Rhythm six was drawn as a second closed loop, so a count of 6 was drawn like an 8. The six is now one bowl with an open hook above it. `TetoRhythm-Text.ttf` and `TetoRhythm-Display.ttf` were regenerated from `Design/Brand/Type/build_rhythm.py` into `Teto/Resources/Fonts/` and `Agreements/`. Static source inspection and a glyph render only. No app launch.

## 2026-10-21 — Short comment sheet and settings account actions

The short-video comment sheet uses one ivory fill for the Comments row and the list under it. The row meets the sheet edges. The bottom row is the comment field and a send control, with the field using the spare width. On home Shorts the sheet sits on the tab page as a child of that page, so it covers the create control and the Live / Voice / Chats / Me dock. A short like stays on the red heart after its pop, and a save stays on the filled star; a second tap clears that state. A like tapped while another local save is still writing waits and is kept. Me Liked uses that same video list for the number and the tiles under it. Another tap on a live video stays on that video and does not add a tile. A live-room like still does not stay selected. Settings keeps Edit profile, the two agreement rows, and Blocked full width. Log out and Delete account sit lower, in shorter centered borders. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-21 — Separate films, portraits, and room covers

Live and Shorts no longer draw from one shared film list. Each bundled clip is in one place: portrait clips in Shorts, landscape clips in Live. A dance imported on this device stays in Shorts. Chats, voice rooms, comments, and film credits each use one photograph per person, and the same name keeps the same photograph. The eight voice-room cards each use a different dance photograph. Rooms saved on this device take a cover from a separate set of four dance photographs. Details are in `dance-media-expansion.md`. Static source and media checks only. No app launch.

## 2026-10-21 — Live notes, unlimited likes, blocks, and voice rooms

A live room no longer shows a comment control, a save control, or a stacked comment list. The bottom row was the ivory speaker, a text field, like beside the gift, and share at the far right. The speaker in that row is superseded by the 2026-10-22 live room note. Like and share in a live room show the icon only. Sending a line from the field used to float that line across the top of the video. Live lines now sit above the field, as described in the 2026-10-22 live room note. Each like adds another like and floats a small red heart; it does not turn the like off. A short video still uses a single like, comments, and save. Blocking in a live room or a voice room returns to that list. Blocking in a short video removes that creator's videos from the current list. Saving a report used to follow those same exits; that part is superseded by the 2026-10-22 report and block hiding note. Settings opens Blocked, which lists those creators. A long press there can unblock one. The older sentence that Settings has no report list is superseded by that same note: Reported is a separate row. The choice stays on this device. Voice cards use the live-card lime edge and evergreen corner marks, with the photo filling the card and no white border. In a voice room the speaker and microphone sit together at the lower left, and the message field uses the remaining width. Live and voice bottom controls are fixed at 36 points wide with a 2-point gap. The text field takes the width those controls no longer use. The vertical inset under the old live comment list stays as it was. Tapping a message places a small quote on top of that field. The next line is a reply in the local transcript. That tap does not open a report. A long press on someone else's line does. The long-press note here is the current behavior; see the 2026-10-22 report note. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-21 — Living badge on home cards

Each home live card shows a rounded badge just above the avatar and name. The badge has a white rounded border, three moving white bars, and the word Living in the Teto Rhythm display face. Shorts cards do not show it. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-21 — Creation close and agreement prompt

Closing a page that opened from the plus shrinks that whole page back into the plus. The entry screen still asks for the Terms of Service and Privacy Policy. Continue without the check opens a card whose text asks the reader to review and agree. Agree and log in checks the box and enters. Disagree closes the card and stays on the entry screen. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-21 — Voice room invite seat

A voice room keeps the dancer seats and adds an Invite seat on the same row. The seat uses the round evergreen frame and the enamel plus. Tapping it opens the friends you follow. Choosing one saves an invite in that chat on this device. The friend is not added to the room, and no voice connection starts. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-21 — Home mark, create control, and chat row actions

The Live home page shows the Teto mark at the top left. Create is a lime plus at the bottom right, in the same place as the voice page, and opens live or short creation for the mode that is open. A chat row swipes left to Pin or Unpin, Mark read or Mark unread, Mute or Unmute, and Delete. Those four actions are square 48-point buttons with no corner radius, flush with the row. The row stops when the buttons are open and cannot slide off the screen. Pinned rows stay at the top of the inbox. Mark unread places a coral count bubble on the row; the number is 1 for that action, and an existing larger count still shows its own number. Mute places a slashed bell on the row. Delete hides that chat on this device and keeps it hidden after the next launch. The bubble and the bell are enamel artwork loaded through TetoIcon. Read, pin, mute, and hidden state stay in the local library and do not contact a server. `StudioOptions` uses the non-failable `UIStackView` coder initializer. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-21 — Seats inside the frame, share sheet, and chat circles

A voice room shows your own avatar beside up to three other dancers, centered in one row. Voice bars sit inside the bottom of the avatar border. A closed microphone uses the ivory microphone-off mark, and opening or closing your own microphone updates that seat. Bars appear on your seat only while your microphone is open, the room speaker is on, and the current line is yours. The room speaker still uses the ivory speaker. These controls change the local picture only and do not start a voice connection. Share opens a bottom sheet on the studio background: the title is Share with, the first row is friend avatars and names, and the second row is Share link. Choosing a friend saves a pending message in that chat on this device. Share link copies `teto://party/{id}` and states that the address stays inside Teto. Home live cards place the moving meter inside the lower part of the video frame. Every moving voice meter uses three thin white bars. Live covers are decoded as soon as the home page opens, and the Live / Shorts control takes its size without waiting for a tap. The voice category track opens with its selection on All and shows every party. Opening comments on a short video shrinks that video toward the top with the sheet and keeps the clip playing. Voice-room and chat avatars use portrait photographs, including chats that previously had no picture. Playback on those cards starts after that first layout. Chat portraits, including the story row and inbox, use a round evergreen frame. The chat plus opens Create a group, Add a friend, and Scan. Create a group begins with Face to face, then a divider and the friends you follow, with a checkbox to the left of each round portrait. Create now stays pale and does not respond until at least two friends are selected, then saves the group on this device. Face to face states that a nearby match is not available. Add a friend uses the same white search capsule as chat search; a dancer appears under the field only after an ID is entered. Scan reads a QR friend code with the camera and can follow a known dancer on this device. An unknown code or a denied camera stays on that screen with an accurate message. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-21 — Ivory controls, voice seats, and creation handoff

Live and short videos start with sound on. The live sound control used the ivory speaker at the same 32-point size as the other rail icons. That live-room control is superseded by the 2026-10-22 live room note. A short video still has the ivory speaker, and the gift icon is the ivory enamel artwork. Home live cards open the room from a tap on the video frame. Search, create, add-friend, settings, and the other top icon buttons hide the iOS 26 glass plate. A voice room centers up to four bordered avatars. The closed-microphone mark, share sheet, and home meter placement in this paragraph are superseded by the seats note above. The room's own speaker and microphone change that local picture only; they do not start a voice connection. Info opens the room introduction and a report action saved on this device. Create grows the studio background into the creation page without a fade. Static source inspection and a compiler typecheck only. No app launch.

## 2026-10-21 — Rooms, follow, bubbles, and live cards

Live and short videos no longer show a second comment field. Comments stay on the comment control. After a follow in a live room, that control becomes a small check beside the name. A creator profile used a red frame with a plus before a follow and a green frame with a check after it. That circle is superseded by the 2026-10-22 profile actions note. The short-video speaker sits under Share, in ivory, at the same size as the other rail icons. Live, Shorts, Voice, and Chats share one transparent bubble that follows a drag and then springs into place. Create, search, and settings are bare icons. Voice and Chats no longer put a filter control in the top corner. The chat plus menu and the home meter placement in this paragraph are superseded by the seats note above. Home live cards play their saved dance videos inside the frame, muted, while the card is on screen. The full-length loop is superseded by the 2026-10-22 cover note, which keeps the first second only. The chat title stays centered. Static source inspection only. No build or device check.

## 2026-10-21 — Comment window and reaction icons

Opening comments on a short or live video shrinks the video to the top of the screen and keeps it playing. The comments sit underneath that window and close by the close control, a downward drag, or a tap on the video. Like and Save use the same glossy icon family: an ivory heart or star while idle, and a coral heart or gold star after the action. Comment, Share, and More use that same ivory enamel and the same icon size. The live gift control uses that same 32-point size. Static source inspection only. No build or device check.

## 2026-10-21 — Calls, search, creation, and reactions

Voice-call microphone and speaker now share one state: lit while on, and a slashed icon while off. Video calls use an empty camera icon; the camera with a dancer stays on Live. Search grows from the tapped control into a top bar and blurs the page behind it. Create grows from the tapped control until the creation page opens. Like uses an outline heart that springs into a red heart, and Save uses the same motion with a star. Share is an in-app English card with Copy and Close, so the sheet does not follow the device language. Comments keep a single close control. The entry screen asks for agreement with a checkbox. Terms of Service and Privacy Policy are text links. The entry mark is shown as a 160-point rounded square. Static source inspection only. No build or device check.

## 2026-10-21 — Full-bleed layout and bubble selection

Page artwork now extends through the status bar and the home indicator. The floating tab dock is more transparent, and its lime bubble follows a horizontal drag before snapping. The Live / Shorts switch and the voice category row use the same sliding bubble. Chat voice calls use a tilted handset (`TetoIcon-handset`); ending a call still uses the horizontal receiver. Edit profile is in Settings. The Live list keeps its cards and actions, with a full-bleed dance photograph behind them, and the live room vignette is deeper. Static source inspection only. No build or device check.

## 2026-10-20 — Creation and community update

Live and Shorts now open separate creation forms instead of opening Photos immediately. New content is stored in a durable pending-review outbox, visible from the Me Pending review chip between Saved and About, and excluded from discovery. The separate button under Wallet is superseded by the note at the top of this file. No upload or review service is connected. Per-video like/save baselines are about 10–30. Comment reports are available in Shorts, Live and voice rooms. The eight built-in parties have disjoint 3–10-member rosters and display member counts rather than large heat figures. This supersedes earlier direct-import creation and shared-avatar behavior below. Details and source inventory: [creation-review-and-community.md](creation-review-and-community.md).

# Teto implementation status

Current product: English-language dance social frontend, iOS 16+, four tabs. The latest user request supersedes the earlier commerce/art/social room variants. See `live-room.md` for the current source inventory and replacement points; older records are preserved under `archive/`.

## Implemented in source

- Brand redesign (2026-10-20): the user-selected Rhythm t identity uses a single ivory lowercase-t silhouette on evergreen, with a rising crossbar and curved foot. This replaces the earlier Dancing T figure. Welcome and sign-in share the existing native `TetoBrandLockup`; the loading mark matches the installed icon. Selected artwork, exact image-generation prompts and runtime mappings are recorded in `Design/Brand/Teto-Rhythm-2026-10-20/`. Static source/resource and image inspection only; no build or runtime verification.

- Second dance-media batch: 12 additional Pexels films, 24 bundled clips total. Live and Shorts independently shuffle once per AppStore session with newest collection first and the original two clips last. Imported dances retain their existing priority; saved collection IDs/order remain compatible. Source/cover/provenance and static media checks recorded in `dance-media-expansion.md`; no app build or runtime verification.

- Dance media expanded by 10 licensed Pexels clips (12 total), with covers, English descriptions, stable IDs, source originals, hashes and five-timestamp visual review records. Live and Shorts share the expanded catalog. See `dance-media-expansion.md`. Media/static inspection only; no app build or runtime verification.

- Live restoration (2026-10-20): Live opens the original embedded video/room library; room cards and Live search results open `LiveRoomView`. Shorts alone uses the swipe feed at the main entry. Fresh Studio styling remains, with light Live list navigation and immersive Shorts navigation. This supersedes the earlier shared Live/Shorts feed design. No build or runtime verification was performed.

- Whole-app Fresh Studio coverage now includes all light utility/form sheets, live comments/options, voice-room interiors, call backgrounds, creator conversations, gift icon styling and a new matching AppIcon/loading mark. See the whole-app section of `fresh-studio-theme.md` and `whole-app-theme-files.txt`. Static inspection only; no build or runtime visual verification.

- Fresh Studio reference alignment now includes custom four-tab chrome, a Live room-card landing page, distinct photographic party cards/avatars, compact inbox, profile collection tabs and faceted diamond artwork. See the second-alignment section of `fresh-studio-theme.md`. Source and assets only; runtime visual equivalence has not been verified.

- Fresh Studio is the selected visual theme: cream surfaces, evergreen buttons, lime accents, dance photography, rounded cards and coordinated wallet/gift styling. Existing navigation and data identities are preserved. The wallet now uses diamonds only. See `fresh-studio-theme.md` for files, resource provenance and validation limits.

- Visible branding is now Teto, including the installed display name, welcome, agreement, profile, party header, share text and camera permission. Existing identifiers and storage root stay intact. Me > Wallet includes a single Diamonds balance, nine USD recharge packs and an empty transaction-history screen. The live gift sheet offers nine priced gifts, quantity/total, and a wallet shortcut. Purchase/gift adapters explicitly fail as unavailable, with no fake credit, deduction or delivery. See `wallet-and-gifts.md`.

- Person/group chats and creator private conversations have Voice call and Video call buttons. Full-screen call layouts reuse recipient avatars/names; microphone/speaker buttons change visual state and End returns to the same conversation. Video uses an actual local AVCaptureSession with front/back switching, permission/error states, and inactive/exit teardown. No audio capture, recording, signaling or network call is implemented. User Agreement v1.1 and About now describe camera permission accurately. See `chat-call-screens.md`.

- Startup now follows Welcome → One-tap sign in → main tabs on each cold launch. The agreement checkbox starts unchecked, cannot be bypassed by browsing, and opening the terms does not accept them. Consent version/time persist atomically through an optional library field before navigation. Me > Settings opens the same User Agreement text and acceptance record; old email/password entry is removed. See `welcome-and-agreement.md`.

- Live's existing More menu and a new Shorts More button below Share provide shared Report video and Block creator actions. The hiding, Settings lists, and local undo behavior in this bullet are superseded by the 2026-10-22 report and block note at the top of this file. See `content-safety.md`.

- Live and Shorts author avatars now open a shared full-screen creator profile: cover/avatar/name, Likes/Following/Followers, biography, IP region, Follow/Message and a three-column dance-video grid. Unknown statistics use a dash and unknown IP uses Unavailable. Message opens a full-screen chat window with the author avatar/name, private draft bubble and bottom composer. Creator follows, per-author private message drafts and opened conversation records persist locally via optional schema fields. These conversations appear in Chats with search/pin/draft filtering and reopen the same author chat window; older saved drafts are included automatically. Work tiles play full screen and return to the profile. See `creator-profile.md`.

- Saved-video cards now open a full-screen cover reusing ShortsFeedView and ShortVideoPage, with the selected collection ID, automatic 1× looping playback, floating controls/comments and an explicit back button that stops playback before dismissing to the existing collection. Collection playback includes videos longer than three minutes and keeps an unsaved current video open until exit. Personal-video management still uses direct view destinations; duplicate UUID destinations remain removed. Source inspection only; device behavior is not yet verified.

- Chats now has a screenshot-inspired white inbox, ten English dance conversations, avatar notes, search, unread/pinned filters and conversation details. Read state, pin overrides and reply drafts persist locally; no message transport is connected. See `dance-chats.md`.

- Voice now opens an English dance party discovery page: a cream page with photographic two-column cards, category/search/filter, local party creation, an immersive room interior and the original four-tab navigation with a transparent background. Asset/interaction details: `party-discovery.md` and `voice-party-room.md`. The room interior has authored dance conversations (1–3 new lines every random 1–2 seconds, looping through 48 English phrases with a 200-entry cap), a member rail, local follow/private notes, native sharing and explicit unavailable voice-connection feedback. Chat flow pauses for sheets, backgrounding and exit; history reading suspends auto-scroll.

- Screenshot-inspired Shorts layout: left video import, right search, lower caption, five-action rail and constant-speed floating English comments. See `shorts-layout.md` for interaction boundaries and file inventory.

- English UI across entry, Live, Shorts, dance rooms, Voice, Chats and Me; prior Chinese room copy and staging labels removed.
- Shared two-film dance catalog for Live and Shorts; seven non-dance bundled videos, covers and original source videos removed.
- Full-screen dance rooms with stable AVPlayer ownership, local/HTTPS/cover interfaces, explicit 1× looping, error/retry, mute and lifecycle management.
- 152 authored English dance comments, mixing one-word reactions, two- and three-word notes, and longer lines, cycling at a randomly selected rate of 1–5 comments per second; stable IDs, bounded history, a Chat flow switch and cancellation on inactive/paused/failed/covered states. The earlier 96-line count described the script before 2026-10-22. No server messages or online viewer counts are implied by the sequence.
- Keyboard-aware comments, local follow/likes, floating hearts, gift selection, native share and English practice/community sheets.
- Local imports/favorites/profile/drafts continue to save atomically. Optional `isDance` preserves old snapshot decoding; old uncategorized personal imports remain in Me and can be explicitly added to the dance feed.
- Runtime artwork uses the retained dance covers. Source/license credits remain accessible.

## Still not connected

Online authentication, public uploads/feeds, real-time broadcasting, voice RTC, messages/calls, remote account data, payments and gift delivery. These operations have not been reported as completed.

## Inspections performed

Read/inspected source and media provenance, visually inspected the retained dance covers, scanned app-owned text for Chinese/retired staging terms, inspected references, generated Xcode project metadata and checked plist/project format. Original reference screenshots and the retained dance source downloads are preserved outside the app target. The seven non-dance source downloads were deleted; their provenance records remain.

No build, compiler/typecheck, simulator, app execution, SwiftUI preview or tests were run. Actual layout, keyboard, lifecycle, comment loop/scrolling, accessibility and persisted-library compatibility remain unverified on a device.
