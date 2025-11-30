import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/widget_loader.dart';
import '../../models/widget_metadata.dart';
import 'docs_search_delegate.dart';

class DocsShell extends StatelessWidget {
  final Widget child;

  const DocsShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.widgets, size: 24),
            const SizedBox(width: 12),
            Text(
              'Arcade UI',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 32),
            const SizedBox(width: 32),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DocsSearchDelegate());
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () => launchUrl(
              Uri.parse('https://github.com/medz/flutter-arcade-ui'),
            ),
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      drawer: !isDesktop ? const Drawer(child: DocsSidebar()) : null,
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 280,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: const DocsSidebar(),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class DocsSidebar extends StatelessWidget {
  const DocsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SidebarLink(
                    title: 'Home',
                    icon: Icons.home_outlined,
                    isSelected: currentPath == '/',
                    onTap: () => context.go('/'),
                  ),
                  const SizedBox(height: 8),
                  _SidebarLink(
                    title: 'Getting Started',
                    icon: Icons.rocket_launch_outlined,
                    isSelected: currentPath == '/get-started',
                    onTap: () => context.go('/get-started'),
                  ),
                  const SizedBox(height: 8),
                  _SidebarLink(
                    title: 'Widgets',
                    icon: Icons.widgets_outlined,
                    isSelected: currentPath == '/widgets',
                    onTap: () => context.go('/widgets'),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  ...WidgetLoader.groups.map((group) {
                    final widgets = WidgetLoader.getWidgetsByGroup(group);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Text(
                            WidgetMetadata.capitalize(group),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        ...widgets.map((widget) {
                          final path =
                              '/widgets/${widget.identifier.replaceAll('_', '-')}';
                          return _SidebarLink(
                            title: widget.name,
                            isSelected: currentPath == path,
                            isSubItem: true,
                            onTap: () => context.go(path),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarLink extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool isSelected;
  final bool isSubItem;
  final VoidCallback onTap;

  const _SidebarLink({
    required this.title,
    this.icon,
    this.isSelected = false,
    this.isSubItem = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: isSubItem ? 12 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            if (isSubItem) const SizedBox(width: 8),
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
