import 'package:flutter/material.dart';

import '../models/servicio.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../utils/formato.dart';

/// Tarjeta del catálogo de servicios.
/// El diseño usa el icono de la categoría sobre un recuadro de color.
class TarjetaServicio extends StatelessWidget {
  const TarjetaServicio({
    super.key,
    required this.servicio,
    required this.onTap,
  });

  final Servicio servicio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recuadro con el icono de la categoría
              Container(
                width: double.infinity,
                height: AppSizes.imagenServicio,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: AppRadius.deCampo,
                ),
                child: Icon(
                  AppIcons.deCategoria(servicio.categoria),
                  size: 36,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                servicio.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.seccion.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Duración y precio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.reloj, size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(
                        Formato.duracion(servicio.duracionMin),
                        style: AppTextStyles.secundario
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Text(
                    Formato.dinero(servicio.precio),
                    style: AppTextStyles.precio.copyWith(color: cs.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Público al que se dirige
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: AppRadius.deChip,
                ),
                child: Text(
                  servicio.publico.etiqueta,
                  style: AppTextStyles.pastilla
                      .copyWith(color: cs.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
