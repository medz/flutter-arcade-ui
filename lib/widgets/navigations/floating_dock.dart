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
  final _keys = <GlobalKey>[];

  static const _defaultDecoration = BoxDecoration(
    color: Color(0xFFF5F5F5),
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
  static const _defaultItemDecoration = BoxDecoration(color: Color(0xFFE8E8E8));

  @override
  void initState() {
    super.initState();
    _syncKeys();
  }

  @override
  void didUpdateWidget(FloatingDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) _syncKeys();
  }

  void _syncKeys() {
    _keys
      ..clear()
      ..addAll(List.generate(widget.items.length, (_) => GlobalKey()));
  }

  @override
  Widget build(BuildContext context) {
    final deco = _merge(_defaultDecoration, widget.decoration);
    final itemDeco = _merge(_defaultItemDecoration, widget.itemDecoration);

    return MouseRegion(
      onHover: (e) => setState(() => _mouseX = e.position.dx),
      onExit: (_) => setState(() => _mouseX = null),
      child: DecoratedBox(
        decoration: deco,
        child: Padding(
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < widget.items.length; i++) ...[
                _DockIcon(
                  key: _keys[i],
                  gKey: _keys[i],
                  item: widget.items[i],
                  mouseX: _mouseX,
                  baseSize: widget.baseItemSize,
                  maxSize: widget.maxItemSize,
                  distance: widget.distance,
                  decoration: _merge(itemDeco, widget.items[i].decoration),
                ),
                if (i < widget.items.length - 1) SizedBox(width: widget.gap),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DockIcon extends StatefulWidget {
  final GlobalKey gKey;
  final FloatingDockItem item;
  final double? mouseX;
  final double baseSize, maxSize, distance;
  final BoxDecoration decoration;

  const _DockIcon({
    super.key,
    required this.gKey,
    required this.item,
    required this.mouseX,
    required this.baseSize,
    required this.maxSize,
    required this.distance,
    required this.decoration,
  });

  @override
  State<_DockIcon> createState() => _DockIconState();
}

class _DockIconState extends State<_DockIcon> {
  bool _hovered = false;

  double get _scale {
    if (widget.mouseX == null) return 1.0;
    final box = widget.gKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return 1.0;
    final center = box.localToGlobal(Offset.zero).dx + box.size.width / 2;
    final dist = (widget.mouseX! - center).abs();
    if (dist > widget.distance) return 1.0;
    return 1.0 +
        (widget.maxSize / widget.baseSize - 1.0) * (1 - dist / widget.distance);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: widget.baseSize, end: widget.baseSize * _scale),
          builder: (context, s, _) {
            final offset = widget.baseSize - s;
            return SizedBox(
              width: s,
              height: widget.baseSize,
              child: OverflowBox(
                maxWidth: s,
                maxHeight: s,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Transform.translate(
                      offset: Offset(0, offset),
                      child: DecoratedBox(
                        decoration: widget.decoration.copyWith(
                          borderRadius:
                              widget.decoration.borderRadius ??
                              BorderRadius.circular(s * 0.25),
                        ),
                        child: SizedBox(
                          width: s,
                          height: s,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            heightFactor: 0.5,
                            child: FittedBox(child: widget.item.icon),
                          ),
                        ),
                      ),
                    ),
                    if (widget.item.title != null)
                      Positioned(
                        bottom: s - offset + 6,
                        left: s / 2,
                        child: _Tooltip(widget.item.title!, _hovered),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Tooltip extends StatelessWidget {
  final String title;
  final bool visible;
  const _Tooltip(this.title, this.visible);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 150),
      tween: Tween(begin: 0, end: visible ? 1.0 : 0.0),
      builder: (context, v, child) {
        if (v == 0) return const SizedBox.shrink();
        return FractionalTranslation(
          translation: Offset(-0.5, (1 - v) * 0.5),
          child: Opacity(opacity: v, child: child),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF404040)),
          ),
        ),
      ),
    );
  }
}

class FloatingDockItem {
  final Widget icon;
  final String? title;
  final BoxDecoration? decoration;
  final VoidCallback? onTap;

  const FloatingDockItem({
    required this.icon,
    this.title,
    this.decoration,
    this.onTap,
  });
}

BoxDecoration _merge(BoxDecoration base, BoxDecoration? o) {
  if (o == null) return base;
  return BoxDecoration(
    color: o.color ?? base.color,
    image: o.image ?? base.image,
    border: o.border ?? base.border,
    borderRadius: o.borderRadius ?? base.borderRadius,
    boxShadow: o.boxShadow ?? base.boxShadow,
    gradient: o.gradient ?? base.gradient,
    backgroundBlendMode: o.backgroundBlendMode ?? base.backgroundBlendMode,
    shape: o.shape,
  );
}
