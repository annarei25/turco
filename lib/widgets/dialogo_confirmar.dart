import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';

/// Diálogo de confirmación del diseño: icono, título, mensaje y dos botones de texto.
/// Devuelve true si se pulsa el botón de acción.
Future<bool> mostrarConfirmacion(
  BuildContext context, {
  IconData icono = AppIcons.alerta,
  Color? colorIcono,
  required String titulo,
  required String mensaje,
  required String textoAccion,
  Color? colorAccion,
  String textoVolver = 'Volver',
}) async {
  final cs = Theme.of(context).colorScheme;
  final resultado = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.hoja),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 24, color: colorIcono ?? cs.error),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              titulo,
              style: AppTextStyles.tituloPantalla.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              mensaje,
              style: AppTextStyles.cuerpoDialogo
                  .copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => ctx.pop(false),
                  child: Text(textoVolver),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: colorAccion ?? cs.primary,
                  ),
                  onPressed: () => ctx.pop(true),
                  child: Text(textoAccion),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return resultado ?? false;
}
