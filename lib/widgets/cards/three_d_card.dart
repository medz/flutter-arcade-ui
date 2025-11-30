import 'package:flutter/material.dart';

const double _kDegreesToRadians = 0.0174533;

class ThreeDCardData extends InheritedWidget {
  final bool isHovered;

  const ThreeDCardData({
    super.key,
    required this.isHovered,
    required super.child,
  });

  static ThreeDCardData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThreeDCardData>();
  }

  @override
  bool updateShouldNotify(ThreeDCardData oldWidget) {
    return oldWidget.isHovered != isHovered;
  }
}

class ThreeDCard extends StatefulWidget {
  final Widget child;
  final double sensitivity;
  final Duration duration;
  final BoxDecoration? decoration;
  final BoxDecoration? hoverDecoration;
  final EdgeInsetsGeometry? padding;
  final double maxRotationX;
  final double maxRotationY;
  final VoidCallback? onHoverStart;
  final VoidCallback? onHoverEnd;
  final Curve curve;
  final bool enabled;

  const ThreeDCard({
    super.key,
    required this.child,
    this.sensitivity = 25.0,
    this.duration = const Duration(milliseconds: 200),
    this.decoration,
    this.hoverDecoration,
    this.padding,
    this.maxRotationX = 25.0,
    this.maxRotationY = 25.0,
    this.onHoverStart,
    this.onHoverEnd,
    this.curve = Curves.easeOut,
    this.enabled = true,
  }) : assert(sensitivity > 0, 'sensitivity must be greater than 0'),
       assert(maxRotationX >= 0, 'maxRotationX must be non-negative'),
       assert(maxRotationY >= 0, 'maxRotationY must be non-negative');

  @override
  State<ThreeDCard> createState() => _ThreeDCardState();
}

class _ThreeDCardState extends State<ThreeDCard> {
  bool _isHovered = false;
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  DateTime _lastHoverUpdate = DateTime.now();
  static const _hoverThrottleMs = 16;

  void _handleHoverStart() {
    if (!widget.enabled) return;
    setState(() => _isHovered = true);
    widget.onHoverStart?.call();
  }

  void _handleHoverEnd() {
    if (!widget.enabled) return;
    setState(() {
      _isHovered = false;
      _rotationX = 0.0;
      _rotationY = 0.0;
    });
    widget.onHoverEnd?.call();
  }

  void _handleHover(PointerEvent event) {
    if (!widget.enabled) return;

    final now = DateTime.now();
    if (now.difference(_lastHoverUpdate).inMilliseconds < _hoverThrottleMs) {
      return;
    }
    _lastHoverUpdate = now;

    final size = context.size;
    if (size == null) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final x = (event.localPosition.dx - centerX) / widget.sensitivity;
    final y = (event.localPosition.dy - centerY) / widget.sensitivity;

    setState(() {
      _rotationX = (-y).clamp(-widget.maxRotationX, widget.maxRotationX);
      _rotationY = x.clamp(-widget.maxRotationY, widget.maxRotationY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHoverStart(),
      onExit: (_) => _handleHoverEnd(),
      onHover: _handleHover,
      child: ThreeDCardData(
        isHovered: _isHovered,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _rotationX),
          duration: widget.duration,
          curve: widget.curve,
          builder: (context, rx, _) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _rotationY),
              duration: widget.duration,
              curve: widget.curve,
              builder: (context, ry, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(rx * _kDegreesToRadians)
                    ..rotateY(ry * _kDegreesToRadians),
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: widget.duration,
                    curve: widget.curve,
                    decoration: _isHovered && widget.hoverDecoration != null
                        ? _mergeDecorations(
                            widget.decoration,
                            widget.hoverDecoration!,
                          )
                        : widget.decoration,
                    padding: widget.padding,
                    child: widget.child,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  BoxDecoration? _mergeDecorations(BoxDecoration? base, BoxDecoration hover) {
    if (base == null) return hover;

    return base.copyWith(
      color: hover.color ?? base.color,
      image: hover.image ?? base.image,
      border: hover.border ?? base.border,
      borderRadius: hover.borderRadius ?? base.borderRadius,
      boxShadow: hover.boxShadow ?? base.boxShadow,
      gradient: hover.gradient ?? base.gradient,
      backgroundBlendMode:
          hover.backgroundBlendMode ?? base.backgroundBlendMode,
      shape: hover.shape != BoxShape.rectangle ? hover.shape : base.shape,
    );
  }
}

class ThreeDCardItem extends StatelessWidget {
  final Widget child;
  final double translateX;
  final double translateY;
  final double translateZ;
  final double rotateX;
  final double rotateY;
  final double rotateZ;
  final Duration duration;

  const ThreeDCardItem({
    super.key,
    required this.child,
    this.translateX = 0,
    this.translateY = 0,
    this.translateZ = 0,
    this.rotateX = 0,
    this.rotateY = 0,
    this.rotateZ = 0,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    final isHovered = ThreeDCardData.of(context)?.isHovered ?? false;

    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOut,
      transform: isHovered
          ? (Matrix4.identity()
              ..setTranslationRaw(translateX, translateY, -translateZ)
              ..rotateX(rotateX * _kDegreesToRadians)
              ..rotateY(rotateY * _kDegreesToRadians)
              ..rotateZ(rotateZ * _kDegreesToRadians))
          : Matrix4.identity(),
      child: child,
    );
  }
}
