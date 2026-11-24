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
    if (_initialized) return;
    try {
      // handleInterruptions (activo por defecto) pausa al desconectar
      // los auriculares y ante interrupciones de audio de otras apps.
      final player = AudioPlayer();
      _audioPlayer = player;

      // Sesión de audio tipo música: maneja el foco de audio y las
      // interrupciones (llamadas, alarmas, otras apps de sonido).
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      player.playerStateStream.listen((state) {
        final processing = state.processingState;
        // Una radio en vivo no termina nunca: si llega a "completed"
        // mientras suena, la señal se cortó.
        if (state.playing &&
            processing == ProcessingState.completed &&
            _currentStation != null) {
          _errorController.add('La transmisión se interrumpió');
        }
        // Tras un error el reproductor queda en "idle" aunque playing siga
        // en true: en ese caso no está sonando nada.
        _isPlaying = state.playing &&
            processing != ProcessingState.idle &&
            processing != ProcessingState.completed;
        _playerStateController.add(_isPlaying);
      });

      // Desde just_audio 0.10 los errores de reproducción llegan por errorStream.
      player.errorStream.listen((e) {
        debugPrint('Error durante la reproducción: ${e.message}');
        _errorController.add(e.message ?? 'Error de reproducción');
      });

      _initialized = true;
    } catch (e) {
      debugPrint('Error inicializando el servicio de audio: $e');
    }
  }

  /// Reproduce una estación. Devuelve false si no se pudo conectar.
  /// Con [force] vuelve a conectar aunque ya esté sonando (útil en vivo).
  Future<bool> playStation(RadioStation station, {bool force = false}) async {
    final player = _audioPlayer;
    if (!_initialized || player == null) return false;

    if (!force && _currentStation?.id == station.id && _isPlaying) {
      return true;
    }

    final streamUri = Uri.tryParse(station.streamUrl);
    if (streamUri == null || !streamUri.hasScheme || streamUri.host.isEmpty) {
      debugPrint('URL de stream inválida: ${station.streamUrl}');
      return false;
    }
    final artUri = Uri.tryParse(station.imageUrl ?? '');

    try {
      // El tag MediaItem alimenta la notificación multimedia y la
      // pantalla de bloqueo (título, país/género y carátula).
      await player.setAudioSource(
        AudioSource.uri(
          streamUri,
          tag: MediaItem(
            id: station.uuid.isNotEmpty ? station.uuid : station.streamUrl,
            title: station.name,
            artist: [
              if (station.country.isNotEmpty) station.country,
              if (station.genre.isNotEmpty) station.genre,
            ].join(' • '),
            artUri: artUri != null && artUri.hasScheme && artUri.host.isNotEmpty
                ? artUri
                : null,
          ),
        ),
      );

      // NO esperar play(): en un stream en vivo su Future no termina
      // hasta que se detiene la reproducción.
      unawaited(player.play().catchError((Object e) {
        debugPrint('Error en play(): $e');
      }));

      _currentStation = station;
      return true;
    } catch (e) {
      // También llega aquí si otra estación interrumpió esta carga.
      debugPrint('Error al reproducir la estación ${station.name}: $e');
      return false;
    }
  }

  // Pausar la reproducción
  Future<void> pause() async {
    try {
      await _audioPlayer?.pause();
    } catch (e) {
      debugPrint('Error al pausar: $e');
    }
  }

  /// Reanuda volviendo a conectar: en una radio en vivo se vuelve al
  /// directo en lugar de reproducir audio viejo del búfer.
  Future<bool> resume() async {
    final station = _currentStation;
    if (station == null) return false;
    return playStation(station, force: true);
  }

  // Detener la reproducción
  Future<void> stop() async {
    _currentStation = null;
    try {
      await _audioPlayer?.stop();
    } catch (e) {
      debugPrint('Error al detener: $e');
    }
  }
}
