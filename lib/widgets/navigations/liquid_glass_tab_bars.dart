import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';

class LiquidGlassTabBars extends StatefulWidget {
  final List<LiquidGlassTabBarItem> items;
  final LiquidGlassTabBarItem? trailingItem;
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  final double height;
  final double iconSize;
  final double iconLabelSpacing;
  final double labelFontSize;
  final EdgeInsets padding;
  final EdgeInsets indicatorPadding;
  final double gap;
  final double groupGap;

  final double borderRadius;
  final double indicatorRadius;

  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;

  final double blurSigma;
  final Color sheenColor;
  final Color sheenSecondaryColor;

  final Color indicatorColor;
  final Color indicatorBorderColor;
  final Color indicatorShadowColor;
  final double indicatorShadowBlur;
  final Offset indicatorShadowOffset;
  final double indicatorBlurSigma;

  final Color selectedColor;
  final Color unselectedColor;

  final bool useSafeArea;
  final bool hideOnKeyboard;

  final Duration animationDuration;
  final Curve animationCurve;

  final int maxItems;
  final bool enforceMaxItems;

  final Color badgeColor;
  final Color badgeTextColor;
  final TextStyle? badgeTextStyle;

  final TextStyle? labelStyle;
  final TextStyle? selectedLabelStyle;

  const LiquidGlassTabBars({
    super.key,
    required this.items,
    this.trailingItem,
    this.initialIndex = 0,
    this.onChanged,
    this.height = 52,
    this.iconSize = 20,
    this.iconLabelSpacing = 2,
    this.labelFontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    this.indicatorPadding = const EdgeInsets.all(2),
    this.gap = 0,
    this.groupGap = 10,
    this.borderRadius = 26,
    this.indicatorRadius = 24,
    this.backgroundColor = const Color(0x66FFFFFF),
    this.borderColor = const Color(0x8CFFFFFF),
    this.shadowColor = const Color(0x33000000),
    this.shadowBlur = 28,
    this.shadowOffset = const Offset(0, 14),
    this.blurSigma = 24,
    this.sheenColor = const Color(0x73FFFFFF),
    this.sheenSecondaryColor = const Color(0x12FFFFFF),
    this.indicatorColor = const Color(0x30FFFFFF),
    this.indicatorBorderColor = const Color(0xB3FFFFFF),
    this.indicatorShadowColor = const Color(0x24000000),
    this.indicatorShadowBlur = 16,
    this.indicatorShadowOffset = const Offset(0, 7),
    this.indicatorBlurSigma = 14,
    this.selectedColor = const Color(0xFF007AFF),
    this.unselectedColor = const Color(0xFF8E8E93),
    this.useSafeArea = true,
    this.hideOnKeyboard = true,
    this.animationDuration = const Duration(milliseconds: 180),
    this.animationCurve = Curves.easeOutCubic,
    this.maxItems = 5,
    this.enforceMaxItems = true,
    this.badgeColor = const Color(0xFFFF3B30),
    this.badgeTextColor = const Color(0xFFFFFFFF),
    this.badgeTextStyle,
    this.labelStyle,
    this.selectedLabelStyle,
  }) : assert(items.length > 1, 'items must contain at least 2 tabs'),
       assert(height > 0, 'height must be greater than 0'),
       assert(iconSize > 0, 'iconSize must be greater than 0'),
       assert(iconLabelSpacing >= 0, 'iconLabelSpacing must be non-negative'),
       assert(labelFontSize > 0, 'labelFontSize must be greater than 0'),
       assert(gap >= 0, 'gap must be non-negative'),
       assert(groupGap >= 0, 'groupGap must be non-negative'),
       assert(borderRadius >= 0, 'borderRadius must be non-negative'),
       assert(indicatorRadius >= 0, 'indicatorRadius must be non-negative'),
       assert(shadowBlur >= 0, 'shadowBlur must be non-negative'),
       assert(blurSigma >= 0, 'blurSigma must be non-negative'),
       assert(
         indicatorShadowBlur >= 0,
         'indicatorShadowBlur must be non-negative',
       ),
       assert(
         indicatorBlurSigma >= 0,
         'indicatorBlurSigma must be non-negative',
       ),
       assert(maxItems > 0, 'maxItems must be greater than 0'),
       assert(
         !enforceMaxItems ||
             items.length + (trailingItem == null ? 0 : 1) <= maxItems,
         'items length exceeds maxItems. Consider using fewer tabs.',
       );

