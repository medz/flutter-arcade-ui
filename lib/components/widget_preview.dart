import 'package:flutter/material.dart';
import '../services/widget_loader.dart';
import '../models/widget_metadata.dart';
import 'widget_code.dart';

/// A component that displays a widget preview with tabs for Preview and Code view.
/// Supports responsive sizing: square on mobile, 16:9 on desktop.
class WidgetPreview extends StatefulWidget {
  /// Widget identifier (e.g., "cards/three_d_card")
  final String identifier;

  /// Optional custom preview widget
  final Widget? previewWidget;

  const WidgetPreview({
    super.key,
    required this.identifier,
    this.previewWidget,
  });

  @override
  State<WidgetPreview> createState() => _WidgetPreviewState();
}

class _WidgetPreviewState extends State<WidgetPreview>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WidgetMetadata? _metadata;
  String? _sourceCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWidget();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWidget() async {
    setState(() => _isLoading = true);

    final metadata = WidgetLoader.findByIdentifier(widget.identifier);
    if (metadata != null) {
      // Load DEMO code instead of source code for the Code tab
      final code = await WidgetLoader.loadDemoCode(metadata);
      setState(() {
        _metadata = metadata;
        _sourceCode = code;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_metadata == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Widget not found: ${widget.identifier}'),
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab bar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Preview'),
                        Tab(text: 'Code'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swipe gestures
                children: [
                  // Preview tab
                  _buildPreviewTab(),
                  // Code tab
                  _buildCodeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTab() {
    return Container(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      child: Center(
        child:
            widget.previewWidget ??
            const Text(
              'Preview widget not provided.\nPass previewWidget to WidgetPreview.',
              textAlign: TextAlign.center,
            ),
      ),
    );
  }

  Widget _buildCodeTab() {
    if (_sourceCode == null) {
      return const Center(child: Text('Source code not available'));
    }

    return WidgetCode(code: _sourceCode!, title: '${_metadata!.name}.dart');
  }
}
