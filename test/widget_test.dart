import 'package:flutter_test/flutter_test.dart';
import 'package:smart_calculator_plus/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCalculatorApp());
    expect(find.text('Smart Calculator Plus'), findsOneWidget);
  });
}
