import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/country.dart';
import '../models/radio_station.dart';
import '../services/audio_service.dart';
import '../services/radio_api_service.dart';

/// Estado de una lista de emisoras (populares, búsqueda o país).
class StationListState {
  List<RadioStation> stations = const [];
  bool loading = false;
  String error = '';
  int _request = 0;
}

class RadioProvider with ChangeNotifier {
  static const String _connectionError =
      'No se pudo conectar con el directorio de radios. Revisa tu conexión a internet.';
  static const int _maxPlayAttempts = 3;

  final AudioService _audioService = AudioService();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final StreamController<String> _messages = StreamController<String>.broadcast();
  bool _disposed = false;

  // Listas de cada pestaña (cada una con su propio estado de carga/error)
  final StationListState popular = StationListState();
  final StationListState search = StationListState();
  final StationListState byCountry = StationListState();
  Future<List<RadioStation>> Function()? _searchFetch;
  Country? _selectedCountry;

  List<RadioStation> _favoriteStations = [];

  // Reproducción
  RadioStation? _currentStation;
  List<RadioStation> _queue = const [];
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _wantsPlayback = false;
  bool _isReconnecting = false;
  int _playToken = 0;

  // Países y géneros cargados dinámicamente desde la API
  List<Country> _countries = [];
  bool _countriesLoading = false;
  List<String> _genres = const [
    'pop', 'rock', 'news', 'jazz', 'classical', 'dance', 'sports', 'talk',
  ];

  // Temporizador de apagado
  Timer? _sleepTimer;
  Timer? _sleepTicker;
  DateTime? _sleepEndTime;

  RadioProvider() {
    _initializeProvider();
  }

  // Getters
  List<RadioStation> get favoriteStations => _favoriteStations;
  RadioStation? get currentStation => _currentStation;
  bool get isPlaying => _isPlaying;

  /// Conectando con la emisora (distinto de cargar listas).
  bool get isBuffering => _isBuffering;
  List<Country> get countries => _countries;
  bool get countriesLoading => _countriesLoading;
  List<String> get genres => _genres;
  Country? get selectedCountry => _selectedCountry;
  bool get hasSearched => _searchFetch != null;

  /// Mensajes puntuales para mostrar al usuario (SnackBar).
  Stream<String> get messages => _messages.stream;

