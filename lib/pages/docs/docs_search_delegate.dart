import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unrouter/flutter.dart';

import '../../models/widget_metadata.dart';
import '../../services/widget_loader.dart';
import '../../theme/arcade_theme.dart';

class DocsSearchDelegate extends SearchDelegate<WidgetMetadata?> {
  @override
  String get searchFieldLabel => 'Search widgets';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Clear search',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Close search',
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults(context);

  Widget _buildResults(BuildContext context) {
    final results = WidgetLoader.search(query.trim());
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: ArcadeColors.muted,
              ),
              const SizedBox(height: 16),
              Text(
                query.isEmpty
                    ? 'Type to search the widget gallery.'
                    : 'No widgets match “$query”.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ArcadeColors.muted, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final widget = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          title: Text(
            widget.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            widget.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: ArcadeColors.muted, fontSize: 13),
          ),
          trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
          onTap: () {
            close(context, widget);
            unawaited(useRouter(context).push(widget.routePath));
          },
        );
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: ArcadeColors.canvas,
        titleTextStyle: const TextStyle(
          color: ArcadeColors.text,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
