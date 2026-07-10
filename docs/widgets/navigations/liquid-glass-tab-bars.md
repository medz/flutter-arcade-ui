Liquid Glass Tab Bars place navigation in a floating functional layer above app content. The component samples the backdrop, adds directional edge highlights, and moves a translucent selection lens between tabs.

This is a Flutter approximation of Apple’s dynamic system material, not a replacement for the native `UITabBar`/`UIGlassEffect` rendering pipeline.

## Preview

@{WidgetPreview:navigations/liquid_glass_tab_bars}

## Features

- Backdrop-aware floating navigation layer
- Directional glass edge and specular highlights
- Translucent selection lens with fluid position and press motion
- Optional detached trailing action group, matching Apple’s current tab/search hierarchy
- Evenly spaced tabs with icon + label
- Optional badges for counts or alerts
- Safe area aware and keyboard-hide support

## Design basis

The component follows Apple’s [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass) guidance: keep glass in the topmost functional layer, let content remain visible beneath it, use color purposefully, and avoid opaque custom bar backgrounds that mask the material.

## Properties

### LiquidGlassTabBars

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `items` | `List<LiquidGlassTabBarItem>` | *required* | Tabs to display |
| `trailingItem` | `LiquidGlassTabBarItem?` | `null` | Optional detached circular action after the main tab group |
| `initialIndex` | `int` | `0` | Starting selected tab |
| `onChanged` | `ValueChanged<int>?` | `null` | Called when selection changes |
| `height` | `double` | `52` | Height of each glass group |
| `iconSize` | `double` | `20` | Icon size |
| `iconLabelSpacing` | `double` | `2` | Spacing between icon and label |
| `labelFontSize` | `double` | `10` | Label font size |
| `padding` | `EdgeInsets` | `EdgeInsets.symmetric(horizontal: 8, vertical: 5)` | Inner padding around the main group |
| `indicatorPadding` | `EdgeInsets` | `EdgeInsets.all(2)` | Lens inset; a negative horizontal value expands the lens beyond one tab |
| `gap` | `double` | `0` | Gap between items |
| `groupGap` | `double` | `10` | Gap before a detached trailing item |
| `borderRadius` | `double` | `26` | Main glass group corner radius |
| `indicatorRadius` | `double` | `24` | Selection lens corner radius |
| `backgroundColor` | `Color` | `Color(0x66FFFFFF)` | Translucent glass tint |
| `borderColor` | `Color` | `Color(0x8CFFFFFF)` | Directional edge highlight color |
| `shadowColor` | `Color` | `Color(0x33000000)` | Outer shadow color |
| `shadowBlur` | `double` | `28` | Outer shadow blur |
| `shadowOffset` | `Offset` | `Offset(0, 14)` | Outer shadow offset |
| `blurSigma` | `double` | `24` | Backdrop blur strength |
| `sheenColor` | `Color` | `Color(0x73FFFFFF)` | Specular highlight color |
| `sheenSecondaryColor` | `Color` | `Color(0x12FFFFFF)` | Secondary reflected-light tint |
| `indicatorColor` | `Color` | `Color(0x30FFFFFF)` | Selection lens tint |
| `indicatorBorderColor` | `Color` | `Color(0xB3FFFFFF)` | Selection lens edge highlight |
| `indicatorShadowColor` | `Color` | `Color(0x24000000)` | Selection lens shadow color |
| `indicatorShadowBlur` | `double` | `16` | Selection lens shadow blur |
| `indicatorShadowOffset` | `Offset` | `Offset(0, 7)` | Selection lens shadow offset |
| `indicatorBlurSigma` | `double` | `14` | Selection lens backdrop blur |
| `selectedColor` | `Color` | `Color(0xFF007AFF)` | Selected icon/label color |
| `unselectedColor` | `Color` | `Color(0xFF8E8E93)` | Unselected icon/label color |
| `useSafeArea` | `bool` | `true` | Adds bottom safe area inset padding |
| `hideOnKeyboard` | `bool` | `true` | Hides the bar when the keyboard appears |
| `animationDuration` | `Duration` | `180ms` | Color/position animation duration |
| `animationCurve` | `Curve` | `Curves.easeOutCubic` | Animation curve |
| `maxItems` | `int` | `5` | Maximum total main and trailing items when enforcement is enabled |
| `enforceMaxItems` | `bool` | `true` | Asserts when item count exceeds `maxItems` |
| `badgeColor` | `Color` | `Color(0xFFFF3B30)` | Badge background color |
| `badgeTextColor` | `Color` | `Colors.white` | Badge text color |
| `badgeTextStyle` | `TextStyle?` | `null` | Overrides badge text style |
| `labelStyle` | `TextStyle?` | `null` | Overrides base label style |
| `selectedLabelStyle` | `TextStyle?` | `null` | Overrides selected label style |

### LiquidGlassTabBarItem

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `label` | `String` | *required* | Tab label |
| `icon` | `Widget` | *required* | Default icon |
| `activeIcon` | `Widget?` | `null` | Icon for selected state |
| `inactiveIcon` | `Widget?` | `null` | Icon for unselected state |
| `badge` | `String?` | `null` | Badge text (number or “!”) |
| `onTap` | `VoidCallback?` | `null` | Called when this tab is tapped |

## Usage

```dart
import 'widgets/navigations/liquid_glass_tab_bars.dart';

LiquidGlassTabBars(
  items: const [
    LiquidGlassTabBarItem(label: 'Home', icon: Icon(Icons.home_rounded)),
    LiquidGlassTabBarItem(label: 'New', icon: Icon(Icons.grid_view_rounded)),
    LiquidGlassTabBarItem(label: 'Library', icon: Icon(Icons.podcasts_rounded)),
  ],
  trailingItem: const LiquidGlassTabBarItem(
    label: 'Search',
    icon: Icon(Icons.search_rounded),
  ),
  onChanged: (index) {
    // react to selection
  },
)
```

## Tips

- Overlay the bar on content with `Stack`/`Positioned`; placing it below an opaque panel prevents the glass from sampling meaningful content
- Keep the main group focused; use `trailingItem` for a distinct parallel action such as search
- Use tint for selected or important actions; keep the remaining content monochrome
- Use `indicatorPadding` to tighten or loosen the selection lens
- Set `useSafeArea: false` if your layout already handles bottom insets

## Source Code

@{WidgetCode:navigations/liquid_glass_tab_bars}
