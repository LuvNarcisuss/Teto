# Teto bottom navigation artwork

Four standalone transparent PNG icons generated with the built-in image_gen tool. Exact prompts and original tool output paths are preserved in prompts.json. Originals remain unchanged; app assets are copied into Assets.xcassets/TabLive, TabVoice, TabChats and TabMe imagesets.

Live uses a rhythm/play badge, Voice headphones, Chats overlapping bubbles, and Me a profile badge. All use evergreen, spring lime and ivory. Labels remain Live, Voice, Chats, Me in English.

MainTabView.swift retains the native four-item TabView and its OS-provided enclosure and selection animation. A private TabNavigationArtwork helper caches 30-point original-color UIImages at 3x scale with alpha-preserving aspect-fit drawing. Source PNGs retain full resolution; there are no changes to tab routes, detail visibility rules or safe-area ownership.

Source/asset inspection only. No app run, compilation, simulator, Preview or tests. Actual tab appearance and animation depend on the installed iOS version; device rendering remains unverified.
