import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_manager/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const TontineManagerApp());
    expect(find.text('Tontine-Manager'), findsOneWidget);
  });
}
