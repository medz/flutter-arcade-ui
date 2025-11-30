lines, and floating particles. Creates a mesmerizing 3D depth illusion perfect for immersive backgrounds.

## Preview

@{WidgetPreview:backgrounds/black_hole_background}

## Features

- Animated rotating discs
- Radial line patterns
- Floating particle effects
- 3D depth illusion
- Smooth canvas-based rendering
- Customizable colors and speeds

## Installation

Copy the widget code into your project:

1. Create: `lib/widgets/backgrounds/black_hole_background.dart`
2. Copy the source code
3. Import and use in your app

## Usage

```dart
import 'package:flutter/material.dart';
import 'widgets/backgrounds/black_hole_background.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlackHoleBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Into the Void',
              style: TextStyle(fontSize: 48, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `child` | `Widget?` | Child widget to display over the effect | `null` |
| `discCount` | `int` | Number of rotating discs | `8` |
| `lineCount` | `int` | Number of radial lines | `36` |
| `particleCount` | `int` | Number of floating particles | `50` |

## Performance Tips

- Reduce `discCount` and `particleCount` on lower-end devices
- Use sparingly in scrollable views
- Consider disabling when app is in background

## Source Code

@{WidgetCode:backgrounds/black_hole_background}


- [Dock](/docs/navigations/dock)
