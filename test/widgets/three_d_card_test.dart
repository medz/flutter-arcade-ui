import 'package:arcade/widgets/cards/three_d_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ThreeDCard handles hover and disposes its animation', (
    tester,
  ) async {
    var hoverStarts = 0;
    var hoverEnds = 0;
    const cardKey = Key('card');

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ThreeDCard(
            onHoverStart: () => hoverStarts++,
            onHoverEnd: () => hoverEnds++,
            child: const SizedBox(key: cardKey, width: 220, height: 160),
          ),
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.byKey(cardKey)));
    await tester.pump(const Duration(milliseconds: 40));
    expect(hoverStarts, 1);

    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(milliseconds: 240));
    expect(hoverEnds, 1);
    await mouse.removePointer();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
