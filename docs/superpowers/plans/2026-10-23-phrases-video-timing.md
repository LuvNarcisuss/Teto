# Phrases video timing implementation plan

**Goal:** Cover all seven bundled lessons with action cues tied to their actual video time; use aspect-fill video framing.
**Architecture:** Versioned authoring JSON outside the app records actions and instructional intervals against the existing MP4 files; a generator writes validated literals into the existing Swift catalog. AVPlayer time drives synchronized Counts; independent authored/edited phrases retain the existing practice clock. Catalog text is derived from actual action cues, grouped for paging without imposing a 64-count limit.
**Tech stack:** UIKit, Swift 5, AVFoundation, iOS 16. No new app dependencies.
**Spec:** User clarification on 2026-10-23: cover the entire instructional video and expand the number of counts to match actual movement. This supersedes the independent notes and fixed eight-eights assumptions in early plans.

## Constraints and review focus

- All visible text is English; use existing bitmap icons.
- Do not change video bytes, speed, catalog IDs, saved private phrases, or Live/Shorts assets.
- Do not interpolate a beat grid across spoken instruction or label six-step/waltz instruction as eight musical beats.
- Keep existing learned data; new timed catalog sections use their own learned-key version.
- Seeking, buffering, looping, switching Film/Counts, and backgrounding must not start a second clock or reset progress unexpectedly.
- No build, app execution, simulator, previews or tests. Use source/resource inspection, media timestamps and static validation only.

## Tasks

- [x] Annotate complete runtime films: explicit action onsets, instructional gaps, original file hashes and review evidence; inspect source speech and representative motion frames.
- [x] Add validated timeline models and catalog loading; derive paged count text, support actual final-page size and expanded phrase lengths while preserving old data.
- [x] Drive timed Counts with AVPlayer current time, retain position across modes, support section looping/from-start, and show original pace instead of unrelated fixed tempos.
- [x] Retain custom phrase playback, expand editor compatibility, preserve old learned marks, and keep long-page navigation compact.
- [x] Update manifests/handoff and statically inspect cue coverage, order, bounds, text, resources and compatibility. Document that playback/visual synchronization has not been checked on iOS.
