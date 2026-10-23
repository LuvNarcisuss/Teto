# Dance chats

> Current UIKit group-avatar behavior (2026-10-23): the inbox and group title use actual member photo mosaics through `conversationPortrait`, including locally created groups. Group arrays are preserved; repeated/missing assets are skipped during rendering, with at most nine portraits. The older SwiftUI component inventory below is historical. See [media audit](media-uniqueness-2026-10-23.md).

## Layout and content

The Chats tab now follows the supplied screenshot's structure: a white inbox, centered Chats title, an inbox menu on the left, search/plus on the right, a horizontal avatar-note strip, then full-width conversation rows. Rows contain a circular avatar, name, message summary, time and an unread badge. Pinned rows use a subtle gray background; group avatars use a four-person mosaic. The existing Live / Voice / Chats / Me navigation is retained. No Android status icons or replacement bottom bar are drawn.

All built-in content is English and dance-focused. `DanceChatCatalog` contains ten authored conversations: Dance activity, Maya Chen, After Class Crew, Leo Brooks, Zoe Park, Noah Rivera, K-pop Practice Circle, Aria Wilson, Finn Taylor, and Ballet & Balance. There are six person chats, three groups and one activity thread, each with multiple message bubbles. Topics include choreography, weight shifts, rhythm, jazz warm-ups, playlists, filming and ballet practice. Time labels and initial unread counts are catalog fixtures; they are not incoming server events. No online indicator, delivery receipt, typing indicator, fake payment or live call status is generated.

## Interactions

- Author private-message conversations join the existing Chats list when opened from a creator profile. The same creator ID deduplicates Live/Shorts/Profile entries. They show the author avatar/name, local update time and saved draft; selecting a row resumes the shared author conversation window, and Back returns to Chats. Search, pinning, Drafts filtering and the contact picker include these entries. Empty drafts retain their conversation row. No remote unread/delivery state is generated.

- Open any row to read its message history. Local unread state clears and persists after opening.
- The top-right magnifier expands into an inline search field in the inbox header, matching names and conversation text within the current inbox filter. The avatar strip and filter summary collapse so the conversation rows move directly below the search field. Cancel clears the query, dismisses the keyboard and restores the header and avatar strip. The transition respects Reduce Motion. The inbox has no persistent search bar, separate search sheet or activity toolbar icon; Dance activity remains available as a conversation row. The menu filters All chats, Unread, Pinned or Drafts; it also marks all read and opens the previous personal message draft.
- Long-press a row to mark read or pin/unpin. The detail toolbar also controls pinning. Equal-priority rows retain their catalog order.
- The plus button opens a searchable list of the existing dance friends/groups, then navigates to the selected conversation.
- Avatar rings open authored dance notes with a licensed dance-film cover and credit. Your day opens the existing independent dance-post/import sheet.
- Each conversation supports a reply draft of up to 2,000 characters. The pencil action saves it locally, and the inbox then shows its Draft summary. The composer explains that messaging is not connected. It does not send a message or insert a delivered outgoing bubble. Saving an empty draft clears it.
- The old general-purpose `messageDraft` remains accessible under My notes; no existing draft is overwritten by the new per-conversation fields.

## Persistence and boundaries

`LocalLibrary.chatState` is optional for backward-compatible version-1 snapshot decoding. `ChatLocalState` holds read IDs, pin overrides and per-conversation drafts. AppStore saves changes through the existing atomic repository; failures retain the existing library and entered draft, with error feedback. Catalog IDs and message IDs are stable.

The conversation history, contacts, activity tips, unread fixtures and dance notes are authored local content. Read/pin/draft changes and opened creator-conversation records are persisted. Creator records live in the optional CreatorLocalState.conversations field; old creator drafts are surfaced even if no record exists yet. There is no messaging backend, account lookup, message transport, public story posting or automatic reply service. The page has no staging labels.

## Files and assets

- `Features/Chats/ChatsView.swift`: inbox, search, filters, menus and navigation.
- `ChatModels.swift`: typed authored conversations/messages and persistent local state.
- `ChatComponents.swift`: avatar, story strip and conversation row.
- `ChatConversationView.swift`: message bubbles, draft composer, contacts sheet and dance-note sheet.
- `MessageDraftEditor.swift`: preserved existing notes editor, extracted from the old inbox file.
- `Domain/LocalLibrary.swift`, `App/AppStore.swift`: optional chat state and atomic mutations.
- `Resources/Assets.xcassets/ChatAvatar1.imageset` through `ChatAvatar8.imageset`: original vector avatars. Replace the SVGs with licensed images and update Contents.json filenames as needed; group mosaics reuse them. Missing assets fall back to a person symbol.
- Original screenshot retained unchanged outside the runtime target at `Design/References/Chats/inbox-original.jpg`.
- Regenerated `Teto.xcodeproj/project.pbxproj` includes the new Swift files and assets.

The layout uses native navigation/search/sheets, a LazyVStack inbox and message history, adaptive text, 44-point toolbar/composer targets, VoiceOver labels, and safe-area input placement. Inbox summaries allow more lines at accessibility sizes. There are no repeating animation tasks or timers.

## Verification

Performed source/resource inspection, English/staging-copy scans, source-reference checks, JSON/SVG parsing and Xcode project metadata generation/plist format checks. SwiftUI Preview declarations are supplied for the inbox, large text and a conversation, but were not run.

No build, typecheck, simulator, app run or tests were executed, as requested. Actual layout, keyboard, navigation, read/pin persistence and migration of saved libraries require runtime verification.
