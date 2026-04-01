import 'package:cricket_manager_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const CricketManagerApp());
    expect(find.text('Cricket Dynasty Manager'), findsOneWidget);
    expect(find.text('Season 2026 Command Center'), findsOneWidget);
  });
}
