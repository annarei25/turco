import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

/// Tema global de la app: claro y oscuro con los mismos componentes.
/// Las pantallas no definen colores ni formas: las toman de aquí.
class AppTheme {
  AppTheme._();

  static ThemeData get claro => _construir(AppColors.claro);
  static ThemeData get oscuro => _construir(AppColors.oscuro);

  static OutlineInputBorder _borde(Color color, double ancho) {
    return OutlineInputBorder(
      borderRadius: AppRadius.deCampo,
      borderSide: BorderSide(color: color, width: ancho),
    );
  }

  static ThemeData _construir(ColorScheme cs) {
    final scrim = cs.scrim.withValues(alpha: 0.4);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,

      // Escala de la guía de estilo (los demás tamaños están en AppTextStyles)
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),

      // Barra superior: alto 56, título 20/600
      appBarTheme: AppBarTheme(
        toolbarHeight: AppSizes.barraSuperior,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle:
            AppTextStyles.tituloPantalla.copyWith(color: cs.onSurface),
      ),

      // Barra inferior: alto 76, etiquetas 12 (600 seleccionada, 500 el resto)
      navigationBarTheme: NavigationBarThemeData(
        height: AppSizes.barraNavegacion,
        backgroundColor: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: cs.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final activo = estados.contains(WidgetState.selected);
          return AppTextStyles.etiquetaCampo.copyWith(
            fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
            color: activo ? cs.onSurface : cs.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((estados) {
          final activo = estados.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: activo ? cs.onSecondaryContainer : cs.onSurfaceVariant,
          );
        }),
      ),

      // Botón flotante extendido
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.deTarjeta),
        extendedTextStyle: AppTextStyles.seccion,
        extendedPadding: const EdgeInsetsDirectional.only(start: 20, end: 20),
        extendedIconLabelSpacing: 10,
        iconSize: 20,
      ),

      // Tarjetas: radio 16, fondo surfaceContainer
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.deTarjeta),
      ),

      // Chips de filtro: alto 32, radio 8
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.deChip),
        side: WidgetStateBorderSide.resolveWith((estados) {
          if (estados.contains(WidgetState.selected)) return BorderSide.none;
          return BorderSide(color: cs.outlineVariant);
        }),
        selectedColor: cs.secondaryContainer,
        showCheckmark: false, // el check lo dibuja ChipFiltro con el icono Lucide
        padding: const EdgeInsets.symmetric(horizontal: 4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        iconTheme: const IconThemeData(size: 14),
        labelStyle: AppTextStyles.chip.copyWith(
          color: WidgetStateColor.resolveWith((estados) =>
              estados.contains(WidgetState.selected)
                  ? cs.onSecondaryContainer
                  : cs.onSurfaceVariant),
        ),
      ),

      // Selector segmentado: el fondo y el borde ya vienen como en el diseño
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(AppTextStyles.chip),
          iconSize: const WidgetStatePropertyAll(14.0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      ),

      // Botones: forma de píldora
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSizes.boton),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.seccion,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSizes.boton),
          shape: const StadiumBorder(),
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.outline),
          textStyle: AppTextStyles.seccion,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: AppTextStyles.seccion,
        ),
      ),

      // Campos de texto: radio 12, borde 1 (error 2)
      inputDecorationTheme: InputDecorationTheme(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        hintStyle: AppTextStyles.cuerpo.copyWith(color: cs.outline),
        errorStyle: AppTextStyles.secundario.copyWith(color: cs.error),
        border: _borde(cs.outline, 1),
        enabledBorder: _borde(cs.outline, 1),
        focusedBorder: _borde(cs.primary, 2),
        errorBorder: _borde(cs.error, 2),
        focusedErrorBorder: _borde(cs.error, 2),
      ),

      // Diálogos: radio 28, fondo surfaceContainer
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        barrierColor: scrim,
        iconColor: cs.error,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.deHoja),
        titleTextStyle:
            AppTextStyles.tituloPantalla.copyWith(color: cs.onSurface),
        contentTextStyle:
            AppTextStyles.cuerpoDialogo.copyWith(color: cs.onSurfaceVariant),
      ),

      // Hojas inferiores: radio superior 28, asa 36x4
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        modalBackgroundColor: cs.surface,
        modalBarrierColor: scrim,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false, // el asa se dibuja en cada hoja (widgets/asa_hoja.dart)
        dragHandleColor: cs.outlineVariant,
        dragHandleSize: const Size(36, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.hoja),
          ),
        ),
      ),

      // SnackBar flotante: radio 8
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        actionTextColor: cs.inversePrimary,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentTextStyle:
            AppTextStyles.cuerpo.copyWith(color: cs.onInverseSurface),
      ),

      // Menú del botón de tema: radio 12
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.deCampo),
        textStyle: AppTextStyles.valor.copyWith(color: cs.onSurface),
      ),

      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
