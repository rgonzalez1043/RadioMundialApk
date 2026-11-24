import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:radio_mundial_api/models/radio_station.dart';
import 'package:radio_mundial_api/services/radio_api_service.dart';

Map<String, dynamic> _station(String uuid, {String url = 'https://radio.test/live'}) => {
      'stationuuid': uuid,
      'name': 'Radio $uuid',
      'url': url,
      'url_resolved': url,
      'favicon': '',
      'country': 'Chile',
      'tags': 'pop,rock',
      'votes': 10,
      'bitrate': 128,
    };

void main() {
  setUp(() => RadioApiService.resetServers(['a.test', 'b.test']));

  test('la búsqueda codifica el texto y oculta emisoras caídas', () async {
    late Uri requested;
    RadioApiService.client = MockClient((request) async {
      requested = request.url;
      return http.Response(jsonEncode([_station('1')]), 200);
    });

    final result = await RadioApiService.searchStations('  AC/DC #1? ñandú ');

    expect(result, hasLength(1));
    expect(requested.path, '/json/stations/search');
    expect(requested.queryParameters['name'], 'AC/DC #1? ñandú');
    expect(requested.queryParameters['hidebroken'], 'true');
    expect(requested.fragment, isEmpty);
  });

  test('si un servidor falla prueba con el siguiente', () async {
    final hosts = <String>[];
    RadioApiService.client = MockClient((request) async {
      hosts.add(request.url.host);
      if (request.url.host == 'a.test') return http.Response('caído', 503);
      return http.Response(jsonEncode([_station('1'), _station('2')]), 200);
    });

    final result = await RadioApiService.getPopularStations();

    expect(result.map((s) => s.uuid), ['1', '2']);
    expect(hosts, ['a.test', 'b.test']);
  });

  test('si todos los servidores fallan lanza RadioApiException', () async {
    RadioApiService.client = MockClient((_) async => http.Response('', 500));

    expect(
      RadioApiService.getStationsByCountryCode('cl'),
      throwsA(isA<RadioApiException>()),
    );
  });

  test('parseStations descarta emisoras sin nombre o sin URL válida', () {
    final body = jsonEncode([
      _station('ok'),
      _station('sin-url', url: ''),
      {..._station('sin-nombre'), 'name': '  '},
      {..._station('texto'), 'votes': '42', 'bitrate': null},
    ]);

    final stations = parseStations(body);

    expect(stations.map((s) => s.uuid), ['ok', 'texto']);
    expect(stations.last.votes, 42);
    expect(stations.last.bitrate, 0);
  });

  test('un favorito guardado se recupera igual', () {
    final original = RadioStation.fromJson(_station('fav'));
    final restored = RadioStation.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );

    expect(restored, original);
    expect(restored.url, original.url);
    expect(restored.tags, original.tags);
  });
}
