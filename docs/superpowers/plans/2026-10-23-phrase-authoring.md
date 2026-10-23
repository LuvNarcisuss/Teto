# Complete phrase authoring and recurring preparation counts

User requirements: every eight-count loop starts with 5,6,7,8; authors can create cards with the video, cover, counts and practice settings that existing cards have. Continue UIKit / Swift 5 / iOS 16, English app text, existing icons, local atomic storage; no builds/typechecks/tests/App/simulator.

Decisions: reuse Photos video selection and app-owned media copying. Add optional lesson metadata to DancePhrase for backward compatibility. New cards require dance video and authored action timestamps; legacy text-only records remain editable without forced data loss. Creator name/avatar come from the current profile. New phrase imports stay outside Live/Shorts and pending submissions. Author-attested English dance content is not represented as automatic moderation or online publication.

Author fields: title, style, video, chosen cover frame, action text/start/end, instruction text before actions and at the end, default playback rate and starting mode, preparation BPM, original creator/permission attribution. The complete lesson timeline fills instruction gaps; no fabricated uniform action timing. Branches preserve independent media/timing/attribution snapshots. Detail resolves local and catalog media through the same path; feed cards use the authored cover. Creator profiles retain their existing text links for both catalog and authored phrases, opening the shared detail screen.

- [x] Add repeating preparation counts to both playback clocks; freeze the video until preparation completes, cancel on pause/background, scale preparation intervals with selected practice rate. Independent agent owns PhrasePulse.swift only.
- [x] Add optional authoring models, validated timeline/group mapping, local media persistence/rollback/reference retention, and common media/cover/timeline resolution.
- [x] Expand the editor with inline video playback/scrubbing, frame cover selection, manual start/end marking and numeric editing, instruction/credit/default settings, local save and discard protection. Integrate custom lessons in details and cards.
- [x] Static audit English text, reference ownership, legacy decoding, generated/catalog media immutability and cancellation. Update current documents and perform final source review. No runtime claims.

Verification emphasis: partial sections, replaced video invalidating timestamps, stale picker/thumbnail results, save failure cleanup, shared branch media references, deletion retaining referenced files, pause while counting in, count-in once per page loop rather than each internal action range, failed/canceled startup, changed learned marks after timing edits.
