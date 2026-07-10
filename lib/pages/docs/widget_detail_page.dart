import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unrouter/flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/markdown_renderer.dart';
import '../../models/widget_metadata.dart';
import '../../services/docs_loader.dart';
import '../../services/widget_loader.dart';
import '../../theme/arcade_theme.dart';
import '../../widgets/backgrounds/black_hole_background_demo.dart';
import '../../widgets/backgrounds/flickering_grid_demo.dart';
import '../../widgets/borders/gliding_glow_box_demo.dart';
import '../../widgets/cards/three_d_card_demo.dart';
import '../../widgets/games/space_shooter_demo.dart';
import '../../widgets/navigations/dock_demo.dart';
import '../../widgets/navigations/floating_dock_demo.dart';
import '../../widgets/navigations/liquid_glass_tab_bars_demo.dart';
import '../../widgets/navigations/motion_tabs_demo.dart';

const _githubUrl = 'https://github.com/medz/flutter-arcade-ui';

class WidgetDetailPage extends StatefulWidget {
  final String group;
  final String name;

  const WidgetDetailPage({super.key, required this.group, required this.name});

  @override
  State<WidgetDetailPage> createState() => _WidgetDetailPageState();
}

class _WidgetDetailPageState extends State<WidgetDetailPage> {
  final _headingKeys = <String, GlobalKey>{};
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant WidgetDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group == widget.group && oldWidget.name == widget.name) {
      return;
    }

    _headingKeys.clear();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identifier = '${widget.group}/${widget.name.replaceAll('-', '_')}';
    final metadata = WidgetLoader.findByIdentifier(identifier);
    if (metadata == null) return _NotFound(identifier: identifier);

    final markdown = metadata.docPath == null
        ? ''
        : DocsLoader.read(metadata.docPath!);
    final headings = _extractHeadings(markdown);
    _syncHeadingKeys(headings);

    final showTableOfContents = MediaQuery.sizeOf(context).width >= 1180;
    return Title(
      title: '${metadata.name} - Flutter Arcade UI',
      color: ArcadeColors.violet,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.sizeOf(context).width < 700 ? 20 : 40,
                  34,
                  MediaQuery.sizeOf(context).width < 700 ? 20 : 40,
                  72,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Breadcrumbs(metadata: metadata),
                        const SizedBox(height: 30),
                        Text(
                          metadata.name,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontSize: MediaQuery.sizeOf(context).width < 600
                                    ? 38
                                    : 46,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                                letterSpacing: -1.8,
                              ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          metadata.description,
                          style: const TextStyle(
                            color: ArcadeColors.muted,
                            fontSize: 17,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (markdown.isNotEmpty)
                          MarkdownRenderer(
                            markdown: markdown,
                            headingKeys: _headingKeys,
                            previewWidgets: {
                              identifier:
                                  _previewFor(identifier) ?? const SizedBox(),
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showTableOfContents)
            SizedBox(
              width: 230,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: ArcadeColors.border)),
                ),
                child: _TableOfContents(
                  headings: headings,
                  onHeadingTap: _scrollToHeading,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _syncHeadingKeys(List<String> headings) {
    _headingKeys.removeWhere((heading, _) => !headings.contains(heading));
    for (final heading in headings) {
      _headingKeys.putIfAbsent(heading, GlobalKey.new);
    }
  }

  void _scrollToHeading(String heading) {
    final context = _headingKeys[heading]?.currentContext;
    if (context == null) return;
    unawaited(
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      ),
    );
  }
}

List<String> _extractHeadings(String markdown) {
  return [
    for (final line in markdown.split('\n'))
      if (line.trimLeft().startsWith('## ')) line.trim().substring(3).trim(),
  ];
}

Widget? _previewFor(String identifier) {
  return switch (identifier) {
    'backgrounds/flickering_grid' => const FlickeringGridDemo(),
    'backgrounds/black_hole_background' => const BlackHoleBackgroundDemo(),
    'navigations/dock' => const DockDemo(),
    'navigations/floating_dock' => const FloatingDockDemo(),
    'navigations/motion_tabs' => const MotionTabsDemo(),
    'navigations/liquid_glass_tab_bars' => const LiquidGlassTabBarsDemo(),
    'borders/gliding_glow_box' => const GlidingGlowBoxDemo(),
    'cards/three_d_card' => const ThreeDCardDemo(),
    'games/space_shooter' => const SpaceShooterDemo(),
    _ => null,
  };
}

class _Breadcrumbs extends StatelessWidget {
  final WidgetMetadata metadata;

  const _Breadcrumbs({required this.metadata});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: ArcadeColors.muted,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          InkWell(
            onTap: () => unawaited(useRouter(context).push('/widgets')),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text('Widgets', style: style),
            ),
          ),
          const _BreadcrumbDivider(),
          Text(metadata.categoryName, style: style),
          const _BreadcrumbDivider(),
          Text(
            metadata.name,
            style: style?.copyWith(color: ArcadeColors.violet),
          ),
        ],
      ),
    );
  }
}

class _BreadcrumbDivider extends StatelessWidget {
  const _BreadcrumbDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 17,
        color: ArcadeColors.muted,
      ),
    );
  }
}

class _TableOfContents extends StatelessWidget {
  final List<String> headings;
  final ValueChanged<String> onHeadingTap;

  const _TableOfContents({required this.headings, required this.onHeadingTap});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 34, 20, 28),
        children: [
          const Text(
            'On This Page',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          for (final heading in headings)
            _TocLink(title: heading, onTap: () => onHeadingTap(heading)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1),
          ),
          _ExternalLink(
            icon: Icons.star_border_rounded,
            title: 'Star on GitHub',
            uri: Uri.parse(_githubUrl),
          ),
          _ExternalLink(
            icon: Icons.bug_report_outlined,
            title: 'Create Issues',
            uri: Uri.parse('$_githubUrl/issues'),
          ),
        ],
      ),
    );
  }
}

class _TocLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _TocLink({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Text(
          title,
          style: const TextStyle(color: ArcadeColors.muted, fontSize: 13),
        ),
      ),
    );
  }
}

class _ExternalLink extends StatelessWidget {
  final IconData icon;
  final String title;
  final Uri uri;

  const _ExternalLink({
    required this.icon,
    required this.title,
    required this.uri,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          unawaited(launchUrl(uri, mode: LaunchMode.externalApplication)),
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: ArcadeColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: ArcadeColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.north_east_rounded,
              size: 14,
              color: ArcadeColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  final String identifier;

  const _NotFound({required this.identifier});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: ArcadeColors.muted,
            ),
            const SizedBox(height: 16),
            Text('Widget not found: $identifier'),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () => unawaited(useRouter(context).push('/widgets')),
              child: const Text('Back to widgets'),
            ),
          ],
        ),
      ),
    );
  }
}
