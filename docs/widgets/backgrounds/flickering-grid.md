A mesmerizing animated grid background with randomly flickering cells. Perfect for creating dynamic, eye-catching backgrounds.

## Preview

@{WidgetPreview:backgrounds/flickering_grid}

## Features

- Smooth flickering animation with random cell opacity changes
- Fully customizable grid appearance (size, gap, color)
- Canvas-based rendering for optimal performance
- Support for child widgets as overlay
- Zero external dependencies

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `color` | `Color` | `Colors.black` | Color of the grid squares |
| `squareSize` | `double` | `4.0` | Size of each grid square in pixels |
| `gridGap` | `double` | `6.0` | Gap between grid squares |
| `flickerChance` | `double` | `0.3` | Probability of a square flickering per frame |
| `maxOpacity` | `double` | `0.3` | Maximum opacity of the flickering squares |
| `duration` | `Duration` | `1 second` | Animation loop duration |
| `child` | `Widget?` | `null` | Optional child widget displayed over the grid |

## Usage

```dart
import 'widgets/backgrounds/flickering_grid.dart';

FlickeringGrid(
  color: Colors.deepPurple,
  child: Center(
    child: Text('Hello, Arcade UI!'),
  ),
)
```

## Examples

### Dense Grid

```dart
FlickeringGrid(
  color: Colors.blue,
  squareSize: 2.0,
  gridGap: 3.0,
  maxOpacity: 0.5,
)
```

### Sparse Grid with Slow Animation

```dart
FlickeringGrid(
  color: Colors.green,
  squareSize: 8.0,
  gridGap: 12.0,
  flickerChance: 0.1,
  duration: Duration(seconds: 2),
)
```

## Source Code

@{WidgetCode:backgrounds/flickering_grid}