import 'package:flutter/material.dart';

class AppTheme {
  // Colores modernos y vibrantes
  static const Color primaryColor = Color(0xFF6C63FF); // Púrpura vibrante
  static const Color secondaryColor = Color(0xFF00D4FF); // Azul cyan brillante
  static const Color accentColor = Color(0xFFFF6B6B); // Coral vibrante
  static const Color backgroundColor = Color(0xFF0F0F23); // Azul muy oscuro
  static const Color surfaceColor = Color(0xFF1A1A2E); // Azul oscuro
  static const Color cardColor = Color(0xFF16213E); // Azul medio oscuro
  
  // Gradientes modernos
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundColor, surfaceColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardColor, Color(0xFF1E2749)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Tema principal
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primaryColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: Colors.white70,
          backgroundColor: Colors.transparent,
        ),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: Colors.white24,
        thumbColor: secondaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.3),
        trackHeight: 4,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Colors.white60,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIconColor: Colors.white70,
        suffixIconColor: Colors.white70,
      ),
    );
  }
  
  // Colores adicionales para widgets específicos
  static const Color playButtonColor = Color(0xFF00FF88); // Verde brillante
  static const Color pauseButtonColor = Color(0xFFFFB800); // Amarillo dorado
  static const Color stopButtonColor = Color(0xFFFF4757); // Rojo vibrante
  static const Color favoriteColor = Color(0xFFFF3838); // Rojo corazón
  static const Color liveIndicatorColor = Color(0xFF00FF88); // Verde en vivo
  
  // Sombras modernas
  static List<BoxShadow> get modernShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 15,
      offset: Offset(0, 5),
    ),
  ];
}