  /// Tiempo restante del temporizador de apagado (null si no hay ninguno).
  Duration? get sleepRemaining {
    final endTime = _sleepEndTime;
    if (endTime == null) return null;
    final remaining = endTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> _initializeProvider() async {
    // Las listas no dependen del reproductor: se cargan en paralelo.
    unawaited(_loadFavorites());
    unawaited(loadPopularStations());
    unawaited(loadCountries());
    unawaited(loadGenres());

    await _audioService.initialize();
    if (_disposed) return;

    _subscriptions.add(_audioService.onPlayerStateChanged.listen((isPlaying) {
      _isPlaying = isPlaying;
      _notify();
    }));
    // Reconectar si el stream se cae a mitad de la reproducción
    _subscriptions.add(
      _audioService.onPlaybackError.listen((_) => _handleStreamDrop()),
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _message(String text) {
    if (!_disposed) _messages.add(text);
  }

  // ---------------------------------------------------------------------------
  // Listas de emisoras
  // ---------------------------------------------------------------------------

  Future<void> _loadList(
    StationListState list,
    Future<List<RadioStation>> Function() fetch,
  ) async {
    final request = ++list._request;
    list.loading = true;
    list.error = '';
    _notify();
    try {
      final stations = await fetch();
      if (request != list._request) return; // llegó una petición más nueva
      list.stations = stations;
    } catch (e) {
      if (request != list._request) return;
      debugPrint('Error cargando emisoras: $e');
      list.error = _connectionError;
      if (list.stations.isNotEmpty) _message(_connectionError);
    } finally {
      if (request == list._request) {
        list.loading = false;
        _notify();
      }
    }
  }

  void _resetList(StationListState list) {
    list._request++;
    list.stations = const [];
    list.loading = false;
    list.error = '';
  }

  Future<void> loadPopularStations() =>
      _loadList(popular, RadioApiService.getPopularStations);

  /// Busca por nombre. Una búsqueda vacía limpia los resultados.
  Future<void> searchStations(String query) {
    final text = query.trim();
    if (text.isEmpty) {
      _searchFetch = null;
      _resetList(search);
      _notify();
      return Future.value();
    }
    return _startSearch(() => RadioApiService.searchStations(text));
  }

  /// Busca por género (etiqueta de Radio Browser).
  Future<void> searchByGenre(String genre) =>
      _startSearch(() => RadioApiService.getStationsByGenre(genre));

  Future<void> retrySearch() {
    final fetch = _searchFetch;
    return fetch == null ? Future.value() : _loadList(search, fetch);
  }

  Future<void> _startSearch(Future<List<RadioStation>> Function() fetch) {
    _searchFetch = fetch;
    search.stations = const [];
    return _loadList(search, fetch);
  }

  /// Abre la lista de emisoras de un país dentro de la pestaña Países.
  Future<void> selectCountry(Country country) {
    _selectedCountry = country;
    byCountry.stations = const [];
    return _loadList(
      byCountry,
      () => RadioApiService.getStationsByCountryCode(country.iso31661),
    );
  }

  void clearSelectedCountry() {
    _selectedCountry = null;
    _resetList(byCountry);
    _notify();
  }

  Future<void> loadCountries() async {
    if (_countriesLoading) return;
    _countriesLoading = true;
    _notify();
    try {
      _countries = await RadioApiService.getCountries();
    } catch (e) {
      debugPrint('Error cargando países: $e');
    } finally {
      _countriesLoading = false;
      _notify();
    }
  }

  Future<void> loadGenres() async {
    try {
      final genres = await RadioApiService.getGenres();
      if (genres.isNotEmpty) {
        _genres = genres;
        _notify();
      }
    } catch (e) {
      debugPrint('Error cargando géneros: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Reproducción
  // ---------------------------------------------------------------------------

  /// Reproduce una estación. Si no responde, prueba con las siguientes de
  /// [queue] (la lista desde la que se eligió) y avisa al usuario.
  Future<void> playStation(RadioStation station, {List<RadioStation>? queue}) {
    if (queue != null) _queue = List.unmodifiable(queue);
    _wantsPlayback = true;
    return _play(station, attempt: 1, token: ++_playToken, original: station);
  }

  Future<void> _play(
    RadioStation station, {
    required int attempt,
    required int token,
    required RadioStation original,
  }) async {
    _currentStation = station;
    _isBuffering = true;
    _notify();

    final ok = await _audioService.playStation(station);
    // Si el usuario eligió otra estación mientras conectaba, no tocar nada.
    if (token != _playToken) return;

    if (ok) {
      _isBuffering = false;
      _notify();
      unawaited(RadioApiService.registerStationClick(station.uuid));
      if (station != original) {
        _message('«${original.name}» no responde. Reproduciendo «${station.name}».');
      }
      return;
    }

    final next = attempt < _maxPlayAttempts ? _nextStationAfter(station) : null;
    if (next != null && next != original) {
      await _play(next, attempt: attempt + 1, token: token, original: original);
    } else {
      _clearPlayback();
      _message('No se pudo reproducir «${original.name}». Prueba con otra emisora.');
    }
  }

  RadioStation? _nextStationAfter(RadioStation station) {
    if (_queue.length < 2) return null;
    final index = _queue.indexWhere((s) => s.id == station.id);
    if (index == -1) return null;
    return _queue[(index + 1) % _queue.length];
  }

  // Reconexión cuando el stream se interrumpe a mitad de la reproducción
  Future<void> _handleStreamDrop() async {
    final station = _currentStation;
    if (station == null || !_wantsPlayback || _isBuffering || _isReconnecting) {
      return;
    }

    _isReconnecting = true;
    final token = ++_playToken;
    _isBuffering = true;
    _notify();
    debugPrint('Stream interrumpido, reconectando...');

    await Future.delayed(const Duration(seconds: 3));
    final ok = token == _playToken &&
        !_disposed &&
        await _audioService.playStation(station, force: true);
    _isReconnecting = false;
    if (token != _playToken) return;

    if (ok) {
      _isBuffering = false;
      _notify();
    } else {
      _clearPlayback();
      _message('Se perdió la conexión con «${station.name}».');
    }
  }

  Future<void> togglePlayPause() async {
    final station = _currentStation;
    if (station == null) return;

    if (_isPlaying) {
      _wantsPlayback = false;
      await _audioService.pause();
      return;
    }

    _wantsPlayback = true;
    final token = ++_playToken;
    _isBuffering = true;
    _notify();
    final ok = await _audioService.resume();
    if (token != _playToken) return;
    if (ok) {
      _isBuffering = false;
      _notify();
    } else {
      _clearPlayback();
      _message('No se pudo reconectar con «${station.name}».');
    }
  }

  Future<void> stopPlayback() async {
    _playToken++;
    _clearPlayback();
    await _audioService.stop();
  }

  void _clearPlayback() {
    _wantsPlayback = false;
    _currentStation = null;
    _isPlaying = false;
    _isBuffering = false;
    _notify();
  }

  // ---------------------------------------------------------------------------
  // Temporizador de apagado
  // ---------------------------------------------------------------------------

  void setSleepTimer(Duration duration) {
    cancelSleepTimer();
    _sleepEndTime = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, _onSleepTimerFired);
    // Actualizar la cuenta regresiva visible cada 30 segundos
    _sleepTicker = Timer.periodic(const Duration(seconds: 30), (_) => _notify());
    _notify();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTicker?.cancel();
    _sleepTimer = null;
    _sleepTicker = null;
    _sleepEndTime = null;
    _notify();
  }

  Future<void> _onSleepTimerFired() async {
    cancelSleepTimer();
    await stopPlayback();
  }

  // ---------------------------------------------------------------------------
  // Favoritos
  // ---------------------------------------------------------------------------

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorite_stations') ?? [];
      _favoriteStations = favoritesJson
          .map((s) => RadioStation.fromJson(json.decode(s) as Map<String, dynamic>))
          .toList();
      _notify();
    } catch (e) {
      debugPrint('Error cargando favoritos: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'favorite_stations',
        _favoriteStations.map((s) => json.encode(s.toJson())).toList(),
      );
    } catch (e) {
      debugPrint('Error guardando favoritos: $e');
    }
  }

  Future<void> toggleFavorite(RadioStation station) async {
    if (isFavorite(station)) {
      _favoriteStations.removeWhere((s) => s.id == station.id);
    } else {
      _favoriteStations.add(station);
    }
    _notify();
    await _saveFavorites();
  }

  bool isFavorite(RadioStation station) {
    return _favoriteStations.any((s) => s.id == station.id);
  }

  @override
  void dispose() {
    _disposed = true;
    _sleepTimer?.cancel();
    _sleepTicker?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _messages.close();
    super.dispose();
  }
}
