# Counts-led practice

The user corrected the playback model: the lesson video must follow the selected counts and practice pace, with repeated or slower eight-count learning for beginners.

Use one host-clock practice transport for bundled lessons. It selects source action intervals, controls looping and speed, and supplies both the count highlight and AVPlayer's time/rate anchor. Video time observations do not advance counts. Whole-lesson playback retains instruction; looping a page includes only its up-to-eight actual action cues. Adjacent cues play continuously, instruction gaps are skipped. Partial final pages stay partial. Existing annotations preserve relative rhythm; they are not reinterpreted as uniform musical beats.

Film and Counts both expose Loop 8 counts (or the actual shorter size), Whole lesson and 0.5x / 0.75x / 1x. Default entry remains Film at 1x. Switching views retains position, speed and loop. Pausing preserves position for continuation of the same mode. Changing page restarts its loop when already playing, otherwise positions it paused. Changing speed preserves the current action position. Backgrounding pauses and requires an explicit restart.

Approach chosen by implementation judgment within the user's request: external host-clock transport with prepared video segments. Keeping AVPlayer as the count clock would retain the rejected dependency; forcing one uniform duration on every annotated action would distort the varied dances. No new navigation, material re-encoding or data migration. User-selected slow playback supersedes the former original-speed-only rule for this practice screen; stored media remains unchanged.

Seek/preroll readiness gates clock startup; stale completions cannot restart canceled practice. Playback failure or stall pauses both and exposes a retryable English message. Manual annotation precision and actual iOS audiovisual behavior remain unverified.

UIKit / Swift 5 / AVFoundation / iOS 16; English app text and existing icons only. No compilation, tests, app execution or simulator. Existing private phrases retain their independent click clock and are not falsely assigned parent-video timings.
