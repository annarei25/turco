import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../utils/fechas.dart';
import '../utils/formato.dart';
import '../viewmodels/agenda_viewmodel.dart';

/// Cabecera de semana + tira de los siete días + aviso del domingo.
class TiraDias extends StatelessWidget {
  const TiraDias({super.key, required this.agenda});

  final AgendaViewModel agenda;

  Future<void> _elegirFecha(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: agenda.fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (fecha != null) agenda.seleccionarFecha(fecha);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dias = agenda.diasSemana;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Semana anterior, mes y semana siguiente + "Elegir fecha"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkResponse(
                  onTap: agenda.semanaAnterior,
                  radius: 20,
                  child: Icon(AppIcons.izquierda,
                      size: 22, color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  Formato.mesAnio(agenda.fecha),
                  style: AppTextStyles.nombre.copyWith(color: cs.onSurface),
                ),
                const SizedBox(width: AppSpacing.md),
                InkResponse(
                  onTap: agenda.semanaSiguiente,
                  radius: 20,
                  child: Icon(AppIcons.derecha,
                      size: 22, color: cs.onSurfaceVariant),
                ),
              ],
            ),
            InkWell(
              onTap: () => _elegirFecha(context),
              borderRadius: AppRadius.deChip,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.calendario, size: 18, color: cs.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Elegir fecha',
                    style: AppTextStyles.chip.copyWith(color: cs.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Los siete días, de igual ancho, separados por 4
        LayoutBuilder(
          builder: (context, constraints) {
            const separacion = 4.0;
            final ancho = (constraints.maxWidth - separacion * 6) / 7;
            return SizedBox(
              height: AppSizes.diaTira,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dias.length,
                itemBuilder: (context, i) {
                  final dia = dias[i];
                  return Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : separacion),
                    child: SizedBox(
                      width: ancho,
                      child: _DiaTira(
                        dia: dia,
                        seleccionado: Fechas.mismoDia(dia, agenda.fecha),
                        onTap: () => agenda.seleccionarFecha(dia),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Domingo: salón cerrado',
          style: AppTextStyles.pie.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _DiaTira extends StatelessWidget {
  const _DiaTira({
    required this.dia,
    required this.seleccionado,
    required this.onTap,
  });

  final DateTime dia;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colorNombre = seleccionado ? cs.onPrimary : cs.onSurfaceVariant;
    final colorNumero = seleccionado ? cs.onPrimary : cs.onSurface;

    final casilla = Material(
      color: seleccionado ? cs.primary : cs.surface,
      borderRadius: AppRadius.deDia,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.deDia,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Formato.diaCorto(dia),
              style: AppTextStyles.dia.copyWith(color: colorNombre),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${dia.day}',
              style: AppTextStyles.tituloItem.copyWith(color: colorNumero),
            ),
          ],
        ),
      ),
    );

    // El domingo se ve atenuado: el salón está cerrado.
    return Fechas.esDomingo(dia) ? Opacity(opacity: 0.4, child: casilla) : casilla;
  }
}
