import 'package:arcade/widgets/navigations/dock.dart';
import 'package:arcade/widgets/navigations/floating_dock.dart';
import 'package:arcade/widgets/navigations/liquid_glass_tab_bars.dart';
import 'package:arcade/widgets/navigations/motion_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dock keeps its resting height compact', (tester) async {
    await tester.pumpWidget(
      _looseHost(
        const Dock(
          items: [
            DockIcon(child: Icon(Icons.home)),
            DockIcon(child: Icon(Icons.settings)),
          ],
        ),
      ),
    );

    expect(tester.getSize(find.byType(Dock)).height, 64);
  });

  testWidgets('Dock lays out items vertically and keeps taps working', (
    tester,
  ) async {
    var taps = 0;
    const firstKey = Key('first');
    const secondKey = Key('second');

    await tester.pumpWidget(
      _looseHost(
        Dock(
          direction: Axis.vertical,
          itemSize: 40,
          maxScale: 1,
          items: [
            DockIcon(
              onTap: () => taps++,
              child: const Icon(Icons.home, key: firstKey),
            ),
            const DockSeparator(),
            const DockIcon(child: Icon(Icons.settings, key: secondKey)),
          ],
        ),
      ),
    );

    final first = tester.getCenter(find.byKey(firstKey));
    final second = tester.getCenter(find.byKey(secondKey));
    expect(first.dx, closeTo(second.dx, 0.1));
    expect(first.dy, lessThan(second.dy));

    await tester.tap(find.byKey(firstKey));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MotionTabs reports selection and item taps', (tester) async {
    int? selected;
    var itemTaps = 0;

    await tester.pumpWidget(
      _host(
        MotionTabs(
          onChanged: (value) => selected = value,
          items: [
            const MotionTabItem(label: 'Preview'),
            MotionTabItem(label: 'Code', onTap: () => itemTaps++),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Code'));
    await tester.pumpAndSettle();
    expect(selected, 1);
    expect(itemTaps, 1);
  });

  testWidgets('FloatingDock keeps its resting height compact', (tester) async {
    await tester.pumpWidget(
      _looseHost(
        FloatingDock(
          items: const [
            FloatingDockItem(icon: Icon(Icons.home)),
            FloatingDockItem(icon: Icon(Icons.settings)),
          ],
        ),
      ),
    );

    expect(tester.getSize(find.byType(FloatingDock)).height, 72);
  });

  testWidgets('LiquidGlassTabBars clamps and updates selection', (
    tester,
  ) async {
    int? selected;

    await tester.pumpWidget(
      _host(
        LiquidGlassTabBars(
          initialIndex: 99,
          onChanged: (value) => selected = value,
          items: const [
            LiquidGlassTabBarItem(label: 'Home', icon: Icon(Icons.home)),
            LiquidGlassTabBarItem(label: 'Search', icon: Icon(Icons.search)),
            LiquidGlassTabBarItem(label: 'Profile', icon: Icon(Icons.person)),
          ],
          trailingItem: const LiquidGlassTabBarItem(
            label: 'More',
            icon: Icon(Icons.more_horiz),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(selected, 0);

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    expect(selected, 3);
    expect(tester.takeException(), isNull);
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: 420, height: 320, child: child)),
    ),
  );
}

Widget _looseHost(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}
