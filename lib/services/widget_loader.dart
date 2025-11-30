import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/widget_metadata.dart';

/// Service for loading and managing widget metadata and source code.
class WidgetLoader {
  /// Registry of all available widgets in the library
  /// Registry of all available widgets in the library
  static List<WidgetMetadata> _widgets = [];

  /// Initialize the loader by loading metadata from assets
  static Future<void> initialize() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final jsonPaths = manifest
          .listAssets()
          .where(
            (String key) =>
                key.contains('docs/widgets/') && key.endsWith('.json'),
          )
          .toList();

      final loadedWidgets = <WidgetMetadata>[];

      for (final path in jsonPaths) {
        try {
          final jsonContent = await rootBundle.loadString(path);
          final jsonMap = json.decode(jsonContent);

          // Extract identifier from file path
          // e.g., "docs/widgets/backgrounds/black_hole_background.json"
          // -> "backgrounds/black_hole_background"
          final parts = path.split('/');
          final fileName = parts.last.replaceAll('.json', '');
          final group = parts[parts.length - 2];
          final identifier = '$group/$fileName';

          loadedWidgets.add(
            WidgetMetadata.fromJson(jsonMap, identifier: identifier),
          );
        } catch (e) {
          debugPrint('Error loading widget metadata from $path: $e');
        }
      }

      // Sort widgets by name
      loadedWidgets.sort((a, b) => a.name.compareTo(b.name));
      _widgets = loadedWidgets;
    } catch (e) {
      debugPrint('Error initializing WidgetLoader: $e');
    }
  }

  /// Get all widgets
  static List<WidgetMetadata> get widgets => List.unmodifiable(_widgets);

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
