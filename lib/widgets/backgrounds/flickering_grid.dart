import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

class FlickeringGrid extends StatefulWidget {
  final double squareSize;
  final double gridGap;
  final double flickerChance;
  final Color color;
  final double maxOpacity;
  final Duration duration;
  final Widget? child;

  const FlickeringGrid({
    super.key,
    this.squareSize = 4,
    this.gridGap = 6,
    this.flickerChance = 0.3,
    this.color = const Color(0xFF000000),
    this.maxOpacity = 0.3,
    this.duration = const Duration(seconds: 1),
    this.child,
  }) : assert(squareSize > 0, 'squareSize must be greater than 0'),
       assert(gridGap >= 0, 'gridGap must be non-negative'),
       assert(
         flickerChance >= 0 && flickerChance <= 1,
         'flickerChance must be between 0 and 1',
       ),
       assert(
         maxOpacity >= 0 && maxOpacity <= 1,
         'maxOpacity must be between 0 and 1',
       );

  @override
  State<FlickeringGrid> createState() => _FlickeringGridState();
}

class _FlickeringGridState extends State<FlickeringGrid>
    with SingleTickerProviderStateMixin {
  static const _frameInterval = Duration(milliseconds: 33);

  final _random = Random();
  final _repaint = _RepaintNotifier();
  late final AnimationController _controller;
  Size _size = Size.zero;
  List<double> _from = [];
  List<double> _to = [];
  Duration _lastRepaintElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(_onAnimationTick)
      ..addStatusListener(_onAnimationStatus);
    unawaited(_controller.forward());
  }

  @override
  void didUpdateWidget(covariant FlickeringGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.squareSize != widget.squareSize ||
        oldWidget.gridGap != widget.gridGap ||
        oldWidget.maxOpacity != widget.maxOpacity) {
      _size = Size.zero;
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onAnimationTick)
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _onAnimationTick() {
    final elapsed = _controller.lastElapsedDuration ?? Duration.zero;
    if (!_controller.isCompleted &&
        elapsed - _lastRepaintElapsed < _frameInterval) {
      return;
    }
    _lastRepaintElapsed = elapsed;
    _repaint.notify();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _to.isEmpty) return;
    for (var i = 0; i < _to.length; i++) {
      _from[i] = _to[i];
      if (_random.nextDouble() <= widget.flickerChance) {
        _to[i] = _random.nextDouble() * widget.maxOpacity;
      }
    }
    _lastRepaintElapsed = Duration.zero;
    unawaited(_controller.forward(from: 0));
  }

  void _setup(Size size) {
    if (size == _size) return;
    _size = size;
    final step = widget.squareSize + widget.gridGap;
    final columns = (size.width / step).ceil();
    final rows = (size.height / step).ceil();
    final count = max(0, columns * rows);
    _from = List.generate(
      count,
      (_) => _random.nextDouble() * widget.maxOpacity,
    );
    _to = List.of(_from);
  }

  @override
  Widget build(BuildContext context) {
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final shouldAnimate = !animationsDisabled && widget.flickerChance > 0;
    if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    } else if (shouldAnimate && !_controller.isAnimating) {
      unawaited(_controller.forward(from: _controller.value));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded =
            constraints.hasBoundedWidth && constraints.hasBoundedHeight;
        final size = bounded ? constraints.biggest : Size.zero;
        _setup(size);

        return CustomPaint(
          painter: _FlickeringGridPainter(
            from: _from,
            to: _to,
            progress: _controller,
            repaint: _repaint,
            squareSize: widget.squareSize,
            gridGap: widget.gridGap,
            color: widget.color,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _RepaintNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class _FlickeringGridPainter extends CustomPainter {
  final List<double> from;
  final List<double> to;
  final Animation<double> progress;
  final double squareSize;
  final double gridGap;
  final Color color;
  final Paint _paint = Paint()..style = PaintingStyle.fill;

  _FlickeringGridPainter({
    required this.from,
    required this.to,
    required this.progress,
    required Listenable repaint,
    required this.squareSize,
    required this.gridGap,
    required this.color,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final step = squareSize + gridGap;
    final columns = (size.width / step).ceil();
    final rows = (size.height / step).ceil();
    final count = min(from.length, to.length);

    for (var column = 0; column < columns; column++) {
      for (var row = 0; row < rows; row++) {
        final index = column * rows + row;
        if (index >= count) return;
        final opacity =
            from[index] + (to[index] - from[index]) * progress.value;
        _paint.color = color.withValues(alpha: opacity);
        canvas.drawRect(
          Rect.fromLTWH(column * step, row * step, squareSize, squareSize),
          _paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlickeringGridPainter oldDelegate) {
    return from != oldDelegate.from ||
        to != oldDelegate.to ||
        squareSize != oldDelegate.squareSize ||
        gridGap != oldDelegate.gridGap ||
        color != oldDelegate.color;
  }
}
