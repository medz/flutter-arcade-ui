A sleek floating dock with magnification effect and tooltip labels. Features a frosted glass aesthetic and smooth hover animations, ideal for app navigation or quick actions.

## Preview

@{WidgetPreview:navigations/floating_dock}

## Features

- Proximity-based magnification effect on hover
- Tooltip labels appear above icons on hover
- Customizable dock and item appearance
- Frosted glass default styling
- Smooth animation transitions
- Zero external dependencies

## Properties

### FloatingDock

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `items` | `List<FloatingDockItem>` | *required* | List of dock items to display |
| `baseItemSize` | `double` | `48.0` | Base size of each dock item |
| `maxItemSize` | `double` | `68.0` | Maximum size when cursor is closest |
| `distance` | `double` | `150.0` | Distance in pixels for magnification effect |
| `gap` | `double` | `12.0` | Gap between dock items |
| `padding` | `EdgeInsetsGeometry?` | `EdgeInsets.symmetric(horizontal: 16, vertical: 12)` | Padding inside the dock |
| `decoration` | `BoxDecoration?` | Light rounded box | Decoration for the dock container |
| `itemDecoration` | `BoxDecoration?` | Light grey box | Default decoration for items |

### FloatingDockItem

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `icon` | `Widget` | *required* | The icon widget to display |
| `title` | `String?` | `null` | Tooltip text shown on hover |
| `decoration` | `BoxDecoration?` | `null` | Custom decoration for this item |
| `onTap` | `VoidCallback?` | `null` | Callback when item is tapped |

## Usage

```dart
import 'widgets/navigations/floating_dock.dart';

FloatingDock(
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
)
```

## Examples

### Dark Theme

```dart
FloatingDock(
  decoration: BoxDecoration(
    color: Colors.grey[900],
    borderRadius: BorderRadius.circular(20),
  ),
  itemDecoration: BoxDecoration(
    color: Colors.grey[800],
  ),
  items: [
    FloatingDockItem(
      icon: Icon(Icons.rocket, color: Colors.white),
      title: 'Launch',
    ),
    FloatingDockItem(
      icon: Icon(Icons.settings, color: Colors.white),
      title: 'Settings',
    ),
  ],
)
```

### Larger Icons

```dart
FloatingDock(
  baseItemSize: 56.0,
  maxItemSize: 80.0,
  gap: 16.0,
  items: [...],
)
```

### Subtle Magnification

```dart
FloatingDock(
  baseItemSize: 48.0,
  maxItemSize: 56.0,
  distance: 100.0,
  items: [...],
)
```

### Custom Item Styling

```dart
FloatingDockItem(
  icon: Icon(Icons.favorite, color: Colors.white),
  title: 'Favorites',
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.pink, Colors.red],
    ),
  ),
  onTap: () {},
)
```

## Tips

- Keep titles short (1-2 words) for clean tooltips
- Limit to 5-7 items for best user experience
- Position at bottom center for familiar interaction pattern
- Use consistent icon colors for cohesive appearance
- Consider using colored icons to differentiate actions

## Source Code

@{WidgetCode:navigations/floating_dock}