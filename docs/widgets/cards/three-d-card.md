# ThreeDCard

An interactive card with 3D tilt effect that follows mouse/pointer movement, creating depth and visual interest.

## Preview

@{WidgetPreview:cards/three_d_card}

## Features

- Mouse/pointer tracking
- 3D perspective transform
- Smooth tilt animation
- Customizable hover decoration
- Shadow effects

## Installation

1. Create: `lib/widgets/cards/three_d_card.dart`  
2. Copy the source code
3. Use in your app

## Usage

```dart
import 'package:flutter/material.dart';
import 'widgets/cards/three_d_card.dart';

class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThreeDCard(
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Your card content
          ],
        ),
      ),
    );
  }
}
```

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `child` | `Widget` | The card content |
| `decoration` | `BoxDecoration?` | Base decoration |
| `hoverDecoration` | `BoxDecoration?` | Decoration when hovering |

## Tips

- Works best with cards 200-500px in size
- Combine with shadows for enhanced depth
- Great for product showcases
- Use subtle tilt for professional look

## Source Code

@{WidgetCode:cards/three_d_card}

## Related Widgets

- [GlidingGlowBox](/docs/borders/gliding-glow-box)
