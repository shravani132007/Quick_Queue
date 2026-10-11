import 'package:flutter_test/flutter_test.dart';

import 'package:smart_canteen/main.dart';

void main() {
  testWidgets('SmartCanteenApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCanteenApp());
    expect(find.text('WELCOME'), findsOneWidget);
  });

  testWidgets('Admin role toggle reveals Register New Shop button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmartCanteenApp());
    expect(find.text('WELCOME'), findsOneWidget);

    // Tap on Admin button
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // Verify 'Register New Shop / Canteen' button appears
    expect(find.text('Register New Shop / Canteen'), findsOneWidget);
  });
}
