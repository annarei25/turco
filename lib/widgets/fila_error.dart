import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';

/// Mensaje de error bajo un campo: icono de alerta (13) + texto 12/400 en error.
class FilaError extends StatelessWidget {
  const FilaError(this.mensaje, {super.key});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(AppIcons.errorCampo, size: 13, color: cs.error),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            mensaje,
            style: AppTextStyles.secundario.copyWith(color: cs.error),
          ),
        ),
      ],
    );
  }
}
