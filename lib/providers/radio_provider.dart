import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/country.dart';
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

  // Países y géneros cargados dinámicamente desde la API
  List<Country> _countries = [];
  List<String> _genres = const [
    'Pop', 'Rock', 'News', 'Jazz', 'Classical', 'Dance', 'Sports', 'Talk',
  ];
  bool _countriesLoading = false;

  // Recuperación ante streams caídos
  static const int _maxPlayAttempts = 3;
  int _playAttempts = 0;
  bool _isReconnecting = false;

  // Temporizador de apagado
  Timer? _sleepTimer;
  Timer? _sleepTicker;
  DateTime? _sleepEndTime;

  // Getters
  List<RadioStation> get stations => _stations;
  List<RadioStation> get favoriteStations => _favoriteStations;
  RadioStation? get currentStation => _currentStation;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  String get errorMessage => _errorMessage;
  AudioService get audioService => _audioService;
  List<Country> get countries => _countries;
  List<String> get genres => _genres;
  bool get countriesLoading => _countriesLoading;

  /// Tiempo restante del temporizador de apagado (null si no hay ninguno).
  Duration? get sleepRemaining {
    final endTime = _sleepEndTime;
    if (endTime == null) return null;
    final remaining = endTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

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

    // Reconectar si el stream se cae a mitad de la reproducción
    _audioService.onPlaybackError.listen((_) => _handleStreamDrop());

    // Cargar favoritos y estaciones al inicio
    await _loadFavorites();
    await loadPopularStations();

    // Países y géneros se cargan en segundo plano
    unawaited(loadCountries());
    unawaited(loadGenres());
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

  // Obtener estaciones por código de país (ISO 3166-1 alfa-2)
  Future<void> getStationsByCountryCode(String countryCode) async {
    await _performApiCall(() async {
      _stations = await RadioApiService.getStationsByCountryCode(countryCode);
    });
  }

  // Obtener estaciones por género
  Future<void> getStationsByGenre(String genre) async {
    await _performApiCall(() async {
      _stations = await RadioApiService.getStationsByGenre(genre);
    });
  }

  // Cargar la lista de países desde la API
  Future<void> loadCountries() async {
    if (_countriesLoading) return;
    _countriesLoading = true;
    notifyListeners();
    try {
      _countries = await RadioApiService.getCountries();
    } catch (e) {
      debugPrint('Error cargando países: $e');
    } finally {
      _countriesLoading = false;
      notifyListeners();
    }
  }

  // Cargar los géneros más populares desde la API
  Future<void> loadGenres() async {
    try {
      final genres = await RadioApiService.getGenres();
      if (genres.isNotEmpty) {
        _genres = genres;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error cargando géneros: $e');
    }
  }

  // Reproducir una estación con recuperación ante streams caídos:
  // si falla, prueba automáticamente con las siguientes de la lista.
  Future<void> playStation(RadioStation station) async {
    _playAttempts = 0;
    await _playWithRecovery(station);
  }

  Future<void> _playWithRecovery(RadioStation station) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _audioService.playStation(station);
      if (success) {
        _currentStation = station;
        _isPlaying = true;
        _playAttempts = 0;
        // Registrar el clic en radio-browser (ayuda a las estadísticas de la API)
        unawaited(RadioApiService.registerStationClick(station.uuid));
      } else {
        await _tryNextStation(station);
      }
    } catch (e) {
      debugPrint('Error al reproducir: $e');
      await _tryNextStation(station);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _tryNextStation(RadioStation failedStation) async {
    _playAttempts++;
    final next = _nextStationAfter(failedStation);

    if (_playAttempts < _maxPlayAttempts && next != null) {
      debugPrint('Stream caído, probando con: ${next.name}');
      await _playWithRecovery(next);
    } else {
      _currentStation = null;
      _isPlaying = false;
      _playAttempts = 0;
      _setError('No se pudo reproducir. Prueba con otra estación.');
    }
  }

  RadioStation? _nextStationAfter(RadioStation station) {
    if (_stations.length < 2) return null;
    final index = _stations.indexWhere((s) => s.id == station.id);
    if (index == -1) return null;
    return _stations[(index + 1) % _stations.length];
  }

  // Reconexión cuando el stream se interrumpe a mitad de la reproducción
  Future<void> _handleStreamDrop() async {
    final station = _currentStation;
    if (station == null || _isReconnecting) return;

    _isReconnecting = true;
    debugPrint('Stream interrumpido, reconectando...');
    await Future.delayed(const Duration(seconds: 3));

    final success = await _audioService.playStation(station);
    if (!success) {
      _currentStation = null;
      _isPlaying = false;
      _setError('Se perdió la conexión con la estación.');
    }
    notifyListeners();
    _isReconnecting = false;
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

  // Activar el temporizador de apagado
  void setSleepTimer(Duration duration) {
    cancelSleepTimer();
    _sleepEndTime = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, _onSleepTimerFired);
    // Actualizar la cuenta regresiva visible cada 30 segundos
    _sleepTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      notifyListeners();
    });
    notifyListeners();
  }

  // Cancelar el temporizador de apagado
  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTicker?.cancel();
    _sleepTimer = null;
    _sleepTicker = null;
    _sleepEndTime = null;
    notifyListeners();
  }

  Future<void> _onSleepTimerFired() async {
    _sleepTicker?.cancel();
    _sleepTicker = null;
    _sleepTimer = null;
    _sleepEndTime = null;
    await stopPlayback();
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
    _sleepTimer?.cancel();
    _sleepTicker?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
