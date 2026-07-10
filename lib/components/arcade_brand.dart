import 'package:flutter/material.dart';

import '../theme/arcade_theme.dart';

class ArcadeBrand extends StatelessWidget {
  final double markSize;

  const ArcadeBrand({super.key, this.markSize = 26});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ArcadeMark(size: markSize),
        const SizedBox(width: 12),
        Text(
          'Arcade UI',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class ArcadeMark extends StatelessWidget {
  final double size;

  const ArcadeMark({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) {
    final tileSize = (size - 4) / 2;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: _MarkTile(size: tileSize, color: ArcadeColors.violet),
          ),
          Align(
            alignment: Alignment.topRight,
            child: _MarkTile(size: tileSize, color: ArcadeColors.aqua),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: _MarkTile(size: tileSize, color: ArcadeColors.aqua),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: _MarkTile(size: tileSize, color: ArcadeColors.violet),
          ),
        ],
      ),
    );
  }
}

class _MarkTile extends StatelessWidget {
  final double size;
  final Color color;

  const _MarkTile({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: SizedBox.square(dimension: size),
    );
  }
}
