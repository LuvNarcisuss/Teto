# Native live room — implementation and handoff

> Historical record only. Follow `../../AGENTS.md` for current requirements. Earlier staging labels and non-dance media must not be restored; seven non-dance original downloads were deleted on 2026-10-19.

## Entry and scope

Open **Live → Live room scenes → Commerce / Art / Social**. Each entry presents `LiveRoomView` full screen using a different `LiveRoomConfiguration`. The existing Live video cards also open this room shell using the selected local media; they have zero synthetic viewers/likes and only a local-mode system message. Existing collection details (rename, removal, favorites) remain accessible through Me/Your videos/Saved; Shorts retains its existing detail route and playback behavior.

Baseline remains **iOS 17, Swift 5, native SwiftUI**, with `ObservableObject` / `@StateObject` consistent with AppStore. No dependency, SDK, endpoint, signing account or deployment target was added. The rest of the app remains English. This new reference-specific room uses the Chinese text expressly requested in the latest specification. Live room fixture names, counts and comments are illustrative, not real activity.

## Reference evidence

The three provided Desktop images were opened and visually inspected, then copied unmodified into `Design/References/LiveRooms`:

| Saved reference | Original Desktop file | Scene |
| --- | --- | --- |
| `commerce-original.jpg` | `微信图片_20261019143953_3_2.jpg` | Store, promotions, right-side product card |
| `art-original.jpg` | `微信图片_20261019144410_4_2.jpg` | Drawing, exhibition, lower comments |
| `social-original.jpg` | `微信图片_20261019144411_5_2.jpg` | Portrait, compact header, low comments |

These are design references outside the app bundle. They are **not used as full-screen backgrounds**, so no screenshot status bar, comment or header is duplicated. Original screenshots, videos and decorative app assets remain untouched. The store rating retains only `店铺好评率9…`; no full numeric score is invented.

Native layout follows the references' layering: full-screen media, top/bottom gradients, scene extensions, compact header and audience capsules, lower comments, optional right-side product card, bottom input/actions, floating hearts/toasts/sheets. The device supplies the status bar and Home Indicator. Buttons and text input respect safe areas. There are no app navigation/tab bars inside the room.

## Files

All new Swift files live under `Teto/Features/LiveRoom/`:

| File | Responsibility |
| --- | --- |
| `LiveRoomModels.swift` | Modes, streamer, audience, optional badges, comments, product, campaign, media/configuration and fixtures |
| `LiveRoomStore.swift` | Observable room state, service boundary, local demo implementation, bounded comment history, cancellable operations/notices |
| `LiveVideoView.swift` | Stable AVPlayer owner, local/HTTPS/cover source, fit/fill, ready/error/loading state, looping, mute, lifecycle and fallback |
| `LiveRoomChrome.swift` | StreamerHeaderView, AudiencePreviewView, SecondaryNavigationView, ExhibitionWidgetView, reusable avatars/icons |
| `CommentFeedView.swift` | Stable-ID lazy comment feed, badge/nickname/body text, top fade, history reading and new-message button |
| `FeaturedProductCardView.swift` | Right-side product, product image fallback and expandable information |
| `BottomActionBarView.swift` | Focused input, emoji insertion, keyboard/send controls, adaptive action row and floating heart |
| `LiveRoomSheets.swift` | GiftSheetView, ProductSheetView, audience, panel model and native UIActivityViewController share bridge |
| `LiveRoomView.swift` | Layering, safe-area composition, scene extensions, interaction routing, sheet/lifecycle management and previews |
| `LiveRoomScenePicker.swift` | Three clearly labeled demo entry cards |

Updated existing files: `Teto/Features/Live/VideoLibraryView.swift` (scene entry and full-screen room presentation); `Teto.xcodeproj/project.pbxproj` (generated source registration); README and implementation status. Existing LocalVideoPlayback, ShortsPlayback, library schema and persistence were not modified for this feature.

## Media and asset replacement

Change fixtures or inject a configuration in `LiveRoomModels.swift`:

```swift
var config = LiveRoomDemoData.configuration(.art)
config.media = LiveRoomMedia(
    source: .local(localFileURL),
    scaling: .fit,
    coverAsset: "LiveArtCover"
)
```

Use `.remote(httpsURL)` for a playable HTTPS file/HLS URL, or `.coverOnly` to show a cover. Source selection is a code configuration seam, not a built-in URL downloader. No credentials or URLs are persisted. No real network stream has been supplied or verified. Device ATS settings are unchanged. For a real live source, replace the player adapter with the chosen SDK/protocol and revisit demo-file looping rather than presenting a file loop as live streaming.

