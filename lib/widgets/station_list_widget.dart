import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/radio_station.dart';
import '../providers/radio_provider.dart';
import '../theme/app_theme.dart';

class StationListWidget extends StatelessWidget {
  final List<RadioStation> stations;

  const StationListWidget({
    super.key,
    required this.stations,
  });

  @override
  Widget build(BuildContext context) {
    if (stations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.radio,
              color: Colors.white54,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron estaciones',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        return StationTile(station: station);
      },
    );
  }
}

class StationTile extends StatelessWidget {
  final RadioStation station;

  const StationTile({
    super.key,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioProvider>(
      builder: (context, radioProvider, child) {
        final isCurrentStation = radioProvider.currentStation?.id == station.id;
        final isPlaying = isCurrentStation && radioProvider.isPlaying;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: isCurrentStation 
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.3),
                    AppTheme.secondaryColor.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isCurrentStation ? AppTheme.modernShadow : [],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            
            // Imagen de la estación
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: AppTheme.backgroundGradient,
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
                            size: 20,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: FaIcon(
                            FontAwesomeIcons.radio,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      )
                    : const Center(
                        child: FaIcon(
                          FontAwesomeIcons.radio,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ),
              ),
            ),
            
            // Información de la estación
            title: Text(
              station.name,
              style: TextStyle(
                color: isCurrentStation ? Colors.white : Colors.white.withValues(alpha: 0.87),
                fontWeight: isCurrentStation ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (station.country.isNotEmpty && station.genre.isNotEmpty)
                      const Text(
                        ' • ',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    if (station.genre.isNotEmpty)
                      Expanded(
                        child: Text(
                          station.genre,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                
                // Indicador de reproducción
                if (isCurrentStation)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (radioProvider.isLoading)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          )
                        else if (isPlaying)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                        
                        const SizedBox(width: 6),
                        
                        Text(
                          radioProvider.isLoading 
                              ? 'Conectando...'
                              : isPlaying 
                                  ? 'Reproduciendo'
                                  : 'Pausado',
                          style: TextStyle(
                            color: isPlaying ? Colors.green : Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            // Botones de acción
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón de favorito
                IconButton(
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
                    size: 16,
                  ),
                ),
                
                // Botón de play
                IconButton(
                  onPressed: () {
                    if (isCurrentStation && isPlaying) {
                      radioProvider.togglePlayPause();
                    } else {
                      radioProvider.playStation(station);
                    }
                  },
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: isCurrentStation && isPlaying
                          ? AppTheme.primaryGradient
                          : null,
                      color: isCurrentStation && isPlaying
                          ? null
                          : AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FaIcon(
                      isCurrentStation && isPlaying
                          ? FontAwesomeIcons.pause
                          : FontAwesomeIcons.play,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            
            // Acción al tocar la tile
            onTap: () {
              if (isCurrentStation) {
                radioProvider.togglePlayPause();
              } else {
                radioProvider.playStation(station);
              }
            },
          ),
        );
      },
    );
  }
}
