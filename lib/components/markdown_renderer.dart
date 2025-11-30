import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widget_preview.dart';
import 'widget_code.dart';
import '../services/widget_loader.dart';

/// Enhanced markdown renderer with support for custom widget embedding.
/// Supports:
/// - @{WidgetPreview:identifier} - Embeds a widget preview
/// - @{WidgetCode:identifier} - Embeds widget source code
class MarkdownRenderer extends StatelessWidget {
  /// The markdown content to render
  final String markdown;

  /// Custom preview widgets to use (keyed by identifier)
  final Map<String, Widget>? previewWidgets;

  const MarkdownRenderer({
    super.key,
    required this.markdown,
    this.previewWidgets,
  });

  @override
  Widget build(BuildContext context) {
    // Parse markdown and extract custom directives
    final parsed = _parseCustomSyntax(markdown);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: parsed.map((segment) {
        if (segment is _MarkdownSegment) {
          return MarkdownBody(
            data: segment.content,
            selectable: true,
            onTapLink: (text, href, title) {
              if (href != null) {
                launchUrl(Uri.parse(href));
              }
            },
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                .copyWith(
                  blockSpacing: 16,
                  h1: Theme.of(context).textTheme.headlineMedium,
                  h2: Theme.of(context).textTheme.headlineSmall,
                  h3: Theme.of(context).textTheme.titleLarge,
                  code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.grey[200],
                  ),
                ),
          );
        } else if (segment is _WidgetPreviewSegment) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: WidgetPreview(
              identifier: segment.identifier,
              previewWidget: previewWidgets?[segment.identifier],
            ),
          );
        } else if (segment is _WidgetCodeSegment) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: FutureBuilder<String>(
              future: _loadCode(segment.identifier),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SizedBox(
                  height: 400,
                  child: WidgetCode(
                    code: snapshot.data ?? '// Error loading code',
                    title: segment.identifier,
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Future<String> _loadCode(String identifier) async {
    final metadata = WidgetLoader.findByIdentifier(identifier);
    if (metadata != null) {
      return await WidgetLoader.loadSourceCode(metadata);
    }
    return '// Widget not found: $identifier';
  }

  List<dynamic> _parseCustomSyntax(String content) {
    final segments = <dynamic>[];
    final regex = RegExp(r'@\{(WidgetPreview|WidgetCode):([^}]+)\}');

    int lastIndex = 0;
    for (final match in regex.allMatches(content)) {
      // Add markdown before this match
      if (match.start > lastIndex) {
        final mdContent = content.substring(lastIndex, match.start);
        if (mdContent.trim().isNotEmpty) {
          segments.add(_MarkdownSegment(mdContent));
        }
      }

      // Add the custom widget
      final type = match.group(1);
      final identifier = match.group(2)!.trim();

      if (type == 'WidgetPreview') {
        segments.add(_WidgetPreviewSegment(identifier));
      } else if (type == 'WidgetCode') {
        segments.add(_WidgetCodeSegment(identifier));
      }

      lastIndex = match.end;
    }

    // Add remaining markdown
    if (lastIndex < content.length) {
      final mdContent = content.substring(lastIndex);
      if (mdContent.trim().isNotEmpty) {
        segments.add(_MarkdownSegment(mdContent));
      }
    }

    // If no custom syntax found, return single markdown segment
    if (segments.isEmpty) {
      segments.add(_MarkdownSegment(content));
    }

    return segments;
  }
}

// Helper classes for parsed segments
class _MarkdownSegment {
  final String content;
  _MarkdownSegment(this.content);
}

class _WidgetPreviewSegment {
  final String identifier;
  _WidgetPreviewSegment(this.identifier);
}

class _WidgetCodeSegment {
  final String identifier;
  _WidgetCodeSegment(this.identifier);
}
