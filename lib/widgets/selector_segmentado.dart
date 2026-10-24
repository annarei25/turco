import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

/// SegmentedButton a todo el ancho.
///
/// - El valor null sirve para la opción "Todos".
/// - Si [seleccionado] es null y ninguna opción vale null, no hay nada
///   seleccionado (por ejemplo, el género antes de elegir).
class SelectorSegmentado<T> extends StatelessWidget {
  const SelectorSegmentado({
    super.key,
    required this.opciones,
    required this.seleccionado,
    required this.onChanged,
  });

  /// Pares (texto, valor).
  final List<(String, T)> opciones;
  final T seleccionado;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final haySeleccion =
        opciones.any((opcion) => opcion.$2 == seleccionado);

    return SegmentedButton<T>(
      expandedInsets: EdgeInsets.zero,
      emptySelectionAllowed: true,
      selectedIcon: const Icon(AppIcons.marcar), // check Lucide del diseño
      segments: [
        for (final (texto, valor) in opciones)
          ButtonSegment<T>(
            value: valor,
            label: Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
      selected: haySeleccion ? {seleccionado} : <T>{},
      onSelectionChanged: (valores) {
        if (valores.isNotEmpty) onChanged(valores.first);
      },
    );
  }
}
