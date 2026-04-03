import 'package:cricket_manager_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const CricketManagerApp());
    await tester.pumpAndSettle();
    expect(find.text('Command Center'), findsOneWidget);
    expect(find.textContaining('Season 2026'), findsOneWidget);
  });
}
