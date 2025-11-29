import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

class BlackHoleBackground extends StatefulWidget {
  final Color strokeColor;
  final int numberOfLines;
  final int numberOfDiscs;
  final Color particleColor;
  final Widget? child;

  const BlackHoleBackground({
    super.key,
    this.strokeColor = const Color(0x33737373),
    this.numberOfLines = 50,
    this.numberOfDiscs = 50,
    this.particleColor = const Color(0x33FFFFFF),
    this.child,
  });

  @override
  State<BlackHoleBackground> createState() => _BlackHoleBackgroundState();
}

class _BlackHoleBackgroundState extends State<BlackHoleBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  List<_Disc> _discs = [];
  List<List<_Point>> _lines = [];
  List<_Particle> _particles = [];
  _Clip _clip = _Clip();
  _Disc _startDisc = _Disc(p: 0, x: 0, y: 0, w: 0, h: 0);
  _Disc _endDisc = _Disc(p: 0, x: 0, y: 0, w: 0, h: 0);
  Size _rect = Size.zero;
  _ParticleArea _particleArea = _ParticleArea();
  ui.Picture? _linesPicture;

  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _easeInExpo(double p) {
    return p == 0 ? 0 : math.pow(2, 10 * (p - 1)).toDouble();
  }

  double _tweenValue(
    double start,
    double end,
    double p, {
    bool inExpo = false,
  }) {
    final delta = end - start;
    final easeVal = inExpo ? _easeInExpo(p) : p;
    return start + delta * easeVal;
  }

  void _tweenDisc(_Disc disc) {
    disc.x = _tweenValue(_startDisc.x, _endDisc.x, disc.p);
    disc.y = _tweenValue(_startDisc.y, _endDisc.y, disc.p, inExpo: true);
    disc.w = _tweenValue(_startDisc.w, _endDisc.w, disc.p);
    disc.h = _tweenValue(_startDisc.h, _endDisc.h, disc.p);
  }

  void _setSize(Size size) {
    if (_rect == size) return;
    _rect = size;
    _init();
  }

  void _init() {
    _setDiscs();
    _setLines();
    _setParticles();
  }

  void _setDiscs() {
    final width = _rect.width;
    final height = _rect.height;
    if (width <= 0 || height <= 0) return;

    _discs = [];
    _startDisc = _Disc(
      p: 0,
      x: width * 0.5,
      y: height * 0.45,
      w: width * 0.75,
      h: height * 0.7,
    );
    _endDisc = _Disc(p: 0, x: width * 0.5, y: height * 0.95, w: 0, h: 0);

    double prevBottom = height;
    _clip = _Clip();

    for (int i = 0; i < widget.numberOfDiscs; i++) {
      final p = i / widget.numberOfDiscs;
      final disc = _Disc(p: p, x: 0, y: 0, w: 0, h: 0);
      _tweenDisc(disc);
      final bottom = disc.y + disc.h;
      if (bottom <= prevBottom) {
        _clip = _Clip(
          disc: _Disc(p: disc.p, x: disc.x, y: disc.y, w: disc.w, h: disc.h),
          i: i,
        );
      }
      prevBottom = bottom;
      _discs.add(disc);
    }

    if (_clip.disc != null) {
      final disc = _clip.disc!;
      final clipPath = Path();
      clipPath.addOval(
        Rect.fromCenter(
          center: Offset(disc.x, disc.y),
          width: disc.w * 2,
          height: disc.h * 2,
        ),
      );
      clipPath.addRect(Rect.fromLTWH(disc.x - disc.w, 0, disc.w * 2, disc.y));
      _clip.path = clipPath;
    }
  }

  void _setLines() {
    final width = _rect.width;
    final height = _rect.height;
    if (width <= 0 || height <= 0) return;

    _lines = [];
    final linesAngle = (math.pi * 2) / widget.numberOfLines;
    for (int i = 0; i < widget.numberOfLines; i++) {
      _lines.add([]);
    }

    for (var disc in _discs) {
      for (int i = 0; i < widget.numberOfLines; i++) {
        final angle = i * linesAngle;
        final point = _Point(
          x: disc.x + math.cos(angle) * disc.w,
          y: disc.y + math.sin(angle) * disc.h,
        );
        _lines[i].add(point);
      }
    }

    if (_clip.path == null) {
      _linesPicture = null;
      return;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = widget.strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var line in _lines) {
      canvas.save();
      bool lineIsIn = false;
      for (int j = 0; j < line.length; j++) {
        if (j == 0) continue;
        final p0 = line[j - 1];
        final p1 = line[j];
        if (!lineIsIn && _isPointInClipPath(p1.x, p1.y)) {
          lineIsIn = true;
        } else if (lineIsIn) {
          canvas.clipPath(_clip.path!);
        }
        canvas.drawLine(Offset(p0.x, p0.y), Offset(p1.x, p1.y), paint);
      }
      canvas.restore();
    }

    _linesPicture = recorder.endRecording();
  }

  bool _isPointInClipPath(double x, double y) {
    if (_clip.disc == null) return false;
    final disc = _clip.disc!;

    final dx = (x - disc.x) / disc.w;
    final dy = (y - disc.y) / disc.h;
    final ellipseValue = dx * dx + dy * dy;
    final sqrtV = math.sqrt(ellipseValue);

    if (sqrtV <= 1.0) return true;
    final distToEdge = (sqrtV - 1.0) * math.min(disc.w, disc.h);
    if (distToEdge <= 0.2) return true;

    if (y < disc.y && x >= disc.x - disc.w && x <= disc.x + disc.w) {
      return true;
    }

    return false;
  }

  _Particle _initParticle({bool start = false}) {
    final sx =
        (_particleArea.sx ?? 0) +
        (_particleArea.sw ?? 0) * _random.nextDouble();
    final ex =
        (_particleArea.ex ?? 0) +
        (_particleArea.ew ?? 0) * _random.nextDouble();
    final dx = ex - sx;
    final y = start
        ? (_particleArea.h ?? 0) * _random.nextDouble()
        : (_particleArea.h ?? 0);
    final r = 0.5 + _random.nextDouble() * 4;
    final vy = 0.5 + _random.nextDouble();
    return _Particle(
      x: sx,
      sx: sx,
      dx: dx,
      y: y,
      vy: vy,
      p: 0,
      r: r,
      opacity: _random.nextDouble(),
    );
  }

  void _setParticles() {
    final width = _rect.width;
    final height = _rect.height;
    _particles = [];
    final disc = _clip.disc;
    if (disc == null) return;
    _particleArea = _ParticleArea(
      sw: disc.w * 0.5,
      ew: disc.w * 2,
      h: height * 0.85,
    );
    _particleArea.sx = (width - (_particleArea.sw ?? 0)) / 2;
    _particleArea.ex = (width - (_particleArea.ew ?? 0)) / 2;
    for (int i = 0; i < 100; i++) {
      _particles.add(_initParticle(start: true));
    }
  }

  void _moveDiscs() {
    for (var disc in _discs) {
      disc.p = (disc.p + 0.001) % 1;
      _tweenDisc(disc);
    }
  }

  void _moveParticles() {
    for (int i = 0; i < _particles.length; i++) {
      final particle = _particles[i];
      particle.p = 1 - particle.y / (_particleArea.h ?? 1);
      particle.x = particle.sx + particle.dx * particle.p;
      particle.y -= particle.vy;
      if (particle.y < 0) {
        _particles[i] = _initParticle();
      }
    }
  }

  void _tick(Duration elapsed) {
    if (_rect == Size.zero) return;
    _moveDiscs();
    _moveParticles();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _setSize(Size(constraints.maxWidth, constraints.maxHeight));

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _BlackHolePainter(
                discs: _discs,
                linesPicture: _linesPicture,
                particles: _particles,
                clip: _clip,
                startDisc: _startDisc,
                strokeColor: widget.strokeColor,
                particleColor: widget.particleColor,
              ),
            ),
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }
}

