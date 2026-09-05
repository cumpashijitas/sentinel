import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/shared/widgets/responsive_content.dart';

const _contentKey = Key('content');

Future<void> pumpAtWidth(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: ResponsiveContent(
          // Explicit even though it matches the default — the expected
          // values below (500/900/250) are derived from this number.
          // ignore: avoid_redundant_argument_values
          maxWidth: 900,
          child: ColoredBox(
            key: _contentKey,
            color: Colors.red,
            child: SizedBox.expand(),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ResponsiveContent', () {
    testWidgets('fills the available width below maxWidth', (tester) async {
      await pumpAtWidth(tester, 500);

      final size = tester.getSize(find.byKey(_contentKey));
      expect(size.width, 500);
    });

    testWidgets('caps the width above maxWidth', (tester) async {
      await pumpAtWidth(tester, 1400);

      final size = tester.getSize(find.byKey(_contentKey));
      expect(size.width, 900);
    });

    testWidgets('centers the constrained content horizontally', (tester) async {
      await pumpAtWidth(tester, 1400);

      final contentLeft = tester.getTopLeft(find.byKey(_contentKey)).dx;
      // (1400 - 900) / 2
      expect(contentLeft, 250);
    });
  });
}
