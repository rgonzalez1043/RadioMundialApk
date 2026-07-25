import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/radio_station.dart';
import '../models/country.dart';

class RadioApiService {
  static const String baseUrl = 'https://de2.api.radio-browser.info';
  static const Map<String, String> headers = {
    'User-Agent': 'WorldRadioApp/1.0',
    'Content-Type': 'application/json',
  };

  // Obtener estaciones por país
  static Future<List<RadioStation>> getStationsByCountry(String country) async {
    try {
      final url = Uri.parse('$baseUrl/json/stations/bycountry/$country');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RadioStation.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener estaciones: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en getStationsByCountry: $e');
      return _getFallbackStationsByCountry(country);
    }
  }

  // Obtener estaciones por código de país
  static Future<List<RadioStation>> getStationsByCountryCode(String countryCode) async {
    try {
      final url = Uri.parse('$baseUrl/json/stations/bycountrycodeexact/${countryCode.toUpperCase()}');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RadioStation.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener estaciones: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en getStationsByCountryCode: $e');
      return _getFallbackStationsByCountry(countryCode);
    }
  }

  // Obtener estaciones por género/tag
  static Future<List<RadioStation>> getStationsByGenre(String genre) async {
    try {
      final url = Uri.parse('$baseUrl/json/stations/bytag/$genre');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RadioStation.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener estaciones: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en getStationsByGenre: $e');
      return _getFallbackStationsByGenre(genre);
    }
  }

  // Obtener estaciones por país y género
  static Future<List<RadioStation>> getStationsByCountryAndGenre(
    String country, 
    String genre
  ) async {
    try {
      // Primero obtenemos todas las estaciones del país
      final countryStations = await getStationsByCountry(country);
      
      // Luego filtramos por género
      final filteredStations = countryStations.where((station) {
        return station.hasGenre(genre);
      }).toList();

      // Si no hay suficientes, buscamos por género globalmente y filtramos por país
      if (filteredStations.length < 10) {
        final genreStations = await getStationsByGenre(genre);
        final additionalStations = genreStations.where((station) {
          return station.country.toLowerCase().contains(country.toLowerCase()) &&
                 !filteredStations.any((existing) => existing.uuid == station.uuid);
        }).toList();
        
        filteredStations.addAll(additionalStations);
      }

      return filteredStations;
    } catch (e) {
      debugPrint('Error en getStationsByCountryAndGenre: $e');
      return _getFallbackStations();
    }
  }

  // Obtener estaciones populares
  static Future<List<RadioStation>> getPopularStations({int limit = 50}) async {
    try {
      final url = Uri.parse('$baseUrl/json/stations/topvote?limit=$limit');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RadioStation.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener estaciones populares: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en getPopularStations: $e');
      return _getFallbackStations();
    }
  }

