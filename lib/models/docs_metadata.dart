/// Metadata for a documentation page.
class DocsMetadata {
  /// The title of the documentation page
  final String title;

  /// Path to the markdown file relative to docs/
  final String path;

  /// Route path for navigation (e.g., "/docs/getting-started")
  final String route;

  /// Optional parent page for hierarchical navigation
  final DocsMetadata? parent;

  /// Child pages if this is a section
  final List<DocsMetadata> children;

  /// Icon name for navigation display
  final String? icon;

  /// Order for display in navigation
  final int order;

  const DocsMetadata({
    required this.title,
    required this.path,
    required this.route,
    this.parent,
    this.children = const [],
    this.icon,
    this.order = 0,
  });
}