class _BlackHolePainter extends CustomPainter {
  final List<_Disc> discs;
  final ui.Picture? linesPicture;
  final List<_Particle> particles;
  final _Clip clip;
  final _Disc startDisc;
  final Color strokeColor;
  final Color particleColor;

  _BlackHolePainter({
    required this.discs,
    this.linesPicture,
    required this.particles,
    required this.clip,
    required this.startDisc,
    required this.strokeColor,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawDiscs(canvas);
    _drawLines(canvas);
    _drawParticles(canvas);
  }

  void _drawDiscs(Canvas canvas) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(startDisc.x, startDisc.y),
        width: startDisc.w * 2,
        height: startDisc.h * 2,
      ),
      paint,
    );

    for (int i = 0; i < discs.length; i++) {
      if (i % 5 != 0) continue;
      final disc = discs[i];
      if (disc.w < (clip.disc?.w ?? 0) - 5) {
        canvas.save();
        if (clip.path != null) {
          canvas.clipPath(clip.path!);
        }
      }
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(disc.x, disc.y),
          width: disc.w * 2,
          height: disc.h * 2,
        ),
        paint,
      );
      if (disc.w < (clip.disc?.w ?? 0) - 5) {
        canvas.restore();
      }
    }
  }

  void _drawLines(Canvas canvas) {
    if (linesPicture != null) {
      canvas.drawPicture(linesPicture!);
    }
  }

  void _drawParticles(Canvas canvas) {
    if (clip.path == null) return;
    canvas.save();
    canvas.clipPath(clip.path!);
    for (var particle in particles) {
      final paint = Paint()
        ..color = particleColor.withValues(alpha: particle.opacity);
      canvas.drawRect(
        Rect.fromLTWH(particle.x, particle.y, particle.r, particle.r),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BlackHolePainter oldDelegate) => true;
}

class _Disc {
  double p;
  double x;
  double y;
  double w;
  double h;

  _Disc({
    required this.p,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });
}

class _Point {
  double x;
  double y;

  _Point({required this.x, required this.y});
}

class _Particle {
  double x;
  double sx;
  double dx;
  double y;
  double vy;
  double p;
  double r;
  double opacity;

  _Particle({
    required this.x,
    required this.sx,
    required this.dx,
    required this.y,
    required this.vy,
    required this.p,
    required this.r,
    required this.opacity,
  });
}

class _Clip {
  _Disc? disc;
  int? i;
  Path? path;

  _Clip({this.disc, this.i});
}

class _ParticleArea {
  double? sw;
  double? ew;
  double? h;
  double? sx;
  double? ex;

  _ParticleArea({this.sw, this.ew, this.h});
}
