# Welcome, one-tap entry and User Agreement

## Current flow

- A new process starts at Welcome after the existing library load succeeds. `Get started` opens sign-in; `Back` returns to Welcome. Returning from the background retains the current page.
- No email, password, phone number, carrier integration or Apple sign-in is used. `One-tap sign in` is entry to the existing device library, not verified authentication.
- The checkbox begins unchecked on each sign-in page. The entry button is disabled until explicitly checked; opening/closing the agreement does not change it. No browse bypass remains.
- Entry saves the agreement version and current acceptance time via the existing atomic repository transaction. A failure leaves the sign-in screen open with an inline error and allows retry.
- The optional `agreementAcceptance` field preserves schema version 1 compatibility. No profile, media, chat, safety or collection records are reset. The record contains no credential and is not a server audit record.
- Each cold launch repeats Welcome → sign-in as requested. The saved receipt does not automatically bypass entry or check the checkbox.

## Source map

- `Teto/App/AppRootView.swift`: startup steps.
- `Teto/App/AppStore.swift`: atomic consent write.
- `Teto/Domain/LocalLibrary.swift`: optional stored acceptance.
- `Teto/Features/Authentication/WelcomeView.swift`: dance artwork and welcome action.
- `Teto/Features/Authentication/SignInView.swift`: one-tap entry and checkbox/link.
- `Teto/Features/Authentication/UserAgreement.swift`: single English text, version/date and acceptance model.
- `Teto/Features/Authentication/UserAgreementView.swift`: scrollable, selectable agreement content.
- `Teto/Features/Profile/ProfileSettingsView.swift`: User Agreement, acceptance time, blocked creators and About.
- `Teto/Features/Profile/ProfileView.swift`: settings entry and current capability copy.

## Agreement content

Original English terms cover dance community conduct, content ownership and permissions, physical safety, actual feature boundaries, local data and Photos selection, reporting/blocking, sharing, purchases, removal, availability and revisions. No operator identity, contact address, arbitration venue, payment service, moderation team or legal review is invented. Before public distribution, the actual provider must supply its identity/contact and review terms and privacy disclosures against the delivered product and applicable jurisdiction.

Apple's [standard EULA](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/) was consulted for context on license and external-service topics. The in-app text is original and does not copy Apple's provider-specific legal terms or claim to replace platform agreements.

## Static review and unverified behavior

UI copy is English, original dance artwork is reused, scroll views accommodate smaller screens and large type, touch controls have 44pt minimum targets, and the agreement and settings use native navigation/sheets. No automatic entrance animation or automatic agreement acceptance is used.

Only source/resource inspection and project metadata checks are authorized. No compilation, typecheck, app execution, simulator, Preview or tests were performed. Small-screen rendering, largest Dynamic Type, VoiceOver, persistence failure/retry and old-library decoding still require device/runtime verification.
