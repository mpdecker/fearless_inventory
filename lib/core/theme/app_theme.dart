import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _primaryColor = Color(0xFF3F51B5); // Indigo
  static const Color _secondaryColor = Color(0xFF009688); // Teal
  static const Color _surfaceColor = Color(0xFF1E1E2E);
  static const Color _backgroundDark = Color(0xFF12121F);
  static const Color _cardDark = Color(0xFF252535);
  static const Color _onSurface = Color(0xFFE0E0F0);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: _surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _onSurface,
        primaryContainer: Color(0xFF283593),
        secondaryContainer: Color(0xFF00695C),
      ),
      scaffoldBackgroundColor: _backgroundDark,
      cardColor: _cardDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceColor,
        foregroundColor: _onSurface,
        elevation: 0,
        centerTitle: false,
        // Omit a fixed fontSize so toolbar titles respect system text scaling
        // (Dynamic Type on iOS, font scale on Android).
        titleTextStyle: TextStyle(
          color: _onSurface,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: _onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceColor,
        indicatorColor: _primaryColor.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, color: _onSurface),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primaryColor);
          }
          return IconThemeData(color: _onSurface.withOpacity(0.7));
        }),
      ),
      cardTheme: CardThemeData(
        color: _cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: _onSurface.withOpacity(0.7)),
        hintStyle: TextStyle(color: _onSurface.withOpacity(0.4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryColor;
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor.withOpacity(0.4);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceColor,
        selectedColor: _primaryColor.withOpacity(0.3),
        labelStyle: const TextStyle(color: _onSurface),
        side: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: _onSurface,
        iconColor: _onSurface,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.08),
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _onSurface, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: _onSurface, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: _onSurface, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: _onSurface, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: _onSurface),
        bodyLarge: TextStyle(color: _onSurface),
        bodyMedium: TextStyle(color: _onSurface),
        bodySmall: TextStyle(color: Color(0xFFB0B0C8)),
        labelLarge: TextStyle(color: _onSurface),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _cardDark,
        contentTextStyle: const TextStyle(color: _onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
