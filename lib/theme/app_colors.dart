import 'package:flutter/material.dart';

/// Paletas del diseño (guía de estilo del archivo .pen).
///
/// Cada paleta parte de ColorScheme.fromSeed y fija los roles con el valor
/// exacto del diseño. Este es el único archivo con valores de color:
/// las pantallas y widgets leen Theme.of(context).colorScheme.
class AppColors {
  AppColors._();

  static const Color semilla = Color(0xFF00695C);

  static final ColorScheme claro =
      ColorScheme.fromSeed(seedColor: semilla).copyWith(
    primary: const Color(0xFF006A60),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFF9EF2E4),
    onPrimaryContainer: const Color(0xFF00201C),
    secondaryContainer: const Color(0xFFCCE8E2),
    onSecondaryContainer: const Color(0xFF05201C),
    tertiary: const Color(0xFF456179),
    onTertiary: const Color(0xFFFFFFFF),
    tertiaryContainer: const Color(0xFFCDE5FF),
    onTertiaryContainer: const Color(0xFF001D32),
    error: const Color(0xFFBA1A1A),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: const Color(0xFFF4FBF9),
    onSurface: const Color(0xFF161D1C),
    onSurfaceVariant: const Color(0xFF3F4947),
    surfaceContainer: const Color(0xFFE9EFED),
    surfaceContainerHigh: const Color(0xFFE3EAE8),
    outline: const Color(0xFF6F7977),
    outlineVariant: const Color(0xFFBEC9C6),
    inverseSurface: const Color(0xFF2B3231),
    onInverseSurface: const Color(0xFFF4FBF9),
    inversePrimary: const Color(0xFF74F8E5), // acción "Ver" del SnackBar
  );

  static final ColorScheme oscuro = ColorScheme.fromSeed(
    seedColor: semilla,
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF53DBC9),
    onPrimary: const Color(0xFF003731),
    primaryContainer: const Color(0xFF005047),
    onPrimaryContainer: const Color(0xFF74F8E5),
    secondaryContainer: const Color(0xFF314B47),
    onSecondaryContainer: const Color(0xFFCCE8E2),
    tertiary: const Color(0xFFADCAE6),
    onTertiary: const Color(0xFF001D32),
    tertiaryContainer: const Color(0xFF2D4A62),
    onTertiaryContainer: const Color(0xFFCDE5FF),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surface: const Color(0xFF0E1514),
    onSurface: const Color(0xFFDDE4E2),
    onSurfaceVariant: const Color(0xFFBEC9C6),
    surfaceContainer: const Color(0xFF1A2120),
    // El diseño no define este rol en oscuro: valor estándar de Material 3.
    surfaceContainerHigh: const Color(0xFF252B2A),
    outline: const Color(0xFF899390),
    outlineVariant: const Color(0xFF3F4947),
  );
}
