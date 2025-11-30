An interactive 3D card that responds to mouse/pointer movement with realistic perspective transforms. Perfect for product showcases, portfolios, and interactive UI elements.

## Preview

@{WidgetPreview:cards/three_d_card}

## Features

- Real-time mouse/pointer tracking with 3D perspective
- Smooth tilt animation with configurable sensitivity
- Hover state decoration support
- Nested `ThreeDCardItem` for layered parallax effects
- Throttled updates for optimal performance
- Zero external dependencies

## Properties

### ThreeDCard

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | *required* | The card content |
| `sensitivity` | `double` | `25.0` | Mouse movement sensitivity (higher = less tilt) |
| `duration` | `Duration` | `200ms` | Animation duration for tilt transitions |
| `decoration` | `BoxDecoration?` | `null` | Base decoration for the card |
| `hoverDecoration` | `BoxDecoration?` | `null` | Decoration applied when hovering |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding inside the card |
| `maxRotationX` | `double` | `25.0` | Maximum rotation on X axis (degrees) |
| `maxRotationY` | `double` | `25.0` | Maximum rotation on Y axis (degrees) |
| `onHoverStart` | `VoidCallback?` | `null` | Callback when hover begins |
| `onHoverEnd` | `VoidCallback?` | `null` | Callback when hover ends |
| `curve` | `Curve` | `Curves.easeOut` | Animation curve |
| `enabled` | `bool` | `true` | Whether the 3D effect is enabled |

### ThreeDCardItem

Use inside `ThreeDCard` to create parallax layers that move independently.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | *required* | The item content |
| `translateX` | `double` | `0` | Horizontal translation on hover |
| `translateY` | `double` | `0` | Vertical translation on hover |
| `translateZ` | `double` | `0` | Depth translation on hover |
| `rotateX` | `double` | `0` | X-axis rotation on hover (degrees) |
| `rotateY` | `double` | `0` | Y-axis rotation on hover (degrees) |
| `rotateZ` | `double` | `0` | Z-axis rotation on hover (degrees) |
| `duration` | `Duration` | `500ms` | Animation duration |

## Usage

```dart
import 'widgets/cards/three_d_card.dart';

ThreeDCard(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
  child: Container(
    width: 300,
    height: 400,
    padding: EdgeInsets.all(24),
    child: Column(
      children: [
        Text('Product Name'),
        Text('\$99.00'),
      ],
    ),
  ),
)
```

## Examples

### With Hover Shadow

```dart
ThreeDCard(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
  ),
  hoverDecoration: BoxDecoration(
    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30)],
  ),
  child: YourContent(),
)
```

### Subtle Tilt Effect

```dart
ThreeDCard(
  sensitivity: 40.0,
  maxRotationX: 10.0,
  maxRotationY: 10.0,
  child: YourContent(),
)
```

### Parallax Layers

```dart
ThreeDCard(
  child: Stack(
    children: [
      // Background layer - moves less
      ThreeDCardItem(
        translateZ: 20,
        child: Image.asset('background.png'),
      ),
      // Foreground layer - moves more
      ThreeDCardItem(
        translateZ: 50,
        translateY: -10,
        child: Text('Floating Title'),
      ),
    ],
  ),
)
```

## Tips

- Use `sensitivity` between 20-40 for natural feel
- Combine with `hoverDecoration` for enhanced shadows on hover
- Nest `ThreeDCardItem` widgets for parallax depth effects
- Keep card size between 200-500px for best visual impact

## Source Code

@{WidgetCode:cards/three_d_card}