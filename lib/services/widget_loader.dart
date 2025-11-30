import 'package:flutter/services.dart';
import '../models/widget_metadata.dart';

/// Service for loading and managing widget metadata and source code.
class WidgetLoader {
  /// Registry of all available widgets in the library
  static final List<WidgetMetadata> _widgets = [
    WidgetMetadata(
      name: 'FlickeringGrid',
      group: 'backgrounds',
      description:
          'A mesmerizing animated grid background with randomly flickering cells.',
      sourcePath: 'lib/widgets/backgrounds/flickering_grid.dart',
      demoPath: 'lib/widgets/backgrounds/flickering_grid_demo.dart',
      docPath: 'widgets/backgrounds/flickering-grid.md',
      tags: ['background', 'animation', 'grid'],
    ),
    WidgetMetadata(
      name: 'BlackHoleBackground',
      group: 'backgrounds',
      description:
          'A stunning black hole tunnel effect with animated discs and particles.',
      sourcePath: 'lib/widgets/backgrounds/black_hole_background.dart',
      demoPath: 'lib/widgets/backgrounds/black_hole_background_demo.dart',
      docPath: 'widgets/backgrounds/black-hole-background.md',
      tags: ['background', 'animation', '3d'],
    ),
    WidgetMetadata(
      name: 'Dock',
      group: 'navigations',
      description: 'A macOS-style dock with magnifying icon effect on hover.',
      sourcePath: 'lib/widgets/navigations/dock.dart',
      demoPath: 'lib/widgets/navigations/dock_demo.dart',
      docPath: 'widgets/navigations/dock.md',
      tags: ['navigation', 'dock', 'animation'],
    ),
    WidgetMetadata(
      name: 'FloatingDock',
      group: 'navigations',
      description:
          'A floating dock with magnification effect and hover tooltips.',
      sourcePath: 'lib/widgets/navigations/floating_dock.dart',
      demoPath: 'lib/widgets/navigations/floating_dock_demo.dart',
      docPath: 'widgets/navigations/floating-dock.md',
      tags: ['navigation', 'dock', 'tooltip'],
    ),
    WidgetMetadata(
      name: 'GlidingGlowBox',
      group: 'borders',
      description:
          'A container with animated glowing spots that glide along the edges.',
      sourcePath: 'lib/widgets/borders/gliding_glow_box.dart',
      demoPath: 'lib/widgets/borders/gliding_glow_box_demo.dart',
      docPath: 'widgets/borders/gliding-glow-box.md',
      tags: ['border', 'animation', 'glow'],
    ),
    WidgetMetadata(
      name: 'ThreeDCard',
      group: 'cards',
      description:
          'An interactive card with 3D tilt effect that follows pointer movement.',
      sourcePath: 'lib/widgets/cards/three_d_card.dart',
      demoPath: 'lib/widgets/cards/three_d_card_demo.dart',
      docPath: 'widgets/cards/three-d-card.md',
      tags: ['card', '3d', 'interactive'],
    ),
  ];

  /// Get all widgets
  static List<WidgetMetadata> get allWidgets => List.unmodifiable(_widgets);

  /// Get widgets by group/category
  static List<WidgetMetadata> getWidgetsByGroup(String group) {
    return _widgets.where((w) => w.group == group).toList();
  }

  /// Get all unique groups
  static List<String> get groups {
    return _widgets.map((w) => w.group).toSet().toList()..sort();
  }

  /// Find a widget by identifier (e.g., "backgrounds/flickering_grid")
  static WidgetMetadata? findByIdentifier(String identifier) {
    return _widgets.cast<WidgetMetadata?>().firstWhere(
      (w) => w?.identifier == identifier,
      orElse: () => null,
    );
  }

  /// Load the source code for a widget
  static Future<String> loadSourceCode(WidgetMetadata widget) async {
    try {
      return await rootBundle.loadString(widget.sourcePath);
    } catch (e) {
      return '// Error loading source code: $e';
    }
  }

  /// Load the demo code for a widget
  static Future<String> loadDemoCode(WidgetMetadata widget) async {
    try {
      return await rootBundle.loadString(widget.demoPath);
    } catch (e) {
      return '// Error loading demo code: $e';
    }
  }

  /// Search widgets by name or description
  static List<WidgetMetadata> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _widgets.where((w) {
      return w.name.toLowerCase().contains(lowerQuery) ||
          w.description.toLowerCase().contains(lowerQuery) ||
          w.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
