import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/markdown_renderer.dart';
import '../../components/widget_preview.dart';
import '../../services/docs_loader.dart';
import '../../services/widget_loader.dart';
import '../../models/widget_metadata.dart';
import '../../widgets/backgrounds/flickering_grid_demo.dart';
import '../../widgets/backgrounds/black_hole_background_demo.dart';
import '../../widgets/navigations/dock_demo.dart';
import '../../widgets/navigations/floating_dock_demo.dart';
import '../../widgets/borders/gliding_glow_box_demo.dart';
import '../../widgets/cards/three_d_card_demo.dart';

/// Widget detail page (/docs/:group/:name)
class WidgetDetailPage extends StatelessWidget {
  final String group;
  final String name;

  const WidgetDetailPage({super.key, required this.group, required this.name});

  @override
  Widget build(BuildContext context) {
    // Convert kebab-case URL parameters to snake_case for identifier
    final snakeCaseName = name.replaceAll('-', '_');
    final identifier = '$group/$snakeCaseName';
    final metadata = WidgetLoader.findByIdentifier(identifier);

    if (metadata == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Widget Not Found')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          metadata.name,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Widget header
            _WidgetHeader(metadata: metadata),
            const SizedBox(height: 32),
            // Widget preview
            WidgetPreview(
              identifier: identifier,
              previewWidget: _getPreviewWidget(identifier),
            ),
            const SizedBox(height: 32),
            // Documentation
            if (metadata.docPath != null)
              FutureBuilder<String>(
                future: DocsLoader.loadMarkdown(metadata.docPath!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  return SizedBox(
                    height: 600,
                    child: MarkdownRenderer(
                      markdown: snapshot.data!,
                      previewWidgets: {
                        identifier:
                            _getPreviewWidget(identifier) ?? const SizedBox(),
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget? _getPreviewWidget(String identifier) {
    // Map identifiers to their demo widgets
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

class _WidgetHeader extends StatelessWidget {
  final WidgetMetadata metadata;

  const _WidgetHeader({required this.metadata});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            metadata.categoryName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Widget name
        Text(
          metadata.name,
          style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Description
        Text(
          metadata.description,
          style: GoogleFonts.inter(
            fontSize: 18,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        // Tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: metadata.tags.map((tag) {
            return Chip(
              label: Text(tag),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            );
          }).toList(),
        ),
      ],
    );
  }
}
