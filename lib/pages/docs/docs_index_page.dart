import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unrouter/flutter.dart';

import '../../models/widget_metadata.dart';
import '../../services/widget_loader.dart';
import '../../theme/arcade_theme.dart';

class DocsIndexPage extends StatelessWidget {
  const DocsIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<WidgetMetadata>>{};
    for (final widget in WidgetLoader.widgets) {
      (groups[widget.group] ??= []).add(widget);
    }

    return Title(
      title: 'Widgets - Flutter Arcade UI',
      color: ArcadeColors.violet,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width < 700 ? 20 : 42,
            vertical: 40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Widget Index',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Browse every copy-ready widget in Arcade UI.',
                    style: TextStyle(
                      color: ArcadeColors.muted,
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 42),
                  for (final entry in groups.entries) ...[
                    _GroupHeader(
                      title: WidgetMetadata.capitalize(entry.key),
                      count: entry.value.length,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: ArcadeColors.surface,
                        border: Border.all(color: ArcadeColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (var i = 0; i < entry.value.length; i++)
                            _WidgetRow(
                              widget: entry.value[i],
                              showDivider: i != entry.value.length - 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;
  final int count;

  const _GroupHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 10),
        Text(
          '$count',
          style: const TextStyle(
            color: ArcadeColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WidgetRow extends StatelessWidget {
  final WidgetMetadata widget;
  final bool showDivider;

  const _WidgetRow({required this.widget, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => unawaited(useRouter(context).push(widget.routePath)),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(bottom: BorderSide(color: ArcadeColors.border))
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ArcadeColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: ArcadeColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
