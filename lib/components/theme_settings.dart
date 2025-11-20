import 'package:flutter/material.dart';

class ThemeSettings {
  static ThemeData lightTheme() {
    final theme = ThemeData.light().copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Colors.deepPurple, // Morado principal
        onPrimary: Colors.white, // Texto sobre color primario
        secondary: Colors.purpleAccent, // Morado claro
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        background: Colors.white,
        onBackground: Colors.black87,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      cardColor: Colors.grey[100],
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 248, 248, 248),
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
    return theme;
  }

  static ThemeData darkTheme() {
    final theme = ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Colors.deepPurple, // Morado principal
        onPrimary: Colors.white, // Texto sobre color primario
        secondary: Colors.purpleAccent, // Morado claro
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        background: Color(0xFF121212), // Fondo oscuro tipo WhatsApp Dark
        onBackground: Colors.white,
        surface: Color(0xFF1E1E1E), // Superficie gris oscuro
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF2D2D2D),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.deepPurple, // AppBar morado
        foregroundColor: Colors.white, // Texto blanco
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
    return theme;
  }
}
