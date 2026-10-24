import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

/// Chip de filtro (alto 32). El estilo viene del tema.
/// Seleccionado: icono check (Lucide, 14) + texto, separados por 6.
class ChipFiltro extends StatelessWidget {
  const ChipFiltro({
    super.key,
    required this.etiqueta,
    required this.seleccionado,
    required this.onTap,
  });

  final String etiqueta;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      selected: seleccionado,
      onSelected: (_) => onTap(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (seleccionado) ...[
            Icon(AppIcons.marcar, size: 14, color: cs.onSecondaryContainer),
            const SizedBox(width: 6),
          ],
          Text(etiqueta),
        ],
      ),
    );
  }
}
