# Chat voice and video screens

## Entry and appearance

Both `ChatConversationView` (person/group conversations, excluding activity) and `CreatorConversationView` offer phone/video toolbar buttons. Opening either screen dismisses the keyboard and presents a full-screen cover; the original conversation and unsaved composer remain in place. End and the top-left back button close only the call screen. Blocked creators cannot open calls from their private conversation.

Voice uses a warm gray/teal blurred-color background, the conversation's round avatar and name, and bottom Microphone / End / Speaker rounded-square controls. Video fills the background with the device camera, has soft top/bottom gradients, matching bottom controls and a top-right Flip camera button. Buttons stay inside real iOS safe areas; system status and Home Indicator remain native. The layout scrolls its central content on short screens, with a smaller voice avatar in landscape. All app-authored strings are English; screenshots are reference-only and are not bundled.

## Actual capability

- `ChatCallView.swift`: shared call UI and explicit `Not connected` status. No outgoing call is placed, no person is contacted, no connected state/duration/receipt is fabricated. Microphone and speaker buttons are local visual choices, not audio routing or recording. No CallKit, microphone access, AVAudioSession setup or call transport is used.
- `CallCameraController.swift`: stable state object with separate serial capture worker, front-facing default and front/back switching. Video input only; no file output or network upload. Permission callbacks use a generation token so leaving/backgrounding invalidates pending starts. Start/stop/configuration run on the serial queue; view state is updated on MainActor.
- `CallCameraView.swift`: AVCaptureVideoPreviewLayer with aspect-fill, front mirroring and interface-orientation rotation. Layer detaches on removal.
- Inactive/exit stops the capture session and removes inputs; active foreground restarts only while this video screen is visible. Permission denied/restricted, absent camera, runtime failure and interruption have English states. Denial offers Settings; errors/interruption offer retry. Interrupted sessions can resume when the interruption ends.
- `Info.plist`: NSCameraUsageDescription added. Permission is requested only on opening video, never opening voice or the chat itself. No NSMicrophoneUsageDescription is needed or added.
- About and User Agreement are updated to describe local camera use; agreement version is 1.1, dated October 20, 2026. Previous stored consent receipts are retained until the next explicit acceptance.

## Sources and files

Reference originals: `Design/References/Calls/voice-original.jpg` and `video-original.jpg`. Existing conversation avatar assets and creator covers are reused. No new online assets or media were downloaded.

Implementation references: Apple's [startRunning documentation](https://developer.apple.com/documentation/avfoundation/avcapturesession/startrunning%28%29) describes its blocking behavior, and [camera authorization documentation](https://developer.apple.com/documentation/avfoundation/avcapturedevice/requestaccess%28for%3Acompletionhandler%3A%29) describes the permission request and required usage-description key.

Modified integration: `Features/Chats/ChatConversationView.swift`, `Features/Creators/CreatorProfileView.swift`, `Features/Profile/ProfileView.swift`, `Features/Authentication/UserAgreement.swift`, `Support/Info.plist`, and generated Xcode project metadata.

## Verification boundary

Source/resource checks and Xcode project metadata validation only. No compiler, typecheck, app execution, simulator, Preview or tests were run. Device camera authorization, switching, portrait/landscape rotation, interruption/resume, rapid open/close, return with unsaved drafts, VoiceOver and large-type layout remain runtime verification items. Neither screenshot matching nor physical camera behavior is claimed as runtime-verified.
