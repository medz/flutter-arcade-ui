# Getting Started with Arcade UI

Welcome! This guide will help you get started with Arcade UI widgets in your Flutter projects.

## What is Arcade UI?

Arcade UI is **not a package**—it's a curated collection of ready-to-use Flutter widgets. You don't install it via `pubspec.yaml`. Instead, you browse our showcase, find the widgets you love, and copy them directly into your project.

No dependency or few dependencies. No version conflicts. Just beautiful code that you own.

## Navigation

The Arcade UI website has a simple structure:

- [Home](/) - The main landing page with project introduction
- [Get Started](/get-started) - This guide you're reading now
- [Widgets](/widgets) - Browse all available widgets by category

## Widget Categories

Our widgets are organized into the following categories:

| Category | Description | Examples |
|----------|-------------|----------|
| **Backgrounds** | Animated background effects | FlickeringGrid, BlackHoleBackground |
| **Borders** | Glowing and animated border effects | GlidingGlowBox |
| **Cards** | Interactive card components | ThreeDCard |
| **Navigations** | Navigation UI components | Dock, FloatingDock |

## How to Use

### Step 1: Browse the Widget Gallery

Visit the [Widgets](/widgets) page to see all available widgets organized by category. Each widget card shows a brief description and tags.

### Step 2: View Widget Details

Click on any widget to open its detail page at `/widgets/:group/:name`. Each detail page includes:

- **Live preview** - See the widget in action
- **Source code** - Complete, copy-ready code
- **Properties table** - All configurable options
- **Usage examples** - Common use cases

### Step 3: Copy the Code

1. On the widget detail page, find the **Source Code** section
2. Click the copy button
3. The complete widget code is now in your clipboard

### Step 4: Add to Your Project

Create a new file in your Flutter project and paste the code:

```dart
// Example: lib/widgets/backgrounds/flickering_grid.dart

// Paste the copied code here
```

We recommend organizing widgets by category, mirroring our structure:

```
lib/
  widgets/
    backgrounds/
      flickering_grid.dart
    borders/
      gliding_glow_box.dart
    cards/
      three_d_card.dart
    navigations/
      floating_dock.dart
```

### Step 5: Import and Use

```dart
import 'package:flutter/material.dart';
import 'widgets/backgrounds/flickering_grid.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlickeringGrid(
      color: Colors.deepPurple,
      child: Center(
        child: Text('Hello, Arcade UI!'),
      ),
    );
  }
}
```

## Dependencies

Most widgets have **zero external dependencies** and only use:

- `package:flutter/widgets.dart`
- `dart:math`
- `dart:async`

If a widget requires additional packages, it will be clearly documented on the widget's detail page.

## Customization

Since you own the code, you have complete freedom to:

- Adjust colors, sizes, and timing
- Modify animations and behaviors
- Combine multiple widgets
- Add your own enhancements

## Tips

- **Read the code** - Understanding how widgets work helps you customize them
- **Check properties** - Each widget documents its configurable properties
- **Experiment** - Try different values to match your design
- **Combine widgets** - Layer multiple effects for unique results

## Resources

- [GitHub Repository](https://github.com/medz/flutter-arcade-ui) - Source code and examples
- [Widget Gallery](/widgets) - Browse all widgets

---

Ready to build something beautiful? [Browse the widgets](/widgets) now!
