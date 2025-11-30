import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/widget_loader.dart';
import '../models/widget_metadata.dart';

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
  bool _isCodeTabSelected = false;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadWidget();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    setState(() {
      _isCodeTabSelected = _tabController.index == 1;
    });
  }

  Future<void> _loadWidget() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final metadata = WidgetLoader.findByIdentifier(widget.identifier);
    if (metadata != null) {
      // Load DEMO code instead of source code for the Code tab
      final code = await WidgetLoader.loadDemoCode(metadata);
      if (!mounted) return;
      setState(() {
        _metadata = metadata;
        _sourceCode = code;
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    if (_sourceCode == null) return;
    await Clipboard.setData(ClipboardData(text: _sourceCode!));
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      type: MaterialType.transparency,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab bar with copy button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  // Tabs on the left
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Preview'),
                      Tab(text: 'Code'),
                    ],
                  ),
                  const Spacer(),
                  // Copy button on the right (only visible when Code tab is selected)
                  AnimatedOpacity(
                    opacity: _isCodeTabSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedSlide(
                      offset: _isCodeTabSelected
                          ? Offset.zero
                          : const Offset(0.2, 0),
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: _isCodeTabSelected ? _copyToClipboard : null,
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _copied
                                      ? Icons.check_rounded
                                      : Icons.copy_rounded,
                                  size: 16,
                                  color: _copied
                                      ? Colors.green
                                      : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _copied ? 'Copied!' : 'Copy',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Display code directly without header
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          _sourceCode!,
          style: GoogleFonts.firaCode(
            fontSize: 13,
            height: 1.6,
            color: isDark ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
