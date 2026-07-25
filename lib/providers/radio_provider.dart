import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/radio_station.dart';
import '../services/audio_service.dart';
import '../services/radio_api_service.dart';

class RadioProvider with ChangeNotifier {
  final AudioService _audioService = AudioService();

  // Estado de la aplicación
  List<RadioStation> _stations = [];
  List<RadioStation> _favoriteStations = [];
  RadioStation? _currentStation;
  bool _isLoading = false;
  bool _isPlaying = false;
  String _errorMessage = '';
  double _volume = 0.7;

  // Getters
  List<RadioStation> get stations => _stations;
  List<RadioStation> get favoriteStations => _favoriteStations;
  RadioStation? get currentStation => _currentStation;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  String get errorMessage => _errorMessage;
  double get volume => _volume;
  AudioService get audioService => _audioService;

  // Constructor
  RadioProvider() {
    _initializeProvider();
  }

  // Inicializar el provider
  Future<void> _initializeProvider() async {
    await _audioService.initialize();
    
    // Escuchar cambios en el estado del reproductor
    _audioService.onPlayerStateChanged.listen((isPlaying) {
      _isPlaying = isPlaying;
      notifyListeners();
    });

    // Cargar favoritos y estaciones al inicio
    await _loadFavorites();
    await loadPopularStations();
  }

  // Cargar favoritos desde SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorite_stations') ?? [];
      
      _favoriteStations = favoritesJson
          .map((jsonString) => RadioStation.fromJson(json.decode(jsonString)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando favoritos: $e');
    }
  }

  // Guardar favoritos en SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favoriteStations
          .map((station) => json.encode(station.toJson()))
          .toList();
      
      await prefs.setStringList('favorite_stations', favoritesJson);
    } catch (e) {
      debugPrint('Error guardando favoritos: $e');
    }
  }

  // Cargar estaciones populares
  Future<void> loadPopularStations() async {
    await _performApiCall(() async {
      _stations = await RadioApiService.getPopularStations();
    });
  }

  // Buscar estaciones
  Future<void> searchStations(String query) async {
    if (query.trim().isEmpty) {
      await loadPopularStations();
      return;
    }

    await _performApiCall(() async {
      _stations = await RadioApiService.searchStations(query);
    });
  }

  // Obtener estaciones por país
  Future<void> getStationsByCountry(String country) async {
    await _performApiCall(() async {
      _stations = await RadioApiService.getStationsByCountry(country);
    });
  }

  // Obtener estaciones por género
  Future<void> getStationsByGenre(String genre) async {
    await _performApiCall(() async {
      _stations = await RadioApiService.getStationsByGenre(genre);
    });
  }

  // Reproducir una estación
  Future<void> playStation(RadioStation station) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _audioService.playStation(station);
      if (success) {
        _currentStation = station;
        _isPlaying = true;
        // Registrar el clic en radio-browser (ayuda a las estadísticas de la API)
        RadioApiService.registerStationClick(station.uuid);
      } else {
        _setError('No se pudo reproducir la estación');
      }
    } catch (e) {
      _setError('Error al reproducir: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioService.pause();
      } else {
        await _audioService.resume();
      }
    } catch (e) {
      _setError('Error al pausar/reanudar: $e');
    }
  }

  // Detener reproducción
  Future<void> stopPlayback() async {
    try {
      await _audioService.stop();
      _currentStation = null;
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      _setError('Error al detener: $e');
    }
  }

  // Establecer volumen
  Future<void> setVolume(double volume) async {
    try {
      _volume = volume;
      await _audioService.setVolume(volume);
      notifyListeners();
    } catch (e) {
      _setError('Error al cambiar volumen: $e');
    }
  }

  // Toggle favorito
  Future<void> toggleFavorite(RadioStation station) async {
    if (isFavorite(station)) {
      _favoriteStations.removeWhere((s) => s.id == station.id);
    } else {
      _favoriteStations.add(station);
    }
    await _saveFavorites();
    notifyListeners();
  }

  // Verificar si es favorito
  bool isFavorite(RadioStation station) {
    return _favoriteStations.any((s) => s.id == station.id);
  }

  // Método auxiliar para llamadas API
  Future<void> _performApiCall(Future<void> Function() apiCall) async {
    try {
      _setLoading(true);
      _clearError();
      await apiCall();
    } catch (e) {
      _setError('Error de conexión: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Métodos auxiliares
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
