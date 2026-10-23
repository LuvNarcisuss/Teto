# Dance party discovery

## Entry and design

Open the existing **Voice** tab to find the new dance party discovery page. The supplied screenshot is retained unchanged at `Design/References/Parties/discovery-original.jpg`, outside the app target. The page now uses a white background and dark header text per the latest user request, while retaining teal accents, fixed header/category strip, two-column cards, cyan/purple double borders, floating actions and the original transparent four-tab navigation (restored by the latest user request). The product remains **Teto**, and all built-in text is English.

The reference's game categories are replaced with **Hip-hop, K-pop, Jazz, Freestyle, Ballet and House**. Eight authored rooms cover choreography, practice, dance friends and filming routines. No Soul brand, Android status symbols or fake Home Indicator is added. The discovery page remains a room list; its separate interior is documented in `voice-party-room.md`. The skill lookup did not yield a matching discovery-page design; visual decisions follow the supplied reference and sizing constraints directly.

## Components and architecture

Existing iOS 16+, Swift 5, SwiftUI and ObservableObject conventions are retained.

- `Features/Parties/PartyDiscoveryView.swift`: fixed header, room grid, loading/error/empty states, floating actions, sheets and navigation.
- `PartyComponents.swift`: `DiscoveryHeaderView`, `PartySectionHeaderView`, `GameCategoryStrip`, `PartyRoomGrid`, `PartyRoomCard`, `RoomTypeBadge`, `OverlappingAvatarGroup`, `PopularityLabel` and `FloatingPartyActions`.
- The former custom white five-position navigation and central hump have been removed. The native tab bar remains visible with a clear/hidden background and light color scheme on Voice.
- `PartyModels.swift`: rooms, voice/video types, independent card appearance, dance categories, participants, filter, popularity and navigation destinations.
- `PartyDiscoveryStore.swift`: injectable `PartyDiscoveryServing`, local catalog loading, refresh/cancellation and filtering. No network request is made by the current provider.
- `PartySheets.swift`: searchable full list, filters, room-interior entry, party create/edit, independent dance-post form and tool callbacks.
- `App/MainTabView.swift`: Voice routes to the new page; it retains the original Live, Voice, Chats and Me tabs with a transparent bar on the party page.
- `Domain/LocalLibrary.swift`: two optional room-draft metadata fields (`danceCategory`, `partyType`) preserve decoding of old snapshots.
- `App/AppStore.swift`: video import optionally accepts a title and returns a success flag; media/title are committed together using the existing persistence and failure cleanup. Existing import callers remain compatible.

## Behavior

- Category chips toggle independently; no category is selected initially. Filter supports all/voice/video and popularity order.
- Search matches room names, descriptions and dance styles. All parties opens the complete local catalog plus saved room drafts.
- Refresh reloads the provider and reorders catalog rooms; it preserves saved drafts, blocks duplicate loads and exposes loading/error states. Reduced Motion replaces the floating spinner with a static hourglass.
- Room cards open the immersive VoicePartyRoomView in a full-screen cover, including entries from search/all parties. Close returns to the existing list. No audio/video connection, microphone permission or speaking animation is started. See `voice-party-room.md`.
- Create party saves a title, description, dance style and room type via the existing room-draft persistence. It appears at the top of the collection and can be edited from its details. No online room is published.
- `DancePostSheet` remains a reusable Photos/title form in source, but the removed center navigation button no longer presents it. The existing video import entry remains at the top left of Live/Shorts. No public post is claimed.
- Header Mood, Cards and the globe each have independent callbacks. The included local tool flows select a dance mood, cycle conversation prompts, and show a connection-availability page. These are product choices, not claimed functionality inferred from the screenshot.
- Navigation labels remain Live, Voice, Chats and Me; all four use the existing app tab routing. There is no extra center post button on the party page.

## Catalog and truthfulness

Heat is a distinct `PartyPopularity` model, not an online count. The reference-provided values are retained as local catalog values: 1.35k, 1.64k, 81, 258, 2.40k and 95. The last two rooms have no heat value. All online counts are unknown, and none are rendered. Participants use authored illustrated avatars, not fetched user identities. Card emphasis is controlled by `PartyCardAppearance` independently of room type or paid/verified status.

Backend discovery, account matching, public room creation, real-time audio/video, online presence and public posting remain unconnected. There are no staging labels on the page, and unavailable operations are described directly where relevant.

## Assets and replacements

Ten original vector assets were added under `Teto/Resources/Assets.xcassets`:

- `PartyCategory-hipHop`, `PartyCategory-kPop`, `PartyCategory-jazz`, `PartyCategory-freestyle`, `PartyCategory-ballet`, `PartyCategory-house`: replace the SVG file in the corresponding imageset to change dance category artwork.
- `PartyAvatar1` through `PartyAvatar4`: replace these original illustrated avatar SVGs with licensed avatar images, preserving the imageset name/Contents.json mapping.

`DiscoveryHeaderView.brandAsset` accepts a replacement asset name. Until a brand image is supplied, the centered native text wordmark is **Teto**. `PartyAvatarView` and category chips fall back to SF Symbols when the named image is missing. Icons, avatar groups and room data are configurable independently; no full screenshot is used as a background.

## Layout and accessibility

The grid uses 16-point outer margins, 12-point gaps and a 150-point baseline card minimum height. Card height scales with Dynamic Type; accessibility sizes switch to one column. Titles are capped at two lines. Avatar groups fall back from four to three/two/zero images to preserve heat labels. The centered wordmark has equal flexible side regions; narrow/large-text headers use icon-only tools with accessibility names.

Primary buttons keep 44-point hit targets. The floating circles are 48 points with a 16-point gap and 12-point right margin. A 144-point grid bottom inset lets the last row scroll above them. The original native tab bar owns the bottom safe area; the party background extends behind it. Floating refresh/create actions remain above that safe area. Native status bars/Home Indicator are retained. The discovery page, search and creation/filter sheets use a light color scheme; the separately presented room interior uses a dark gradient. The dark room cards keep their white text. The refresh circle has a subtle outline/shadow for visibility on white. VoiceOver room labels include name, type, style and known popularity.

## Inspection and remaining verification

Provided SwiftUI previews: full catalog, large Dynamic Type, card grid, empty catalog and failing provider. They have not been launched. Source/API availability and project/resource references were inspected; Xcode project metadata was regenerated and plist/project syntax checked. Original screenshot bytes are retained.

No compiler, typecheck, build, simulator, app launch or test was run, per the user's instruction. Device appearance, toolbar/tab switching, Home Indicator contrast, large-font layout, keyboard, navigation, refresh timing and actual saved-library migration remain unverified at runtime.
