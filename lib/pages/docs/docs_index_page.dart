import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/widget_loader.dart';
import '../../models/widget_metadata.dart';

/// Documentation index page (/docs)
class DocsIndexPage extends StatelessWidget {
  const DocsIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Group widgets by category
    final groups = <String, List<WidgetMetadata>>{};
    for (var widget in WidgetLoader.widgets) {
      if (!groups.containsKey(widget.group)) {
        groups[widget.group] = [];
      }
      groups[widget.group]!.add(widget);
    }

    return Title(
      title: 'Widget Index - Flutter Arcade UI',
      color: Theme.of(context).primaryColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Widgets',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Widget Index',
              style: GoogleFonts.outfit(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'List of all the widgets provided by Arcade UI.',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),
            // All Widgets Section
            Text(
              'All widgets',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            ...groups.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          '${entry.key[0].toUpperCase()}${entry.key.substring(1)}',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${entry.value.length})',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: entry.value.asMap().entries.map((widgetEntry) {
                        final index = widgetEntry.key;
                        final widget = widgetEntry.value;
                        final isLast = index == entry.value.length - 1;

                        return _ComponentListItem(
                          widget: widget,
                          showDivider: !isLast,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ComponentListItem extends StatelessWidget {
  final WidgetMetadata widget;
  final bool showDivider;

  const _ComponentListItem({required this.widget, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.go('/widgets/${widget.identifier.replaceAll('_', '-')}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.1),
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.name,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  'View',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
