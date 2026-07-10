import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/widget_loader.dart';
import '../theme/arcade_theme.dart';
import 'widget_code.dart';
import 'widget_preview.dart';

class MarkdownRenderer extends StatelessWidget {
  final String markdown;
  final Map<String, Widget>? previewWidgets;
  final Map<String, GlobalKey>? headingKeys;

  const MarkdownRenderer({
    super.key,
    required this.markdown,
    this.previewWidgets,
    this.headingKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final segment in _parse(markdown))
          ..._widgetsForSegment(segment, context),
      ],
    );
  }

  List<Widget> _widgetsForSegment(_Segment segment, BuildContext context) {
    return switch (segment) {
      _MarkdownSegment(:final content) => _markdownSections(content, context),
      _PreviewSegment(:final identifier) => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: WidgetPreview(
            identifier: identifier,
            previewWidget: previewWidgets?[identifier],
          ),
        ),
      ],
      _SourceSegment(:final identifier) => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: FutureBuilder<String>(
            future: _loadSource(identifier),
            builder: (context, snapshot) => WidgetCode(
              code: snapshot.data ?? '// Loading source…',
              title: '$identifier.dart',
            ),
          ),
        ),
      ],
      _CodeSegment(:final code, :final language) => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: WidgetCode(
            code: code,
            title: language.isEmpty ? 'code' : language,
          ),
        ),
      ],
    };
  }

  List<Widget> _markdownSections(String content, BuildContext context) {
    final sections = <Widget>[];
    final buffer = StringBuffer();
    String? heading;

    void flush() {
      if (buffer.isEmpty) return;
      final body = _markdownBody(buffer.toString(), context);
      sections.add(
        heading == null || headingKeys?[heading] == null
            ? body
            : KeyedSubtree(key: headingKeys![heading], child: body),
      );
      buffer.clear();
    }

    for (final line in content.split('\n')) {
      if (line.trimLeft().startsWith('## ')) {
        flush();
        heading = line.trim().substring(3).trim();
      }
      buffer.writeln(line);
    }
    flush();
    return sections;
  }

  Widget _markdownBody(String content, BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownBody(
      data: content,
      selectable: true,
      onTapLink: (_, href, _) {
        final uri = href == null ? null : Uri.tryParse(href);
        if (uri != null) {
          unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
        }
      },
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        blockSpacing: 16,
        p: const TextStyle(
          color: Color(0xFFD6D6DC),
          fontSize: 15,
          height: 1.65,
        ),
        h1: theme.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -1.2,
        ),
        h1Padding: const EdgeInsets.only(bottom: 14),
        h2: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
        ),
        h2Padding: const EdgeInsets.only(top: 28, bottom: 10),
        h3: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        h3Padding: const EdgeInsets.only(top: 22, bottom: 8),
        a: const TextStyle(color: ArcadeColors.violet),
        code: const TextStyle(
          color: ArcadeColors.aqua,
          backgroundColor: ArcadeColors.surfaceRaised,
          fontFamily: 'monospace',
          fontSize: 12.5,
        ),
        blockquoteDecoration: const BoxDecoration(
          color: ArcadeColors.surface,
          border: Border(
            left: BorderSide(color: ArcadeColors.violet, width: 3),
          ),
        ),
        tableBorder: TableBorder.all(color: ArcadeColors.border),
        tableHead: const TextStyle(fontWeight: FontWeight.w800),
        tableBody: const TextStyle(color: Color(0xFFD6D6DC), height: 1.4),
        tableCellsPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        listBullet: const TextStyle(color: ArcadeColors.violet),
      ),
    );
  }

  Future<String> _loadSource(String identifier) async {
    final metadata = WidgetLoader.findByIdentifier(identifier);
    return metadata == null
        ? '// Widget not found: $identifier'
        : WidgetLoader.loadSourceCode(metadata);
  }
}

List<_Segment> _parse(String content) {
  final pattern = RegExp(
    r'```([^\n`]*)\n([\s\S]*?)```|@\{(WidgetPreview|WidgetCode):([^}]+)\}',
  );
  final segments = <_Segment>[];
  var cursor = 0;

  for (final match in pattern.allMatches(content)) {
    if (match.start > cursor) {
      final before = content.substring(cursor, match.start);
      if (before.trim().isNotEmpty) segments.add(_MarkdownSegment(before));
    }

    final language = match.group(1);
    if (language != null) {
      segments.add(_CodeSegment(match.group(2)!.trimRight(), language.trim()));
    } else {
      final identifier = match.group(4)!.trim();
      segments.add(
        match.group(3) == 'WidgetPreview'
            ? _PreviewSegment(identifier)
            : _SourceSegment(identifier),
      );
    }
    cursor = match.end;
  }

  if (cursor < content.length) {
    final tail = content.substring(cursor);
    if (tail.trim().isNotEmpty) segments.add(_MarkdownSegment(tail));
  }
  if (segments.isEmpty) segments.add(_MarkdownSegment(content));
  return segments;
}

sealed class _Segment {
  const _Segment();
}

final class _MarkdownSegment extends _Segment {
  final String content;
  const _MarkdownSegment(this.content);
}

final class _PreviewSegment extends _Segment {
  final String identifier;
  const _PreviewSegment(this.identifier);
}

final class _SourceSegment extends _Segment {
  final String identifier;
  const _SourceSegment(this.identifier);
}

final class _CodeSegment extends _Segment {
  final String code;
  final String language;
  const _CodeSegment(this.code, this.language);
}
