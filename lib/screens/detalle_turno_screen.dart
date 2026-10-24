import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/turno.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../utils/formato.dart';
import '../viewmodels/salon_viewmodel.dart';
import '../widgets/avatar_inicial.dart';
import '../widgets/barra_con_volver.dart';
import '../widgets/dialogos_turno.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/pastilla_estado.dart';

/// Detalle de un turno. Si está programado se puede editar, completar o
/// cancelar; si no, es de solo lectura. Si el id no existe, muestra un mensaje.
class DetalleTurnoScreen extends StatelessWidget {
  const DetalleTurnoScreen({
    super.key,
    required this.salon,
    required this.turnoId,
  });

  final SalonViewModel salon;

  /// Viene del parámetro de ruta /turno/:id (null si no es un número).
  final int? turnoId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: salon,
      builder: (context, _) {
        final id = turnoId;
        final turno = id == null ? null : salon.turnoPorId(id);

        return Scaffold(
          appBar: const BarraConVolver(titulo: 'Detalle del turno'),
          body: turno == null
              ? const _NoEncontrado()
              : _Contenido(salon: salon, turno: turno),
        );
      },
    );
  }
}

class _NoEncontrado extends StatelessWidget {
  const _NoEncontrado();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.topCenter,
      child: EstadoVacio(
        icono: AppIcons.sinResultados,
        titulo: 'No encontramos este turno',
        mensaje: 'El turno no existe o ya no está disponible.',
        fondo: cs.errorContainer,
        colorIcono: cs.error,
        diametro: AppSizes.circuloNoEncontrado,
        tamanoIcono: 52,
        estiloTitulo: AppTextStyles.tituloHoja,
        separacion: 14,
        espacioSuperior: 90,
        accion: FilledButton.icon(
          onPressed: () => context.go('/agenda'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, AppSizes.botonDetalle),
          ),
          icon: const Icon(AppIcons.volver, size: 18),
          label: const Text('Volver a la agenda'),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.salon, required this.turno});

  final SalonViewModel salon;
  final Turno turno;

  Future<void> _editar(BuildContext context) async {
    final guardado = await context.push<Turno>('/turno/${turno.id}/editar');
    // Si se guardó, el detalle se cierra y la Agenda recibe el turno guardado.
    if (guardado != null && context.mounted) context.pop(guardado);
  }

  Future<void> _completar(BuildContext context, String cliente) async {
    final confirmado =
        await confirmarCompletarTurno(context, cliente: cliente, turno: turno);
    if (confirmado) salon.completarTurno(turno.id);
  }

  Future<void> _cancelar(BuildContext context, String cliente) async {
    final confirmado =
        await confirmarCancelarTurno(context, cliente: cliente, turno: turno);
    if (confirmado) salon.cancelarTurno(turno.id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cliente = salon.clientePorId(turno.clienteId);
    final estilista = salon.estilistaPorId(turno.estilistaId);
    final nombreCliente = cliente?.nombre ?? '';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: AppSpacing.contenido,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Horario ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  AvatarInicial(
                                    inicial: cliente?.inicial ?? '',
                                    diametro: AppSizes.avatarDetalle,
                                    fondo: cs.primaryContainer,
                                    colorTexto: cs.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: AppSpacing.xl),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombreCliente,
                                          style: AppTextStyles.tituloVacio
                                              .copyWith(color: cs.onSurface),
                                        ),
                                        const SizedBox(height: AppSpacing.xxs),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(AppIcons.telefono,
                                                size: 13,
                                                color: cs.onSurfaceVariant),
                                            const SizedBox(
                                                width: AppSpacing.xs),
                                            Text(
                                              Formato.telefono(
                                                  cliente?.telefono ?? ''),
                                              style: AppTextStyles.nota
                                                  .copyWith(
                                                      color:
                                                          cs.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            PastillaEstado(estado: turno.estado),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _Dato(
                          icono: AppIcons.calendario,
                          etiqueta: 'Fecha',
                          valor: Formato.fechaLarga(turno.inicio),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _Dato(
                          icono: AppIcons.reloj,
                          etiqueta: 'Hora',
                          valor: '${Formato.hora(turno.inicio)} a '
                              '${Formato.hora(turno.fin)} '
                              '(${Formato.duracion(turno.duracionMin)})',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _Dato(
                          icono: AppIcons.persona,
                          etiqueta: 'Estilista',
                          valor: estilista?.primerNombre ?? '',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Servicios y total ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Servicios',
                          style:
                              AppTextStyles.seccion.copyWith(color: cs.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        for (final servicio in turno.servicios) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      servicio.nombre,
                                      style: AppTextStyles.valor
                                          .copyWith(color: cs.onSurface),
                                    ),
                                    Text(
                                      Formato.duracion(servicio.duracionMin),
                                      style: AppTextStyles.secundario.copyWith(
                                          color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                Formato.dinero(servicio.precio),
                                style: AppTextStyles.seccion
                                    .copyWith(color: cs.onSurface),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const Divider(),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: AppTextStyles.seccion
                                  .copyWith(color: cs.onSurface),
                            ),
                            Text(
                              Formato.dinero(turno.precioTotal),
                              style:
                                  AppTextStyles.total.copyWith(color: cs.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Notas (con scroll propio) ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Notas',
                          style:
                              AppTextStyles.seccion.copyWith(color: cs.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxHeight: AppSizes.notasMax),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Text(
                                turno.notas ?? 'Sin notas',
                                style: AppTextStyles.notaLarga
                                    .copyWith(color: cs.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Creado el ${Formato.fechaNumerica(turno.creadoEn)} · '
                  'Modificado el ${Formato.fechaNumerica(turno.modificadoEn)}',
                  style: AppTextStyles.pie.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),

        // --- Barra de acciones ---
        Container(
          color: cs.surfaceContainer,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              child: turno.esProgramado
                  ? _Acciones(
                      onEditar: () => _editar(context),
                      onCompletar: () => _completar(context, nombreCliente),
                      onCancelar: () => _cancelar(context, nombreCliente),
                    )
                  : _SoloLectura(estado: turno.estado),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fila con icono, etiqueta pequeña y valor (Fecha, Hora, Estilista).
class _Dato extends StatelessWidget {
  const _Dato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icono, size: 18, color: cs.primary),
        const SizedBox(width: AppSpacing.xxl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: AppTextStyles.pie.copyWith(color: cs.onSurfaceVariant),
              ),
              Text(
                valor,
                style: AppTextStyles.valor.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Editar, Completar y Cancelar: tres botones de igual ancho, alto 44.
class _Acciones extends StatelessWidget {
  const _Acciones({
    required this.onEditar,
    required this.onCompletar,
    required this.onCancelar,
  });

  final VoidCallback onEditar;
  final VoidCallback onCompletar;
  final VoidCallback onCancelar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const tamano = Size(0, AppSizes.botonDetalle);
    const relleno = EdgeInsets.symmetric(horizontal: 4);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEditar,
            style: OutlinedButton.styleFrom(
              minimumSize: tamano,
              padding: relleno,
            ),
            icon: const Icon(AppIcons.editar, size: 18),
            label: const Text('Editar'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onCompletar,
            style: FilledButton.styleFrom(
              minimumSize: tamano,
              padding: relleno,
            ),
            icon: const Icon(AppIcons.marcar, size: 18),
            label: const Text('Completar'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TextButton.icon(
            onPressed: onCancelar,
            style: TextButton.styleFrom(
              foregroundColor: cs.error,
              minimumSize: tamano,
              padding: relleno,
              shape: const StadiumBorder(),
            ),
            icon: const Icon(AppIcons.cancelar, size: 18),
            label: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }
}

class _SoloLectura extends StatelessWidget {
  const _SoloLectura({required this.estado});

  final EstadoTurno estado;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final texto = estado == EstadoTurno.completado
        ? 'Turno completado: solo lectura'
        : 'Turno cancelado: solo lectura';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(AppIcons.candado, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Text(
          texto,
          style: AppTextStyles.chip.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
