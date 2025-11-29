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
    _drawGlow(canvas, Offset(topX, topY), glowWidth, glowHeight);

    // Bottom glow - moves from right to left
    final bottomX =
        size.width + glowWidth / 2 - progress * (moveRange + glowWidth);
    final bottomY = size.height - glowHeight / 2;
    _drawGlow(canvas, Offset(bottomX, bottomY), glowWidth, glowHeight);

    canvas.restore();
  }

  void _drawGlow(Canvas canvas, Offset center, double width, double height) {
    // Use scale transform to properly render ellipse with RadialGradient
    final scaleX = width / height;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scaleX, 1.0);

    final radius = height / 2;
    final circleRect = Rect.fromCircle(center: Offset.zero, radius: radius);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0)],
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
