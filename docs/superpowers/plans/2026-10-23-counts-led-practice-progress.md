# Execution ledger — 2026-10-23-counts-led-practice.md

- Ruling: Implement the user's explicit correction directly with the existing UIKit stack; source-rhythm scaling at 0.5x/0.75x/1x is a reversible implementation choice. Arbitrary action cues are not converted into uniform musical beats.
- Ruling: Explicit no-build/no-tests/no-simulator constraints override executable skill gates. Source inspection only; runtime timing remains unverified.
- Ruling: No Git repository; before-file copies are in `/tmp/teto-counts-led/before`. No worktree/commit is fabricated.
- Pre-flight: The domain supplies action-only ranges; the clock supplies source time and host anchor; the player consumes them. The controller is the sole owner of transport mode, speed and UI state. Player callbacks may report readiness/failure but must not drive count progress.

- Task 1 complete: Domain derives contiguous action-only intervals per page; PhraseLessonClock owns position from system host time, gates preparation, preserves pause position and cancels stale callbacks.
- Task 2 complete: AVPlayer exact seek/preroll and host synchronization consume the clock anchor. Both Film/Counts expose page loop, whole lesson and three playback rates; mode switches preserve state, background pauses, counts restart at 1 per page.
- Task 3 static inspection: All seven media hashes match existing manifest values; action/page totals and partial tails unchanged; changed Swift string literals are English without prohibited product wording. Non-Phrases manifest entries and project.pbxproj unchanged. Current handoff/status/manifest playback notes updated. Independent review completed once.
- Ruling: Apple requires automaticallyWaitsToMinimizeStalling=false for host-time synchronization and a ready player at zero rate before preroll. The implementation observes readiness and pauses on stall/failure; source annotations remain manually estimated. Actual slow audio quality and device timing remain unverified.

## Final review and fix pass

- Fixed: Exclusive segment endpoints could select the next page on pause. Added a cue-time projection that stays inside the current segment, separate from the exact transport endpoint, and explicitly retained the selected loop section. Static tracing used the reported Reach and turn boundary at 10.4 s; resume retains section 1 and begins its next loop instead of selecting section 2.
- Fixed: A failed AVPlayer/item was reused indefinitely by retry. Failed playback objects are now replaced before preparing the preserved practice position/rate/mode.
- Ruling: Regraded the two caption findings as important behavior mismatches: a stale Pause control can unexpectedly start playback, and private phrases cannot actually resume. Refreshed controls on return without restarting and restored Stop for private phrases. Static source inspection confirms both changes; no executable tests were run under the binding user constraint.
- Final: Ruling: Runtime synchronization, loop smoothness and slow-audio quality require iOS execution, which the user prohibits; retain the explicit unverified status. Existing manual annotation accuracy, media licensing/content and unrelated navigation are unchanged and were not re-reviewed; inaccurate existing annotations would still affect action boundaries.
- Final static inspection after fixes: Changed string literals remain English with no prohibited product wording, both manifests parse, and the endpoint/failed-player/return/private-clock paths were read in source. No deferred code-review findings. No compilation, typecheck, tests, App execution or simulator.
