import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cliente.dart';
import '../models/turno.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../utils/formato.dart';
import '../viewmodels/clientes_viewmodel.dart';
import '../viewmodels/salon_viewmodel.dart';
import '../viewmodels/turno_form_viewmodel.dart';
import '../widgets/avatar_inicial.dart';
import '../widgets/dialogo_confirmar.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/hoja_cliente.dart';
import '../widgets/hoja_cliente_form.dart';
import '../widgets/selector_segmentado.dart';
import '../widgets/snackbar_turno.dart';

/// Lista de clientes con búsqueda, filtro de género y hoja de detalle.
class ClientesScreen extends StatefulWidget {
  const ClientesScreen({
    super.key,
    required this.clientes,
    required this.salon,
  });

  final ClientesViewModel clientes;
  final SalonViewModel salon;

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  late final TextEditingController _busquedaCtl =
      TextEditingController(text: widget.clientes.busqueda);

  @override
  void dispose() {
    _busquedaCtl.dispose();
    super.dispose();
  }

  Future<void> _nuevoCliente() async {
    await mostrarFormularioCliente(context, salon: widget.salon);
  }

  Future<void> _abrirCliente(Cliente cliente) async {
    final accion = await mostrarHojaCliente(
      context,
      salon: widget.salon,
      cliente: cliente,
    );
    if (accion == null || !mounted) return;

    switch (accion) {
      case AccionCliente.nuevoTurno:
        // El formulario se abre con este cliente ya elegido.
        final turno = await context.push<Turno>(
          '/turno/nuevo',
          extra: TurnoInicial(clienteId: cliente.id),
        );
        if (turno != null && mounted) mostrarTurnoGuardado(context, turno);
      case AccionCliente.editar:
        await mostrarFormularioCliente(
          context,
          salon: widget.salon,
          editando: cliente,
        );
      case AccionCliente.eliminar:
        await _eliminar(cliente);
    }
  }

  Future<void> _eliminar(Cliente cliente) async {
    final salon = widget.salon;
    final cs = Theme.of(context).colorScheme;

    // No se puede eliminar un cliente con turnos programados.
    if (!salon.puedeEliminarCliente(cliente.id)) {
      final programados = salon
          .turnosDeCliente(cliente.id)
          .where((t) => t.esProgramado)
          .toList();
      final n = programados.length;
      final proximo = programados.last; // la lista viene del más reciente al más antiguo
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'No se puede eliminar: ${cliente.nombre} tiene $n '
              '${n == 1 ? 'turno programado' : 'turnos programados'}.',
            ),
            action: SnackBarAction(
              label: 'Ver',
              onPressed: () => context.push('/turno/${proximo.id}'),
            ),
          ),
        );
      return;
    }

    final confirmado = await mostrarConfirmacion(
      context,
      titulo: '¿Eliminar a ${cliente.nombre}?',
      mensaje:
          'Se eliminará el cliente junto con su historial de turnos completados y cancelados.',
      textoAccion: 'Eliminar',
      colorAccion: cs.error,
      textoVolver: 'Cancelar',
    );
    if (confirmado) salon.eliminarCliente(cliente.id);
  }

  String _resumen(ClientesViewModel vm) {
    String cuenta(int n, String singular, String plural) =>
        '$n ${n == 1 ? singular : plural}';
    return '${cuenta(vm.total, 'cliente', 'clientes')} · '
        '${cuenta(vm.totalMujeres, 'mujer', 'mujeres')} · '
        '${cuenta(vm.totalHombres, 'hombre', 'hombres')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            tooltip: 'Nuevo cliente',
            onPressed: _nuevoCliente,
            icon: Icon(AppIcons.personaNueva,
                size: 22, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 3),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoCliente,
        icon: const Icon(AppIcons.personaNueva),
        label: const Text('Nuevo cliente'),
      ),
      body: ListenableBuilder(
        listenable: widget.clientes,
        builder: (context, _) {
          final vm = widget.clientes;
          final lista = vm.clientesFiltrados;
          final vacia = lista.isEmpty;

          // Un solo ListView.separated: el primer elemento es la cabecera
          // (búsqueda, filtro y totales), así todo se desplaza junto y no hay
          // overflow con el teclado abierto ni en horizontal.
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: 1 + (vacia ? 1 : lista.length),
            separatorBuilder: (_, i) {
              if (i == 0) return const SizedBox(height: AppSpacing.lg);
              return vacia ? const SizedBox.shrink() : const Divider();
            },
            itemBuilder: (context, i) {
              if (i == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Buscador(controller: _busquedaCtl, onChanged: vm.buscar),
                    const SizedBox(height: AppSpacing.lg),
                    SelectorSegmentado<Genero?>(
                      opciones: const <(String, Genero?)>[
                        ('Todos', null),
                        ('Mujeres', Genero.mujer),
                        ('Hombres', Genero.hombre),
                      ],
                      seleccionado: vm.genero,
                      onChanged: vm.filtrarGenero,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _resumen(vm),
                      style: AppTextStyles.secundario
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                );
              }

              if (vacia) {
                return EstadoVacio(
                  icono: AppIcons.clientes,
                  titulo: vm.total == 0
                      ? 'No hay clientes'
                      : 'No se encontraron clientes',
                  mensaje: vm.total == 0
                      ? 'Registra el primero con el botón de abajo.'
                      : 'Prueba con otro nombre o teléfono, o cambia el filtro.',
                );
              }

              final cliente = lista[i - 1];
              return _FilaCliente(
                cliente: cliente,
                turnos: vm.cantidadTurnos(cliente),
                onTap: () => _abrirCliente(cliente),
              );
            },
          );
        },
      ),
    );
  }
}

/// Caja de búsqueda: alto 48, radio 24, lupa de 20 y texto de ayuda.
class _Buscador extends StatelessWidget {
  const _Buscador({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: AppSizes.buscador,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(AppIcons.buscar, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.cuerpo.copyWith(color: cs.onSurface),
              // Sin bordes ni relleno: la barra ya la dibuja el Container.
              // El tema define bordes para los campos del formulario, por eso
              // se anulan todos aquí.
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: 'Buscar por nombre o teléfono',
                hintStyle:
                    AppTextStyles.cuerpo.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de la lista: avatar, nombre, teléfono y género, y cantidad de turnos.
class _FilaCliente extends StatelessWidget {
  const _FilaCliente({
    required this.cliente,
    required this.turnos,
    required this.onTap,
  });

  final Cliente cliente;
  final int turnos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final esMujer = cliente.genero == Genero.mujer;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AvatarInicial(
              inicial: cliente.inicial,
              diametro: AppSizes.avatarLista,
              fondo: esMujer ? cs.primaryContainer : cs.tertiaryContainer,
              colorTexto:
                  esMujer ? cs.onPrimaryContainer : cs.onTertiaryContainer,
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nombre,
                    style: AppTextStyles.nombre.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${Formato.telefono(cliente.telefono)} · '
                    '${cliente.genero.etiqueta}',
                    style: AppTextStyles.secundario
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              Formato.turnos(turnos),
              style: AppTextStyles.etiquetaCampo
                  .copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
