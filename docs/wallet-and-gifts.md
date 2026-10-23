# Teto wallet and live gifts

## Bundle identity update (2026-10-23)

The project now uses `com.teto.dance`, replacing `im.seex.sao2-neiku-30`. Existing product IDs are retained; product availability for the new App Store app has not been verified. Signing profiles and App Store Connect products must match the new bundle identity. No Apple Developer or App Store Connect configuration was changed. Local data is not migrated across bundle identifiers.

## Current purchase behavior (2026-10-22)

Diamond purchases use StoreKit 1 (`SKProductsRequest`, `SKPaymentQueue`, and `SKPayment`). The wallet shows the store's localized price after it loads, or See price until then. A purchase waits for that product request. The payment sheet opens only after StoreKit returns the package. The confirmation does not present the catalog USD amount as the charge. Diamonds are written to `Application Support/Teto/wallet-v1.json` only for a purchased or restored transaction whose product ID is one of the nine packages below, and only once per transaction ID. `finishTransaction` runs after that save. Payments that are canceled, unavailable, or otherwise unsuccessful say that the user has not been charged. Ask to Buy stays unfinished and does not add diamonds. There is no restore control. Signing out does not clear the ledger. Deleting the account removes the wallet file with the Teto library directory. A gift with a high enough balance spends diamonds on this device, writes a gift line in the wallet, and plays on the full-screen film. It does not claim that a remote person received the diamonds. A short balance leaves the balance unchanged. Xcode Run uses `Teto/Resources/TetoDiamonds.storekit` for these seven consumables. The configured bundle identifier is `com.teto.dance`. The service-boundary paragraph later in this file is superseded by this section.

## Brand and data preservation

App display name, welcome/sign-in, profile/About, party heading, authored activity sender, shares, camera permission and agreement copy now say Teto. The current icon has no written brand and is retained. Swift type names, source directory, Xcode target/scheme `teto`, and the Application Support/Teto library path stay as they are. The configured bundle identifier is `com.teto.dance`. Existing private profiles, media, follows, chats, reports and consent records are not rewritten or reset. Historical docs retain their original brand context.

## Wallet flow

Me > Wallet opens a Fresh Studio light page with a diamond balance card, a recharge grid, purchase confirmation and transaction history. On-screen USD prices in this paragraph are superseded by the current purchase behavior section: the screen uses the StoreKit price, or See price. Diamonds are the only virtual currency; there is no currency selector or coin balance. Diamond artwork uses mint/evergreen gradients. The original seven store package IDs, diamond amounts, and reference prices are unchanged. Two packs complete the grid: 16,800 diamonds at $29.99 and 42,600 diamonds at $69.99. No wallet data was persisted before the first ledger, so no balance migration is needed.

| USD | Diamonds | Product ID | Source |
| --- | ---: | --- | --- |
| $0.99 | 400 | `hoewtkchclzkuruf` | Purchase catalog |
| $1.99 | 800 | `qbfuucwaccetjljs` | Purchase catalog |
| $4.99 | 2,450 | `mdnrsibqccschjcg` | Purchase catalog |
| $9.99 | 5,150 | `olfouxazhsdntxzs` | Purchase catalog |
| $19.99 | 10,800 | `ejtvapyfnomaimlf` | Purchase catalog |
| $29.99 | 16,800 | `mwkqplvxbtdrjcsn` | Added pack |
| $49.99 | 29,400 | `uficsdpshzadegnz` | Purchase catalog |
| $69.99 | 42,600 | `hycnfrwzqmkplvtd` | Added pack |
| $99.99 | 63,700 | `cbhpozbwbvfwgqxp` | Purchase catalog |

Each package uses the store product ID from the purchase catalog. The earlier proposed IDs `qlrpflukqugckska` and `zhkxxppfqwqfwhcp` stay retired. The $29.99 and $69.99 packs use the new IDs in the table. The listed USD amounts are reference catalog values, not prices retrieved from Apple's storefront.

The original tier screenshot is retained outside the target at `Design/References/Wallet/tiers-original.png`. Bank/account information from the provided screenshot is not needed for product mapping and is not included in the app configuration.

## Live gift flow

Live > Gifts shows diamond balance, Recharge shortcut, nine gift tiles, quantity 1–99, computed total and Send confirmation. It opens at the large sheet size. Opening the wallet from this sheet retains the selected gift and quantity; closing the wallet returns to gift selection. The stream's existing sheet-aware playback lifecycle remains in control.

| Gift | Diamonds each |
| --- | ---: |
| Rose | 10 |
| Balloons | 50 |
| Heart | 100 |
| Beat Drop | 200 |
| Spotlight | 500 |
| Bouquet | 1,000 |
| Dance Crown | 2,000 |
| Encore | 5,000 |
| Dance Galaxy | 10,000 |

Artwork is code-native SwiftUI/SF Symbols with gradients, including a three-flower bouquet; no third-party raster gift assets are required. Currency and gift artwork can be replaced in WalletComponents.swift without changing prices or actions.

## Service boundary

Superseded for purchases by the current purchase behavior section above. The paragraph below describes the earlier unconnected adapter and is kept as history.

`AppStore` owns one `WalletStore` shared by profile and live gifts. Gift sending still does not deduct diamonds or claim delivery. The earlier adapter never started a payment and did not write a balance. That purchase limit no longer applies: diamond purchases now go through StoreKit 1 and the local wallet file.

Real purchases require this app's configured StoreKit products, storefront prices, verified transactions, transaction finishing/recovery and an authoritative consumable ledger. Real gifts also need authenticated recipients, balance validation, atomic debit/delivery and idempotency. These are not connected by this change. Future service implementations must supply verified balances/history; catalog selections are not evidence of a purchase. No real money or financial account is accessed.

User Agreement is now v1.3 (October 20, 2026), with Teto branding and accurate currency/payment capability wording.

## Files

New: `Teto/Features/Wallet/WalletModels.swift`, `WalletStore.swift`, `WalletComponents.swift`, `WalletView.swift`, `LiveGiftSheetView.swift`.

Integration: `App/AppStore.swift`, `Features/Profile/ProfileView.swift`, `Features/LiveRoom/LiveRoomView.swift`, `LiveRoomSheets.swift`, `LiveRoomStore.swift`. Visible-brand updates additionally affect authentication/agreement, AppRootView, profile settings, party views, chat catalog, live/shorts share text, video removal text and Info.plist. Generated project metadata includes the new Swift files.

## Static checks and remaining verification

Reviewed tier values, nine gifts, shared-wallet wiring, empty balance/history, unavailable-service behavior, English copy, visible-brand changes, retained storage identity and project references. No compilation, typecheck, test, simulator, app or SwiftUI Preview execution was performed. Layout at small/large Dynamic Type, live-sheet→wallet→gift navigation and physical-device behavior remain unverified. This does not establish App Store purchase readiness.
