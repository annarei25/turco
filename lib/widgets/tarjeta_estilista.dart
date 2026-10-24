import 'package:flutter/material.dart';

import '../models/estilista.dart';
import '../models/servicio.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import 'avatar_inicial.dart';

/// Tarjeta de un estilista: avatar, nombre, categorías en las que trabaja
/// y cantidad de turnos programados hoy.
class TarjetaEstilista extends StatelessWidget {
  const TarjetaEstilista({
    super.key,
    required this.estilista,
    required this.categorias,
    required this.turnosHoy,
    required this.onTap,
  });

  final Estilista estilista;
  final List<Categoria> categorias;
  final int turnosHoy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textoTurnos = turnosHoy == 0
        ? 'Sin turnos hoy'
        : '$turnosHoy ${turnosHoy == 1 ? 'turno' : 'turnos'} hoy';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AvatarInicial(
                inicial: estilista.inicial,
                diametro: AppSizes.avatarEstilista,
                fondo: cs.primaryContainer,
                colorTexto: cs.onPrimaryContainer,
              ),
              const SizedBox(width: AppSpacing.xxl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estilista.nombre,
                      style:
                          AppTextStyles.tituloItem.copyWith(color: cs.onSurface),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Servicios que realiza, agrupados por categoría
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final categoria in categorias)
                          Chip(
                            label: Text(categoria.etiqueta),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      textoTurnos,
                      style: AppTextStyles.etiquetaCampo.copyWith(
                        color: turnosHoy == 0
                            ? cs.onSurfaceVariant
                            : cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xxl),
              Icon(AppIcons.derecha, size: 22, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