- **Commerce** currently uses a clearly marked warm placeholder cover. Provide clean footage containing the wooden table, hands/phone and marketing backdrop. A generated native placeholder poster shows the requested campaign strings only while no cover exists and `containsCampaignArtwork` is false. Set that flag true for video with baked-in posters. `Campaign.posterPrice` is `449`; `FeaturedProduct.couponPrice` is independently `569`. `launchPrice` is `599`. The supplied screenshot timer `00:40.55` is a static reference value, never a fake active countdown.
- **Art** currently uses a clearly marked cover placeholder with `.fit`. Supply a clean character-drawing video or cover, including necessary software panels. The watermark, character sticker and equipment notes belong in that supplied media; no second copy is rendered by the app.
- **Social** uses the existing first licensed Pexels stock clip as temporary playback media, explicitly not the named host. Replace the source/cover with the intended authorized portrait footage. Original creator/source links are available in the room's playback/material sheet.
- `media.coverAsset`: image-set name in `Teto/Resources/Assets.xcassets`; `media.coverURL`: local JPEG/PNG URL. The fit/fill choice also applies to covers.
- `Streamer.avatarAsset`, `AudienceMember.avatarAsset`, `FeaturedProduct.imageAsset`: optional Assets image-set names. Current fallbacks are symbols; product fallback explicitly reads `商品图占位`. The brand uses a generic store symbol rather than inventing a logo.
- Optional custom action image sets: **LiveHeart**, **LiveGift**, **LiveCart**, **LiveShare**. `LiveActionIcon` detects them by name. Until provided, pink/indigo heart, pink gift, orange cart and white share are clearly documented SF Symbol placeholders, not claims of exact 3D screenshot artwork.

No screenshot content was cropped into runtime assets. No unavailable image set is referenced with an unconditional `Image(name)` call.

## Implemented behavior and limits

- Header includes follow state, source-configured likes, up to three overlapping avatars, viewer capsule, and 44-point close button. Horizontal fitting reduces avatar count; accessibility text uses a second header row. Nickname truncates on one line.
- The two non-commerce modes have hour ranking/plaza; Art has `基础展馆 0/12`, Social has a subtle `礼物展馆`. Commerce has service/ranking/coupon/campaign entrances and optional expandable product data. Commerce components are absent from the other modes.
- Comments use stable UUIDs and a lazy stack, with optional colored inline badges, cyan names, dark bubbles and multiline content. The viewport holds roughly 4–6 ordinary short messages, fewer when lines or text sizes grow. A drag through history or the VoiceOver history action stops auto-follow; pending comments produce a return-to-latest button. Returning to the bottom resumes following. History is bounded at 200 messages for this demo. `LiveRoomStore.append` is the insertion seam for a future subscription; no fake timed arrivals are generated.
- Sending validates/trims up to 200 characters, appends a message marked `仅本机`, preserves input on failure, and never claims delivery. Keyboard focus uses FocusState. While composing, the header reduces to the name and close button to leave room for large text. The input sits in a bottom safeAreaInset; it follows the keyboard while the media ignores keyboard insets. Product card is hidden during composition, accessibility sizes, landscape or insufficient vertical space; cart/details remain available.
- Product card can close; it shows the source-specified independent coupon price, sales fixture, product text, subsidy and detail action. Product info folds independently. Product and service panels label all reference prices/policies as samples, not actual merchant promises.
- Likes update session-only counts and produce bounded floating hearts and a button pulse. Reduce Motion suppresses heart/pulse/haptic triggers. Heart tasks cancel when removed or the room exits. Gift/coupon/purchase actions update local preview selections only and explicitly indicate no gift delivery, coupon claim, charge or order.
- Native share opens the iOS share sheet with demo text. It does not fabricate a stream link or claim a share was completed.
- Viewer, ranking, plaza, exhibition, gifts, products and media use native sheets. The current ranking/plaza/exhibition content is explicitly sample or empty data, not connected services.
- Media loads once for a stable source, uses explicit 1× playback and automatic file looping, starts muted, and exposes pause/mute via the `演示 · 非实时直播` playback/material button. No progress bar or permanent central pause button is drawn. Sheets/backgrounding pause media; returning resumes only if the user had not manually paused. Missing/failed media shows its cover, with retry; startup has a cancellable 20-second timeout. Exiting detaches KVO/notification observers and the AVPlayer item.
- Follow, likes, comments and selections last only for the presented room session. They are not online account state and are not persisted to the user's media library. A new `LiveRoomServicing` adapter can provide real operations; subscription, authentication, moderation, product availability and payment confirmation still require separate integration.

## Preview and validation boundary

Source includes named SwiftUI previews for **Commerce**, **Art**, **Social**, **Empty / Large Type**, and **Missing local video**. Demo data can be instantiated without AppStore, a login or a backend. Preview declarations are supplied but were not executed.

Actually performed: inspected all three reference images, inspected source for state ownership/scene conditions/keyboard and layout constraints/cleanup/service separation, generated project metadata with XcodeGen, and checked project/Info.plist format with plutil. No Swift compiler, type checker, build, simulator, app launch or automated tests were run, per the standing instruction.

Still unverified: successful compilation; 320/375/393/430-point iPhones, notch/Dynamic Island/insets, keyboard and landscape behavior, largest Dynamic Type/VoiceOver focus, comment-history gesture routing, network buffering/retry, sheet transitions, repeat playback, system share targets and resource release on a device. These are pending acceptance checks, not reported passes. Exact visual fidelity is also limited by missing clean scene media, avatars, product images and bespoke action art.
