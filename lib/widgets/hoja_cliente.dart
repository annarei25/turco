import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cliente.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../utils/formato.dart';
import '../viewmodels/salon_viewmodel.dart';
import 'asa_hoja.dart';
import 'avatar_inicial.dart';
import 'pastilla_estado.dart';

/// Lo que el usuario eligió en la hoja del cliente.
enum AccionCliente { nuevoTurno, editar, eliminar }

/// Hoja con los datos del cliente, su historial de turnos y las acciones
/// Nuevo turno, Editar y Eliminar. La pantalla que la abre ejecuta la acción.
Future<AccionCliente?> mostrarHojaCliente(
  BuildContext context, {
  required SalonViewModel salon,
  required Cliente cliente,
}) {
  return showModalBottomSheet<AccionCliente>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      final historial = salon.turnosDeCliente(cliente.id);
      final esMujer = cliente.genero == Genero.mujer;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: AsaHoja()),
              const SizedBox(height: AppSpacing.xxl),

              // Cabecera: avatar, nombre, teléfono y correo
              Row(
                children: [
                  AvatarInicial(
                    inicial: cliente.inicial,
                    diametro: AppSizes.avatarHoja,
                    fondo: esMujer ? cs.primaryContainer : cs.tertiaryContainer,
                    colorTexto:
                        esMujer ? cs.onPrimaryContainer : cs.onTertiaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nombre,
                          style: AppTextStyles.tituloHoja
                              .copyWith(color: cs.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        _DatoContacto(
                          icono: AppIcons.telefono,
                          texto: Formato.telefono(cliente.telefono),
                        ),
                        if (cliente.correo != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          _DatoContacto(
                            icono: AppIcons.correo,
                            texto: cliente.correo!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Historial de turnos (con scroll si es largo)
              Text(
                'Historial de turnos · ${historial.length}',
                style: AppTextStyles.chipFuerte.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (historial.isEmpty)
                Text(
                  'Todavía no tiene turnos.',
                  style: AppTextStyles.nota.copyWith(color: cs.onSurfaceVariant),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: historial.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.xxl),
                    itemBuilder: (context, i) {
                      final turno = historial[i];
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${Formato.fechaCorta(turno.inicio)} · '
                              '${turno.serviciosTexto}',
                              style: AppTextStyles.nota
                                  .copyWith(color: cs.onSurface),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          PastillaEstado(estado: turno.estado),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.xxl),

              // Acciones
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => ctx.pop(AccionCliente.nuevoTurno),
                      icon: const Icon(AppIcons.agregar, size: 18),
                      label: const Text('Nuevo turno'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => ctx.pop(AccionCliente.editar),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    icon: const Icon(AppIcons.editar, size: 16),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Tooltip(
                    message: 'Eliminar cliente',
                    child: OutlinedButton(
                      onPressed: () => ctx.pop(AccionCliente.eliminar),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                        side: BorderSide(color: cs.outlineVariant),
                        minimumSize: const Size(AppSizes.boton, AppSizes.boton),
                        fixedSize: const Size(AppSizes.boton, AppSizes.boton),
                      ),
                      child: Icon(AppIcons.eliminar, size: 18, color: cs.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _DatoContacto extends StatelessWidget {
  const _DatoContacto({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icono, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            texto,
            style: AppTextStyles.nota.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
