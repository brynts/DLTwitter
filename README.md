# DLTwitter (Open-Source Reconstruction)

This repository reconstructs tweak source from the shipped `DLTwitter.dylib` so it can be audited, improved, and shared.

This project it shows that a tweak can be documented and opened for collaboration even if the original was distributed in binary/protected form. This README avoids reverse‑engineering details and focuses on high‑level behavior, usage, and hooks.

> Note: This build may be buggy. I do not have a valid certificate for my non‑jailbroken test device, so I cannot fully validate behavior on hardware.

## Requirements

- Theos
- iOS SDK installed under `$(THEOS)/sdks` (dont ever creat new tweak bedsidess in this sh*t theos)
- clang toolchain compatible with your Theos setup

## Build

Use the helper script:

```
./build.sh
```

Defaults:
- `THEOS=/Users/*/theos`
- `SDKROOT=/Users/*/theos/sdks/iPhoneOS26.2.sdk`
- package scheme: `deb`

Examples:

```
./build.sh deb --no-clean
THEOS=/path/to/theos SDKROOT=/path/to/sdk ./build.sh
./build.sh none
```

If you prefer raw Theos:

```
make package THEOS_PACKAGE_SCHEME=deb
```

Bundle resources are staged at:

```
layout/Library/Application Support/DLTwitter.bundle
```

## Install / Test

- Install the generated `.deb` from `packages/` on your device.
- Ensure `DLTwitter.bundle` is installed at `/Library/Application Support/` (or `/var/jb/Library/Application Support/` for rootless).

## Settings UI (User Facing)

- Download: Always download in highest quality
- Media: Share media, no repeat for videos, disable scrolling to next video
- Popup Alert: Confirm follow, confirm like/unlike
- Direct Messages: Disable typing indicator, enable voice message
- Browser: Open links in Safari, browse accounts that blocked you
- Generic: Enable voice tweet, remove promo ads, enable tip jar, copy profile info, always show “Translate Tweet”
- App Lock: Enable
- OpenSource POC: ZeroDeadBeef, Support account etc
- Special Thanks Again: ZeroDeadBeef

## Feature Tree (High Level)

Download & Media
- Download button overlay on media cards
- Download button in inline playback controls
- Long‑press download menu (explore cards + multi‑media slideshow)
- Highest quality selection via video variants
- Share media toggle

Video UX
- Disable looping
- Disable autoplay/next video in immersive explore
- Optional legacy video UI (internal flag)

Safety & UX
- Confirm follow
- Confirm like/unlike
- Open external links in Safari

Social / Profile
- Tip jar enabled
- Copy profile info
- Always show Translate Tweet button
- Browse accounts that blocked you

Messages
- Disable typing indicator in DMs
- Enable voice message in DMs

App Security
- App Lock (blur + local authentication)

## Hook Map (Twitter/X classes)

Below is the exact class-level hook map used in this project:

Settings & Navigation
- `T1AppSplitHostView` → `initWithFrame:hostedView:hasDivider:` (inject settings button in sidebar)

Download & Media
- `T1StatusPhotoVideoForwardView` → `layoutSubviews` (overlay download button)
- `T1ImmersiveExploreCardView` → `layoutSubviews` (overlay button + long‑press)
- `T1TwitterSwift.ImmersiveInlinePlaybackButtonsStackView` → `didMoveToSuperview` (inline playback button)
- `T1TwitterSwift.ImmersiveExploreCardView` → `presentShareSheet:` (download menu entry)
- `T1SlideshowViewController` → `slideshowSeekController:didLongPressWithRecognizer:` (multi‑media long‑press)

Video UX
- `TAVPlaylistItem` → `prefersLooping` (disable looping)
- `T1ImmersiveExploreViewController` → `viewDidLoad`, `handleVerticalPan:` (disable autoplay/next)
- `TPSTwitterFeatureSwitches` → `boolForKey:` (legacy video UI + ads + voice features)

Safety & UX
- `T1FollowControl` → `_followUser:event:` (confirm follow)
- `TUIFollowControl` → `_followUser:event:` (confirm follow)
- `TFNTwitterAccount` → `favoriteStatus:responseBlock:` (confirm like)
- `TFNTwitterAccount` → `unfavoriteStatus:responseBlock:` (confirm unlike)
- `T1SafariViewController` → `initWithRootURL:account:sourceStatus:entersReaderIfAvailable:scribeComponent:scribeParameters:` (open external links in Safari)
- `T1StandardStatusBodyViewAdapter` → `bodyTextView:didTapActiveTextRange:` (open links)

App Lock
- `T1AppDelegate` → `applicationDidBecomeActive:`
- `T1AppDelegate` → `applicationWillResignActive:`
- `T1AppDelegate` → `applicationWillTerminate:`

Profiles & Blocks
- `T1ProfileUserViewModel` → `blockingViewerRelationshipState` (track blocked state)
- `T1ProfileUserViewModel` → `username` (capture handle)
- `T1LegacyEmptyProfileInterstitialViewController` → `initWithEmptyContentMessage:style:` (blocked‑user button)
- `TFNEmptyStateViewController` → `initWithConfiguration:` (blocked‑user button)
- `T1ProfileActionButtonsView` → `layoutSubviews`, `initWithFrame:` (copy profile info button)

Translate & Ads
- `TFNTwitterStatus` → `isTranslatable` (always show translate)
- `TFNTwitterStatus` → `isCardHidden` (hide promoted cards)
- `TFNItemsDataViewAdapterRegistry` → `dataViewAdapterForItem:` (filter promoted items)
- `TFNItemsDataViewController` → `tableViewCellForItem:atIndexPath:`
- `TFNItemsDataViewController` → `tableView:heightForRowAtIndexPath:`
- `TFNItemsDataViewController` → `tableView:heightForHeaderInSection:`

## Internal Flags (No UI in the original dylib)

These keys exist in the dylib and are wired into the implementation but are not exposed in the visible settings screen:

- `DL_EnableOldVideoInterface` (legacy video UI)
- `DL_ProtectWithFaceId` (biometric unlock)
- `DL_DelayAppLock` (delay in seconds)
- `DL_faceIdSaveDate` (last unlock timestamp)

If you need them, set via `NSUserDefaults` or add your own UI toggles.

## Hidden Debugging

- Tap the **DLTwitter** title **10 times** in the header.
- Enter the passcode: `-<day>` where `<day>` is today’s day‑of‑month.
  - Example: on **January 27, 2026**, the passcode is `-27`.

## Assets

The dylib contains only the asset names (for example, `icon.png`, `twitter.png`, `Heart.png`, `download_40pt`), not the PNG data. If you have the original bundle, drop the images into:  

```
layout/Library/Application Support/DLTwitter.bundle
```

## Notes

- This is a best‑effort, source‑level reconstruction based on the dylib.
- The tweak is defensive around selector availability to reduce crashes across Twitter/X versions.
- Some features rely on runtime heuristics to locate media URLs in the host app.
- Some server‑side checks were removed, and the dylib size was reduced from ~10MB to ~1MB in this open‑source build.
- This is a PoC for open‑sourcing tweaks. Join the Telegram channel: https://t.me/ZeroxDeadBeef
