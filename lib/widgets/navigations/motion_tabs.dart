import 'dart:math' as math;
import 'package:flutter/material.dart';

class MotionTabs extends StatefulWidget {
  final List<MotionTabItem> items;
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  final Color backgroundColor;
  final Color overlayColor;
  final Color selectedColor;
  final Color textColor;
  final Color selectedTextColor;

  final double height;
  final double borderRadius;
  final EdgeInsets padding;
  final double gap;
  final Duration animationDuration;
  final Curve animationCurve;

  const MotionTabs({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onChanged,
    this.backgroundColor = const Color(0xFF2F4BFF),
    this.overlayColor = const Color(0x24FFFFFF),
    this.selectedColor = Colors.white,
    this.textColor = Colors.white,
    this.selectedTextColor = const Color(0xFF1C1F3E),
    this.height = 56,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.gap = 8,
    this.animationDuration = const Duration(milliseconds: 220),
    this.animationCurve = Curves.easeOutCubic,
  }) : assert(items.length > 0, 'items cannot be empty');

  @override
  State<MotionTabs> createState() => _MotionTabsState();
}

class _MotionTabsState extends State<MotionTabs> {
  late int _selectedIndex;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _clampIndex(widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant MotionTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      _selectedIndex = _clampIndex(widget.initialIndex);
    }
    if (widget.items.length != oldWidget.items.length) {
      _selectedIndex = _clampIndex(_selectedIndex);
      _hoveredIndex = null;
    }
  }

  int _clampIndex(int index) {
    return index.clamp(0, widget.items.length - 1);
  }

  void _handleTap(int index) {
    if (_selectedIndex == index) {
      widget.items[index].onTap?.call();
      return;
    }

    setState(() => _selectedIndex = index);
    widget.onChanged?.call(index);
    widget.items[index].onTap?.call();
  }

  void _handleHover(int index) {
    if (_hoveredIndex == index) return;
    setState(() => _hoveredIndex = index);
  }

  void _clearHover() {
    if (_hoveredIndex == null) return;
    setState(() => _hoveredIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);

    return MouseRegion(
      onExit: (_) => _clearHover(),
      child: ClipRRect(
        borderRadius: radius,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.backgroundColor,
                widget.backgroundColor.withValues(alpha: 0.78),
              ],
            ),
          ),
          child: SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fallbackWidth =
                    widget.items.length * 120 +
                    widget.gap * (widget.items.length - 1) +
                    widget.padding.horizontal;
                final availableWidth = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : fallbackWidth.toDouble();

                final rawContentWidth = math.max(
                  0.0,
                  availableWidth - widget.padding.horizontal,
                );
                final totalGapWidth =
                    widget.gap * (widget.items.length - 1).toDouble();
                final minContentWidth =
                    totalGapWidth + widget.items.length.toDouble();
                final contentWidth = math.max(
                  rawContentWidth,
                  minContentWidth.toDouble(),
                );
                final tabWidth =
                    (contentWidth - totalGapWidth) / widget.items.length;

                final overlayWidth = _hoveredIndex == null
                    ? contentWidth
                    : tabWidth;
                final overlayLeft =
                    widget.padding.left +
                    (_hoveredIndex ?? 0) * (tabWidth + widget.gap);
                final itemHeight = math.max(
                  0.0,
                  widget.height - widget.padding.vertical,
                );
                final selectedLeft =
                    widget.padding.left +
                    _selectedIndex * (tabWidth + widget.gap);

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          color: widget.backgroundColor,
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                      left: selectedLeft,
                      top: widget.padding.top,
                      bottom: widget.padding.bottom,
                      width: tabWidth,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: widget.selectedColor,
                            borderRadius: BorderRadius.circular(
                              math.max(0.0, widget.borderRadius - 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                      left: overlayLeft,
                      top: widget.padding.top,
                      bottom: widget.padding.bottom,
                      width: overlayWidth,
                      child: IgnorePointer(
                        child: AnimatedContainer(
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                          decoration: BoxDecoration(
                            color: widget.overlayColor,
                            borderRadius: BorderRadius.circular(
                              math.max(0.0, widget.borderRadius - 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: widget.padding,
                      child: Row(
                        children: [
                          for (var i = 0; i < widget.items.length; i++) ...[
                            _TabButton(
                              width: tabWidth,
                              height: itemHeight,
                              item: widget.items[i],
                              selected: i == _selectedIndex,
                              textColor: widget.textColor,
                              selectedTextColor: widget.selectedTextColor,
                              selectedColor: widget.selectedColor,
                              borderRadius: widget.borderRadius,
                              duration: widget.animationDuration,
                              curve: widget.animationCurve,
                              onTap: () => _handleTap(i),
                              onHover: () => _handleHover(i),
                            ),
                            if (i != widget.items.length - 1)
                              SizedBox(width: widget.gap),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final double width;
  final double height;
  final MotionTabItem item;
  final bool selected;
  final Color textColor;
  final Color selectedTextColor;
  final Color selectedColor;
  final double borderRadius;
  final Duration duration;
  final Curve curve;
  final VoidCallback onTap;
  final VoidCallback onHover;

  const _TabButton({
    required this.width,
    required this.height,
    required this.item,
    required this.selected,
    required this.textColor,
    required this.selectedTextColor,
    required this.selectedColor,
    required this.borderRadius,
    required this.duration,
    required this.curve,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = math.max(0.0, borderRadius - 4);
    final iconColor = selected ? selectedTextColor : textColor;

    return MouseRegion(
      onEnter: (_) => onHover(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          curve: curve,
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(effectiveRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(begin: iconColor, end: iconColor),
                  duration: duration,
                  curve: curve,
                  builder: (context, color, child) => IconTheme(
                    data: IconThemeData(color: color, size: 18),
                    child: child!,
                  ),
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: FittedBox(child: item.icon),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: curve,
                style: TextStyle(
                  color: selected ? selectedTextColor : textColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                child: Text(item.label, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MotionTabItem {
  final String label;
  final Widget? icon;
  final VoidCallback? onTap;

  const MotionTabItem({required this.label, this.icon, this.onTap});
}
