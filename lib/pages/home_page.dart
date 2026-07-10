import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unrouter/flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/arcade_brand.dart';
import '../theme/arcade_theme.dart';
import '../widgets/backgrounds/flickering_grid.dart';
import '../widgets/borders/gliding_glow_box.dart';
import '../widgets/navigations/motion_tabs.dart';

const _githubUrl = 'https://github.com/medz/flutter-arcade-ui';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Flutter Arcade UI',
      color: ArcadeColors.violet,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: RepaintBoundary(
                child: FlickeringGrid(
                  color: ArcadeColors.violet,
                  squareSize: 2,
                  gridGap: 16,
                  flickerChance: 0.12,
                  maxOpacity: 0.2,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.15, -0.2),
                    radius: 1.15,
                    colors: [
                      ArcadeColors.canvas.withValues(alpha: 0.3),
                      ArcadeColors.canvas.withValues(alpha: 0.94),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const _HomeHeader(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 980;
                        return SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            isDesktop ? 48 : 24,
                            isDesktop ? 44 : 28,
                            isDesktop ? 48 : 24,
                            40,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1500),
                              child: isDesktop
                                  ? const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(flex: 5, child: _HeroCopy()),
                                        SizedBox(width: 44),
                                        Expanded(
                                          flex: 7,
                                          child: _WidgetStage(),
                                        ),
                                      ],
                                    )
                                  : const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _HeroCopy(),
                                        SizedBox(height: 48),
                                        _WidgetStage(),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 48),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ArcadeColors.border)),
      ),
      child: Row(
        children: [
          const ArcadeBrand(markSize: 28),
          const Spacer(),
          if (!compact) ...[
            _HeaderLink(
              label: 'Widgets',
              onTap: () => _push(context, '/widgets'),
            ),
            _HeaderLink(
              label: 'Get started',
              onTap: () => _push(context, '/get-started'),
            ),
            _HeaderLink(label: 'GitHub', onTap: _openGitHub),
          ] else
            IconButton(
              tooltip: 'Browse widgets',
              onPressed: () => _push(context, '/widgets'),
              icon: const Icon(Icons.grid_view_rounded),
            ),
        ],
      ),
    );
  }
}

class _HeaderLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HeaderLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: ArcadeColors.text,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final headlineSize = width >= 1200 ? 64.0 : (width >= 600 ? 52.0 : 42.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Beautiful Flutter\n'),
              const TextSpan(
                text: 'widgets,',
                style: TextStyle(color: ArcadeColors.violet),
              ),
              const TextSpan(text: ' ready to\nmake yours.'),
            ],
          ),
          style: TextStyle(
            fontSize: headlineSize,
            height: 1.04,
            letterSpacing: -2.4,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const Text(
            'Browse crafted interactions, copy the code, and ship something '
            'that feels considered.',
            style: TextStyle(
              color: ArcadeColors.muted,
              fontSize: 18,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 34),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => _push(context, '/widgets'),
              style: FilledButton.styleFrom(
                backgroundColor: ArcadeColors.violet,
                foregroundColor: ArcadeColors.canvas,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 19),
              label: const Text('Explore widgets'),
            ),
            OutlinedButton.icon(
              onPressed: () => _push(context, '/get-started'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ArcadeColors.text,
                side: const BorderSide(color: ArcadeColors.aqua),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 19),
              label: const Text('Get started'),
            ),
          ],
        ),
      ],
    );
  }
}

class _WidgetStage extends StatelessWidget {
  const _WidgetStage();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 520),
      decoration: BoxDecoration(
        color: ArcadeColors.surface.withValues(alpha: 0.94),
        border: Border.all(color: ArcadeColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 680;
          final cells = const [
            _ShowcaseCell(
              title: 'Flickering grid',
              icon: Icons.grid_view_rounded,
              preview: _GridPreview(),
              code: 'FlickeringGrid(\n  squareSize: 4,\n  gridGap: 8,\n)',
            ),
            _ShowcaseCell(
              title: 'Motion tabs',
              icon: Icons.motion_photos_on_outlined,
              preview: _TabsPreview(),
              code: 'MotionTabs(\n  items: tabs,\n  initialIndex: 0,\n)',
            ),
            _ShowcaseCell(
              title: 'Glowing border',
              icon: Icons.crop_free_rounded,
              preview: _GlowPreview(),
              code: 'GlidingGlowBox(\n  color: aqua,\n  borderRadius: 16,\n)',
            ),
          ];

          if (stacked) {
            return Column(children: cells);
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cells.length; i++) ...[
                Expanded(child: cells[i]),
                if (i != cells.length - 1)
                  const VerticalDivider(width: 1, thickness: 1),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ShowcaseCell extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget preview;
  final String code;

  const _ShowcaseCell({
    required this.title,
    required this.icon,
    required this.preview,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 19, color: ArcadeColors.violet),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        SizedBox(height: 270, child: preview),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(18),
          child: SelectableText(
            code,
            style: const TextStyle(
              color: ArcadeColors.muted,
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.65,
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPreview extends StatelessWidget {
  const _GridPreview();

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: FlickeringGrid(
        color: ArcadeColors.violet,
        squareSize: 5,
        gridGap: 12,
        flickerChance: 0.18,
        maxOpacity: 0.72,
      ),
    );
  }
}

class _TabsPreview extends StatelessWidget {
  const _TabsPreview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Center(
        child: MotionTabs(
          height: 46,
          borderRadius: 12,
          gap: 4,
          padding: const EdgeInsets.all(6),
          items: const [
            MotionTabItem(label: 'Preview'),
            MotionTabItem(label: 'Code'),
          ],
        ),
      ),
    );
  }
}

class _GlowPreview extends StatelessWidget {
  const _GlowPreview();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: GlidingGlowBox(
          color: ArcadeColors.aqua,
          borderRadius: 18,
          borderWidth: 2,
          child: const SizedBox(
            width: 126,
            height: 126,
            child: Icon(
              Icons.view_in_ar_rounded,
              size: 54,
              color: ArcadeColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

void _push(BuildContext context, String path) {
  unawaited(useRouter(context).push(path));
}

void _openGitHub() {
  unawaited(
    launchUrl(Uri.parse(_githubUrl), mode: LaunchMode.externalApplication),
  );
}
