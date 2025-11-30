/// Metadata for a widget in the Arcade UI library.
class WidgetMetadata {
  /// The display name of the widget (e.g., "FlickeringGrid")
  final String name;

  /// The category/group this widget belongs to (e.g., "backgrounds")
  final String group;

  /// A brief description of what the widget does
  final String description;

  /// Path to the widget source file relative to lib/
  final String sourcePath;

  /// Path to the widget demo file relative to lib/
  final String demoPath;

  /// Optional path to the documentation markdown file
  final String? docPath;

  /// Tags for filtering and searching
  final List<String> tags;

  const WidgetMetadata({
    required this.name,
    required this.group,
    required this.description,
    required this.sourcePath,
    required this.demoPath,
    this.docPath,
    this.tags = const [],
  });

  factory WidgetMetadata.fromJson(Map<String, dynamic> json) {
    return WidgetMetadata(
      name: json['name'] as String,
      group: json['group'] as String,
      description: json['description'] as String,
      sourcePath: json['sourcePath'] as String,
      demoPath: json['demoPath'] as String,
      docPath: json['docPath'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  /// Get the identifier used in routes (e.g., "backgrounds/flickering_grid")
  String get identifier => '$group/${_toSnakeCase(name)}';

  /// Get the display category name with proper capitalization
  String get categoryName => capitalize(group);

  static String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp(r'^_'), '');
  }

  static String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}
