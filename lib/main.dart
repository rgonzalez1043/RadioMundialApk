import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'providers/radio_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Audio en segundo plano con notificación multimedia
  // (controles en pantalla de bloqueo y centro de notificaciones).
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'worldradio_fm_audio',
      androidNotificationChannelName: 'Reproducción de radio',
      androidNotificationOngoing: true,
    );
  } catch (e) {
    debugPrint('No se pudo inicializar el audio en segundo plano: $e');
  }

  runApp(const RadioMundialApp());
}

class RadioMundialApp extends StatelessWidget {
  const RadioMundialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RadioProvider(),
      child: MaterialApp(
        title: 'WorldRadio FM',
        theme: AppTheme.theme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Limitar el escalado de texto del sistema para evitar
          // desbordamientos (overflow) en las pantallas fijas.
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(
                minScaleFactor: 0.85,
                maxScaleFactor: 1.25,
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
