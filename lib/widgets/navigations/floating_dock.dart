import 'package:flutter/foundation.dart';
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
    this.baseItemSize = 48,
    this.maxItemSize = 68,
    this.distance = 150,
    this.gap = 12,
    this.padding,
    this.decoration,
    this.itemDecoration,
  }) : assert(items.length > 0, 'items cannot be empty'),
       assert(baseItemSize > 0, 'baseItemSize must be greater than 0'),
       assert(
         maxItemSize >= baseItemSize,
         'maxItemSize must be at least baseItemSize',
       ),
       assert(distance > 0, 'distance must be greater than 0'),
       assert(gap >= 0, 'gap must be non-negative');

  @override
  State<FloatingDock> createState() => _FloatingDockState();
}

class _FloatingDockState extends State<FloatingDock> {
  final _pointerX = ValueNotifier<double?>(null);

  static const _defaultDecoration = BoxDecoration(
    color: Color(0xFFF5F5F5),
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
  static const _defaultItemDecoration = BoxDecoration(color: Color(0xFFE8E8E8));

  @override
  void dispose() {
    _pointerX.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = _merge(_defaultDecoration, widget.decoration);
    final itemDecoration = _merge(
      _defaultItemDecoration,
      widget.itemDecoration,
    );

    return MouseRegion(
      onHover: (event) => _pointerX.value = event.position.dx,
      onExit: (_) => _pointerX.value = null,
      child: DecoratedBox(
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
                  item: widget.items[i],
                  pointerX: _pointerX,
                  baseSize: widget.baseItemSize,
                  maxSize: widget.maxItemSize,
                  distance: widget.distance,
                  decoration: _merge(
                    itemDecoration,
                    widget.items[i].decoration,
                  ),
                ),
                if (i != widget.items.length - 1) SizedBox(width: widget.gap),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingDockIcon extends StatefulWidget {
  final FloatingDockItem item;
  final ValueListenable<double?> pointerX;
  final double baseSize;
  final double maxSize;
  final double distance;
  final BoxDecoration decoration;

  const _FloatingDockIcon({
    required this.item,
    required this.pointerX,
    required this.baseSize,
    required this.maxSize,
    required this.distance,
    required this.decoration,
  });

  @override
  State<_FloatingDockIcon> createState() => _FloatingDockIconState();
}

class _FloatingDockIconState extends State<_FloatingDockIcon> {
  bool _hovered = false;

  double _scale(double? pointerX) {
    if (pointerX == null) return 1;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return 1;
    final center = box.localToGlobal(box.size.center(Offset.zero)).dx;
    final delta = (pointerX - center).abs();
    if (delta >= widget.distance) return 1;
    final maxScale = widget.maxSize / widget.baseSize;
    return 1 + (maxScale - 1) * (1 - delta / widget.distance);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.item.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.item.onTap,
        child: ValueListenableBuilder<double?>(
          valueListenable: widget.pointerX,
          builder: (context, pointerX, _) {
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              tween: Tween(end: widget.baseSize * _scale(pointerX)),
              builder: (context, size, _) {
                final offset = widget.baseSize - size;
                return SizedBox(
                  width: size,
                  height: widget.baseSize,
                  child: OverflowBox(
                    maxWidth: size,
                    maxHeight: size,
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Transform.translate(
                          offset: Offset(0, offset),
                          child: DecoratedBox(
                            decoration: widget.decoration.copyWith(
                              borderRadius:
                                  widget.decoration.borderRadius ??
                                  BorderRadius.circular(size * 0.25),
                            ),
                            child: SizedBox.square(
                              dimension: size,
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                heightFactor: 0.5,
                                child: FittedBox(child: widget.item.icon),
                              ),
                            ),
                          ),
                        ),
                        if (widget.item.title case final title?)
                          Positioned(
                            bottom: size - offset + 6,
                            left: size / 2,
                            child: FractionalTranslation(
                              translation: const Offset(-0.5, 0),
                              child: _DockTooltip(
                                title: title,
                                visible: _hovered,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DockTooltip extends StatelessWidget {
  final String title;
  final bool visible;

  const _DockTooltip({required this.title, required this.visible});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 0.25),
          duration: const Duration(milliseconds: 120),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF202126),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF3A3B42)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                title,
                maxLines: 1,
                style: const TextStyle(fontSize: 12, color: Color(0xFFF5F5F5)),
              ),
            ),
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

BoxDecoration _merge(BoxDecoration base, BoxDecoration? override) {
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
