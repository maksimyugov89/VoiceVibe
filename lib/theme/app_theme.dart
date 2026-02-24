import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VoiceVibeTheme {
  VoiceVibeTheme._();

  // Цветовая палитра
  static const electricViolet = Color(0xFF6C5CE7);
  static const lightViolet = Color(0xFFA29BFE);
  static const cyanVibration = Color(0xFF00B8D4);
  static const pinkWave = Color(0xFFFF6B9D);
  static const lightPink = Color(0xFFFD79A8);
  static const successGreen = Color(0xFF26DE81);
  static const warningOrange = Color(0xFFFF9F43);
  static const errorRed = Color(0xFFEE5253);
  
  // Фоновые цвета
  static const bgLight = Color(0xFFF8F9FF);
  static const bgDark = Color(0xFF0F0E1C);
  static const surfaceDark = Color(0xFF1A1830);
  static const cardDark = Color(0xFF252341);

  // Градиенты
  static const voiceGradient = LinearGradient(
    colors: [electricViolet, lightViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const recordingGradient = LinearGradient(
    colors: [pinkWave, lightPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successGradient = LinearGradient(
    colors: [cyanVibration, successGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Spacing система
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;

  // Border Radius
  static const double radiusSmall = 8;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusXLarge = 32;
  static const double radiusCircular = 100;

  // Elevation и тени
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> largeShadow = [
    BoxShadow(
      color: electricViolet.withOpacity(0.15),
      blurRadius: 30,
      offset: const Offset(0, 15),
    ),
  ];

  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: electricViolet.withOpacity(0.3),
      blurRadius: 40,
      spreadRadius: 5,
    ),
  ];

  // СВЕТЛАЯ ТЕМА
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: electricViolet,
    scaffoldBackgroundColor: bgLight,
    
    colorScheme: const ColorScheme.light(
      primary: electricViolet,
      secondary: cyanVibration,
      tertiary: pinkWave,
      surface: Colors.white,
      background: bgLight,
      error: errorRed,
    ),

    // AppBar с blur эффектом
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.transparent,
      foregroundColor: electricViolet,
      titleTextStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: electricViolet,
        letterSpacing: 0.5,
      ),
    ),

    // Карточки с глубиной
    cardTheme: CardThemeData( // ИЗМЕНЕНО
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Floating Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(0.95),
      indicatorColor: electricViolet.withOpacity(0.1),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 75,
    ),

    // Elevated Button с градиентом
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: electricViolet,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCircular),
        ),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: electricViolet,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: CircleBorder(),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: electricViolet,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );

  // ТЕМНАЯ ТЕМА
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: lightViolet,
    scaffoldBackgroundColor: bgDark,
    
    colorScheme: const ColorScheme.dark(
      primary: lightViolet,
      secondary: cyanVibration,
      tertiary: pinkWave,
      surface: surfaceDark,
      background: bgDark,
      error: errorRed,
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    ),

    cardTheme: CardThemeData( // ИЗМЕНЕНО
      elevation: 0,
      color: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: surfaceDark.withOpacity(0.95),
      indicatorColor: lightViolet.withOpacity(0.2),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 75,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: lightViolet,
        foregroundColor: bgDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCircular),
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: lightViolet,
      foregroundColor: bgDark,
      elevation: 8,
      shape: CircleBorder(),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: Colors.white70,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white60,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.white,
      ),
    ),
  );
}

// Пример кастомного клиппера для волнового эффекта
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}