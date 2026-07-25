import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/radio_provider.dart';
import '../widgets/station_list_widget.dart';
import '../widgets/player_widget.dart';
import '../widgets/search_widget.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Las estaciones se cargan desde el constructor del RadioProvider,
    // no es necesario cargarlas de nuevo aquí.
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Radio Mundial',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.secondaryColor,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(
              icon: FaIcon(FontAwesomeIcons.fire, size: 18),
              text: 'Popular',
            ),
            Tab(
              icon: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 18),
              text: 'Buscar',
            ),
            Tab(
              icon: FaIcon(FontAwesomeIcons.globe, size: 18),
              text: 'Países',
            ),
            Tab(
              icon: FaIcon(FontAwesomeIcons.heart, size: 18),
              text: 'Favoritos',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Reproductor fijo en la parte superior
          Consumer<RadioProvider>(
            builder: (context, radioProvider, child) {
              if (radioProvider.currentStation != null) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const PlayerWidget(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pestaña Popular
                _buildPopularTab(),
                
                // Pestaña Buscar
                _buildSearchTab(),
                
                // Pestaña Países
                _buildCountriesTab(),
                
                // Pestaña Favoritos
                _buildFavoritesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTab() {
    return Consumer<RadioProvider>(
      builder: (context, radioProvider, child) {
        if (radioProvider.isLoading && radioProvider.stations.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        if (radioProvider.errorMessage.isNotEmpty && radioProvider.stations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(
                  FontAwesomeIcons.triangleExclamation,
                  color: Colors.orange,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  radioProvider.errorMessage,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mostrando estaciones de respaldo',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => radioProvider.loadPopularStations(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Mostrar mensaje si estamos usando estaciones de respaldo
        if (radioProvider.stations.isNotEmpty && radioProvider.errorMessage.isNotEmpty) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Conexión limitada - Mostrando estaciones de respaldo',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: TextButton(
                        onPressed: () => radioProvider.loadPopularStations(),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Reintentar',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StationListWidget(stations: radioProvider.stations),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () => radioProvider.loadPopularStations(),
          color: AppTheme.secondaryColor,
          child: StationListWidget(stations: radioProvider.stations),
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        SearchWidget(
          controller: _searchController,
          onSearch: (query) {
            context.read<RadioProvider>().searchStations(query);
          },
        ),
        Expanded(
          child: Consumer<RadioProvider>(
            builder: (context, radioProvider, child) {
              if (radioProvider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                );
              }

              return StationListWidget(stations: radioProvider.stations);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCountriesTab() {
    final countries = [
      {'name': 'Argentina', 'code': 'argentina', 'flag': '🇦🇷'},
      {'name': 'España', 'code': 'spain', 'flag': '🇪🇸'},
      {'name': 'México', 'code': 'mexico', 'flag': '🇲🇽'},
      {'name': 'Colombia', 'code': 'colombia', 'flag': '🇨🇴'},
      {'name': 'Chile', 'code': 'chile', 'flag': '🇨🇱'},
      {'name': 'Perú', 'code': 'peru', 'flag': '🇵🇪'},
      {'name': 'Estados Unidos', 'code': 'united states', 'flag': '🇺🇸'},
      {'name': 'Reino Unido', 'code': 'united kingdom', 'flag': '🇬🇧'},
      {'name': 'Francia', 'code': 'france', 'flag': '🇫🇷'},
      {'name': 'Alemania', 'code': 'germany', 'flag': '🇩🇪'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        return Card(
          color: AppTheme.cardColor,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Text(
              country['flag']!,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              country['name']!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const FaIcon(
              FontAwesomeIcons.chevronRight,
              color: Colors.white54,
              size: 16,
            ),
            onTap: () {
              context.read<RadioProvider>().getStationsByCountry(country['code']!);
              _tabController.animateTo(0); // Ir a la pestaña popular para mostrar resultados
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<RadioProvider>(
      builder: (context, radioProvider, child) {
        if (radioProvider.favoriteStations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.heart,
                  color: Colors.white54,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'No tienes estaciones favoritas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Toca el corazón en cualquier estación para agregarla aquí',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return StationListWidget(stations: radioProvider.favoriteStations);
      },
    );
  }
}
