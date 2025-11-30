A captivating black hole effect with rotating discs, radial lines, and floating particles. Creates a mesmerizing 3D depth illusion perfect for immersive hero sections.

## Preview

@{WidgetPreview:backgrounds/black_hole_background}

## Features

- Animated rotating elliptical discs creating depth illusion
- Radial line patterns converging to center
- Floating particle effects with varying opacity
- Smooth canvas-based rendering with clipping
- Support for child widgets as overlay
- Zero external dependencies

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `strokeColor` | `Color` | `Color(0x33737373)` | Color of the disc outlines and radial lines |
| `numberOfLines` | `int` | `50` | Number of radial lines emanating from center |
| `numberOfDiscs` | `int` | `50` | Number of rotating elliptical discs |
| `particleColor` | `Color` | `Color(0x33FFFFFF)` | Color of the floating particles |
| `child` | `Widget?` | `null` | Optional child widget displayed over the effect |

## Usage

```dart
import 'widgets/backgrounds/black_hole_background.dart';

BlackHoleBackground(
  child: Center(
    child: Text(
      'Into the Void',
      style: TextStyle(fontSize: 48, color: Colors.white),
    ),
  ),
)
```

## Examples

### Vibrant Style

```dart
BlackHoleBackground(
  strokeColor: Colors.purple.withOpacity(0.3),
  particleColor: Colors.white.withOpacity(0.5),
  numberOfLines: 72,
  numberOfDiscs: 60,
)
```

### Minimal Style

```dart
BlackHoleBackground(
  strokeColor: Colors.grey.withOpacity(0.1),
  particleColor: Colors.white.withOpacity(0.2),
  numberOfLines: 24,
  numberOfDiscs: 30,
)
```

## Performance Tips

- Reduce `numberOfDiscs` and `numberOfLines` on lower-end devices
- Consider pausing animation when widget is not visible
- Use sparingly—one instance per screen is recommended

## Source Code

@{WidgetCode:backgrounds/black_hole_background}