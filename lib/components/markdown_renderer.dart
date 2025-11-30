import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widget_preview.dart';
import 'widget_code.dart';
import '../services/widget_loader.dart';

/// Enhanced markdown renderer with support for custom widget embedding.
/// Supports:
/// - @{WidgetPreview:identifier} - Embeds a widget preview
/// - @{WidgetCode:identifier} - Embeds widget source code
/// - Code blocks with copy functionality
class MarkdownRenderer extends StatelessWidget {
  /// The markdown content to render
  final String markdown;

  /// Custom preview widgets to use (keyed by identifier)
  final Map<String, Widget>? previewWidgets;

  /// Map of heading titles to GlobalKeys for scrolling
  final Map<String, GlobalKey>? headingKeys;

  const MarkdownRenderer({
    super.key,
    required this.markdown,
    this.previewWidgets,
    this.headingKeys,
  });

  @override
  Widget build(BuildContext context) {
    // Parse markdown and extract custom directives and code blocks
    final parsed = _parseContent(markdown);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: parsed.expand((segment) {
        if (segment is _MarkdownSegment) {
          // Split segment by headings to properly attach keys
          return _splitByHeadings(segment.content, context);
        } else if (segment is _WidgetPreviewSegment) {
          return [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: WidgetPreview(
                identifier: segment.identifier,
                previewWidget: previewWidgets?[segment.identifier],
              ),
            ),
          ];
        } else if (segment is _WidgetCodeSegment) {
          return [
            Padding(
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
            ),
          ];
        } else if (segment is _CodeBlockSegment) {
          return [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _CodeBlockWidget(
                code: segment.code,
                language: segment.language,
              ),
            ),
          ];
        }

        return [const SizedBox.shrink()];
      }).toList(),
    );
  }

  /// Split markdown content by headings and attach GlobalKeys
  List<Widget> _splitByHeadings(String content, BuildContext context) {
    final widgets = <Widget>[];
    final lines = content.split('\n');
    final buffer = StringBuffer();
    String? currentHeading;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().startsWith('## ')) {
        // Save previous section
        if (buffer.isNotEmpty) {
          widgets.add(
            _buildMarkdownWidget(
              buffer.toString(),
              context,
              headingKey: currentHeading != null && headingKeys != null
                  ? headingKeys![currentHeading]
                  : null,
            ),
          );
          buffer.clear();
        }

        // Start new section with this heading
        currentHeading = line.trim().substring(3).trim();
        buffer.writeln(line);
      } else {
        buffer.writeln(line);
      }
    }

    // Add remaining content
    if (buffer.isNotEmpty) {
      widgets.add(
        _buildMarkdownWidget(
          buffer.toString(),
          context,
          headingKey: currentHeading != null && headingKeys != null
              ? headingKeys![currentHeading]
              : null,
        ),
      );
    }

    return widgets.isEmpty ? [const SizedBox.shrink()] : widgets;
  }

  /// Build a markdown widget with optional key
  Widget _buildMarkdownWidget(
    String content,
    BuildContext context, {
    GlobalKey? headingKey,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final markdownBody = MarkdownBody(
      data: content,
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href));
        }
      },
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        blockSpacing: 16,
        // Heading styles
        h1: Theme.of(context).textTheme.headlineMedium,
        h1Padding: const EdgeInsets.only(top: 24, bottom: 8),
        h2: Theme.of(context).textTheme.headlineSmall,
        h2Padding: const EdgeInsets.only(top: 32, bottom: 8),
        h3: Theme.of(context).textTheme.titleLarge,
        h3Padding: const EdgeInsets.only(top: 24, bottom: 8),
        // Inline code styling
        code: GoogleFonts.firaCode(
          fontSize: 13,
          color: isDark ? Colors.pink[300] : Colors.pink[700],
          backgroundColor: isDark
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFEEEEEE),
        ),
      ),
    );

    if (headingKey != null) {
      return Container(key: headingKey, child: markdownBody);
    }

    return markdownBody;
  }

  Future<String> _loadCode(String identifier) async {
    final metadata = WidgetLoader.findByIdentifier(identifier);
    if (metadata != null) {
      return await WidgetLoader.loadSourceCode(metadata);
    }
    return '// Widget not found: $identifier';
  }

  /// Parse content and extract custom syntax, code blocks
  List<dynamic> _parseContent(String content) {
    final segments = <dynamic>[];

    // Combined regex for custom directives and code blocks
    final customDirectiveRegex = RegExp(
      r'@\{(WidgetPreview|WidgetCode):([^}]+)\}',
    );
    final codeBlockRegex = RegExp(r'```(\w*)\n([\s\S]*?)```', multiLine: true);

    // Find all matches and sort by position
    final matches = <_Match>[];

    for (final match in customDirectiveRegex.allMatches(content)) {
      matches.add(_Match(match.start, match.end, 'directive', match));
    }

    for (final match in codeBlockRegex.allMatches(content)) {
      matches.add(_Match(match.start, match.end, 'codeblock', match));
    }

    matches.sort((a, b) => a.start.compareTo(b.start));

    int lastIndex = 0;
    for (final m in matches) {
      // Add markdown before this match
      if (m.start > lastIndex) {
        final mdContent = content.substring(lastIndex, m.start);
        if (mdContent.trim().isNotEmpty) {
          segments.add(_MarkdownSegment(mdContent));
        }
      }

      if (m.type == 'directive') {
        final match = m.match;
        final type = match.group(1);
        final identifier = match.group(2)!.trim();

        if (type == 'WidgetPreview') {
          segments.add(_WidgetPreviewSegment(identifier));
        } else if (type == 'WidgetCode') {
          segments.add(_WidgetCodeSegment(identifier));
        }
      } else if (m.type == 'codeblock') {
        final match = m.match;
        final language = match.group(1) ?? '';
        final code = match.group(2) ?? '';
        segments.add(_CodeBlockSegment(code.trimRight(), language));
      }

      lastIndex = m.end;
    }

    // Add remaining markdown
    if (lastIndex < content.length) {
      final mdContent = content.substring(lastIndex);
      if (mdContent.trim().isNotEmpty) {
        segments.add(_MarkdownSegment(mdContent));
      }
    }

    // If no content found, return single markdown segment
    if (segments.isEmpty) {
      segments.add(_MarkdownSegment(content));
    }

    return segments;
  }
}

// Helper class for sorting matches
class _Match {
  final int start;
  final int end;
  final String type;
  final RegExpMatch match;

  _Match(this.start, this.end, this.type, this.match);
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

class _CodeBlockSegment {
  final String code;
  final String language;
  _CodeBlockSegment(this.code, this.language);
}

/// Code block widget with copy functionality
class _CodeBlockWidget extends StatefulWidget {
  final String code;
  final String language;

  const _CodeBlockWidget({required this.code, this.language = ''});

  @override
  State<_CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<_CodeBlockWidget> {
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (mounted) {
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _copied = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = widget.language.isNotEmpty ? widget.language : 'code';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with language label and copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252525) : const Color(0xFFEEEEEE),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  lang,
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _copyToClipboard,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 14,
                          color: _copied
                              ? Colors.green
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _copied ? 'Copied!' : 'Copy',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _copied
                                ? Colors.green
                                : (isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code content
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              widget.code,
              style: GoogleFonts.firaCode(
                fontSize: 13,
                height: 1.6,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
