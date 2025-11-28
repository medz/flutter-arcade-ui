import 'package:alien_signals/alien_signals.dart';
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
    this.color = const Color(0),
    this.maxOpacity = 0.3,
    this.duration = const Duration(seconds: 1),
    this.child,
  });

  @override
  State<FlickeringGrid> createState() => _FlickeringGridState();
}

class _FlickeringGridState extends State<FlickeringGrid>
    with SingleTickerProviderStateMixin<FlickeringGrid> {
  late final controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final squares = <Signal<double>>[];

  Size? cachedSize;
  int cols = 0;
  int rows = 0;

  @override
  void initState() {
    super.initState();
    controller
      ..repeat()
      ..addListener(tick);
  }

  void tick() {}

  void setup(Size size) {
    if (size == cachedSize) return;
    cols = (size.width / (widget.squareSize + widget.gridGap)).floor();
    rows = (size.height / (widget.squareSize + widget.gridGap)).floor();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight),
            cols = (size.width / (widget.squareSize + widget.gridGap)).floor(),
            rows = (size.height / (widget.squareSize + widget.gridGap)).floor();

        setup(size);

        return Text("1");
      },
    );
  }
}

//   void _onTick() {
//     if (_squares.isEmpty) return;

//     double dt = 0.016; // approx 60fps

//     bool changed = false;
//     for (int i = 0; i < _squares.length; i++) {
//       if (_random.nextDouble() < widget.flickerChance * dt) {
//         _squares[i] = _random.nextDouble() * widget.maxOpacity;
//         changed = true;
//       }
//     }

//     if (changed) {
//       setState(() {});
//     }
//   }

//   void _setupGrid(Size size) {
//     if (_lastSize == size) return;
//     _lastSize = size;

//     _cols = (size.width / (widget.squareSize + widget.gridGap)).floor();
//     _rows = (size.height / (widget.squareSize + widget.gridGap)).floor();

//     _squares = List.generate(
//       _cols * _rows,
//       (_) => _random.nextDouble() * widget.maxOpacity,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         _setupGrid(Size(constraints.maxWidth, constraints.maxHeight));
//         return CustomPaint(
//           size: Size(constraints.maxWidth, constraints.maxHeight),
//           painter: _FlickeringGridPainter(
//             squares: _squares,
//             cols: _cols,
//             rows: _rows,
//             squareSize: widget.squareSize,
//             gridGap: widget.gridGap,
//             color: widget.color,
//           ),
//           child: widget.child,
//         );
//       },
//     );
//   }
// }

// class _FlickeringGridPainter extends CustomPainter {
//   final List<double> squares;
//   final int cols;
//   final int rows;
//   final double squareSize;
//   final double gridGap;
//   final Color color;

//   _FlickeringGridPainter({
//     required this.squares,
//     required this.cols,
//     required this.rows,
//     required this.squareSize,
//     required this.gridGap,
//     required this.color,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;

//     for (int i = 0; i < cols; i++) {
//       for (int j = 0; j < rows; j++) {
//         int index = i * rows + j;
//         if (index >= squares.length) continue;

//         double opacity = squares[index];
//         paint.color = color.withOpacity(opacity);

//         double x = i * (squareSize + gridGap);
//         double y = j * (squareSize + gridGap);

//         canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _FlickeringGridPainter oldDelegate) {
//     return true; // Always repaint as we are animating
//   }
// }
