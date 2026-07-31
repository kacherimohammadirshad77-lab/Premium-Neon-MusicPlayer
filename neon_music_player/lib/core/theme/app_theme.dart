import 'package:flutter/material.dart';

/// Defines every built-in neon theme. Each [NeonTheme] carries the palette
/// values needed to drive the whole app's ThemeData + custom glass widgets.
class NeonTheme {
  final String id;
  final String name;
  final Color background;
  final Color surface;
  final Color primary; // main neon accent
  final Color secondary; // secondary glow color
  final Color onSurface;
  final bool isAmoled;

  const NeonTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.onSurface,
    this.isAmoled = false,
  });

  Color get glow => primary;

  LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary.withOpacity(0.35),
          secondary.withOpacity(0.12),
        ],
      );
}

class AppThemes {
  AppThemes._();

  static const skyBlueNeon = NeonTheme(
    id: 'sky_blue_neon',
    name: 'Sky Blue Neon',
    background: Color(0xFF080808),
    surface: Color(0xFF121417),
    primary: Color(0xFF00D9FF),
    secondary: Color(0xFF00F5FF),
    onSurface: Colors.white,
  );

  static const emeraldGreenNeon = NeonTheme(
    id: 'emerald_green_neon',
    name: 'Emerald Green Neon',
    background: Color(0xFF080808),
    surface: Color(0xFF101512),
    primary: Color(0xFF00FFA3),
    secondary: Color(0xFF17E88F),
    onSurface: Colors.white,
  );

  static const purpleNeon = NeonTheme(
    id: 'purple_neon',
    name: 'Purple Neon',
    background: Color(0xFF080808),
    surface: Color(0xFF15111A),
    primary: Color(0xFFB16CFF),
    secondary: Color(0xFF7B2FFF),
    onSurface: Colors.white,
  );

  static const orangeNeon = NeonTheme(
    id: 'orange_neon',
    name: 'Orange Neon',
    background: Color(0xFF080808),
    surface: Color(0xFF171310),
    primary: Color(0xFFFF9900),
    secondary: Color(0xFFFFC266),
    onSurface: Colors.white,
  );

  static const redNeon = NeonTheme(
    id: 'red_neon',
    name: 'Red Neon',
    background: Color(0xFF080808),
    surface: Color(0xFF190E0E),
    primary: Color(0xFFFF3B3B),
    secondary: Color(0xFFFF6B6B),
    onSurface: Colors.white,
  );

  static const pinkNeon = NeonTheme(
    id: 'pink_neon',
    name: 'Pink Neon',
    background: Color(0xFF080808),
    surface: Color(0xFF19111A),
    primary: Color(0xFFFF4FD8),
    secondary: Color(0xFFFF8AE8),
    onSurface: Colors.white,
  );

  static const whiteMinimal = NeonTheme(
    id: 'white_minimal',
    name: 'White Minimal',
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF0091FF),
    secondary: Color(0xFF00B4FF),
    onSurface: Colors.black,
  );

  static const amoledBlack = NeonTheme(
    id: 'amoled_black',
    name: 'AMOLED Black',
    background: Color(0xFF000000),
    surface: Color(0xFF000000),
    primary: Color(0xFF00D9FF),
    secondary: Color(0xFF00F5FF),
    onSurface: Colors.white,
    isAmoled: true,
  );

  static const List<NeonTheme> all = [
    skyBlueNeon,
    emeraldGreenNeon,
    purpleNeon,
    orangeNeon,
    redNeon,
    pinkNeon,
    whiteMinimal,
    amoledBlack,
  ];

  static NeonTheme byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => skyBlueNeon);

  /// Builds a full Material 3 ThemeData from a [NeonTheme].
  static ThemeData buildThemeData(NeonTheme theme) {
    final isDark = theme.onSurface == Colors.white;
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: theme.primary,
      onPrimary: isDark ? Colors.black : Colors.white,
      secondary: theme.secondary,
      onSecondary: isDark ? Colors.black : Colors.white,
      error: const Color(0xFFFF5252),
      onError: Colors.white,
      surface: theme.surface,
      onSurface: theme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: theme.background,
      colorScheme: colorScheme,
      splashColor: theme.primary.withOpacity(0.15),
      highlightColor: theme.primary.withOpacity(0.08),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: theme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: theme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.primary.withOpacity(0.18)),
        ),
      ),
      textTheme: (isDark ? Typography.whiteMountainView : Typography.blackMountainView)
          .apply(bodyColor: theme.onSurface, displayColor: theme.onSurface),
      iconTheme: IconThemeData(color: theme.onSurface),
      sliderTheme: SliderThemeData(
        activeTrackColor: theme.primary,
        thumbColor: theme.primary,
        inactiveTrackColor: theme.primary.withOpacity(0.2),
        overlayColor: theme.primary.withOpacity(0.15),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: theme.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: theme.surface,
        selectedItemColor: theme.primary,
        unselectedItemColor: theme.onSurface.withOpacity(0.5),
      ),
    );
  }
}
