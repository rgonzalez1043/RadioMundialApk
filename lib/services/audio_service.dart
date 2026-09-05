import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import '../models/radio_station.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _audioPlayer;
  final StreamController<bool> _playerStateController = StreamController<bool>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  RadioStation? _currentStation;
  bool _isPlaying = false;
  bool _initialized = false;

  Stream<bool> get onPlayerStateChanged => _playerStateController.stream;

  /// Errores ocurridos durante la reproducción (p. ej. el stream se cayó).
  Stream<String> get onPlaybackError => _errorController.stream;

  RadioStation? get currentStation => _currentStation;
  bool get isPlaying => _isPlaying;

  // Inicializar el servicio de audio
  Future<void> initialize() async {
    try {
      // handleInterruptions (activo por defecto) pausa al desconectar
      // los auriculares y ante interrupciones de audio de otras apps.
      _audioPlayer = AudioPlayer();

      // Sesión de audio tipo música: maneja el foco de audio y las
      // interrupciones (llamadas, alarmas, otras apps de sonido).
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Escuchar cambios en el estado del reproductor
      _audioPlayer!.playerStateStream.listen((state) {
        _isPlaying = state.playing;
        _playerStateController.add(_isPlaying);
      });

      // Errores mientras se reproduce (stream caído a mitad de sesión)
      _audioPlayer!.playbackEventStream.listen(
        (_) {},
        onError: (Object e, StackTrace st) {
          debugPrint('Error durante la reproducción: $e');
          _isPlaying = false;
          _playerStateController.add(false);
          _errorController.add(e.toString());
        },
      );

      _initialized = true;
    } catch (e) {
      debugPrint('Error inicializando el servicio de audio: $e');
    }
  }

  // Reproducir una estación de radio
  Future<bool> playStation(RadioStation station) async {
    if (!_initialized || _audioPlayer == null) return false;

    try {
      // Si ya está reproduciendo la misma estación, no hacer nada
      if (_currentStation?.id == station.id && _isPlaying) {
        return true;
      }

      debugPrint('Intentando reproducir: ${station.name} - ${station.streamUrl}');

      // El tag MediaItem alimenta la notificación multimedia y la
      // pantalla de bloqueo (título, país/género y carátula).
      final source = AudioSource.uri(
        Uri.parse(station.streamUrl),
        tag: MediaItem(
          id: station.uuid,
          title: station.name,
          artist: [
            if (station.country.isNotEmpty) station.country,
            if (station.genre.isNotEmpty) station.genre,
          ].join(' • '),
          artUri: station.imageUrl != null && station.imageUrl!.isNotEmpty
              ? Uri.parse(station.imageUrl!)
              : null,
        ),
      );

      await _audioPlayer!.setAudioSource(source);

      // NO esperar play(): en un stream en vivo su Future no termina
      // hasta que se detiene la reproducción.
      unawaited(_audioPlayer!.play());

      _currentStation = station;
      _isPlaying = true;

      return true;
    } catch (e) {
      debugPrint('Error al reproducir la estación ${station.name}: $e');

      // Intentar limpiar el estado en caso de error
      _currentStation = null;
      _isPlaying = false;

      return false;
    }
  }

  // Pausar la reproducción
  Future<void> pause() async {
    try {
      await _audioPlayer?.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error al pausar: $e');
    }
  }

  // Reanudar la reproducción
  Future<void> resume() async {
    try {
      if (_currentStation != null && _audioPlayer != null) {
        unawaited(_audioPlayer!.play());
        _isPlaying = true;
      }
    } catch (e) {
      debugPrint('Error al reanudar: $e');
    }
  }

  // Detener la reproducción
  Future<void> stop() async {
    try {
      await _audioPlayer?.stop();
      _isPlaying = false;
      _currentStation = null;
    } catch (e) {
      debugPrint('Error al detener: $e');
    }
  }

  // Dispose
  void dispose() {
    _audioPlayer?.dispose();
    _playerStateController.close();
    _errorController.close();
  }
}
