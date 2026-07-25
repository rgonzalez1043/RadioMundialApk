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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.modernShadow,
          ),
          child: Column(
            children: [
              // Información de la estación
              Row(
                children: [
                  // Imagen de la estación
                  Container(
                    width: 60,
                    height: 60,
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
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
              
              const SizedBox(height: 16),
              
              // Control de volumen
              Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.volumeLow,
                    color: Colors.white54,
                    size: 14,
                  ),
                  Expanded(
                    child: Slider(
                      value: radioProvider.volume,
                      onChanged: radioProvider.setVolume,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white24,
                      thumbColor: Colors.white,
                    ),
                  ),
                  const FaIcon(
                    FontAwesomeIcons.volumeHigh,
                    color: Colors.white54,
                    size: 14,
                  ),
                ],
              ),
              
              // Indicador de estado
              if (radioProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Conectando...',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (radioProvider.isPlaying && !radioProvider.isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
