import 'package:flutter_test/flutter_test.dart';
import 'package:textile_erp/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TextileERPMain());
    expect(find.byType(TextileERPMain), findsOneWidget);
  });
}
