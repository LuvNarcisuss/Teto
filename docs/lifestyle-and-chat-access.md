# Lifestyle visuals and reciprocal chat access

## Visual assets

Eight Pexels photographs add everyday context: street coffee, coffee conversations, a park walk, two rehearsal scenes, ballet shoes, a music break and casual sneakers. Original downloaded bytes and source URLs/credits/checksums are preserved in `Design/SourceLifestyle/manifest.json`; app copies are in `Teto/Resources/Assets.xcassets/Lifestyle*.imageset`. Room covers and chat stories use contextual photos; a few avatar choices also use music or footwear. Existing user profile choices are preserved. These pictures decorate authored content; photo subjects are not represented as actual members, filmmakers or endorsers.

Three new transparent illustrations were produced using the built-in image_gen tool, one generation per asset: DanceSneakers, VoiceHeadphones and ChatSpark. Originals and exact prompts are in `Design/GeneratedDanceIcons/` (`prompts.json`). App assets retain original alpha. They appear in the Live heading, Voice heading, chat activity/stories/relationship cards and personal collection empty states. The native four-tab bubble navigation is unchanged.

## Messaging rules

AppStore owns the permission decision and validates it again immediately before saving:
- Mutual follow: unlimited local messages (individual messages are limited to 2,000 characters).
- Any non-mutual direct conversation: one introductory message total, not one per session or per day. A follow by the sender alone does not unlock more messages.
- An existing incoming follower can be followed back to become mutual.
- Group conversations are exempt; activity conversations cannot be replied to; blocked creators cannot receive messages.
- Authored history does not consume the introductory allowance. Messages submitted by the current user do, including after unfollowing or reopening the app.

The incoming relationship is distinct from the outgoing follow. Existing fictional contacts Maya, Leo and Zoe start mutual; Noah is an incoming follower. Aria/Finn and creator conversations start non-mutual. Unknown incoming creator relationships default to false. No follow-back is manufactured when the user taps Follow. These are explicitly local catalog relationships, not fetched social-graph records. An eventual authoritative service must populate followerIDs using canonical conversation IDs (`creator-chat:<creator ID>` for authors) and enforce the same rules server-side.

## Persistence and service boundary

Optional fields on ChatLocalState preserve older snapshots: sentMessages, followingOverrides and followerIDs. Outgoing message IDs, timestamps and content are saved atomically with the existing LocalLibrary repository. Sender follow state, author inbox records and draft clearing share that commit. Save failures do not consume the one-message allowance. The main-actor busy guard prevents duplicate concurrent submissions. Author-profile private messages and Chats both use ChatConversationView and the same canonical conversation ID. Inbox previews and conversation bodies read current store records.

Messages are local outbox records with Pending status, not delivered messages. No network send, real follow relationship, delivery/read receipt, or automatic remote reply is implemented. Existing chats, drafts and media remain intact.

## Modified sources

- App/AppStore.swift: relationship rules, local message commit, current inbox records.
- Features/Chats/ChatModels.swift: backward-compatible persistence fields and authored relationships.
- Features/Chats/ChatConversationView.swift: shared sender, follow/back action, limit notice, pending bubbles, lifestyle story viewer.
- Features/Creators/CreatorProfileView.swift: shared author conversation route.
- Features/Chats/ChatComponents.swift: photographic story cards and activity illustration.
- DesignSystem/FreshStudioArtwork.swift: stable avatar/story/cover mappings.
- Features/Live/VideoLibraryView.swift, Features/Parties/PartyComponents.swift, Features/Profile/ProfileView.swift: generated illustration integration.

## Validation boundary

Source and resource inspection only; no compilation, typechecking, app launch, simulator, Preview or tests were performed. Device checks remain for Dynamic Type, keyboard layouts, local persistence after relaunch, rapid send taps, one-message limits across entry points, and return navigation. Assets use existing catalog membership; no source-file registration change is required.
