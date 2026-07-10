import 'package:flutter/material.dart';

import 'liquid_glass_tab_bars.dart';

class LiquidGlassTabBarsDemo extends StatefulWidget {
  const LiquidGlassTabBarsDemo({super.key});

  @override
  State<LiquidGlassTabBarsDemo> createState() => _LiquidGlassTabBarsDemoState();
}

class _LiquidGlassTabBarsDemoState extends State<LiquidGlassTabBarsDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SizedBox(
          height: 360,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                const Positioned.fill(child: _PlaceholderContent()),
                Positioned(
                  left: 34,
                  right: 34,
                  bottom: 16,
                  child: LiquidGlassTabBars(
                    initialIndex: _index,
                    onChanged: (index) => setState(() => _index = index),
                    useSafeArea: false,
                    height: 64,
                    iconSize: 20,
                    iconLabelSpacing: 1,
                    labelFontSize: 10,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 5,
                    ),
                    indicatorPadding: const EdgeInsets.symmetric(
                      horizontal: -10,
                      vertical: 2,
                    ),
                    borderRadius: 32,
                    indicatorRadius: 30,
                    backgroundColor: const Color(0xD0FFFFFF),
                    borderColor: const Color(0xB8FFFFFF),
                    sheenColor: const Color(0xC2FFFFFF),
                    sheenSecondaryColor: const Color(0x75FFFFFF),
                    indicatorColor: const Color(0x2EFFFFFF),
                    indicatorBorderColor: const Color(0xD9FFFFFF),
                    selectedColor: const Color(0xFFC13DFF),
                    unselectedColor: const Color(0xFFF7F7F7),
                    shadowColor: const Color(0x3D000000),
                    items: const [
                      LiquidGlassTabBarItem(
                        label: 'Home',
                        icon: Icon(Icons.home_rounded),
                      ),
                      LiquidGlassTabBarItem(
                        label: 'New',
                        icon: Icon(Icons.grid_view_rounded),
                      ),
                      LiquidGlassTabBarItem(
                        label: 'Library',
                        icon: Icon(Icons.podcasts_rounded),
                      ),
                    ],
                    trailingItem: const LiquidGlassTabBarItem(
                      label: 'Search',
                      icon: Icon(Icons.search_rounded),
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

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF050505),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Placeholder(width: 180, height: 18, radius: 5),
            const SizedBox(height: 22),
            SizedBox(
              height: 172,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, _) => const _PlaceholderCard(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, _) =>
                    const _Placeholder(width: 140, height: 120, radius: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Placeholder(width: 140, height: 126, radius: 8),
          SizedBox(height: 9),
          _Placeholder(width: 64, height: 9, radius: 3),
          SizedBox(height: 7),
          _Placeholder(width: 88, height: 9, radius: 3),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Placeholder({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}
