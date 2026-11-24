import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/radio_station.dart';
import '../models/country.dart';

/// Error al consultar el directorio de Radio Browser.
class RadioApiException implements Exception {
  final String message;
  RadioApiException(this.message);
  @override
  String toString() => 'RadioApiException: $message';
}

/// Cliente de la API pública de Radio Browser (https://api.radio-browser.info).
///
/// Radio Browser pide repartir la carga entre sus servidores espejo: la lista
/// se obtiene de `all.api.radio-browser.info` y, si un servidor falla, se
/// prueba con el siguiente.
class RadioApiService {
  static const Duration _timeout = Duration(seconds: 10);
  static const int _pageSize = 100;
  static const Map<String, String> _headers = {
    'User-Agent': 'WorldRadioFM/1.0',
  };
  static const List<String> _defaultServers = [
    'de1.api.radio-browser.info',
    'de2.api.radio-browser.info',
  ];

  /// Cliente HTTP reemplazable en los tests.
  @visibleForTesting
  static http.Client client = http.Client();

  static List<String>? _servers;
  static int _serverIndex = 0;

  @visibleForTesting
  static void resetServers([List<String>? servers]) {
    _servers = servers;
    _serverIndex = 0;
  }

  static Future<List<String>> _getServers() async {
    final cached = _servers;
    if (cached != null) return cached;
    var servers = List<String>.of(_defaultServers);
    try {
      final response = await client
          .get(Uri.https('all.api.radio-browser.info', '/json/servers'),
              headers: _headers)
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final names = (json.decode(response.body) as List)
            .map((s) => (s as Map)['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet();
        if (names.isNotEmpty) servers = names.toList()..shuffle();
      }
    } catch (e) {
      debugPrint('No se pudo obtener la lista de servidores: $e');
    }
    return _servers = servers;
  }

  /// GET a la API probando cada servidor espejo hasta que uno responda.
  static Future<String> _get(String path, Map<String, String> params) async {
    final servers = await _getServers();
    Object? lastError;
    for (var attempt = 0; attempt < servers.length; attempt++) {
      final host = servers[_serverIndex % servers.length];
      try {
        final response = await client
            .get(Uri.https(host, path, params), headers: _headers)
            .timeout(_timeout);
        if (response.statusCode == 200) return response.body;
        lastError = 'HTTP ${response.statusCode}';
      } catch (e) {
        lastError = e;
      }
      debugPrint('Fallo en $host$path: $lastError');
      _serverIndex++;
    }
    throw RadioApiException('Sin respuesta del directorio de radios ($lastError)');
  }

  static Future<List<RadioStation>> _searchStations(Map<String, String> filters,
      {String order = 'clickcount'}) async {
    final body = await _get('/json/stations/search', {
      ...filters,
      'hidebroken': 'true',
      'order': order,
      'reverse': 'true',
      'limit': '$_pageSize',
    });
    return compute(parseStations, body);
  }

  /// Emisoras más votadas.
  static Future<List<RadioStation>> getPopularStations() =>
      _searchStations(const {}, order: 'votes');

  /// Emisoras de un país (código ISO 3166-1 alfa-2).
  static Future<List<RadioStation>> getStationsByCountryCode(String countryCode) =>
      _searchStations({'countrycode': countryCode.toUpperCase()});

  /// Emisoras por género/etiqueta.
  static Future<List<RadioStation>> getStationsByGenre(String genre) =>
      _searchStations({'tag': genre});

  /// Búsqueda por nombre de emisora.
  static Future<List<RadioStation>> searchStations(String query) =>
      _searchStations({'name': query.trim()});

  /// Países ordenados por cantidad de emisoras.
  static Future<List<Country>> getCountries() async {
    final body = await _get('/json/countries', const {
      'order': 'stationcount',
      'reverse': 'true',
      'hidebroken': 'true',
    });
    return (json.decode(body) as List)
        .map((item) => Country.fromJson(item as Map<String, dynamic>))
        .where((c) => c.iso31661.length == 2 && c.stationcount > 0)
        .toList();
  }

  /// Géneros/etiquetas más populares.
  static Future<List<String>> getGenres({int limit = 14}) async {
    final body = await _get('/json/tags', {
      'order': 'stationcount',
      'reverse': 'true',
      'hidebroken': 'true',
      'limit': '$limit',
    });
    return (json.decode(body) as List)
        .map((item) => (item as Map)['name'].toString().trim())
        .where((name) => name.length > 1)
        .toList();
  }

  /// Avisa a Radio Browser que se escuchó una emisora (estadísticas públicas).
  static Future<void> registerStationClick(String stationUuid) async {
    if (stationUuid.isEmpty) return;
    try {
      await _get('/json/url/$stationUuid', const {});
    } catch (e) {
      debugPrint('Error registrando click: $e');
    }
  }
}

/// Convierte la respuesta JSON en emisoras (se ejecuta en otro isolate).
@visibleForTesting
List<RadioStation> parseStations(String body) {
  return (json.decode(body) as List)
      .map((item) => RadioStation.fromJson(item as Map<String, dynamic>))
      .where((s) => s.name.trim().isNotEmpty && s.url.startsWith('http'))
      .toList();
}
