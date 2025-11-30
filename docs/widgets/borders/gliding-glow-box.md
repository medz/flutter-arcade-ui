## Preview

@{WidgetPreview:borders/gliding_glow_box}

## Features

- Smooth gliding animation
- Customizable glow color
- Top and bottom edge glow spots
- Works with any child widget
- Canvas-based rendering

## Installation

1. Create: `lib/widgets/borders/gliding_glow_box.dart`
2. Copy the source code
3. Use in your app

## Usage

```dart
import 'package:flutter/material.dart';
import 'widgets/borders/gliding_glow_box.dart';

class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlidingGlowBox(
      color: Colors.purple,
      child: ElevatedButton(
        onPressed: () {},
        child: Text('Click Me'),
      ),
    );
  }
}
```

## Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `color` | `Color` | Color of the glowing spots | Required |
| `child` | `Widget?` | Child widget to wrap | `null` |
| `speed` | `double` | Animation speed multiplier | `1.0` |

## Use Cases

- Accent highlighted buttons
- Premium feature cards
- Interactive form fields
- Call-to-action elements
- Portfolio showcase items

## Source Code

@{WidgetCode:borders/gliding_glow_box}
