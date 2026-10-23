# Media and profile-action audit — 2026-10-23

## Result and scope

The final runtime inventory contains 86 photographic portraits (including seven phrase-author portraits), 12 room cover photographs, two lifestyle photographs, 46 video covers and 46 dance videos. SHA-256 comparison found no identical files among these 192 assets. Normalized 64×64 RGB comparison found no identical photographic images. The video catalog contains 46 distinct IDs and asset names with both media files present. All film creators now have explicit, distinct portrait mappings; the source manifest's bundled hashes match the files.

Portrait and cover contact sheets were visually reviewed. Each video was inspected at 15%, 50% and 85% of its duration (138 extracted frames). These frames show dance or dance practice; no duplicate clip was identified at those points. Some clips share a shooting location or dancers but have different sequences/framing. This is representative-frame inspection, not an exhaustive full-film overlap or text/transcript analysis. A perceptual-hash near-match, Portrait8 versus PhraseAuthorMaren, was checked visually and consists of different photographs/people.

Machine-readable file inventory and hashes: [inventory.json](../Design/MediaAudit/2026-10-23/inventory.json). Compact visual evidence: [portraits 1](../Design/MediaAudit/2026-10-23/portraits-0.jpg), [portraits 2 and room covers](../Design/MediaAudit/2026-10-23/portraits-1.jpg), [phrase authors](../Design/MediaAudit/2026-10-23/phrase-authors.jpg), [new portraits](../Design/MediaAudit/2026-10-23/new-portraits.jpg), [video covers](../Design/MediaAudit/2026-10-23/covers-0.jpg), and films [1](../Design/MediaAudit/2026-10-23/films-0.jpg), [2](../Design/MediaAudit/2026-10-23/films-1.jpg), [3](../Design/MediaAudit/2026-10-23/films-2.jpg), [4](../Design/MediaAudit/2026-10-23/films-3.jpg), [5](../Design/MediaAudit/2026-10-23/films-4.jpg).

## Corrections

- Group inbox rows previously took `avatars.first`, making After Class Crew look like Maya and K-pop Practice Circle look like Zoe. `conversationPortrait` now lays out the group's real member photographs in a rounded square. Two to four members use two columns; five to nine use three. Partial rows are centered. Repeated or unavailable image assets are skipped; no repeated tiles are manufactured. Empty legacy groups use the existing TetoIcon group mark, never a borrowed personal portrait, without changing saved membership. More than nine members show the first nine distinct available portraits. The same helper serves the group title and contact/share components. This uses the existing licensed photographs and UIKit image views, with no generated artwork or baked replacement file.
- The seven newer lesson-film credit accounts were absent from `DancerPortraits.creators`, so legacy saved-film/profile/chat routes could resolve them to `PortraitLocal`. They now use `Portrait72`–`Portrait78`, each a separately sourced real Pexels photograph. Sources, photographers, license, files, hashes and assignments are recorded in [the portrait manifest](../Design/SourcePortraits/manifest.json). The photographed people are not claimed to be the credited filmmakers or app members. The generated group images attempted before the user's correction were never copied into the project or referenced by the application.
- An individual keeps the same identity photograph across their own screens. Group mosaics intentionally include their members' same photographs, as requested. Source-download copies outside the app bundle are provenance archives, not extra feed entries. User-created groups retain their existing member arrays; user photos, personal videos and saved records were not edited or deleted. Unknown future/private assets cannot be certified unique by this bundled-resource audit.

## Profile actions

| Following | Follows me | Visible actions |
| --- | --- | --- |
| No | No | Wide Follow, Block |
| No | Yes | Wide Follow, Block |
| Yes | No | Wide Following, Block |
| Yes | Yes | Following, Message, Block in the existing layout |

`isMutualProfile` resolves catalog friends through `isMutualChat`; creator conversations use their existing `creator-chat:` follower key. Unknown incoming relationships remain false. Blocked/self profiles do not enable the Message action. The tap handler rechecks mutual state. This does not alter saved inbox access, local message drafts, or the existing first-greeting allowance within Chats.

For a row width W, Block remains (W − 16) / 4. Without Message, Follow is W minus Block minus the remaining 8-point gap. Mutual rows retain the original quarter/half/quarter proportions after two 8-point gaps. Controls retain the existing 48-point minimum height, styles and English labels. Relationship changes rebuild the profile through the existing store observation.

## Verification boundaries

Only source/resource/configuration inspection was performed. Asset filenames, explicit portrait references, creator coverage, catalog IDs, provenance hashes and the modified English labels were checked. A separate read-only code review inspected the avatar and relationship paths. No build, compiler/typecheck, tests, App launch or simulator execution was performed. Layout under Dynamic Type, real-device rendering, persistence and navigation are not runtime-verified.
