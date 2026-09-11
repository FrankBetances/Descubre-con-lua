import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asserts that [finder] matches, scrolling the nearest scrollable first when
/// the target has not been built yet.
///
/// A `ListView` only builds the children inside (or near) the viewport, so on
/// the 800x600 test surface anything below the fold matches zero widgets even
/// though a real user reaches it by scrolling. Asserting without scrolling
/// therefore tests the viewport height, not the screen.
///
/// The search runs downwards first and then upwards, because assertions often
/// come back to content that earlier scrolling has already left behind.
Future<void> expectAfterScrolling(
  WidgetTester tester,
  Finder finder, {
  Matcher matcher = findsOneWidget,
  Finder? scrollable,
  double delta = 180.0,
  int maxScrolls = 40,
}) async {
  if (finder.evaluate().isEmpty) {
    final target = scrollable ?? find.byType(Scrollable).first;

    Future<bool> sweep(Offset step, int iterations) async {
      for (var i = 0; i < iterations && finder.evaluate().isEmpty; i++) {
        await tester.drag(target, step);
        await tester.pumpAndSettle();
      }
      return finder.evaluate().isNotEmpty;
    }

    final found = await sweep(Offset(0, -delta), maxScrolls) ||
        await sweep(Offset(0, delta), maxScrolls * 2);

    if (found) {
      await tester.ensureVisible(finder.first);
      await tester.pumpAndSettle();
    }
  }
  expect(finder, matcher);
}

/// Scrolls [finder] into view and taps it.
///
/// Tapping a widget that earlier scrolling pushed outside the viewport sends
/// the gesture to whatever now occupies those coordinates, so the tap silently
/// does nothing and the assertion that follows fails for the wrong reason.
Future<void> tapAfterScrolling(
  WidgetTester tester,
  Finder finder, {
  Finder? scrollable,
}) async {
  await expectAfterScrolling(
    tester,
    finder,
    matcher: findsWidgets,
    scrollable: scrollable,
  );
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}
