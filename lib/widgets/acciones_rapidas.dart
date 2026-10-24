import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/turno.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import 'asa_hoja.dart';

/// Hoja con las acciones rápidas de un turno programado (pulsación larga).
/// Devuelve EstadoTurno.completado, EstadoTurno.cancelado o null si se cierra.
Future<EstadoTurno?> mostrarAccionesRapidas(
  BuildContext context, {
  required String titulo,
  required String subtitulo,
}) {
  return showModalBottomSheet<EstadoTurno>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: AsaHoja()),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                titulo,
                style: AppTextStyles.tituloVacio.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                subtitulo,
                style: AppTextStyles.nota.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _Accion(
                icono: AppIcons.completar,
                texto: 'Marcar como completado',
                colorIcono: cs.tertiary,
                colorTexto: cs.onSurface,
                onTap: () => ctx.pop(EstadoTurno.completado),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _Accion(
                icono: AppIcons.cancelar,
                texto: 'Cancelar turno',
                colorIcono: cs.error,
                colorTexto: cs.error,
                onTap: () => ctx.pop(EstadoTurno.cancelado),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _Accion extends StatelessWidget {
  const _Accion({
    required this.icono,
    required this.texto,
    required this.colorIcono,
    required this.colorTexto,
    required this.onTap,
  });

  final IconData icono;
  final String texto;
  final Color colorIcono;
  final Color colorTexto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: AppSizes.altoAccionRapida,
        child: Row(
          children: [
            Icon(icono, size: 22, color: colorIcono),
            const SizedBox(width: 16),
            Text(
              texto,
              style: AppTextStyles.opcion.copyWith(color: colorTexto),
            ),
          ],
        ),
      ),
    );
  }
}
