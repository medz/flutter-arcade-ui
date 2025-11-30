# FlickeringGrid

A mesmerizing animated grid background with randomly flickering cells. Perfect for creating eye-catching hero sections or dynamic backgrounds.

## Preview

@{WidgetPreview:backgrounds/flickering_grid}

## Features

- Customizable grid color
- Smooth flickering animation
- Responsive grid sizing
- Child widget support
- Zero dependencies

## Installation

Simply copy the widget code into your project:

1. Create a new file: `lib/widgets/backgrounds/flickering_grid.dart`
2. Copy the source code (see below)
3. Import and use in your app

## Usage

```dart
import 'package:flutter/material.dart';
import 'widgets/backgrounds/flickering_grid.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlickeringGrid(
      color: Colors.green,
      child: Center(
        child: Text(
          'Welcome to Arcade UI',
          style: TextStyle(fontSize: 48, color: Colors.white),
        ),
      ),
    );
  }
}
```

## Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `color` | `Color` | The color of the grid lines and flickering effect | Required |
| `child` | `Widget?` | Child widget to display over the grid | `null` |
| `gridSize` | `double` | Size of each grid cell | `40.0` |
| `flickerDuration` | `Duration` | Duration for each flicker animation | `800ms` |

## Customization Examples

### Larger Grid Cells

```dart
FlickeringGrid(
  color: Colors.blue,
  gridSize: 60.0,
  child: YourContent(),
)
```

### Faster Animation

```dart
FlickeringGrid(
  color: Colors.purple,
  flickerDuration: Duration(milliseconds: 400),
  child: YourContent(),
)
```

## Source Code

@{WidgetCode:backgrounds/flickering_grid}

## Related Widgets

- [BlackHoleBackground](/docs/backgrounds/black-hole-background)
- [FloatingDock](/docs/navigations/floating-dock)
