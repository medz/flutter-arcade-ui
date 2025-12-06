import 'dart:math' as math;
import 'package:flutter/widgets.dart';

class GlidingGlowBox extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration speed;
  final double borderWidth;
  final double? borderRadius;
  final double glowPadding;

  const GlidingGlowBox({
    super.key,
    required this.child,
    this.color = const Color(0xFFE0E0E0),
    this.speed = const Duration(seconds: 6),
    this.borderWidth = 3.0,
    this.borderRadius,
    this.glowPadding = 0,
  });

  @override
  State<GlidingGlowBox> createState() => _GlidingGlowBoxState();
}

class _GlidingGlowBoxState extends State<GlidingGlowBox>
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
    final inset = widget.borderWidth / 2 + widget.glowPadding;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GlidingGlowBoxPainter(
            progress: _controller.value,
            color: widget.color,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
          ),
          child: Padding(padding: EdgeInsets.all(inset), child: child),
        );
      },
      child: widget.child,
    );
  }
}

class _GlidingGlowBoxPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double borderWidth;
  final double? borderRadius;

  _GlidingGlowBoxPainter({
    required this.progress,
    required this.color,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radiusValue = borderRadius ?? size.height / 2;
    final radius = Radius.circular(radiusValue);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    final sweep = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: [
        color.withOpacity(0.0),
        color.withOpacity(0.0),
        color.withOpacity(0.6),
        color,
        color.withOpacity(0.6),
        color.withOpacity(0.0),
      ],
      stops: const [0.0, 0.32, 0.42, 0.5, 0.58, 0.74],
      transform: GradientRotation(math.pi * 2 * progress),
    );

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = sweep.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(rrect, glowPaint);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 0.5
      ..shader = sweep.createShader(rect);
    canvas.drawRRect(rrect.inflate(-borderWidth * 0.25), highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _GlidingGlowBoxPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.borderWidth != borderWidth;
  }
}
