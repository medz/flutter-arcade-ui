import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unrouter/flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/arcade_brand.dart';
import '../../models/widget_metadata.dart';
import '../../services/widget_loader.dart';
import '../../theme/arcade_theme.dart';
import 'docs_search_delegate.dart';

const _githubUrl = 'https://github.com/medz/flutter-arcade-ui';

class DocsShell extends StatelessWidget {
  final Widget? child;

  const DocsShell({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: isDesktop ? 28 : 0,
        title: const ArcadeBrand(),
        actions: [
          IconButton(
            tooltip: 'Search widgets',
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              unawaited(
                showSearch(context: context, delegate: DocsSearchDelegate()),
              );
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Open GitHub',
            icon: const Icon(Icons.code_rounded),
            onPressed: () => unawaited(
              launchUrl(
                Uri.parse(_githubUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 22 : 10),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      drawer: isDesktop
          ? null
          : const Drawer(
              width: 300,
              backgroundColor: ArcadeColors.canvas,
              child: SafeArea(child: DocsSidebar()),
            ),
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 280,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: ArcadeColors.border)),
                ),
                child: DocsSidebar(),
              ),
            ),
          Expanded(child: child ?? const Outlet()),
        ],
      ),
    );
  }
}

class DocsSidebar extends StatelessWidget {
  const DocsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = useRouteURI(context).path;

    return Scrollbar(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          _SidebarLink(
            title: 'Home',
            icon: Icons.home_outlined,
            isSelected: currentPath == '/',
            onTap: () => _navigate(context, '/'),
          ),
          _SidebarLink(
            title: 'Getting Started',
            icon: Icons.rocket_launch_outlined,
            isSelected: currentPath == '/get-started',
            onTap: () => _navigate(context, '/get-started'),
          ),
          _SidebarLink(
            title: 'Widgets',
            icon: Icons.grid_view_rounded,
            isSelected: currentPath == '/widgets',
            onTap: () => _navigate(context, '/widgets'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          for (final group in WidgetLoader.groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
              child: Text(
                WidgetMetadata.capitalize(group).toUpperCase(),
                style: const TextStyle(
                  color: ArcadeColors.violet,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
            ),
            for (final widget in WidgetLoader.getWidgetsByGroup(group))
              _SidebarLink(
                title: widget.name,
                isSubItem: true,
                isSelected: currentPath == widget.routePath,
                onTap: () => _navigate(context, widget.routePath),
              ),
            const SizedBox(height: 12),
          ],
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
    required this.onTap,
    this.icon,
    this.isSelected = false,
    this.isSubItem = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? ArcadeColors.text : ArcadeColors.muted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected
            ? ArcadeColors.violet.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            constraints: const BoxConstraints(minHeight: 42),
            padding: EdgeInsets.symmetric(
              horizontal: isSubItem ? 14 : 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              border: isSelected
                  ? const Border(
                      left: BorderSide(color: ArcadeColors.violet, width: 3),
                    )
                  : null,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 19, color: color),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _navigate(BuildContext context, String path) {
  final scaffold = Scaffold.maybeOf(context);
  if (scaffold?.isDrawerOpen ?? false) scaffold!.closeDrawer();
  unawaited(useRouter(context).replace(path));
}
