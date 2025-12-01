import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A component that displays widget source code with syntax highlighting and copy functionality.
class WidgetCode extends StatelessWidget {
  /// The source code to display
  final String code;

  /// Optional title for the code block
  final String? title;

  /// Whether to show the header with title and copy button
  final bool showHeader;

  const WidgetCode({
    super.key,
    required this.code,
    this.title,
    this.showHeader = true,
  });

  /// Static method to copy code to clipboard with feedback
  static Future<void> copyToClipboard(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: showHeader ? BorderRadius.circular(12) : null,
        border: showHeader
            ? Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with title and copy button (optional)
          if (showHeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF252525)
                    : const Color(0xFFEEEEEE),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (title != null) ...[
                    Expanded(
                      child: Text(
                        title!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (title == null) const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () => copyToClipboard(context, code),
                    tooltip: 'Copy code',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                  ),
                ],
              ),
            ),
          // Code content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                code,
                style: GoogleFonts.firaCode(
                  fontSize: 13,
                  height: 1.6,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
