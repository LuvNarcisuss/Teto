# Execution ledger — 2026-10-23-phrases-video-timing.md

Binding scope: latest user answer, “覆盖整段教学视频，按实际动作扩展拍数”. Follow current source and handoff rather than the early 2026-10-22 UI design.

- Ruling: No compilation, typecheck, app execution, simulator, preview or tests — explicit user/project constraint overrides skill test gates. Static source/resource validation is the permitted evidence; runtime behavior remains unverified.
- Ruling: Work in the supplied directory with before-file copies under `/tmp/teto-counts-alignment/before` — this directory is not a Git repository. No branch, commits or Git worktree are fabricated.
- Ruling: Keep authoring JSON outside the app and generate literals inside the existing `DancePhraseCatalog.swift` — no new runtime resource or project generation is necessary. Generator equality is inspected statically.
- Ruling: A page contains up to eight visible movement cues, not eight imposed musical beats — tutorial holds, waltz and six-step passages use original source time. Manual editorial timestamps need playback calibration; they are not frame-accurate measurements.
- Ruling: New catalog learned marks use a versioned key, retaining old arrays unchanged. Private phrases retain their original independent clock; edited text cannot safely inherit the parent's timed cues.

## Work record

- Task 1: Complete seven full-film timelines (0 through the actual runtime duration), including instruction intervals. Inspected complete-film contact sheets at 0.5–2 s and selected rapid passages at 0.25–0.5 s, with available English count calls. Source hashes recorded in `counts-timelines.json`. Action counts: 132 / 37 / 267 / 212 / 87 / 223 / 187 in catalog order.
- Task 2: Added cue lookup, action/page mapping, variable final-page lengths and validated catalog literals. Removed the old fixed 64-note sets.
- Task 3: Counts uses AVPlayer time; exact seeking, section ranges, shared mode position, original pace, instruction state and aspect-fill are implemented. Background/leaving pauses playback.
- Task 4: Editor and private-phrase pulse support variable page sizes and long phrases. Legacy learned arrays remain stored. Deleted parent sections may be represented in changed-section metadata.
- Task 5: Current handoff and both media manifests updated. Static inspection confirmed continuous full-duration coverage for all seven films, cue bounds/order, English text, action/page totals, matching media hashes and generated Swift literals. Xcode project bytes and non-Phrases manifest entries remain unchanged.
- Fresh-context code review completed once. Fixed both important findings: Film now restores the idle timer only when it owns that setting, preserving private-phrase playback protection; editor dirty-state snapshots retain section boundaries, so regrouping actions triggers the unsaved-changes prompt. Inspected both fixes in source without running the app.
- Review ruling: The proposed correction to catalog-order totals was inconsistent with the current initializer order. Rechecked the actual IDs and retained the verified totals above; this is not a deferred issue.
- Remaining verification boundary: Manual editorial timing, AVPlayer callback/seek behavior and aspect-fill framing still need authorized iOS playback inspection. Static checks do not establish frame-accurate alignment or runtime success.

No application tests were written or executed, and no runtime success is claimed.
