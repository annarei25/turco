import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/turno.dart';
import '../utils/formato.dart';

/// SnackBar "Turno guardado para el mié 21 de octubre" con la acción "Ver",
/// que abre el detalle del turno.
void mostrarTurnoGuardado(BuildContext context, Turno turno) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Turno guardado para el ${Formato.fechaConfirmacion(turno.inicio)}',
        ),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => context.push('/turno/${turno.id}'),
        ),
      ),
    );
}
