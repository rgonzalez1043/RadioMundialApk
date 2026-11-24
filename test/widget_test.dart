import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:radio_mundial_api/main.dart';
import 'package:radio_mundial_api/services/radio_api_service.dart';

void main() {
  testWidgets('sin conexión muestra la app con un mensaje para reintentar',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    RadioApiService.resetServers(['a.test']);
    RadioApiService.client = MockClient((_) async => http.Response('', 503));

    await tester.pumpWidget(const RadioMundialApp());
    await tester.pumpAndSettle();

    expect(find.text('WorldRadio FM'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);
    expect(find.text('Países'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);

    // La pestaña Popular muestra el error real con su botón de reintento.
    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
