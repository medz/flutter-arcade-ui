import 'package:flutter/widgets.dart';

class FloatingDock extends StatefulWidget {
  final List<FloatingDockItem> items;
  final double baseItemSize;
  final double maxItemSize;
  final double distance;
  final double gap;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final BoxDecoration? itemDecoration;

  const FloatingDock({
    super.key,
    required this.items,
    this.baseItemSize = 48.0,
    this.maxItemSize = 68.0,
    this.distance = 150.0,
    this.gap = 12.0,
    this.padding,
    this.decoration,
    this.itemDecoration,
  });

  @override
  State<FloatingDock> createState() => _FloatingDockState();
}

class _FloatingDockState extends State<FloatingDock> {
  double? _mouseX;
  final _itemKeys = <GlobalKey>[];

  static const _defaultDecoration = BoxDecoration(
    color: Color(0xFFF5F5F5),
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );

  static const _defaultItemDecoration = BoxDecoration(color: Color(0xFFE8E8E8));

  @override
  void initState() {
    super.initState();
    _updateKeys();
  }

  @override
  void didUpdateWidget(FloatingDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _updateKeys();
    }
  }

  void _updateKeys() {
    _itemKeys.clear();
    for (var i = 0; i < widget.items.length; i++) {
      _itemKeys.add(GlobalKey());
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = _mergeDecoration(_defaultDecoration, widget.decoration);

    return MouseRegion(
      onHover: (event) => setState(() => _mouseX = event.position.dx),
      onExit: (_) => setState(() => _mouseX = null),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: decoration,
            child: Padding(
              padding:
                  widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < widget.items.length; i++) ...[
                    _FloatingDockIcon(
                      key: _itemKeys[i],
                      globalKey: _itemKeys[i],
                      item: widget.items[i],
                      mouseX: _mouseX,
                      baseSize: widget.baseItemSize,
                      maxSize: widget.maxItemSize,
                      distance: widget.distance,
                      baseDecoration: _mergeDecoration(
                        _defaultItemDecoration,
                        widget.itemDecoration,
                      ),
                    ),
                    if (i < widget.items.length - 1)
                      SizedBox(width: widget.gap),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingDockIcon extends StatefulWidget {
  final GlobalKey globalKey;
  final FloatingDockItem item;
  final double? mouseX;
  final double baseSize;
  final double maxSize;
  final double distance;
  final BoxDecoration baseDecoration;

  const _FloatingDockIcon({
    super.key,
    required this.globalKey,
    required this.item,
    required this.mouseX,
    required this.baseSize,
    required this.maxSize,
    required this.distance,
    required this.baseDecoration,
  });

  @override
  State<_FloatingDockIcon> createState() => _FloatingDockIconState();
}

class _FloatingDockIconState extends State<_FloatingDockIcon> {
  double _getScale() {
    if (widget.mouseX == null) return 1.0;

    final renderBox =
        widget.globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return 1.0;

    final position = renderBox.localToGlobal(Offset.zero);
    final center = position.dx + renderBox.size.width / 2;
    final dist = (widget.mouseX! - center).abs();

    if (dist > widget.distance) return 1.0;

    final ratio = 1 - (dist / widget.distance);
    return 1.0 + (widget.maxSize / widget.baseSize - 1.0) * ratio;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _getScale();
    final size = widget.baseSize * scale;
    final itemDecoration = _mergeDecoration(
      widget.baseDecoration,
      widget.item.decoration,
    );

    return GestureDetector(
      onTap: widget.item.onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: widget.baseSize, end: size),
        builder: (context, animatedSize, child) {
          final yOffset = widget.baseSize - animatedSize;
          final radius = animatedSize * 0.25;
          return SizedBox(
            width: animatedSize,
            height: widget.baseSize,
            child: OverflowBox(
              maxWidth: animatedSize,
              maxHeight: animatedSize,
              child: Transform.translate(
                offset: Offset(0, yOffset),
                child: SizedBox(
                  width: animatedSize,
                  height: animatedSize,
                  child: DecoratedBox(
                    decoration: itemDecoration.copyWith(
                      borderRadius:
                          itemDecoration.borderRadius ??
                          BorderRadius.circular(radius),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: animatedSize * 0.5,
                        height: animatedSize * 0.5,
                        child: FittedBox(child: widget.item.icon),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FloatingDockItem {
  final Widget icon;
  final BoxDecoration? decoration;
  final VoidCallback? onTap;

  const FloatingDockItem({required this.icon, this.decoration, this.onTap});
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
