import 'package:cricket_manager_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to opening screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CricketManagerApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('Chairman'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
  });
}
