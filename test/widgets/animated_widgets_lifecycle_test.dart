import 'package:arcade/widgets/backgrounds/black_hole_background.dart';
import 'package:arcade/widgets/backgrounds/flickering_grid.dart';
import 'package:arcade/widgets/borders/gliding_glow_box.dart';
import 'package:arcade/widgets/games/space_shooter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('decorative animations stop when reduced motion is enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _reducedMotionHost(
        const Stack(
          children: [
            Positioned.fill(child: FlickeringGrid()),
            Positioned.fill(child: BlackHoleBackground()),
            Center(
              child: GlidingGlowBox(child: SizedBox(width: 80, height: 40)),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('animated widgets release their tickers when unmounted', (
    tester,
  ) async {
    for (var i = 0; i < 5; i++) {
      await tester.pumpWidget(
        _host(
          const Stack(
            children: [
              Positioned.fill(child: FlickeringGrid()),
              Positioned.fill(child: BlackHoleBackground()),
              Center(
                child: GlidingGlowBox(child: SizedBox(width: 80, height: 40)),
              ),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpWidget(_host(const SizedBox.shrink()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('space shooter starts, runs, and disposes cleanly', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SpaceShooter(enemySpawnInterval: 10000, bulletFireInterval: 100),
      ),
    );

    expect(find.text('PLAY'), findsOneWidget);
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Score: 10'), findsOneWidget);

    await tester.pumpWidget(_host(const SizedBox.shrink()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: 640, height: 480, child: child)),
    ),
  );
}

Widget _reducedMotionHost(Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(640, 480), disableAnimations: true),
      child: Scaffold(
        body: Center(child: SizedBox(width: 640, height: 480, child: child)),
      ),
    ),
  );
}
