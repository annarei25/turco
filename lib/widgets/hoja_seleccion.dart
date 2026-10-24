import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import 'asa_hoja.dart';
import 'avatar_inicial.dart';

/// Una fila de la hoja de selección.
class ItemSeleccion<T> {
  final T valor;
  final String titulo;
  final String subtitulo;
  final String inicial;
  final Color fondoAvatar;
  final Color colorAvatar;

  const ItemSeleccion({
    required this.valor,
    required this.titulo,
    required this.subtitulo,
    required this.inicial,
    required this.fondoAvatar,
    required this.colorAvatar,
  });
}

/// Hoja inferior con una lista para elegir un valor (cliente o estilista).
/// Mismo estilo que la lista de Clientes: avatar de 44, nombre 15/600 y datos 12/400.
Future<T?> mostrarSeleccion<T>(
  BuildContext context, {
  required String titulo,
  required List<ItemSeleccion<T>> items,
  T? seleccionado,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: AsaHoja()),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                titulo,
                style: AppTextStyles.tituloHoja.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return InkWell(
                      onTap: () => ctx.pop(item.valor),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            AvatarInicial(
                              inicial: item.inicial,
                              diametro: AppSizes.avatarLista,
                              fondo: item.fondoAvatar,
                              colorTexto: item.colorAvatar,
                            ),
                            const SizedBox(width: AppSpacing.xl),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.titulo,
                                    style: AppTextStyles.nombre
                                        .copyWith(color: cs.onSurface),
                                  ),
                                  Text(
                                    item.subtitulo,
                                    style: AppTextStyles.secundario
                                        .copyWith(color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            if (item.valor == seleccionado)
                              Icon(AppIcons.marcar, size: 18, color: cs.primary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
