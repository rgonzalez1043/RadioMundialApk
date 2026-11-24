import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/country.dart';
import '../providers/radio_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/station_list_widget.dart';
import '../widgets/player_widget.dart';
import '../widgets/search_widget.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final Uri privacyPolicyUrl = Uri.parse(
    'https://rgonzalez1043.github.io/RadioMundialApk/privacy-policy.html',
  );

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _countryFilterController = TextEditingController();
  StreamSubscription<String>? _messagesSub;
  String _countryFilter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Avisos puntuales del provider (emisora caída, sin conexión, etc.)
    _messagesSub = context.read<RadioProvider>().messages.listen(_showMessage);
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    _countryFilterController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final hasCountry =
        context.select<RadioProvider, bool>((p) => p.selectedCountry != null);

    // "Atrás" dentro de un país vuelve a la lista de países.
    return PopScope(
      canPop: !hasCountry,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.read<RadioProvider>().clearSelectedCountry();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        // El teclado tapa la lista en vez de comprimir la pantalla
        // (evita desbordes en teléfonos pequeños).
        resizeToAvoidBottomInset: false,
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
                  'WorldRadio FM',
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
          leading: IconButton(
            onPressed: _showAbout,
            tooltip: 'Acerca de',
            icon: const FaIcon(
              FontAwesomeIcons.circleInfo,
              size: 20,
              color: Colors.white70,
            ),
          ),
          actions: [
            Consumer<RadioProvider>(
              builder: (context, radioProvider, child) {
                final timerActive = radioProvider.sleepRemaining != null;
                return IconButton(
                  onPressed: _showSleepTimerSheet,
                  tooltip: 'Temporizador de apagado',
                  icon: FaIcon(
                    FontAwesomeIcons.stopwatch,
                    size: 20,
                    color: timerActive ? AppTheme.secondaryColor : Colors.white70,
                  ),
                );
              },
            ),
          ],
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
                if (radioProvider.currentStation == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  decoration: const BoxDecoration(
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
              },
            ),

            // Contenido de las pestañas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPopularTab(),
                  _buildSearchTab(),
                  _buildCountriesTab(),
                  _buildFavoritesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'WorldRadio FM',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset('assets/logo.png', width: 48, height: 48),
      ),
      children: [
        const Text(
          'Directorio de emisoras: Radio Browser (radio-browser.info). '
          'Cada transmisión pertenece a su respectiva emisora.',
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => launchUrl(
            HomeScreen.privacyPolicyUrl,
            mode: LaunchMode.externalApplication,
          ),
          icon: const FaIcon(FontAwesomeIcons.shieldHalved, size: 16),
          label: const Text('Política de privacidad'),
        ),
      ],
    );
  }

  // Hoja inferior con las opciones del temporizador de apagado
  void _showSleepTimerSheet() {
    final radioProvider = context.read<RadioProvider>();
    const options = [5, 15, 30, 45, 60];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final remaining = radioProvider.sleepRemaining;
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Apagado automático',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (remaining != null)
                  ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.ban,
                      color: AppTheme.accentColor,
                      size: 18,
                    ),
                    title: Text(
                      'Cancelar temporizador (quedan ${_formatRemaining(remaining)})',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      radioProvider.cancelSleepTimer();
                      Navigator.pop(sheetContext);
                      _showMessage('Temporizador cancelado');
                    },
                  ),
                for (final minutes in options)
                  ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.clock,
                      color: Colors.white54,
                      size: 18,
                    ),
                    title: Text(
                      '$minutes minutos',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      radioProvider.setSleepTimer(Duration(minutes: minutes));
                      Navigator.pop(sheetContext);
                      _showMessage('La radio se apagará en $minutes minutos');
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _formatRemaining(Duration remaining) {
    if (remaining.inMinutes >= 1) return '${remaining.inMinutes} min';
    return '${remaining.inSeconds} s';
  }

  /// Lista con sus estados de carga, error y vacío.
  Widget _buildStationList(
    StationListState list, {
    required Future<void> Function() onRetry,
    String emptyTitle = 'No se encontraron emisoras',
  }) {
    if (list.loading && list.stations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    final Widget content;
    if (list.error.isNotEmpty && list.stations.isEmpty) {
      content = EmptyState(
        icon: FontAwesomeIcons.wifi,
        iconColor: Colors.orange,
        title: 'Sin conexión',
        message: list.error,
        actionLabel: 'Reintentar',
        onAction: onRetry,
      );
    } else if (list.stations.isEmpty) {
      content = EmptyState(icon: FontAwesomeIcons.radio, title: emptyTitle);
    } else {
      content = StationListWidget(stations: list.stations);
    }

    return RefreshIndicator(
      onRefresh: onRetry,
      color: AppTheme.secondaryColor,
      child: content,
    );
  }

  Widget _buildPopularTab() {
    return Consumer<RadioProvider>(
      builder: (context, radioProvider, child) => _buildStationList(
        radioProvider.popular,
        onRetry: radioProvider.loadPopularStations,
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        SearchWidget(
          controller: _searchController,
          onSearch: (query) => context.read<RadioProvider>().searchStations(query),
          onGenreSelected: (genre) =>
              context.read<RadioProvider>().searchByGenre(genre),
        ),
        Expanded(
          child: Consumer<RadioProvider>(
            builder: (context, radioProvider, child) {
              if (!radioProvider.hasSearched) {
                return const EmptyState(
                  icon: FontAwesomeIcons.magnifyingGlass,
                  title: 'Busca tu emisora',
                  message: 'Escribe el nombre de una radio o elige un género.',
                );
              }
              return _buildStationList(
                radioProvider.search,
                onRetry: radioProvider.retrySearch,
                emptyTitle: 'Sin resultados para esa búsqueda',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCountriesTab() {
    return Consumer<RadioProvider>(
      builder: (context, radioProvider, child) {
        final country = radioProvider.selectedCountry;
        if (country != null) return _buildCountryStations(radioProvider, country);

        return Column(
          children: [
            // Filtro de países
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _countryFilterController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Filtrar países...',
                  isDense: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12),
                    child: FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _countryFilter = value.trim().toLowerCase());
                },
              ),
            ),
            Expanded(child: _buildCountryList(radioProvider)),
          ],
        );
      },
    );
  }

  Widget _buildCountryList(RadioProvider radioProvider) {
    if (radioProvider.countriesLoading && radioProvider.countries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (radioProvider.countries.isEmpty) {
      return EmptyState(
        icon: FontAwesomeIcons.globe,
        title: 'No se pudieron cargar los países',
        message: 'Revisa tu conexión a internet.',
        actionLabel: 'Reintentar',
        onAction: radioProvider.loadCountries,
      );
    }

    final filtered = _countryFilter.isEmpty
        ? radioProvider.countries
        : radioProvider.countries
            .where((c) => c.name.toLowerCase().contains(_countryFilter))
            .toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: FontAwesomeIcons.globe,
        title: 'Sin resultados para ese filtro',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final country = filtered[index];
        return Card(
          color: AppTheme.cardColor,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Text(
              _flagEmoji(country.iso31661),
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              country.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${country.stationcount} emisoras',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: const FaIcon(
              FontAwesomeIcons.chevronRight,
              color: Colors.white54,
              size: 16,
            ),
            onTap: () {
              FocusScope.of(context).unfocus();
              radioProvider.selectCountry(country);
            },
          ),
        );
      },
    );
  }

  Widget _buildCountryStations(RadioProvider radioProvider, Country country) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: radioProvider.clearSelectedCountry,
                tooltip: 'Volver a países',
                icon: const FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
              Text(
                _flagEmoji(country.iso31661),
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  country.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildStationList(
            radioProvider.byCountry,
            onRetry: () => radioProvider.selectCountry(country),
          ),
        ),
      ],
    );
  }

  // Convierte el código ISO del país (p. ej. "AR") en su bandera emoji
  static String _flagEmoji(String isoCode) {
    final code = isoCode.trim().toUpperCase();
    if (code.length != 2) return '🏳️';
    final first = code.codeUnitAt(0) - 0x41;
    final second = code.codeUnitAt(1) - 0x41;
    if (first < 0 || first > 25 || second < 0 || second > 25) return '🏳️';
    return String.fromCharCodes([0x1F1E6 + first, 0x1F1E6 + second]);
  }

  Widget _buildFavoritesTab() {
    return Consumer<RadioProvider>(
      builder: (context, radioProvider, child) {
        if (radioProvider.favoriteStations.isEmpty) {
          return const EmptyState(
            icon: FontAwesomeIcons.heart,
            title: 'No tienes estaciones favoritas',
            message: 'Toca el corazón en cualquier estación para agregarla aquí.',
          );
        }
        return StationListWidget(stations: radioProvider.favoriteStations);
      },
    );
  }
}
