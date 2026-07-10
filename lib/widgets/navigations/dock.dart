import 'package:flutter/widgets.dart';

class Dock extends StatefulWidget {
  final List<Widget> items;
  final double itemSize;
  final double maxScale;
  final double itemScale;
  final double distance;
  final Axis direction;
  final double gap;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final BoxDecoration? itemDecoration;

  const Dock({
    super.key,
    required this.items,
    this.itemSize = 48,
    this.maxScale = 2,
    this.itemScale = 1,
    this.distance = 100,
    this.direction = Axis.horizontal,
    this.gap = 8,
    this.padding,
    this.decoration,
    this.itemDecoration,
  }) : assert(itemSize > 0, 'itemSize must be greater than 0'),
       assert(maxScale >= 1, 'maxScale must be at least 1'),
       assert(itemScale >= 0, 'itemScale must be non-negative'),
       assert(distance > 0, 'distance must be greater than 0'),
       assert(gap >= 0, 'gap must be non-negative');

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  final _pointer = ValueNotifier<Offset?>(null);

  static const _defaultDecoration = BoxDecoration(
    color: Color(0x80000000),
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
  static const _defaultItemDecoration = BoxDecoration(
    color: Color(0xFF2A2A2A),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = _mergeDecoration(_defaultDecoration, widget.decoration);
    final itemDecoration = _mergeDecoration(
      _defaultItemDecoration,
      widget.itemDecoration,
    );

    return MouseRegion(
      onHover: (event) => _pointer.value = event.position,
      onExit: (_) => _pointer.value = null,
      child: DecoratedBox(
        decoration: decoration,
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.all(8),
          child: _DockConfig(
            pointer: _pointer,
            itemDecoration: itemDecoration,
            direction: widget.direction,
            child: Flex(
              direction: widget.direction,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.items.length; i++) ...[
                  if (widget.items[i] case final DockSeparator separator)
                    separator
                  else
                    _DockItem(
                      itemSize: widget.itemSize,
                      maxScale: widget.maxScale,
                      itemScale: widget.itemScale,
                      distance: widget.distance,
                      direction: widget.direction,
                      child: widget.items[i],
                    ),
                  if (i != widget.items.length - 1)
                    SizedBox(
                      width: widget.direction == Axis.horizontal
                          ? widget.gap
                          : 0,
                      height: widget.direction == Axis.vertical
                          ? widget.gap
                          : 0,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockConfig extends InheritedWidget {
  final ValueNotifier<Offset?> pointer;
  final BoxDecoration itemDecoration;
  final Axis direction;

  const _DockConfig({
    required this.pointer,
    required this.itemDecoration,
    required this.direction,
    required super.child,
  });

  static _DockConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_DockConfig>()!;
  }

  @override
  bool updateShouldNotify(covariant _DockConfig oldWidget) {
    return pointer != oldWidget.pointer ||
        itemDecoration != oldWidget.itemDecoration ||
        direction != oldWidget.direction;
  }
}

class _DockItem extends StatelessWidget {
  final double itemSize;
  final double maxScale;
  final double itemScale;
  final double distance;
  final Axis direction;
  final Widget child;

  const _DockItem({
    required this.itemSize,
    required this.maxScale,
    required this.itemScale,
    required this.distance,
    required this.direction,
    required this.child,
  });

  double _scaleFor(BuildContext context, Offset? pointer) {
    if (pointer == null) return 1;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return 1;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    final delta = direction == Axis.horizontal
        ? (pointer.dx - center.dx).abs()
        : (pointer.dy - center.dy).abs();
    if (delta >= distance) return 1;
    return 1 + (maxScale - 1) * (1 - delta / distance);
  }

  @override
  Widget build(BuildContext context) {
    final config = _DockConfig.of(context);
    return ValueListenableBuilder<Offset?>(
      valueListenable: config.pointer,
      child: child,
      builder: (context, pointer, child) {
        final targetScale = _scaleFor(context, pointer);
        return TweenAnimationBuilder<double>(
          tween: Tween(end: targetScale),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: child,
          builder: (context, scale, child) {
            final size = itemSize * scale;
            final fraction = maxScale == 1 ? 0 : (scale - 1) / (maxScale - 1);
            final contentScale = 1 + (itemScale - 1) * fraction;
            return SizedBox(
              width: direction == Axis.horizontal ? size : itemSize,
              height: direction == Axis.vertical ? size : itemSize,
              child: OverflowBox(
                maxWidth: size,
                maxHeight: size,
                alignment: direction == Axis.horizontal
                    ? Alignment.bottomCenter
                    : Alignment.centerLeft,
                child: _DockItemScale(
                  scale: contentScale,
                  child: SizedBox.square(dimension: size, child: child),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DockItemScale extends InheritedWidget {
  final double scale;

  const _DockItemScale({required this.scale, required super.child});

  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_DockItemScale>()
            ?.scale ??
        1;
  }

  @override
  bool updateShouldNotify(covariant _DockItemScale oldWidget) {
    return scale != oldWidget.scale;
  }
}

class DockIcon extends StatelessWidget {
  final Widget child;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const DockIcon({
    super.key,
    required this.child,
    this.decoration,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _DockConfig.of(context);
    final itemDecoration = _mergeDecoration(config.itemDecoration, decoration);
    final scale = _DockItemScale.of(context);

    return MouseRegion(
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: DecoratedBox(
            decoration: itemDecoration,
            child: Center(
              child: Transform.scale(scale: scale, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class DockSeparator extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const DockSeparator({
    super.key,
    this.width = 1,
    this.height = 32,
    this.color,
    this.margin,
  }) : assert(width > 0, 'width must be greater than 0'),
       assert(height > 0, 'height must be greater than 0');

  @override
  Widget build(BuildContext context) {
    final direction = _DockConfig.of(context).direction;
    final horizontal = direction == Axis.horizontal;
    final lineWidth = horizontal ? width : height;
    final lineHeight = horizontal ? height : width;
    final defaultMargin = horizontal
        ? const EdgeInsets.symmetric(horizontal: 4)
        : const EdgeInsets.symmetric(vertical: 4);

    return Padding(
      padding: margin ?? defaultMargin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? const Color(0x40FFFFFF),
          borderRadius: BorderRadius.circular(width / 2),
        ),
        child: SizedBox(width: lineWidth, height: lineHeight),
      ),
    );
  }
}

BoxDecoration _mergeDecoration(BoxDecoration base, BoxDecoration? override) {
  if (override == null) return base;
  return base.copyWith(
    color: override.color ?? base.color,
    image: override.image ?? base.image,
    border: override.border ?? base.border,
    borderRadius: override.borderRadius ?? base.borderRadius,
    boxShadow: override.boxShadow ?? base.boxShadow,
    gradient: override.gradient ?? base.gradient,
    backgroundBlendMode:
        override.backgroundBlendMode ?? base.backgroundBlendMode,
    shape: override.shape,
  );
}
