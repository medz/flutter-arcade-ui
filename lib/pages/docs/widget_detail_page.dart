import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/markdown_renderer.dart';
import '../../services/docs_loader.dart';
import '../../services/widget_loader.dart';
import '../../widgets/backgrounds/flickering_grid_demo.dart';
import '../../widgets/backgrounds/black_hole_background_demo.dart';
import '../../widgets/navigations/dock_demo.dart';
import '../../widgets/navigations/floating_dock_demo.dart';
import '../../widgets/borders/gliding_glow_box_demo.dart';
import '../../widgets/cards/three_d_card_demo.dart';

/// Widget detail page (/docs/:group/:name)
class WidgetDetailPage extends StatefulWidget {
  final String group;
  final String name;

  const WidgetDetailPage({super.key, required this.group, required this.name});

  @override
  State<WidgetDetailPage> createState() => _WidgetDetailPageState();
}

class _WidgetDetailPageState extends State<WidgetDetailPage> {
  List<String> _tocItems = [];
  final Map<String, GlobalKey> _headingKeys = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WidgetDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset TOC when route changes
    if (oldWidget.group != widget.group || oldWidget.name != widget.name) {
      setState(() {
        _tocItems = [];
        _headingKeys.clear();
      });
    }
  }

  /// Extract headings from markdown content (lines starting with ##)
  List<String> _extractHeadings(String markdown) {
    final headings = <String>[];
    final lines = markdown.split('\n');

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('## ')) {
        headings.add(trimmed.substring(3).trim());
      }
    }

    return headings;
  }

  /// Scroll to a specific heading
  void _scrollToHeading(String heading) {
    final key = _headingKeys[heading];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1, // Position heading near the top
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convert kebab-case URL parameters to snake_case for identifier
    final snakeCaseName = widget.name.replaceAll('-', '_');
    final identifier = '${widget.group}/$snakeCaseName';
    final metadata = WidgetLoader.findByIdentifier(identifier);

    if (metadata == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Widget not found: $identifier',
                style: GoogleFonts.inter(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumbs
                  _Breadcrumbs(group: widget.group, name: metadata.name),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    metadata.name,
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    metadata.description,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Documentation Content
                  if (metadata.docPath != null)
                    FutureBuilder<String>(
                      future: DocsLoader.loadMarkdown(metadata.docPath!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        // Extract TOC items when markdown is loaded
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          final headings = _extractHeadings(snapshot.data!);
                          if (_tocItems.length != headings.length ||
                              !_tocItems.every((e) => headings.contains(e))) {
                            setState(() {
                              _tocItems = headings;
                              _headingKeys.clear();
                              for (var heading in headings) {
                                _headingKeys[heading] = GlobalKey();
                              }
                            });
                          }
                        });

                        return MarkdownRenderer(
                          markdown: snapshot.data!,
                          headingKeys: _headingKeys,
                          previewWidgets: {
                            identifier:
                                _getPreviewWidget(identifier) ??
                                const SizedBox(),
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // Right Sidebar (Table of Contents) - Desktop only
          if (isDesktop)
            Container(
              width: 240,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'On This Page',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Dynamically generate TOC links from markdown headings
                  ..._tocItems.map(
                    (title) => _TOCLink(
                      title: title,
                      onTap: () => _scrollToHeading(title),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(height: 1),
                  const SizedBox(height: 32),
                  _ExternalLink(
                    icon: Icons.star_outline,
                    title: 'Star on GitHub',
                    url: 'https://github.com/medz/flutter-arcade-ui',
                  ),
                  _ExternalLink(
                    icon: Icons.bug_report_outlined,
                    title: 'Create Issues',
                    url: 'https://github.com/medz/flutter-arcade-ui/issues',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget? _getPreviewWidget(String identifier) {
    switch (identifier) {
      case 'backgrounds/flickering_grid':
        return const FlickeringGridDemo();
      case 'backgrounds/black_hole_background':
        return const BlackHoleBackgroundDemo();
      case 'navigations/dock':
        return const DockDemo();
      case 'navigations/floating_dock':
        return const FloatingDockDemo();
      case 'borders/gliding_glow_box':
        return const GlidingGlowBoxDemo();
      case 'cards/three_d_card':
        return const ThreeDCardDemo();
      default:
        return null;
    }
  }
}

class _Breadcrumbs extends StatelessWidget {
  final String group;
  final String name;

  const _Breadcrumbs({required this.group, required this.name});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mutedColor = colorScheme.onSurface.withValues(alpha: 0.6);

    return Row(
      children: [
        Text(
          'Widgets',
          style: GoogleFonts.inter(fontSize: 14, color: mutedColor),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, size: 16, color: mutedColor),
        const SizedBox(width: 8),
        Text(
          group[0].toUpperCase() + group.substring(1),
          style: GoogleFonts.inter(fontSize: 14, color: mutedColor),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, size: 16, color: mutedColor),
        const SizedBox(width: 8),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _TOCLink extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _TOCLink({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _ExternalLink extends StatelessWidget {
  final IconData icon;
  final String title;
  final String url;

  const _ExternalLink({
    required this.icon,
    required this.title,
    required this.url,
  });

  Future<void> _launchUrl() async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _launchUrl,
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_outward,
              size: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
