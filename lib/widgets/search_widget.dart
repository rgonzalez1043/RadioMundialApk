import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/radio_provider.dart';
import '../theme/app_theme.dart';

class SearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const SearchWidget({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Campo de búsqueda
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar estaciones de radio...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          widget.controller.clear();
                          widget.onSearch('');
                          setState(() {});
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.xmark,
                          color: Colors.white54,
                          size: 18,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: widget.onSearch,
            ),
          ),

          const SizedBox(height: 16),

          // Botones de búsqueda rápida por género (cargados de la API)
          Consumer<RadioProvider>(
            builder: (context, radioProvider, child) {
              final genres = radioProvider.genres;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < genres.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _buildGenreChip(genres[i]),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Icono representativo según el nombre del género
  IconData _iconForGenre(String genre) {
    final g = genre.toLowerCase();
    if (g.contains('rock')) return FontAwesomeIcons.guitar;
    if (g.contains('news') || g.contains('noticia')) {
      return FontAwesomeIcons.newspaper;
    }
    if (g.contains('sport') || g.contains('deporte') || g.contains('football')) {
      return FontAwesomeIcons.futbol;
    }
    if (g.contains('talk') || g.contains('podcast')) {
      return FontAwesomeIcons.microphone;
    }
    if (g.contains('dance') ||
        g.contains('electronic') ||
        g.contains('techno') ||
        g.contains('house')) {
      return FontAwesomeIcons.headphones;
    }
    if (g.contains('country') ||
        g.contains('folk') ||
        g.contains('latin') ||
        g.contains('world')) {
      return FontAwesomeIcons.globe;
    }
    if (g.contains('religi') || g.contains('gospel') || g.contains('christian')) {
      return FontAwesomeIcons.church;
    }
    if (g.contains('oldies') ||
        g.contains('retro') ||
        g.contains('80s') ||
        g.contains('90s') ||
        g.contains('70s') ||
        g.contains('60s')) {
      return FontAwesomeIcons.clockRotateLeft;
    }
    return FontAwesomeIcons.music;
  }

  Widget _buildGenreChip(String genre) {
    final label = genre.length > 1
        ? '${genre[0].toUpperCase()}${genre.substring(1)}'
        : genre.toUpperCase();

    return InkWell(
      onTap: () {
        widget.controller.text = genre;
        widget.onSearch(genre);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.2),
              AppTheme.secondaryColor.withValues(alpha: 0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.secondaryColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              _iconForGenre(genre),
              color: Colors.white70,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
