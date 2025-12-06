Bright, pill-shaped Motion Tabs with a color backdrop. A translucent wash sits behind every item and collapses to the hovered tab while the selected tab keeps its own solid background.

## Preview

@{WidgetPreview:navigations/motion_tabs}

## Features

- Colored base with a soft translucent overlay that stretches across every tab
- Hovering collapses the overlay to the hovered tab; leaving expands it again
- Selected tab keeps a solid background and contrasting label color
- Customizable spacing, sizing, timing, and colors
- Optional icons next to labels

## Properties

### MotionTabs

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `items` | `List<MotionTabItem>` | *required* | Tabs to display |
| `initialIndex` | `int` | `0` | Starting selected tab |
| `onChanged` | `ValueChanged<int>?` | `null` | Called when selection changes |
| `backgroundColor` | `Color` | `Color(0xFF2F4BFF)` | Base background color |
| `overlayColor` | `Color` | `Color(0x24FFFFFF)` | Color for the translucent overlay |
| `selectedColor` | `Color` | `Colors.white` | Background for the selected tab |
| `textColor` | `Color` | `Colors.white` | Label color for unselected tabs |
| `selectedTextColor` | `Color` | `Color(0xFF1C1F3E)` | Label color for the selected tab |
| `height` | `double` | `56` | Overall height of the tab set |
| `borderRadius` | `double` | `18` | Corner radius for the container and tabs |
| `padding` | `EdgeInsets` | `EdgeInsets.symmetric(horizontal: 12, vertical: 10)` | Inner padding around the row |
| `gap` | `double` | `8` | Space between tabs |
| `animationDuration` | `Duration` | `220ms` | Duration for hover and selection transitions |
| `animationCurve` | `Curve` | `Curves.easeOutCubic` | Curve for hover and selection transitions |

### MotionTabItem

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `label` | `String` | *required* | Tab label |
| `icon` | `Widget?` | `null` | Optional leading icon |
| `onTap` | `VoidCallback?` | `null` | Called when this tab is tapped |

## Usage

```dart
import 'widgets/navigations/motion_tabs.dart';

MotionTabs(
  items: const [
    MotionTabItem(label: 'Overview'),
    MotionTabItem(label: 'Design'),
    MotionTabItem(label: 'Develop'),
  ],
  onChanged: (index) {
    // react to selection
  },
)
```

## Examples

### Custom Colors

```dart
MotionTabs(
  backgroundColor: const Color(0xFF00BFA6),
  overlayColor: const Color(0x22FFFFFF),
  selectedColor: const Color(0xFF07211E),
  selectedTextColor: const Color(0xFF7FF4DC),
  gap: 12,
  borderRadius: 20,
  items: const [
    MotionTabItem(label: 'Dashboard', icon: Icon(Icons.dashboard)),
    MotionTabItem(label: 'Reports', icon: Icon(Icons.auto_graph)),
    MotionTabItem(label: 'Automation', icon: Icon(Icons.memory)),
  ],
)
```

### With Callbacks

```dart
MotionTabs(
  items: [
    MotionTabItem(
      label: 'Inbox',
      icon: const Icon(Icons.inbox_rounded),
      onTap: () => debugPrint('Inbox pressed'),
    ),
    MotionTabItem(
      label: 'Mentions',
      icon: const Icon(Icons.alternate_email_rounded),
    ),
  ],
  onChanged: (index) => debugPrint('Selected $index'),
)
```

## Tips

- Keep labels short so the hover overlay aligns cleanly
- If the container is very narrow, reduce `gap` to avoid squashed tabs
- Pair `selectedColor` and `selectedTextColor` for strong contrast
- Wrap with `ConstrainedBox` to control max width in wide layouts

## Source Code

@{WidgetCode:navigations/motion_tabs}
