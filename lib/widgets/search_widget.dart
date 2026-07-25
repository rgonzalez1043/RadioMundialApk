import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          
          // Botones de búsqueda rápida por género
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildGenreChip('Rock', FontAwesomeIcons.guitar),
                const SizedBox(width: 8),
                _buildGenreChip('Pop', FontAwesomeIcons.music),
                const SizedBox(width: 8),
                _buildGenreChip('Jazz', FontAwesomeIcons.music),
                const SizedBox(width: 8),
                _buildGenreChip('Classical', FontAwesomeIcons.music),
                const SizedBox(width: 8),
                _buildGenreChip('Electronic', FontAwesomeIcons.headphones),
                const SizedBox(width: 8),
                _buildGenreChip('News', FontAwesomeIcons.newspaper),
                const SizedBox(width: 8),
                _buildGenreChip('Sports', FontAwesomeIcons.futbol),
                const SizedBox(width: 8),
                _buildGenreChip('Talk', FontAwesomeIcons.microphone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String genre, IconData icon) {
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
              icon,
              color: Colors.white70,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              genre,
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
