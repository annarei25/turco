import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../utils/formato.dart';
import '../viewmodels/agenda_viewmodel.dart';

/// Resumen del día: programados, completados e ingreso estimado.
class ResumenDia extends StatelessWidget {
  const ResumenDia({super.key, required this.agenda});

  final AgendaViewModel agenda;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _Dato(
            valor: '${agenda.programados}',
            etiqueta: 'Programados',
            colorValor: cs.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Dato(
            valor: '${agenda.completados}',
            etiqueta: 'Completados',
            colorValor: cs.tertiary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Dato(
            valor: Formato.dinero(agenda.ingresoEstimado),
            etiqueta: 'Ingreso est.',
            colorValor: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.valor,
    required this.etiqueta,
    required this.colorValor,
  });

  final String valor;
  final String etiqueta;
  final Color colorValor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: AppRadius.deResumen,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.tituloPantalla.copyWith(color: colorValor),
          ),
          Text(
            etiqueta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.pie.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
