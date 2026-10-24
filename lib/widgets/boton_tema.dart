import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../viewmodels/tema_viewmodel.dart';

/// Botón de la barra superior que abre el menú Sistema / Claro / Oscuro.
class BotonTema extends StatelessWidget {
  const BotonTema({super.key, required this.tema});

  final TemaViewModel tema;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: tema,
      builder: (context, _) {
        PopupMenuItem<ThemeMode> opcion(
          ThemeMode modo,
          IconData icono,
          String texto,
        ) {
          final activo = tema.modo == modo;
          return PopupMenuItem<ThemeMode>(
            value: modo,
            height: AppSizes.altoFilaMenu,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(icono,
                    size: 18, color: activo ? cs.primary : cs.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xl),
                Expanded(child: Text(texto)),
                if (activo) Icon(AppIcons.marcar, size: 16, color: cs.primary),
              ],
            ),
          );
        }

        return PopupMenuButton<ThemeMode>(
          tooltip: 'Tema',
          position: PopupMenuPosition.under,
          constraints: const BoxConstraints.tightFor(
            width: AppSizes.anchoMenuTema,
          ),
          icon: Icon(AppIcons.tema, size: 22, color: cs.onSurfaceVariant),
          onSelected: tema.cambiar,
          itemBuilder: (_) => [
            opcion(ThemeMode.system, AppIcons.temaSistema, 'Sistema'),
            opcion(ThemeMode.light, AppIcons.temaClaro, 'Claro'),
            opcion(ThemeMode.dark, AppIcons.temaOscuro, 'Oscuro'),
          ],
        );
      },
    );
  }
}
