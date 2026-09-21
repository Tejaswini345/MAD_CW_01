import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cw1_counter_app/main.dart';

void main() {
  testWidgets('counter increments', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CounterImageToggleApp());
    await tester.pumpAndSettle();

    expect(find.text('Counter: 0'), findsOneWidget);

    await tester.tap(find.text('Increment'));
    await tester.pump();

    expect(find.text('Counter: 1'), findsOneWidget);
  });
}
