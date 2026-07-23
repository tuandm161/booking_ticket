import 'package:booking_cinema/shared/widgets/app_press_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPressScale Widget Tests', () {
    testWidgets('renders child widget correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPressScale(
              child: Text('Test Button'),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when pressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPressScale(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('animates scale on press and release', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 80,
                child: AppPressScale(
                  pressedScale: 0.96,
                  // Provide onTap so GestureDetector is part of tree,
                  // which makes hit-testing work correctly in tests.
                  onTap: null,
                  child: Text('Scale Me'),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify initial scale is 1.0 (no press).
      final transformFinder = find.descendant(
        of: find.byType(AppPressScale),
        matching: find.byType(Transform),
      );
      final initial = tester.widget<Transform>(transformFinder);
      expect(initial.transform.getMaxScaleOnAxis(), closeTo(1.0, 0.01));

      // Tap and settle — widget should return to scale 1.0 after release.
      await tester.tap(find.byType(AppPressScale), warnIfMissed: false);
      await tester.pumpAndSettle();

      final afterTap = tester.widget<Transform>(transformFinder);
      expect(afterTap.transform.getMaxScaleOnAxis(), closeTo(1.0, 0.01));
    });

    testWidgets('respects enabled flag when false', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPressScale(
              enabled: false,
              onTap: () => tapped = true,
              child: const Text('Disabled'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });
  });
}
