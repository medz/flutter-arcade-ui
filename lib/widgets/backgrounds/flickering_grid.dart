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
    this.squareSize = 4.0,
    this.gridGap = 6.0,
    this.flickerChance = 0.3,
    this.color = const Color(0xFF000000),
    this.maxOpacity = 0.3,
    this.duration = const Duration(seconds: 1),
    this.child,
  });

  @override
  State<FlickeringGrid> createState() => _FlickeringGridState();
}

class _RepaintNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class _FlickeringGridState extends State<FlickeringGrid>
    with SingleTickerProviderStateMixin<FlickeringGrid> {
  late final controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  final random = Random();
  final repaintNotifier = _RepaintNotifier();

  Size? size;
  int cols = 0;
  int rows = 0;
  List<double> squares = List.empty();

  @override
  void initState() {
    super.initState();
    controller
      ..repeat()
      ..addListener(tick);
  }

  void tick() {
    if (squares.isEmpty) return;

    const dt = 0.016;
    for (int i = 0; i < squares.length; i++) {
      if (random.nextDouble() < widget.flickerChance * dt) {
        squares[i] = random.nextDouble() * widget.maxOpacity;
      }
    }
    repaintNotifier.notify();
  }

  void maybeSetup(Size size) {
    if (size != this.size) {
      this.size = size;
      cols = (size.width / (widget.squareSize + widget.gridGap)).floor();
      rows = (size.height / (widget.squareSize + widget.gridGap)).floor();
      squares = .generate(
        cols * rows,
        (_) => random.nextDouble() * widget.maxOpacity,
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    repaintNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        maybeSetup(size);

        return CustomPaint(
          size: size,
          painter: _FlickeringGridPainter(
            squares: squares,
            cols: cols,
            rows: rows,
            squareSize: widget.squareSize,
            gridGap: widget.gridGap,
            color: widget.color,
            repaint: repaintNotifier,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _FlickeringGridPainter extends CustomPainter {
  final Iterable<double> squares;
  final int cols;
  final int rows;
  final double squareSize;
  final double gridGap;
  final Color color;

  _FlickeringGridPainter({
    required this.squares,
    required this.cols,
    required this.rows,
    required this.squareSize,
    required this.gridGap,
    required this.color,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = .fill;
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        final index = i * rows + j;
        if (index >= squares.length) continue;

        final x = i * (squareSize + gridGap);
        final y = j * (squareSize + gridGap);

        paint.color = color.withValues(alpha: squares.elementAt(index));
        canvas.drawRect(.fromLTWH(x, y, squareSize, squareSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlickeringGridPainter oldDelegate) {
    return cols != oldDelegate.cols ||
        rows != oldDelegate.rows ||
        squareSize != oldDelegate.squareSize ||
        gridGap != oldDelegate.gridGap ||
        color != oldDelegate.color;
  }
}
