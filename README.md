# MiniPlayer SwiftUI

An Apple Music-style mini player for iOS 16+, implemented in SwiftUI with three-way version branching.

## Features

- Tap the mini player bar to expand to full screen
- Drag down to dismiss the expanded player
- Tab bar with Home, Search, and Settings tabs
- Blur background on the collapsed mini player

## Version Branching

| iOS Version | Implementation |
|---|---|
| iOS 26+ | `tabViewBottomAccessory` - native floating accessory above the tab bar |
| iOS 18-25 | `.overlay` with `ultraThinMaterial` pill + `fullScreenCover` with zoom transition |
| iOS 16-17 | `ZStack` + `DragGesture` + `BlurView` overlay |

## Requirements

- iOS 16+
- Xcode 16+
- Swift 5.9+
