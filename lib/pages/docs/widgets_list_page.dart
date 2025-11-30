import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../services/widget_loader.dart';
import '../../models/widget_metadata.dart';

/// Widgets list page (/docs/widgets)
class WidgetsListPage extends StatefulWidget {
  const WidgetsListPage({super.key});

  @override
  State<WidgetsListPage> createState() => _WidgetsListPageState();
}

class _WidgetsListPageState extends State<WidgetsListPage> {
  String? _selectedGroup;
  String _searchQuery = '';

  List<WidgetMetadata> get _filteredWidgets {
    var widgets = WidgetLoader.widgets;

    if (_selectedGroup != null) {
      widgets = widgets.where((w) => w.group == _selectedGroup).toList();
    }

    if (_searchQuery.isNotEmpty) {
      widgets = WidgetLoader.search(_searchQuery);
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final groups = WidgetLoader.groups;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Widget Gallery',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search widgets...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String?>(
                  value: _selectedGroup,
                  hint: const Text('All Categories'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...groups.map(
                      (group) => DropdownMenuItem(
                        value: group,
                        child: Text(_capitalize(group)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedGroup = value);
                  },
                ),
              ],
            ),
          ),
          // Widgets grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredWidgets.length,
              itemBuilder: (context, index) {
                final widget = _filteredWidgets[index];
                return _WidgetCard(widget: widget);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}

class _WidgetCard extends StatelessWidget {
  final WidgetMetadata widget;

  const _WidgetCard({required this.widget});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go('/docs/${widget.group}/${_toKebabCase(widget.name)}');
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.categoryName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Widget name
              Text(
                widget.name,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Expanded(
                child: Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              // Tags
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.tags.take(3).map((tag) {
                  return Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 11)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _toKebabCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '-${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp(r'^-'), '');
  }
}
