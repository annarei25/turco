import 'package:flutter/material.dart';

import '../models/turno.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../utils/formato.dart';
import 'pastilla_estado.dart';

/// Tarjeta de un turno en la lista de la Agenda.
class TarjetaTurno extends StatelessWidget {
  const TarjetaTurno({
    super.key,
    required this.turno,
    required this.cliente,
    required this.estilista,
    required this.onTap,
    this.onLongPress,
  });

  final Turno turno;
  final String cliente;
  final String estilista;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colores = ColoresEstado.de(cs, turno.estado);

    final tarjeta = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de color del estado
                Container(
                  width: AppSizes.barraEstado,
                  decoration: BoxDecoration(
                    color: colores.barra,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Horas: inicio y fin
                SizedBox(
                  width: AppSizes.horasTurno,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Formato.hora(turno.inicio),
                        style:
                            AppTextStyles.nombre.copyWith(color: cs.onSurface),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        Formato.hora(turno.fin),
                        style: AppTextStyles.secundario
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Cliente, servicios, estilista y estado
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente,
                        style:
                            AppTextStyles.nombre.copyWith(color: cs.onSurface),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        turno.serviciosTexto,
                        style: AppTextStyles.secundario
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppIcons.persona,
                                  size: 13, color: cs.onSurfaceVariant),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                estilista,
                                style: AppTextStyles.etiquetaCampo
                                    .copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                          PastillaEstado(estado: turno.estado),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Los turnos cancelados se ven atenuados.
    if (turno.estado == EstadoTurno.cancelado) {
      return Opacity(opacity: 0.75, child: tarjeta);
    }
    return tarjeta;
  }
}
