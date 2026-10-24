import 'package:flutter/material.dart';

import '../models/turno.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Colores de cada estado del turno (todos salen del ColorScheme).
class ColoresEstado {
  final Color barra;
  final Color fondo;
  final Color texto;

  const ColoresEstado({
    required this.barra,
    required this.fondo,
    required this.texto,
  });

  static ColoresEstado de(ColorScheme cs, EstadoTurno estado) {
    return switch (estado) {
      EstadoTurno.programado => ColoresEstado(
          barra: cs.primary,
          fondo: cs.primaryContainer,
          texto: cs.onPrimaryContainer,
        ),
      EstadoTurno.completado => ColoresEstado(
          barra: cs.tertiary,
          fondo: cs.tertiaryContainer,
          texto: cs.onTertiaryContainer,
        ),
      EstadoTurno.cancelado => ColoresEstado(
          barra: cs.error,
          fondo: cs.errorContainer,
          texto: cs.onErrorContainer,
        ),
    };
  }
}

/// Píldora con el estado del turno (radio 8, texto 11/600).
class PastillaEstado extends StatelessWidget {
  const PastillaEstado({super.key, required this.estado});

  final EstadoTurno estado;

  @override
  Widget build(BuildContext context) {
    final colores = ColoresEstado.de(Theme.of(context).colorScheme, estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colores.fondo,
        borderRadius: AppRadius.deChip,
      ),
      child: Text(
        estado.etiqueta,
        style: AppTextStyles.pastilla.copyWith(color: colores.texto),
      ),
    );
  }
}
