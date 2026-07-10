import 'package:arcade/models/widget_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routePath converts asset identifiers to public kebab-case routes', () {
    const metadata = WidgetMetadata(
      name: 'BlackHoleBackground',
      group: 'backgrounds',
      description: 'A background',
      sourcePath: 'lib/widgets/backgrounds/black_hole_background.dart',
      demoPath: 'lib/widgets/backgrounds/black_hole_background_demo.dart',
      identifier: 'backgrounds/black_hole_background',
    );

    expect(metadata.routePath, '/widgets/backgrounds/black-hole-background');
  });
}