  // Buscar estaciones por nombre
  static Future<List<RadioStation>> searchStations(String query) async {
    try {
      final url = Uri.parse('$baseUrl/json/stations/byname/$query');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RadioStation.fromJson(json)).toList();
      } else {
        throw Exception('Error en la búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en searchStations: $e');
      return _getFallbackStationsBySearch(query);
    }
  }

  // Obtener lista de países (ordenados por cantidad de emisoras)
  static Future<List<Country>> getCountries() async {
    try {
      final url = Uri.parse('$baseUrl/json/countries?order=stationcount&reverse=true&hidebroken=true');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Country.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener países: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en getCountries: $e');
      return _getFallbackCountries();
    }
  }

  // Obtener los géneros/tags más populares
  static Future<List<String>> getGenres({int limit = 14}) async {
    try {
      final url = Uri.parse('$baseUrl/json/tags?order=stationcount&reverse=true&limit=$limit&hidebroken=true');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => item['name'].toString().trim())
            .where((name) => name.length > 1)
            .toList();
      } else {
        throw Exception('Error al obtener géneros: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en getGenres: $e');
      return _getFallbackGenres();
    }
  }

  // Registrar click en estación (para estadísticas)
  static Future<void> registerStationClick(String stationUuid) async {
    try {
      final url = Uri.parse('$baseUrl/json/url/$stationUuid');
      await http.get(url, headers: headers);
    } catch (e) {
      // No es crítico si falla
      debugPrint('Error registrando click: $e');
    }
  }

  // Filtrar estaciones de calidad
  static List<RadioStation> filterQualityStations(List<RadioStation> stations) {
    return stations.where((station) {
      // Filtros de calidad
      final hasValidUrl = station.url.isNotEmpty && 
                         (station.url.contains('.mp3') || 
                          station.url.contains('.aac') || 
                          station.url.contains('stream'));
      
      final hasName = station.name.isNotEmpty && station.name.length > 2;
      
      final notPlaylist = !station.url.contains('.m3u') && 
                         !station.url.contains('.pls');
      
      return hasValidUrl && hasName && notPlaylist;
    }).toList();
  }

  // Ordenar estaciones por calidad
  static List<RadioStation> sortByQuality(List<RadioStation> stations) {
    stations.sort((a, b) {
      // Primero por votos, luego por bitrate
      final voteComparison = b.votes.compareTo(a.votes);
      if (voteComparison != 0) return voteComparison;
      
      return b.bitrate.compareTo(a.bitrate);
    });
    
    return stations;
  }

  // Estaciones de respaldo
  static List<RadioStation> _getFallbackStations() {
    return [
      RadioStation(
        uuid: '1',
        name: 'Radio Mitre',
        url: 'https://playerservices.streamtheworld.com/api/livestream-redirect/MITRE.mp3',
        country: 'Argentina',
        tags: 'Noticias',
        homepage: 'Radio Mitre Argentina',
        favicon: 'https://cdn-profiles.tunein.com/s47135/images/logog.png',
        votes: 100,
        bitrate: 128,
      ),
      RadioStation(
        uuid: '2',
        name: 'Cadena SER',
        url: 'https://playerservices.streamtheworld.com/api/livestream-redirect/CADENASER.mp3',
        country: 'España',
        tags: 'Noticias',
        homepage: 'Cadena SER España',
        favicon: 'https://cdn-profiles.tunein.com/s24939/images/logog.jpg',
        votes: 95,
        bitrate: 128,
      ),
      RadioStation(
        uuid: '3',
        name: 'BBC Radio 1',
        url: 'https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one',
        country: 'Reino Unido',
        tags: 'Pop',
        homepage: 'BBC Radio 1',
        favicon: 'https://cdn-profiles.tunein.com/s24943/images/logog.png',
        votes: 90,
        bitrate: 128,
      ),
      RadioStation(
        uuid: '4',
        name: 'RTL',
        url: 'https://streaming.radio.rtl.fr/rtl-1-44-128',
        country: 'Francia',
        tags: 'Noticias',
        homepage: 'RTL Francia',
        favicon: 'https://cdn-profiles.tunein.com/s24941/images/logog.png',
        votes: 85,
        bitrate: 128,
      ),
      RadioStation(
        uuid: '5',
        name: 'KIIS FM',
        url: 'https://playerservices.streamtheworld.com/api/livestream-redirect/KIISFMAAC.aac',
        country: 'Estados Unidos',
        tags: 'Pop',
        homepage: 'KIIS FM Los Angeles',
        favicon: 'https://cdn-profiles.tunein.com/s33395/images/logog.png',
        votes: 80,
        bitrate: 128,
      ),
      RadioStation(
        uuid: '6',
        name: 'Radio Caracol',
        url: 'https://playerservices.streamtheworld.com/api/livestream-redirect/CARACOL_RADIO.mp3',
        country: 'Colombia',
        tags: 'Noticias',
        homepage: 'Radio Caracol Colombia',
        favicon: 'https://cdn-profiles.tunein.com/s25098/images/logog.png',
        votes: 75,
        bitrate: 128,
      ),
      RadioStation(
        uuid: '7',
        name: 'Los 40 México',
        url: 'https://playerservices.streamtheworld.com/api/livestream-redirect/LOS40_MEXICO.mp3',
        country: 'México',
        tags: 'Pop',
        homepage: 'Los 40 Principales México',
        favicon: 'https://cdn-profiles.tunein.com/s308225/images/logog.png',
        votes: 70,
        bitrate: 128,
      ),
      RadioStation(
        uuid: '8',
        name: 'Rock & Pop',
        url: 'https://playerservices.streamtheworld.com/api/livestream-redirect/ROCK_AND_POP.mp3',
        country: 'Chile',
        tags: 'Rock',
        homepage: 'Rock & Pop Chile',
        favicon: 'https://cdn-profiles.tunein.com/s25099/images/logog.png',
        votes: 65,
        bitrate: 128,
      ),
    ];
  }

  // Métodos auxiliares para filtrar estaciones de respaldo
  static List<RadioStation> _getFallbackStationsByCountry(String country) {
    return _getFallbackStations().where((station) => 
      station.country.toLowerCase().contains(country.toLowerCase())
    ).toList();
  }

  static List<RadioStation> _getFallbackStationsByGenre(String genre) {
    return _getFallbackStations().where((station) => 
      station.tags.toLowerCase().contains(genre.toLowerCase())
    ).toList();
  }

  static List<RadioStation> _getFallbackStationsBySearch(String query) {
    return _getFallbackStations().where((station) => 
      station.name.toLowerCase().contains(query.toLowerCase()) ||
      station.country.toLowerCase().contains(query.toLowerCase()) ||
      station.tags.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  static List<Country> _getFallbackCountries() {
    return [
      Country(name: 'Argentina', iso31661: 'AR', stationcount: 1),
      Country(name: 'España', iso31661: 'ES', stationcount: 1),
      Country(name: 'Reino Unido', iso31661: 'GB', stationcount: 1),
      Country(name: 'Francia', iso31661: 'FR', stationcount: 1),
      Country(name: 'Estados Unidos', iso31661: 'US', stationcount: 1),
      Country(name: 'Colombia', iso31661: 'CO', stationcount: 1),
      Country(name: 'México', iso31661: 'MX', stationcount: 1),
      Country(name: 'Chile', iso31661: 'CL', stationcount: 1),
    ];
  }

  static List<String> _getFallbackGenres() {
    return ['Pop', 'Rock', 'Noticias', 'Jazz', 'Classical', 'Electronic', 'Sports', 'Talk'];
  }
}
