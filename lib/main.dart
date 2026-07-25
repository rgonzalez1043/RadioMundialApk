import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/radio_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const RadioMundialApp());
}

class RadioMundialApp extends StatelessWidget {
  const RadioMundialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RadioProvider(),
      child: MaterialApp(
        title: 'Radio Mundial',
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
