# Content reports and creator blocking

## Entry points

Live's existing ellipsis opens More options, retaining playback, mute, speed, chat-flow and credit controls while adding the shared safety section. Shorts adds an ellipsis button directly below Share, using the same safety component in its own native options sheet. Its action rail can scroll if the available height is too short. Buttons retain 44-point targets and English accessibility labels.

The current actions are Report and Block on the UIKit More and Report screens. The report target contains the content id, title, media kind, and stable creator identity. A live or short video uses that video's id. A voice room uses the room id. A comment uses the comment id. Video reports use the same creator identity as the profile. A voice-room block uses the host's participant id.

## Reports

Reasons cover spam, harassment, hate, sexual content, violence, dangerous activity and other concerns. Details are optional, English, up to 500 characters. Save report uses the existing atomic repository. The form says the report stays on this device and is not submitted. No moderation service, case number, enforcement, or platform receipt is fabricated. A successful save closes the form and shows Report saved for three seconds. That note does not mean the report was sent to anyone. The older sentence that a save shows no success card is superseded by this one.

A reported live video, short video, or voice room is hidden. The live room, a presented short-video player, and a voice room then close, and the list behind them refreshes without that item. Home Shorts removes that film from the feed that is already on screen. A reported comment or voice-room line is hidden from that list only; the video or room stays open. Repeating the same content, kind, and reason updates the existing local record. Any saved reason hides the item. Storage errors remain in the form.

Settings > Blocked is a user list: a round portrait and the dancer's name. Settings > Reported keeps one entry per content id and kind, newest first, laid out in two columns. Large text uses one column. A live video uses the live card, a voice room uses the voice card, and a short video uses its cover. Those cards stay still: no playback and no moving ring. A comment report stays as a short note in that grid so it can be removed. A long press, or the VoiceOver action Remove this report, removes every saved reason for that item so it can show again. The page says reports stay on this device. Pending review still lists the signed-in user's own waiting submission. Media, likes, favorites, comments, and drafts are not deleted.

## Blocking

Confirmation explains the local scope: live videos, short videos, voice rooms, and chats are hidden, and the person can be unblocked from Blocked in Settings. A successful atomic save records the creator by stable id, removes the local creator follow, and clears a chat follow stored under that same id. Discovery, search, liked videos, saved videos, personal works, and creator works exclude blocked creators and reported films. The inbox hides a conversation when its id is blocked or when its creator id is blocked, so a catalog friend leaves the chat list along with a creator chat. A voice room is hidden when its id was reported, when `party:` plus that id is blocked, or when any participant id is blocked. Participant ids and film creator ids are separate, so a block is not matched by the person's name.

A dancer profile reached from a person chat places Follow, Message, and Block under the biography. Follow uses the chat relationship for a catalog friend and the creator follow list for a video creator. Choosing Follow or Message while that person is blocked does not change the follow. It says to unblock them from Blocked in Settings. Unblock brings the chat back and does not follow that person again.

The local owner's profile cannot be blocked. Follow and private-draft mutation methods reject blocked creators.

Live and a presented short-video player stop playback, close the options sheet, then close the player. Home Shorts removes that creator's films and keeps the next film, or shows the empty feed when none remain. A voice-room block closes the room and returns to the voice list. Player lifecycle stays paused while the options or report sheet is open.

Blocking does not delete videos, favorites, comments, or private drafts. Settings > Blocked lists each saved person with a portrait and a name. A long press, or the VoiceOver action Unblock, restores visibility and the preserved chat and favorite data. It does not follow that creator again. There is no server-side block, account enforcement, notification to the creator, or message transport integration.

## Storage and files

LocalLibrary.contentSafety is optional for backward compatibility with existing version-1 snapshots. ContentSafetyState stores blocked profiles and LocalContentReport records. It has no credentials or UserDefaults writes. Removing a report or a block changes only that local record.

Current UIKit entry points:

- `Features/Safety/ContentSafety.swift`: targets, reasons, persisted report rows.
- `Features/Community/CommunityControllers.swift`: report form, comment reports, save and close.
- `App/AppStore.swift`, `Domain/LocalLibrary.swift`: atomic mutations, feed filtering, and compatibility.
- `Features/Shorts/VideoFeedController.swift`: live and short-video report or block exit, and the home Shorts feed update.
- `Features/Parties/PartyControllers.swift`: voice-room hiding, room reports, and comment reports.
- `Features/Profile/ProfileControllers.swift`: Settings rows for Blocked and Reported, including long-press undo.

The SwiftUI file names below are historical and are not the current screens. `Features/Safety/ContentSafetyViews.swift`, `Features/LiveRoom/LiveRoomView.swift`, `LiveRoomSheets.swift`, `Features/Shorts/ShortVideoPage.swift`, `ShortsFeedView.swift`, `Features/Profile/ProfileView.swift`, and `Features/Creators/CreatorProfileView.swift` belong to that earlier inventory.

## Verification

Inspected source routing, filter consumers, async success and error branches, English strings, and retained dance media. Static source inspection and a compiler typecheck only. No app launch, simulator, or tests. Sheet dismissal and persisted-library behavior were not exercised on a device.
