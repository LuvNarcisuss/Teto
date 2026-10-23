# Startup black screen after UIKit migration

The existing iPhone 17 Pro simulator's KnownSceneSessions archive still named `SwiftUI.AppSceneDelegate`; its restored content referenced `teto.AppRootView-1`. The installed and source Info.plist only declared single-scene support, without an explicit UIKit scene configuration. The existing Xcode launch record indicated a successful launch followed by debugger termination; it did not establish that a UIKit window was shown.

Added the named Teto scene configuration with `UIWindowScene` and `$(PRODUCT_MODULE_NAME).TetoSceneDelegate`. The programmatic configuration uses the same scene and delegate classes, and the window gets explicit scene bounds and a background color.

The identified simulator's obsolete Saved Application State directory was backed up to `/private/tmp/teto-obsolete-scene-state-20261020` and removed. No Application Support library, conversations, interactions, media, preferences, or account data were deleted. No simulator was started and no app was launched, built or tested. The user must stop their existing Xcode session and run the updated target to verify. Other previously installed devices may retain their own old scene restoration records; those were not accessed or changed.
