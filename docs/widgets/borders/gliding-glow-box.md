A smooth gliding glow ring that orbits the container edges. Perfect for highlighting buttons, cards, or any interactive elements.

## Preview

@{WidgetPreview:borders/gliding_glow_box}

## Features

- Smooth orbiting glow that wraps around the container
- Customizable glow color and intensity
- Adjustable animation speed
- Configurable border width
- Canvas-based rendering with radial gradients
- Zero external dependencies

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | *required* | The child widget to wrap with the glow effect |
| `color` | `Color` | `Color(0xFFE0E0E0)` | Color of the glowing spots |
| `speed` | `Duration` | `6 seconds` | Duration of one complete animation cycle |
| `borderWidth` | `double` | `3.0` | Width of the glow ring |
| `borderRadius` | `double?` | `null` (pill by height) | Corner radius for the glow shape |
| `glowPadding` | `double` | `0` | Extra gap between the glow ring and the child |

## Usage

```dart
import 'widgets/borders/gliding_glow_box.dart';

GlidingGlowBox(
  color: Colors.purple,
  borderRadius: 12,
  glowPadding: 6,
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Click Me'),
  ),
)
```

## Examples

### Fast Purple Glow

```dart
GlidingGlowBox(
  color: Colors.purple,
  speed: Duration(seconds: 3),
  borderRadius: 10,
  glowPadding: 4,
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('Premium Feature'),
  ),
)
```

### Subtle Slow Animation

```dart
GlidingGlowBox(
  color: Colors.blue.withOpacity(0.6),
  speed: Duration(seconds: 10),
  borderWidth: 2.0,
  borderRadius: 14,
  glowPadding: 2,
  child: Card(
    child: ListTile(title: Text('Highlighted Item')),
  ),
)
```

### Thick Border Accent

```dart
GlidingGlowBox(
  color: Colors.amber,
  borderWidth: 5.0,
  borderRadius: 18,
  glowPadding: 8,
  child: Padding(
    padding: EdgeInsets.all(20),
    child: Text('Call to Action'),
  ),
)
```

## Use Cases

- Call-to-action buttons
- Premium feature highlights
- Interactive form fields
- Portfolio showcase items
- Navigation elements

## Source Code

@{WidgetCode:borders/gliding_glow_box}
