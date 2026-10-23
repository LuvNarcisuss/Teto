# Counts-led practice implementation plan

> Execute inline with superpowers:executing-plans. Explicit project constraints replace executable verification with static inspection.

**Goal:** Make video follow count selection, looping and slower beginner practice.
**Architecture:** A host-clock transport controls contiguous source intervals and supplies shared time anchors to Counts and AVPlayer. Readiness gates startup; video progress never drives counts.
**Tech Stack:** UIKit, Swift 5, AVFoundation, iOS 16.
**Spec:** `docs/superpowers/specs/2026-10-23-counts-led-practice-design.md`.

## Constraints and review focus

No build/typecheck/tests/app/simulator; no media-byte changes or new dependencies. Preserve IDs, old data, private-phrase playback and English copy. Inspect cancellation during seek/preroll, pause/resume at segment boundaries, rate changes, rapid page/mode changes, short final pages, and foreground/background transitions. Static checks cannot prove visual or audio synchronization.

## Tasks

- [x] In `DancePhrase.swift`, derive merged action-only ranges for a section. In `PhrasePulse.swift`, add a host-clock practice transport with play, pause, position, preparation and start callbacks, cancellation generation and segment-loop boundaries.
- [x] In `PhraseDetailController.swift`, connect clock-controlled AVPlayer seek/preroll/host synchronization and failure handling; make both modes expose practice controls, preserve state on view changes, support 0.5x/0.75x/1x and actual local counts 1–8.
- [x] Update current handoff, status and material playback notes. Inspect source, unchanged media hashes/project resources, static segment data and English UI text. Complete one fresh-context code review, fix important findings and document the runtime verification boundary.
