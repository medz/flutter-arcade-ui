import 'dart:async';
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
  }) : assert(borderWidth > 0, 'borderWidth must be greater than 0'),
       assert(
         borderRadius == null || borderRadius >= 0,
         'borderRadius must be non-negative',
       ),
       assert(glowPadding >= 0, 'glowPadding must be non-negative');

  @override
  State<GlidingGlowBox> createState() => _GlidingGlowBoxState();
}

class _GlidingGlowBoxState extends State<GlidingGlowBox>
    with SingleTickerProviderStateMixin {
  static const _frameInterval = Duration(milliseconds: 33);

  late final AnimationController _controller;
  final _repaint = _RepaintNotifier();
  Duration _lastRepaintElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.speed)
      ..addListener(_onAnimationTick);
    unawaited(_controller.repeat(reverse: true));
  }

  void _onAnimationTick() {
    final elapsed = _controller.lastElapsedDuration ?? Duration.zero;
    if (elapsed - _lastRepaintElapsed < _frameInterval) return;
    _lastRepaintElapsed = elapsed;
    _repaint.notify();
  }

  @override
  void didUpdateWidget(covariant GlidingGlowBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _controller.duration = widget.speed;
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onAnimationTick)
      ..dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (animationsDisabled && _controller.isAnimating) {
      _controller.stop();
    } else if (!animationsDisabled && !_controller.isAnimating) {
      _lastRepaintElapsed = Duration.zero;
      unawaited(_controller.repeat(reverse: true));
    }

    final inset = widget.borderWidth / 2 + widget.glowPadding;

    return CustomPaint(
      painter: _GlidingGlowBoxPainter(
        progress: _controller,
        color: widget.color,
        borderWidth: widget.borderWidth,
        borderRadius: widget.borderRadius,
        repaint: _repaint,
      ),
      child: Padding(padding: EdgeInsets.all(inset), child: widget.child),
    );
  }
}

class _RepaintNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class _GlidingGlowBoxPainter extends CustomPainter {
  final Animation<double> progress;
  final Color color;
  final double borderWidth;
  final double? borderRadius;

  _GlidingGlowBoxPainter({
    required this.progress,
    required this.color,
    required this.borderWidth,
    required this.borderRadius,
    required Listenable repaint,
  }) : super(repaint: repaint);

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
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.6),
        color,
        color.withValues(alpha: 0.6),
        color.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.32, 0.42, 0.5, 0.58, 0.74],
      transform: GradientRotation(math.pi * 2 * progress.value),
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
    return oldDelegate.color != color ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}
