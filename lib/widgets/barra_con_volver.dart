import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';

/// Barra superior con flecha de volver y título (Detalle y Formulario).
/// Flecha de 24, separación de 12 con el título, margen izquierdo de 16.
class BarraConVolver extends StatelessWidget implements PreferredSizeWidget {
  const BarraConVolver({super.key, required this.titulo, this.alVolver});

  final String titulo;

  /// Si se indica, reemplaza la acción de volver (por ejemplo, confirmar antes de salir).
  final VoidCallback? alVolver;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.barraSuperior);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: 'Volver',
            child: InkResponse(
              radius: 24,
              onTap: alVolver ??
                  () => context.canPop() ? context.pop() : context.go('/agenda'),
              child: Icon(AppIcons.izquierda, size: 24, color: cs.onSurface),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Text(titulo),
        ],
      ),
    );
  }
}
