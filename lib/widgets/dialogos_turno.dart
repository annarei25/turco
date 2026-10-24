import 'package:flutter/material.dart';

import '../models/turno.dart';
import '../theme/app_icons.dart';
import '../utils/formato.dart';
import 'dialogo_confirmar.dart';

/// Confirmación para cancelar un turno (Agenda y Detalle).
Future<bool> confirmarCancelarTurno(
  BuildContext context, {
  required String cliente,
  required Turno turno,
}) {
  return mostrarConfirmacion(
    context,
    titulo: '¿Cancelar este turno?',
    mensaje: 'El horario de $cliente (${Formato.hora(turno.inicio)} a '
        '${Formato.hora(turno.fin)}) quedará libre. '
        'Esta acción no se puede deshacer.',
    textoAccion: 'Cancelar turno',
    colorAccion: Theme.of(context).colorScheme.error,
  );
}

/// Confirmación para completar un turno (Agenda y Detalle).
Future<bool> confirmarCompletarTurno(
  BuildContext context, {
  required String cliente,
  required Turno turno,
}) {
  final cs = Theme.of(context).colorScheme;
  return mostrarConfirmacion(
    context,
    icono: AppIcons.completar,
    colorIcono: cs.tertiary,
    titulo: '¿Completar este turno?',
    mensaje: 'El turno de $cliente (${Formato.hora(turno.inicio)} a '
        '${Formato.hora(turno.fin)}) se marcará como completado y ya no '
        'se podrá editar.',
    textoAccion: 'Completar',
  );
}
