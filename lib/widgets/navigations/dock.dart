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
    this.itemSize = 48.0,
    this.maxScale = 2.0,
    this.itemScale = 1.0,
    this.distance = 100.0,
    this.direction = Axis.horizontal,
    this.gap = 8.0,
    this.padding,
    this.decoration,
    this.itemDecoration,
  });

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  final _mousePositionNotifier = ValueNotifier<Offset?>(null);

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
    _mousePositionNotifier.dispose();
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
      onHover: (event) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final center = renderBox.localToGlobal(
            renderBox.size.center(Offset.zero),
          );
          _mousePositionNotifier.value = event.position - center;
        }
      },
      onExit: (_) => _mousePositionNotifier.value = null,
      child: DecoratedBox(
        decoration: decoration,
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.all(8.0),
          child: _DockConfig(
            notifier: _mousePositionNotifier,
            itemDecoration: itemDecoration,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildItems(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final children = <Widget>[];
    final isHorizontal = widget.direction == Axis.horizontal;
    final itemWidths = <double>[];
    var totalWidth = 0.0;

    for (final item in widget.items) {
      final width = item is DockSeparator
          ? (isHorizontal ? item.width : item.height) +
                (item.margin?.resolve(Directionality.of(context)) ??
                        const EdgeInsets.symmetric(horizontal: 4.0))
                    .horizontal
          : widget.itemSize;
      itemWidths.add(width);
      totalWidth += width;
    }

    totalWidth += (widget.items.length - 1) * widget.gap;
    var currentOffset = -totalWidth / 2;

    for (var i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final width = itemWidths[i];
      final centerOffset = currentOffset + width / 2;

      if (item is DockSeparator) {
        children.add(item);
      } else {
        children.add(
          _DockItem(
            key: ValueKey(i),
            itemSize: widget.itemSize,
            maxScale: widget.maxScale,
            itemScale: widget.itemScale,
            distance: widget.distance,
            direction: widget.direction,
            baseOffset: centerOffset,
            child: item,
          ),
        );
      }

      if (i < widget.items.length - 1) {
        children.add(
          SizedBox(
            width: isHorizontal ? widget.gap : 0,
            height: isHorizontal ? 0 : widget.gap,
          ),
        );
      }

      currentOffset += width + widget.gap;
    }

    return children;
  }
}

class _DockConfig extends InheritedWidget {
  final ValueNotifier<Offset?> notifier;
  final BoxDecoration itemDecoration;

  const _DockConfig({
    required this.notifier,
    required this.itemDecoration,
    required super.child,
  });

  static _DockConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_DockConfig>();
  }

  @override
  bool updateShouldNotify(_DockConfig oldWidget) =>
      notifier != oldWidget.notifier ||
      itemDecoration != oldWidget.itemDecoration;
}

class _DockItem extends StatelessWidget {
  final double itemSize;
  final double maxScale;
  final double itemScale;
  final double distance;
  final Axis direction;
  final double baseOffset;
  final Widget child;

  const _DockItem({
    super.key,
    required this.itemSize,
    required this.maxScale,
    required this.itemScale,
    required this.distance,
    required this.direction,
    required this.baseOffset,
    required this.child,
  });

  double _calcScale(Offset? mouseOffset, double targetScale) {
    if (mouseOffset == null) return 1.0;
    final itemCenter = direction == Axis.horizontal
        ? Offset(baseOffset, 0)
        : Offset(0, baseOffset);
    final dist = (mouseOffset - itemCenter).distance;
    if (dist > distance) return 1.0;
    return 1.0 + (targetScale - 1.0) * (1 - dist / distance);
  }

  @override
  Widget build(BuildContext context) {
    final config = _DockConfig.of(context)!;

    return ValueListenableBuilder<Offset?>(
      valueListenable: config.notifier,
      builder: (context, mouseOffset, _) {
        final scale = _calcScale(mouseOffset, maxScale);
        final childScale = _calcScale(mouseOffset, itemScale);
        final scaledSize = itemSize * scale;

        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 1.0, end: scale),
          builder: (context, animatedScale, _) {
            final size = itemSize * animatedScale;
            return SizedBox(
              width: direction == Axis.horizontal ? scaledSize : itemSize,
              height: direction == Axis.vertical ? scaledSize : itemSize,
              child: Align(
                alignment: direction == Axis.horizontal
                    ? Alignment.bottomCenter
                    : Alignment.centerLeft,
                child: _DockItemScaleProvider(
                  scale: childScale,
                  child: SizedBox(width: size, height: size, child: child),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DockItemScaleProvider extends InheritedWidget {
  final double scale;

  const _DockItemScaleProvider({required this.scale, required super.child});

  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_DockItemScaleProvider>()
            ?.scale ??
        1.0;
  }

  @override
  bool updateShouldNotify(_DockItemScaleProvider oldWidget) =>
      scale != oldWidget.scale;
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
    final baseDecoration = config?.itemDecoration ?? const BoxDecoration();
    final mergedDecoration = _mergeDecoration(baseDecoration, decoration);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: DecoratedBox(
          decoration: mergedDecoration,
          child: Center(
            child: Builder(
              builder: (context) {
                final scale = _DockItemScaleProvider.of(context);
                return Transform.scale(scale: scale, child: child);
              },
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
    this.width = 1.0,
    this.height = 32.0,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 4.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? const Color(0x40FFFFFF),
          borderRadius: BorderRadius.circular(width / 2),
        ),
        child: SizedBox(width: width, height: height),
      ),
    );
  }
}

BoxDecoration _mergeDecoration(BoxDecoration base, BoxDecoration? override) {
  if (override == null) return base;
  return BoxDecoration(
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
