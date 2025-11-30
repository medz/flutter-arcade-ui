A macOS-style dock with smooth magnification effect on hover. Icons scale up as the cursor approaches, creating an iconic and intuitive interaction pattern.

## Preview

@{WidgetPreview:navigations/dock}

## Features

- Smooth proximity-based magnification effect
- Customizable icon and dock appearance
- Support for separators between icon groups
- Horizontal and vertical layouts
- Configurable scale and distance parameters
- Zero external dependencies

## Properties

### Dock

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `items` | `List<Widget>` | *required* | List of `DockIcon` and `DockSeparator` widgets |
| `itemSize` | `double` | `48.0` | Base size of each dock item |
| `maxScale` | `double` | `2.0` | Maximum scale factor when cursor is closest |
| `itemScale` | `double` | `1.0` | Scale factor applied to icon content |
| `distance` | `double` | `100.0` | Distance in pixels for magnification effect |
| `direction` | `Axis` | `Axis.horizontal` | Layout direction of the dock |
| `gap` | `double` | `8.0` | Gap between dock items |
| `padding` | `EdgeInsetsGeometry?` | `EdgeInsets.all(8)` | Padding inside the dock container |
| `decoration` | `BoxDecoration?` | Dark rounded box | Decoration for the dock container |
| `itemDecoration` | `BoxDecoration?` | Dark rounded box | Default decoration for dock icons |

### DockIcon

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | *required* | The icon or content to display |
| `decoration` | `BoxDecoration?` | `null` | Custom decoration (overrides dock default) |
| `padding` | `EdgeInsetsGeometry?` | `EdgeInsets.zero` | Padding around the icon |
| `onTap` | `VoidCallback?` | `null` | Callback when icon is tapped |

### DockSeparator

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `width` | `double` | `1.0` | Width of the separator line |
| `height` | `double` | `32.0` | Height of the separator line |
| `color` | `Color?` | `Color(0x40FFFFFF)` | Color of the separator |
| `margin` | `EdgeInsetsGeometry?` | `EdgeInsets.symmetric(horizontal: 4)` | Margin around the separator |

## Usage

```dart
import 'widgets/navigations/dock.dart';

Dock(
  items: [
    DockIcon(
      child: Icon(Icons.home, color: Colors.white),
      onTap: () => print('Home'),
    ),
    DockIcon(
      child: Icon(Icons.search, color: Colors.white),
      onTap: () => print('Search'),
    ),
    DockSeparator(),
    DockIcon(
      child: Icon(Icons.settings, color: Colors.white),
      onTap: () => print('Settings'),
    ),
  ],
)
```

## Examples

### Custom Styling

```dart
Dock(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.9),
    borderRadius: BorderRadius.circular(20),
  ),
  itemDecoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
  ),
  items: [
    DockIcon(child: Icon(Icons.star, color: Colors.white)),
    DockIcon(child: Icon(Icons.favorite, color: Colors.white)),
  ],
)
```

### Larger Magnification

```dart
Dock(
  itemSize: 56.0,
  maxScale: 2.5,
  distance: 150.0,
  items: [...],
)
```

### Subtle Effect

```dart
Dock(
  maxScale: 1.3,
  distance: 80.0,
  gap: 4.0,
  items: [...],
)
```

### Custom Icon Design

```dart
DockIcon(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.purple, Colors.blue],
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(Icons.apps, color: Colors.white),
  onTap: () {},
)
```

## Tips

- Use `DockSeparator` to visually group related icons
- Keep 5-9 items for optimal usability
- Adjust `distance` based on dock size for natural feel
- Use consistent icon colors for a cohesive appearance

## Source Code

@{WidgetCode:navigations/dock}