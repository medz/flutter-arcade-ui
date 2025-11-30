import 'package:flutter/services.dart';

/// Service for loading documentation markdown files.
class DocsLoader {
  /// Load a markdown file from the docs directory
  static Future<String> loadMarkdown(String path) async {
    try {
      // Normalize path: remove leading slash and docs/ prefix if present
      var normalizedPath = path.startsWith('/') ? path.substring(1) : path;

      // If path already starts with 'docs/', don't add it again
      if (!normalizedPath.startsWith('docs/')) {
        normalizedPath = 'docs/$normalizedPath';
      }

      // Ensure .md extension
      final fullPath = normalizedPath.endsWith('.md')
          ? normalizedPath
          : '$normalizedPath.md';

      return await rootBundle.loadString(fullPath);
    } catch (e) {
      return '# Error Loading Documentation\n\nCould not load documentation file: $path\n\nError: $e';
    }
  }

  /// Load widget documentation by identifier (e.g., "backgrounds/flickering-grid")
  static Future<String> loadWidgetDoc(String identifier) async {
    return loadMarkdown('widgets/$identifier.md');
  }
}
