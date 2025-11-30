# Dock

A macOS-style dock with magnifying icon effect on hover. Icons scale up smoothly when the cursor approaches, creating an iconic interaction pattern.

## Preview

@{WidgetPreview:navigations/dock}

## Features

- Smooth magnification effect on hover
- Customizable icon scale
- Support for separators
- Responsive to cursor position
- Native Flutter implementation

## Installation

Copy the widget code:

1. Create: `lib/widgets/navigations/dock.dart`
2. Copy the source code
3. Import and use

## Usage

```dart
import 'package:flutter/material.dart';
import 'widgets/navigations/dock.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Dock(
          items: [
            DockIcon(
              child: Icon(Icons.home, color: Colors.white),
              onTap: () => print('Home tapped'),
            ),
            DockIcon(
              child: Icon(Icons.search, color: Colors.white),
              onTap: () => print('Search tapped'),
            ),
            DockSeparator(),
            DockIcon(
              child: Icon(Icons.settings, color: Colors.white),
              onTap: () => print('Settings tapped'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Components

### Dock

Main container for dock items.

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `items` | `List<Widget>` | List of DockIcon and DockSeparator widgets | Required |
| `itemScale` | `double` | Maximum scale factor for magnification | `1.5` |

### DockIcon

Individual icon item in the dock.

| Property | Type | Description |
|----------|------|-------------|
| `child` | `Widget` | The icon or content to display |
| `onTap` | `VoidCallback?` | Callback when icon is tapped |

### DockSeparator

Visual separator between dock icon groups.

## Customization

### Custom Icon Designs

```dart
DockIcon(
  child: Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(Icons.apps, color: Colors.white),
  ),
  onTap: () {},
)
```

### Larger Magnification

```dart
Dock(
  itemScale: 2.0,
  items: [...],
)
```

## Source Code

@{WidgetCode:navigations/dock}

## Related Widgets

- [FloatingDock](/docs/navigations/floating-dock)
