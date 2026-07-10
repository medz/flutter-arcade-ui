import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/widget_metadata.dart';
import '../services/widget_loader.dart';
import '../theme/arcade_theme.dart';

class WidgetPreview extends StatefulWidget {
  final String identifier;
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
  late final TabController _tabController;
  WidgetMetadata? _metadata;
  String? _demoCode;
  bool _loading = true;
  bool _copied = false;
  int _loadId = 0;
  Timer? _copyTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant WidgetPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identifier != widget.identifier) {
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    _copyTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final loadId = ++_loadId;
    final metadata = WidgetLoader.findByIdentifier(widget.identifier);
    if (mounted) {
      setState(() {
        _loading = true;
        _metadata = metadata;
        _demoCode = null;
        _copied = false;
      });
    }

    final code = metadata == null
        ? null
        : await WidgetLoader.loadDemoCode(metadata);
    if (!mounted || loadId != _loadId) return;
    setState(() {
      _demoCode = code;
      _loading = false;
    });
  }

  Future<void> _copy() async {
    final code = _demoCode;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    _copyTimer?.cancel();
    setState(() => _copied = true);
    _copyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_metadata == null) {
      return Text('Widget not found: ${widget.identifier}');
    }

    final height = MediaQuery.sizeOf(context).width < 700 ? 430.0 : 500.0;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: ArcadeColors.surface,
        border: Border.all(color: ArcadeColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 48,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: ArcadeColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    labelColor: ArcadeColors.violet,
                    unselectedLabelColor: ArcadeColors.muted,
                    indicatorColor: ArcadeColors.violet,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    tabs: const [
                      Tab(text: 'Preview'),
                      Tab(text: 'Code'),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    if (_tabController.index != 1) {
                      return const SizedBox(width: 12);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextButton.icon(
                        onPressed: _copy,
                        icon: Icon(
                          _copied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 16,
                        ),
                        label: Text(_copied ? 'Copied' : 'Copy'),
                        style: TextButton.styleFrom(
                          foregroundColor: _copied
                              ? ArcadeColors.aqua
                              : ArcadeColors.muted,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                RepaintBoundary(
                  child: ColoredBox(
                    color: const Color(0xFF0A0B10),
                    child: Center(
                      child:
                          widget.previewWidget ??
                          const Text('Preview unavailable'),
                    ),
                  ),
                ),
                ColoredBox(
                  color: const Color(0xFF0B0D12),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: SelectableText(
                      _demoCode ?? '// Demo code unavailable',
                      style: const TextStyle(
                        color: Color(0xFFD4D5DC),
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
