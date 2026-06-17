# Implementation Details

All code lives in `MiniPlayerSwiftUI/ContentView.swift`. The root `ContentView` selects one of three implementations at runtime using `#available` checks.

---

## iOS 26+

**Entry point:** `ContentView.body` - `if #available(iOS 26, *)`

**Key API:** `tabViewBottomAccessory` - a native modifier introduced in iOS 26 that places a floating accessory view directly above the tab bar, managed entirely by the system. No manual offset or overlay math needed.

**Views used:**
- `MiniPlayerView` - the compact bar shown in the accessory slot
- `ExpandedPlayerView` - the full-screen sheet
- `TrackInfoView` - shared album art + title/artist row

**Expand/collapse flow:**
1. `@State private var expandMiniPlayer` in `ContentView` controls the sheet
2. `miniPlayerBar` computed property wraps `MiniPlayerView` with `.matchedTransitionSource(id:in:)` and an `onTapGesture` that toggles `expandMiniPlayer`
3. `.fullScreenCover(isPresented: $expandMiniPlayer)` presents `ExpandedPlayerView`
4. `.navigationTransition(.zoom(sourceID: "MINIPLAYER", in: animation))` on the cover produces the zoom-from-source animation matching the mini player bar position

**Tab structure:**
Uses the iOS 18 `Tab` struct API (required for `tabViewBottomAccessory` to work correctly):

```swift
TabView {
    Tab("Home", systemImage: "house.fill") { HomeView() }
    Tab("Search", systemImage: "magnifyingglass", role: .search) { SearchView() }
    Tab("Settings", systemImage: "gearshape.fill") { SettingsView() }
}
.tabViewBottomAccessory { miniPlayerBar }
```

**`@Namespace`:** `animation` is declared in `ContentView` and shared between `matchedTransitionSource` (on the mini bar) and `navigationTransition(.zoom)` (on the cover) to link the two views for the zoom transition.

---

## iOS 18-25

**Entry point:** `ContentView.body` - `else if #available(iOS 18, *)`

**Approach:** `tabViewBottomAccessory` does not exist on iOS 18-25, so the mini player is manually positioned using `.overlay(alignment: .bottom)` on the `TabView`. The player bar floats as a pill-shaped `ultraThinMaterial` rounded rectangle above the tab bar.

**Layout:**
```swift
tabs
    .overlay(alignment: .bottom) {
        miniPlayerBar
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 15, style: .continuous))
            .offset(y: -60)        // clears the tab bar height (~49pt) + safe area bottom
            .padding(.horizontal, 15)
            .ignoresSafeArea(.keyboard, edges: .all)
    }
```

The `-60` offset is a fixed approximation to clear the tab bar. In a production app this would read the actual tab bar height from a `GeometryReader` or environment value.

**Expand/collapse flow:** Identical to iOS 26 - `matchedTransitionSource` + `navigationTransition(.zoom)` + `fullScreenCover`. Both iOS 18 and iOS 26 share `MiniPlayerView`, `ExpandedPlayerView`, and `miniPlayerBar`.

**Tab structure:** Same `Tab` struct API as iOS 26 (available since iOS 18). The `tabs` computed property is marked `@available(iOS 18, *)` and `miniPlayerBar` is also marked `@available(iOS 18, *)` since both use APIs that don't exist before iOS 18.

---

## iOS 16-17 (Legacy)

**Entry point:** `ContentView.body` - `else` branch, renders `LegacyTabContainer`

**Approach:** No system-managed accessory slot and no zoom transition API. The player is a full-width overlay at the bottom of a `ZStack` that animates between a compact bar (80 pt tall) and full screen, driven entirely by a single `@State var expand: Bool`.

### Structure

```
LegacyTabContainer
  ZStack(alignment: .bottom)
    TabView(selection: $current)          ← old .tabItem API
    LegacyMiniplayer(animation:expand:)   ← sits on top
```

`LegacyTabContainer` owns `@State var expand`, `@State var current`, and `@Namespace var animation`. It passes the namespace and a `$expand` binding down to `LegacyMiniplayer`.

### LegacyMiniplayer layout

The entire player (compact bar + expanded content) is one `VStack` whose `maxHeight` switches between `80` and `.infinity`:

```swift
.frame(maxHeight: expand ? .infinity : 80)
.offset(y: expand ? 0 : -48)   // -48 tucks the bar above the tab bar
```

Collapsed state shows: album art thumbnail + title text + play/forward buttons.
Expanded state shows: large album art, title, LIVE indicator, stop button, volume slider, action buttons.

The title `Text` carries `matchedGeometryEffect(id: "Label", in: animation)` in both conditional branches - collapsed (`if !expand`) and expanded (`if expand`) - so SwiftUI animates it moving between its two positions during the expand/collapse transition.

### Background and tap

The background is a `VStack` containing `BlurView` (a `UIViewRepresentable` wrapping `UIVisualEffectView`) and a `Divider`. The tap-to-expand gesture lives on this background, not on the foreground content:

```swift
.background(
    VStack(spacing: 0) {
        BlurView()
        Divider()
    }
    .onTapGesture {
        withAnimation(.spring()) { expand = true }
    }
)
```

The outer view carries a plain `DragGesture` (not `simultaneousGesture`). This creates a natural priority split: a quick tap (translation < 10 pt, below `DragGesture`'s minimum distance) fails the drag recognizer and falls through to the background's `onTapGesture`. A real drag succeeds the drag recognizer and the background tap never fires.

### Drag-to-dismiss

```swift
.gesture(DragGesture().onEnded(onEnded(value:)).onChanged(onChanged(value:)))
```

`onChanged` only moves the view when already expanded and the drag is downward (`translation.height > 0`). `onEnded` collapses the player if the drag distance exceeded `height` (1/3 of screen height), otherwise snaps back to zero offset.

```swift
func onChanged(value: DragGesture.Value) {
    if value.translation.height > 0 && expand {
        offset = value.translation.height
    }
}

func onEnded(value: DragGesture.Value) {
    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.95)) {
        if value.translation.height > height { expand = false }
        offset = 0
    }
}
```

### BlurView

`UIViewRepresentable` bridging `UIVisualEffectView` with `UIBlurEffect(style: .systemChromeMaterial)`. This gives the frosted-glass look that `.ultraThinMaterial` cannot reproduce identically on older iOS where SwiftUI's material rendering is less capable.

### Safe area

```swift
var height = UIScreen.main.bounds.height / 3
var safeArea = UIApplication.shared.windows.first?.safeAreaInsets
```

`safeArea` is `UIEdgeInsets?`. It is used to pad the drag indicator from the status bar when expanded (`.padding(.top, expand ? safeArea?.top : 0)`) and to pad the bottom action buttons (`.padding(.bottom, safeArea?.bottom == 0 ? 15 : safeArea?.bottom)`).

---

## Shared Views

| View | Used by |
|---|---|
| `TrackInfoView` | iOS 18+: `MiniPlayerView`, `ExpandedPlayerView` |
| `MiniPlayerView` | iOS 18+: compact bar in accessory slot or overlay pill |
| `ExpandedPlayerView` | iOS 18+: full-screen cover |
| `BlurView` | Legacy only: background of `LegacyMiniplayer` |
| `LegacyMiniplayer` | Legacy only |
| `LegacyTabContainer` | Legacy only |
| `HomeView`, `SearchView`, `SettingsView` | All three paths |
