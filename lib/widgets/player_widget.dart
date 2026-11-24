import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/radio_provider.dart';
import '../theme/app_theme.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioProvider>(
      builder: (context, radioProvider, child) {
        final station = radioProvider.currentStation;
        if (station == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.modernShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Información de la estación
              Row(
                children: [
                  // Imagen de la estación
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF16213e),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: station.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: station.imageUrl!,
                              fit: BoxFit.cover,
                              memCacheWidth: 160,
                              placeholder: (context, url) => const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.radio,
                                  color: Colors.white54,
                                  size: 24,
                                ),
                              ),
                              errorWidget: (context, url, error) => const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.radio,
                                  color: Colors.white54,
                                  size: 24,
                                ),
                              ),
                            )
                          : const Center(
                              child: FaIcon(
                                FontAwesomeIcons.radio,
                                color: Colors.white54,
                                size: 24,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Información de texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (station.country.isNotEmpty) ...[
                              const FaIcon(
                                FontAwesomeIcons.locationDot,
                                color: Colors.white54,
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  station.country,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            if (station.country.isNotEmpty && station.genre.isNotEmpty)
                              const Text(
                                ' • ',
                                style: TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            if (station.genre.isNotEmpty)
                              Flexible(
                                child: Text(
                                  station.genre,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Botones de control
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón de favorito
                      Container(
                        decoration: BoxDecoration(
                          color: radioProvider.isFavorite(station) 
                              ? AppTheme.favoriteColor.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => radioProvider.toggleFavorite(station),
                          tooltip: radioProvider.isFavorite(station)
                              ? 'Quitar de favoritos'
                              : 'Agregar a favoritos',
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          padding: EdgeInsets.zero,
                          icon: FaIcon(
                            radioProvider.isFavorite(station)
                                ? FontAwesomeIcons.solidHeart
                                : FontAwesomeIcons.heart,
                            color: radioProvider.isFavorite(station)
                                ? AppTheme.favoriteColor
                                : Colors.white54,
                            size: 18,
                          ),
                        ),
                      ),
                      
                      // Botón de play/pause
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: radioProvider.togglePlayPause,
                          tooltip: radioProvider.isPlaying ? 'Pausar' : 'Reproducir',
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          padding: EdgeInsets.zero,
                          icon: FaIcon(
                            radioProvider.isPlaying
                                ? FontAwesomeIcons.pause
                                : FontAwesomeIcons.play,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      
                      // Botón de stop
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: radioProvider.stopPlayback,
                          tooltip: 'Detener',
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          padding: EdgeInsets.zero,
                          icon: const FaIcon(
                            FontAwesomeIcons.stop,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Fila de estado (Conectando / En vivo / Temporizador)
              if (radioProvider.isBuffering ||
                  radioProvider.isPlaying ||
                  radioProvider.sleepRemaining != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (radioProvider.isBuffering) ...[
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Conectando...',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ] else if (radioProvider.isPlaying) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'En vivo',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if ((radioProvider.isBuffering || radioProvider.isPlaying) &&
                          radioProvider.sleepRemaining != null)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '•',
                            style: TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ),
                      if (radioProvider.sleepRemaining != null) ...[
                        const FaIcon(
                          FontAwesomeIcons.stopwatch,
                          color: AppTheme.secondaryColor,
                          size: 10,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          radioProvider.sleepRemaining!.inMinutes >= 1
                              ? 'Apagado en ${radioProvider.sleepRemaining!.inMinutes} min'
                              : 'Apagado en < 1 min',
                          style: const TextStyle(
                            color: AppTheme.secondaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
