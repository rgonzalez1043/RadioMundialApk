// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:radio_mundial_api/main.dart';

void main() {
  testWidgets('Radio Mundial App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RadioMundialApp());

    // Verify that our app loads with the correct title.
    expect(find.text('Radio Mundial'), findsOneWidget);
    
    // Verify that the tabs are present
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);
    expect(find.text('Países'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
  });
}
