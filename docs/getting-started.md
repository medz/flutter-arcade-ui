# Getting Started with Arcade UI

Welcome! This guide will help you get started with Arcade UI widgets in your Flutter projects.

## What is Arcade UI?

Arcade UI is **not a package**—it's a curated collection of ready-to-use Flutter widgets. You don't install it via `pubspec.yaml`. Instead, you copy the widget code directly into your project.

## How to Use

### Step 1: Browse the Widget Gallery

Visit the [Widgets page](/docs/widgets) to see all available widgets. Each widget includes:

- Live preview
- Complete source code
- Usage examples
- Property documentation

### Step 2: Find Your Widget

Use the search bar or category filters to find the perfect widget for your needs. Categories include:

- **Backgrounds**: Animated grid patterns, particle effects
- **Navigations**: Dock-style menus, floating navigation
- **Borders**: Glowing borders, animated effects
- **Cards**: 3D interactive cards

### Step 3: Copy the Code

1. Click on any widget to view its detail page
2. Switch to the "Code" tab in the preview
3. Click the copy button
4. Paste the code into your Flutter project

### Step 4: Add to Your Project

Create a new file in your project (e.g., `lib/widgets/my_widget.dart`) and paste the copied code.

```dart
// Example: lib/widgets/flickering_grid.dart
import 'package:flutter/material.dart';

// Paste the copied code here
```

### Step 5: Use the Widget

Import and use the widget in your app:

```dart
import 'package:flutter/material.dart';
import 'widgets/flickering_grid.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlickeringGrid(
        color: Colors.blue,
        child: Center(
          child: Text('Hello, Arcade UI!'),
        ),
      ),
    );
  }
}
```

## Dependencies

Most widgets have **zero external dependencies**. A few widgets may use common Flutter packages like:

- `flutter/material.dart` (built-in)
- `flutter/animation.dart` (built-in)

Any additional dependencies will be clearly documented on the widget's detail page.

## Customization

Since you own the code, feel free to customize any widget:

- Change colors, sizes, and animations
- Modify behavior to fit your use case
- Combine multiple widgets for unique effects
- Add your own enhancements

## Tips

- **Read the code**: Understanding how widgets work helps you customize them better
- **Check properties**: Each widget documents its configurable properties
- **Experiment**: Try different values and see what works best for your design
- **Contribute**: If you create something cool, consider sharing it back!

## Need Help?

- Check out [example projects](https://github.com/medz/flutter-arcade-ui)
- Open an issue on GitHub
- Read widget-specific documentation

---

Ready to get started? [Browse the widget gallery](/docs/widgets) now!
