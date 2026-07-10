import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/arcade_theme.dart';

class WidgetCode extends StatelessWidget {
  final String code;
  final String? title;
  final bool showHeader;

  const WidgetCode({
    super.key,
    required this.code,
    this.title,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0D12),
        border: Border.all(color: ArcadeColors.border),
        borderRadius: BorderRadius.circular(9),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader)
            Container(
              constraints: const BoxConstraints(minHeight: 42),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: ArcadeColors.surfaceRaised,
                border: Border(bottom: BorderSide(color: ArcadeColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? 'dart',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ArcadeColors.muted,
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy code',
                    onPressed: () => _copy(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                  ),
                ],
              ),
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                code,
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
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