  @override
  State<LiquidGlassTabBars> createState() => _LiquidGlassTabBarsState();
}

class _LiquidGlassTabBarsState extends State<LiquidGlassTabBars> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _clampIndex(widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant LiquidGlassTabBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      _selectedIndex = _clampIndex(widget.initialIndex);
    }
    if (widget.items.length != oldWidget.items.length ||
        (widget.trailingItem == null) != (oldWidget.trailingItem == null)) {
      _selectedIndex = _clampIndex(_selectedIndex);
    }
  }

  int _clampIndex(int index) {
    final count = widget.items.length + (widget.trailingItem == null ? 0 : 1);
    return index.clamp(0, count - 1);
  }

  void _handleTap(int index) {
    final item = index < widget.items.length
        ? widget.items[index]
        : widget.trailingItem!;
    if (_selectedIndex == index) {
      item.onTap?.call();
      return;
    }

    setState(() => _selectedIndex = index);
    widget.onChanged?.call(index);
    item.onTap?.call();
  }

  Widget _buildIndicator(double radius) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: widget.indicatorShadowColor,
            blurRadius: widget.indicatorShadowBlur,
            offset: widget.indicatorShadowOffset,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.indicatorBlurSigma,
            sigmaY: widget.indicatorBlurSigma,
          ),
          child: CustomPaint(
            foregroundPainter: _GlassEdgePainter(
              radius: radius,
              borderColor: widget.indicatorBorderColor,
              sheenColor: widget.sheenColor,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.indicatorColor,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.sheenColor.withValues(alpha: 0.22),
                    widget.indicatorColor,
                    widget.indicatorColor.withValues(
                      alpha: widget.indicatorColor.a * 0.68,
                    ),
                  ],
                  stops: const [0, 0.48, 1],
                ),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hideOnKeyboard && MediaQuery.of(context).viewInsets.bottom > 0) {
      return const SizedBox.shrink();
    }

    final bottomInset = widget.useSafeArea
        ? MediaQuery.of(context).padding.bottom
        : 0.0;
    final groupedBar = widget.trailingItem == null
        ? _buildMainBar()
        : LayoutBuilder(
            builder: (context, constraints) {
              final mainBar = _buildMainBar();
              final trailingBar = SizedBox.square(
                dimension: widget.height,
                child: _buildTrailingBar(),
              );
              if (!constraints.hasBoundedWidth) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: widget.items.length * 76, child: mainBar),
                    SizedBox(width: widget.groupGap),
                    trailingBar,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: mainBar),
                  SizedBox(width: widget.groupGap),
                  trailingBar,
                ],
              );
            },
          );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: groupedBar,
    );
  }

  Widget _glassShell({required double radius, required Widget child}) {
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor,
            blurRadius: widget.shadowBlur,
            offset: widget.shadowOffset,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurSigma,
            sigmaY: widget.blurSigma,
          ),
          child: CustomPaint(
            foregroundPainter: _GlassEdgePainter(
              radius: radius,
              borderColor: widget.borderColor,
              sheenColor: widget.sheenColor,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.sheenColor.withValues(alpha: 0.24),
                    widget.backgroundColor,
                    widget.sheenSecondaryColor,
                    widget.backgroundColor.withValues(
                      alpha: widget.backgroundColor.a * 0.76,
                    ),
                  ],
                  stops: const [0, 0.34, 0.68, 1],
                ),
                borderRadius: borderRadius,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainBar() {
    final contentPadding = widget.padding;
    return _glassShell(
      radius: widget.borderRadius,
      child: SizedBox(
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fallbackWidth =
                widget.items.length * 76 + contentPadding.horizontal;
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : fallbackWidth.toDouble();
            final rawContentWidth = math.max(
              0.0,
              availableWidth - contentPadding.horizontal,
            );
            final totalGapWidth =
                widget.gap * (widget.items.length - 1).toDouble();
            final contentWidth = math.max(
              rawContentWidth,
              totalGapWidth + widget.items.length.toDouble(),
            );
            final tabWidth =
                (contentWidth - totalGapWidth) / widget.items.length;
            final selectedMainIndex = math.min(
              _selectedIndex,
              widget.items.length - 1,
            );

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  left:
                      contentPadding.left +
                      widget.indicatorPadding.left +
                      selectedMainIndex * (tabWidth + widget.gap),
                  top: widget.indicatorPadding.top,
                  bottom: widget.indicatorPadding.bottom,
                  width: math.max(
                    0.0,
                    tabWidth - widget.indicatorPadding.horizontal,
                  ),
                  child: AnimatedOpacity(
                    opacity: _selectedIndex < widget.items.length ? 1 : 0,
                    duration: widget.animationDuration,
                    child: IgnorePointer(
                      child: _buildIndicator(widget.indicatorRadius),
                    ),
                  ),
                ),
                Padding(
                  padding: contentPadding,
                  child: Row(
                    children: [
                      for (var i = 0; i < widget.items.length; i++) ...[
                        SizedBox(
                          width: tabWidth,
                          child: _buildTabButton(widget.items[i], i),
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
    );
  }

  Widget _buildTrailingBar() {
    final trailingIndex = widget.items.length;
    return _glassShell(
      radius: widget.height / 2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedOpacity(
            opacity: _selectedIndex == trailingIndex ? 1 : 0,
            duration: widget.animationDuration,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: _buildIndicator(widget.height / 2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: _buildTabButton(
              widget.trailingItem!,
              trailingIndex,
              showLabel: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    LiquidGlassTabBarItem item,
    int index, {
    bool showLabel = true,
  }) {
    return _TabBarButton(
      item: item,
      selected: index == _selectedIndex,
      showLabel: showLabel,
      iconSize: widget.iconSize,
      iconLabelSpacing: widget.iconLabelSpacing,
      labelFontSize: widget.labelFontSize,
      selectedColor: widget.selectedColor,
      unselectedColor: widget.unselectedColor,
      badgeColor: widget.badgeColor,
      badgeTextColor: widget.badgeTextColor,
      badgeTextStyle: widget.badgeTextStyle,
      labelStyle: widget.labelStyle,
      selectedLabelStyle: widget.selectedLabelStyle,
      duration: widget.animationDuration,
      curve: widget.animationCurve,
      onTap: () => _handleTap(index),
    );
  }
}

class _GlassEdgePainter extends CustomPainter {
  final double radius;
  final Color borderColor;
  final Color sheenColor;

  const _GlassEdgePainter({
    required this.radius,
    required this.borderColor,
    required this.sheenColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final bounds = Offset.zero & size;
    final outer = RRect.fromRectAndRadius(
      bounds.deflate(0.6),
      Radius.circular(math.max(0, radius - 0.6)),
    );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          sheenColor,
          borderColor,
          borderColor.withValues(alpha: borderColor.a * 0.28),
          const Color(0x33000000),
        ],
        stops: const [0, 0.34, 0.7, 1],
      ).createShader(bounds);
    canvas.drawRRect(outer, edge);

    final topHighlight = Path()
      ..moveTo(radius * 0.72, 1.4)
      ..quadraticBezierTo(
        size.width * 0.5,
        -0.2,
        size.width - radius * 0.72,
        1.4,
      );
    canvas.drawPath(
      topHighlight,
      Paint()
        ..color = sheenColor.withValues(alpha: sheenColor.a * 0.76)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant _GlassEdgePainter oldDelegate) {
    return radius != oldDelegate.radius ||
        borderColor != oldDelegate.borderColor ||
        sheenColor != oldDelegate.sheenColor;
  }
}

class _TabBarButton extends StatefulWidget {
  final LiquidGlassTabBarItem item;
  final bool selected;
  final bool showLabel;
  final double iconSize;
  final double iconLabelSpacing;
  final double labelFontSize;
  final Color selectedColor;
  final Color unselectedColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final TextStyle? badgeTextStyle;
  final TextStyle? labelStyle;
  final TextStyle? selectedLabelStyle;
  final Duration duration;
  final Curve curve;
  final VoidCallback onTap;

  const _TabBarButton({
    required this.item,
    required this.selected,
    required this.showLabel,
    required this.iconSize,
    required this.iconLabelSpacing,
    required this.labelFontSize,
    required this.selectedColor,
    required this.unselectedColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.badgeTextStyle,
    required this.labelStyle,
    required this.selectedLabelStyle,
    required this.duration,
    required this.curve,
    required this.onTap,
  });

  @override
  State<_TabBarButton> createState() => _TabBarButtonState();
}

class _TabBarButtonState extends State<_TabBarButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? widget.selectedColor
        : widget.unselectedColor;
    final iconWidget = widget.selected
        ? (widget.item.activeIcon ?? widget.item.icon)
        : (widget.item.inactiveIcon ?? widget.item.icon);
    final baseLabelStyle =
        widget.labelStyle ??
        TextStyle(fontSize: widget.labelFontSize, height: 1.1);
    final activeLabelStyle = widget.selectedLabelStyle ?? baseLabelStyle;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Semantics(
        button: true,
        selected: widget.selected,
        label: widget.item.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TabIcon(
                  icon: iconWidget,
                  size: widget.iconSize,
                  color: color,
                  badge: widget.item.badge,
                  badgeColor: widget.badgeColor,
                  badgeTextColor: widget.badgeTextColor,
                  badgeTextStyle: widget.badgeTextStyle,
                  duration: widget.duration,
                  curve: widget.curve,
                ),
                if (widget.showLabel) ...[
                  SizedBox(height: widget.iconLabelSpacing),
                  AnimatedDefaultTextStyle(
                    duration: widget.duration,
                    curve: widget.curve,
                    style: (widget.selected ? activeLabelStyle : baseLabelStyle)
                        .copyWith(
                          color: color,
                          fontWeight: widget.selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                    child: Text(
                      widget.item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

class _TabIcon extends StatelessWidget {
  final Widget icon;
  final double size;
  final Color color;
  final String? badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final TextStyle? badgeTextStyle;
  final Duration duration;
  final Curve curve;

  const _TabIcon({
    required this.icon,
    required this.size,
    required this.color,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.badgeTextStyle,
    required this.duration,
    required this.curve,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: duration,
      curve: curve,
      builder: (context, value, child) => IconTheme(
        data: IconThemeData(color: value, size: size),
        child: child!,
      ),
      child: SizedBox(
        height: size,
        width: size,
        child: FittedBox(child: icon),
      ),
    );

    if (badge == null || badge!.isEmpty) {
      return iconWidget;
    }

    iconWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          top: -4,
          right: -10,
          child: _TabBadge(
            text: badge!,
            badgeColor: badgeColor,
            badgeTextColor: badgeTextColor,
            badgeTextStyle: badgeTextStyle,
          ),
        ),
      ],
    );

    return iconWidget;
  }
}

class _TabBadge extends StatelessWidget {
  final String text;
  final Color badgeColor;
  final Color badgeTextColor;
  final TextStyle? badgeTextStyle;

  const _TabBadge({
    required this.text,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.badgeTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isSingle = text.length == 1;
    final padding = isSingle
        ? const EdgeInsets.symmetric(horizontal: 5, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 6, vertical: 2);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: padding,
        child: Text(
          text,
          style: (badgeTextStyle ?? const TextStyle(fontSize: 10)).copyWith(
            color: badgeTextColor,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class LiquidGlassTabBarItem {
  final String label;
  final Widget icon;
  final Widget? activeIcon;
  final Widget? inactiveIcon;
  final String? badge;
  final VoidCallback? onTap;

  const LiquidGlassTabBarItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.inactiveIcon,
    this.badge,
    this.onTap,
  });
}
