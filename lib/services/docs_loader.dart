import 'package:flutter/services.dart';

/// Service for loading documentation markdown files.
class DocsLoader {
  static final Map<String, String> _cache = {};

  static String _normalizePath(String path) {
    var normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    if (!normalizedPath.startsWith('docs/')) {
      normalizedPath = 'docs/$normalizedPath';
    }
    return normalizedPath.endsWith('.md')
        ? normalizedPath
        : '$normalizedPath.md';
  }

  /// Load a markdown file from the docs directory
  static Future<String> loadMarkdown(String path) async {
    final fullPath = _normalizePath(path);
    final cached = _cache[fullPath];
    if (cached != null) return cached;

    try {
      final markdown = await rootBundle.loadString(fullPath);
      _cache[fullPath] = markdown;
      return markdown;
    } catch (e) {
      final markdown =
          '# Documentation unavailable\n\nCould not load `$path`.\n\n$e';
      _cache[fullPath] = markdown;
      return markdown;
    }
  }

  /// Load local documentation into memory before rendering the app.
  static Future<void> preload(Iterable<String> paths) async {
    await Future.wait(paths.map(loadMarkdown));
  }

  /// Read preloaded documentation without adding a loading frame.
  static String read(String path) {
    final fullPath = _normalizePath(path);
    return _cache[fullPath] ??
        '# Documentation unavailable\n\n`$path` was not preloaded.';
  }
}
