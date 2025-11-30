# FloatingDock

A floating dock with magnification effect and hover tooltips. Features smooth animations and a frosted glass aesthetic.

## Preview

@{WidgetPreview:navigations/floating_dock}

## Features

- Hover magnification effect
- Tooltip labels on hover
- Frosted glass background
- Smooth animations
- Customizable items

## Installation

1. Create: `lib/widgets/navigations/floating_dock.dart`
2. Copy the source code
3. Use in your app

## Usage

```dart
import 'package:flutter/material.dart';
import 'widgets/navigations/floating_dock.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FloatingDock(
          items: [
            FloatingDockItem(
              icon: Icon(Icons.home),
              title: 'Home',
              onTap: () => print('Home'),
            ),
            FloatingDockItem(
              icon: Icon(Icons.mail),
              title: 'Mail',
              onTap: () => print('Mail'),
            ),
            FloatingDockItem(
              icon: Icon(Icons.folder),
              title: 'Files',
              onTap: () => print('Files'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## FloatingDockItem

Data class for dock items.

| Property | Type | Description |
|----------|------|-------------|
| `icon` | `Widget` | The icon to display |
| `title` | `String` | Tooltip text shown on hover |
| `onTap` | `VoidCallback?` | Callback when item is tapped |

## Styling Tips

- Use consistent icon colors for a cohesive look
- Keep titles short and descriptive
- Limit to 5-7 items for best UX
- Position at the bottom center for familiarity

## Source Code

@{WidgetCode:navigations/floating_dock}

## Related Widgets

- [Dock](/docs/navigations/dock)
