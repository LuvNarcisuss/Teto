# Dance voice-room interior

> Superseded on 2026-10-21. The running room is `PartyRoomController` in `Teto/Features/Parties/PartyControllers.swift`. The SwiftUI layout below is a historical note. Current behavior is in `implementation-status.md`.



## Layout and entry

`Features/Parties/VoicePartyRoomView.swift` replaces the lightweight PartyDetailsView content. Discovery cards and search/all-party results open the room in a full-screen cover; the close button dismisses only the room, preserving the underlying list. Existing personal draft-management screens remain available.

The supplied screenshot is preserved without alteration at `Design/References/VoiceRoom/room-original.jpg`, outside the app target. The native layout follows its hierarchy: title/follow/focus/close at the top, horizontal secondary entries, two small promotional-style dance topic cards, chat bubbles on the left, four member portraits on the right, and quick prompts plus an input/action row at the bottom. All runtime copy is English and dance-related. No source screenshot, game ads, Chinese copy, Android status bar or fabricated system controls are rendered.

The background is a native gray-blue to warm-purple gradient with soft colored shapes. It extends beyond safe areas; buttons and the bottom inset respect system insets. The discovery page remains white with its existing transparent tab bar. The room hides navigation/tab bars, retains the real status bar and Home Indicator, and uses translucent charcoal bubbles with mint accents. No extra background image or network media is required.

## Components and states

VoicePartyRoomView composes the header, room links, topic cards, conversation, member rail and bottom controls. It reuses PartyRoom, PartyParticipant, PartyAvatarView, PartyCreationSheet and LiveShareSheet. VoiceRoomBackdrop supplies native art; VoiceRoomNoteSheet owns keyboard focus and editing. Room member images come from existing PartyAvatar1–4 assets, with the existing missing-image fallback.

At accessibility font sizes the member rail moves above the conversation and scrolls horizontally, preserving text width. At normal sizes it scrolls vertically on the right. Chat bubbles wrap naturally and scroll independently. The bottom controls omit the secondary music action when space is insufficient. Focus mode hides secondary cards and the rail. Transitions respect Reduce Motion. Action targets are at least 44 points, with accessibility labels. Empty draft rooms omit authored member conversations and show an empty member state.

## Interaction and capability boundaries

- Follow changes room-session state; it does not create a remote relationship or persist after leaving.
- Authored member names and chat lines are catalog content, not incoming messages. While the room is visible and active, a cancellable SwiftUI task waits a random 1–2 seconds, then appends 1–3 lines from a shuffled 48-line English dance script. After exhausting the script it reshuffles and loops. Existing listed members supply the avatars and names. Empty rooms do not generate members or messages. No fabricated online count, live speaking animation, automatic join event or delivery receipt is shown.
- The loop pauses while a sheet or app notice is visible, in the background, after exit, when Chat flow is disabled in room settings, or while VoiceOver is enabled. Reduced Motion disables scrolling animation. Each appended item receives a stable ID, with at most 200 appended entries retained. Dragging the conversation suspends auto-scroll; a new-message button returns to the latest entries. Reading history does not stop message generation. No messages are persisted or transmitted.
- Quick prompts/input open a keyboard-aware private-note editor. English notes up to 200 characters are added to this visit's conversation with a Private note label. The combined appended conversation (chat lines and private notes) is capped at 200 entries and discarded after leaving. Nothing is sent to other members or saved to a backend. Cancel preserves the unfinished draft during the visit.
- Join opens accurate unavailable feedback; it never enables a microphone or claims a connection. No RTC SDK is configured.
- Members opens the participant list with an explicit live-presence limitation. The existing heat metric remains separate from presence.
- Topic cards open dance conversation prompts and practice-playlist guidance. No music streaming or purchase is claimed.
- Invite uses native sharing of the room title and category, with no fabricated join URL or delivery success.
- Settings/about explains current room boundaries. Saved local rooms can reopen the existing edit form.
- Close dismisses the full-screen room to the originating discovery/search list. The room starts no playback, audio capture or network polling. Its chat task is cancelled on departure and does not catch up missed batches after a pause.

## Verification

Inspected Swift source, English UI strings, resource references, lifecycle and routing. Generated Xcode project metadata to register the new source file and checked its plist format. No compilation, typecheck, app/simulator launch, SwiftUI Preview execution or tests were performed. Normal, accessibility-size and empty-room Preview declarations are provided but not executed. On-device layout, keyboard, sheet transitions and dismissal still need runtime verification.
