import 'package:flutter/material.dart';

class StarBorder extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration speed;
  final double borderWidth;

  const StarBorder({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.speed = const Duration(seconds: 6),
    this.borderWidth = 3.0,
  });

  @override
  State<StarBorder> createState() => _StarBorderState();
}

class _StarBorderState extends State<StarBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.speed)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarBorderPainter(
            progress: _controller.value,
            color: widget.color,
            borderWidth: widget.borderWidth,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: widget.borderWidth),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _StarBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double borderWidth;

  _StarBorderPainter({
    required this.progress,
    required this.color,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final borderRadius = size.height / 2;

    // Child rect (inside the padding)
    final childRect = Rect.fromLTRB(
      borderWidth,
      borderWidth,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final childBorderRadius = (size.height - borderWidth * 2) / 2;

    // Clip to area outside child
    final outerRRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );
    final innerRRect = RRect.fromRectAndRadius(
      childRect,
      Radius.circular(childBorderRadius),
    );

    final clipPath = Path()
      ..addRRect(outerRRect)
      ..addRRect(innerRRect)
      ..fillType = PathFillType.evenOdd;

    canvas.save();
    canvas.clipPath(clipPath);

    // Glow dimensions
    final glowWidth = size.width * 0.6;
    final glowHeight = size.height * 0.5;

    // Movement range (independent of glow size)
    final moveRange = size.width;

    // Top glow - moves from left to right
    final topX = -glowWidth / 2 + progress * (moveRange + glowWidth);
    final topY = glowHeight / 2;
    final topLeftEdge = topX - glowWidth / 2;
    final topRightEdge = topX + glowWidth / 2;
    final topOpacity = _calculateCornerOpacity(
      topLeftEdge,
      topRightEdge,
      size.width,
    );
    _drawGlow(canvas, Offset(topX, topY), glowWidth, glowHeight, topOpacity);

    // Bottom glow - moves from right to left
    final bottomX =
        size.width + glowWidth / 2 - progress * (moveRange + glowWidth);
    final bottomY = size.height - glowHeight / 2;
    final bottomLeftEdge = bottomX - glowWidth / 2;
    final bottomRightEdge = bottomX + glowWidth / 2;
    final bottomOpacity = _calculateCornerOpacity(
      bottomLeftEdge,
      bottomRightEdge,
      size.width,
    );
    _drawGlow(
      canvas,
      Offset(bottomX, bottomY),
      glowWidth,
      glowHeight,
      bottomOpacity,
    );

    canvas.restore();
  }

  double _calculateCornerOpacity(
    double leftEdge,
    double rightEdge,
    double width,
  ) {
    final fadeZone = width * 0.1;

    // Left corner: fade based on left edge position
    if (leftEdge < fadeZone) {
      final leftOpacity = (leftEdge / fadeZone).clamp(0.2, 1.0);
      // Right corner: also check right edge
      if (rightEdge > width - fadeZone) {
        final rightOpacity = ((width - rightEdge) / fadeZone).clamp(0.2, 1.0);
        return (leftOpacity * rightOpacity).clamp(0.2, 1.0);
      }
      return leftOpacity;
    }

    // Right corner: fade based on right edge position
    if (rightEdge > width - fadeZone) {
      return ((width - rightEdge) / fadeZone).clamp(0.2, 1.0);
    }

    return 1.0;
  }

  void _drawGlow(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    double opacity,
  ) {
    // Use scale transform to properly render ellipse with RadialGradient
    final scaleX = width / height;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scaleX, 1.0);

    final radius = height / 2;
    final circleRect = Rect.fromCircle(center: Offset.zero, radius: radius);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.8 * opacity),
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(circleRect);

    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StarBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.borderWidth != borderWidth;
  }
}
