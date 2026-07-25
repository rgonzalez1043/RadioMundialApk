import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/radio_station.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  late AudioPlayer _audioPlayer;
  final StreamController<bool> _playerStateController = StreamController<bool>.broadcast();
  RadioStation? _currentStation;
  bool _isPlaying = false;
  
  Stream<bool> get onPlayerStateChanged => _playerStateController.stream;
  
  AudioPlayer get audioPlayer => _audioPlayer;
  RadioStation? get currentStation => _currentStation;
  bool get isPlaying => _isPlaying;

  // Inicializar el servicio de audio
  Future<void> initialize() async {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    
    // Escuchar cambios en el estado del reproductor
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _playerStateController.add(_isPlaying);
    });
  }

  // Reproducir una estación de radio
  Future<bool> playStation(RadioStation station) async {
    try {
      // Si ya está reproduciendo la misma estación, no hacer nada
      if (_currentStation?.id == station.id && _isPlaying) {
        return true;
      }

      // Detener la reproducción actual si existe
      if (_isPlaying) {
        await stop();
      }

      debugPrint('Intentando reproducir: ${station.name} - ${station.streamUrl}');

      // Configurar y reproducir la nueva estación
      await _audioPlayer.play(UrlSource(station.streamUrl));
      
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
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error al pausar: $e');
    }
  }

  // Reanudar la reproducción
  Future<void> resume() async {
    try {
      if (_currentStation != null) {
        await _audioPlayer.resume();
        _isPlaying = true;
      }
    } catch (e) {
      debugPrint('Error al reanudar: $e');
    }
  }

  // Detener la reproducción
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentStation = null;
    } catch (e) {
      debugPrint('Error al detener: $e');
    }
  }

  // Cambiar el volumen
  Future<void> setVolume(double volume) async {
    try {
      // Asegurar que el volumen esté entre 0.0 y 1.0
      volume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      debugPrint('Error al cambiar volumen: $e');
    }
  }

  // Dispose
  void dispose() {
    _audioPlayer.dispose();
    _playerStateController.close();
  }
}