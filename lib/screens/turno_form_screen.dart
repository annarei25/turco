import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cliente.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../utils/fechas.dart';
import '../utils/formato.dart';
import '../viewmodels/salon_viewmodel.dart';
import '../viewmodels/turno_form_viewmodel.dart';
import '../widgets/barra_con_volver.dart';
import '../widgets/campo_selector.dart';
import '../widgets/campo_texto.dart';
import '../widgets/chip_filtro.dart';
import '../widgets/dialogo_confirmar.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/fila_error.dart';
import '../widgets/hoja_cliente_form.dart';
import '../widgets/hoja_seleccion.dart';
import '../widgets/selector_segmentado.dart';

/// Formulario para crear un turno (/turno/nuevo) o editarlo (/turno/:id/editar).
class TurnoFormScreen extends StatefulWidget {
  const TurnoFormScreen({
    super.key,
    required this.salon,
    this.turnoId,
    this.inicial,
  });

  final SalonViewModel salon;

  /// Solo al editar.
  final int? turnoId;

  /// Datos iniciales enviados con extra (cliente, servicio o fecha).
  final TurnoInicial? inicial;

  @override
  State<TurnoFormScreen> createState() => _TurnoFormScreenState();
}

class _TurnoFormScreenState extends State<TurnoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notasCtl = TextEditingController();

  // Un FocusNode por campo: al fallar la validación el foco va al primero con error.
  final _fnCliente = FocusNode();
  final _fnServicios = FocusNode(skipTraversal: true);
  final _fnEstilista = FocusNode();
  final _fnFecha = FocusNode();
  final _fnHora = FocusNode(skipTraversal: true);
  final _fnNotas = FocusNode();

  TurnoFormViewModel? _vm; // null si el turno a editar no existe o no se puede editar
  bool _intentoGuardar = false;

  @override
  void initState() {
    super.initState();
    final id = widget.turnoId;
    if (id == null) {
      _vm = TurnoFormViewModel(widget.salon, inicial: widget.inicial);
    } else {
      final turno = widget.salon.turnoPorId(id);
      if (turno != null && turno.esProgramado) {
        _vm = TurnoFormViewModel(widget.salon, editando: turno);
      }
    }
    final vm = _vm;
    if (vm != null) {
      _notasCtl.text = vm.notas;
      vm.addListener(_mostrarAviso);
    }
  }

  @override
  void dispose() {
    _vm?.removeListener(_mostrarAviso);
    _vm?.dispose();
    _notasCtl.dispose();
    for (final nodo in [
      _fnCliente,
      _fnServicios,
      _fnEstilista,
      _fnFecha,
      _fnHora,
      _fnNotas,
    ]) {
      nodo.dispose();
    }
    super.dispose();
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Avisos del ViewModel (estilista u hora que dejaron de ser válidos).
  void _mostrarAviso() {
    final aviso = _vm?.tomarAviso();
    if (aviso != null && mounted) _mostrarMensaje(aviso);
  }

  /// Los errores solo se muestran después del primer intento de guardar.
  String? _error(String? mensaje) => _intentoGuardar ? mensaje : null;

  // --- Selección de cliente, estilista y fecha ------------------------------

  Future<void> _elegirCliente() async {
    final vm = _vm!;
    final cs = Theme.of(context).colorScheme;
    final cliente = await mostrarSeleccion<Cliente>(
      context,
      titulo: 'Selecciona un cliente',
      seleccionado: vm.cliente,
      items: [
        for (final c in widget.salon.clientes)
          ItemSeleccion<Cliente>(
            valor: c,
            titulo: c.nombre,
            subtitulo: '${Formato.telefono(c.telefono)} · ${c.genero.etiqueta}',
            inicial: c.inicial,
            fondoAvatar: c.genero == Genero.mujer
                ? cs.primaryContainer
                : cs.tertiaryContainer,
            colorAvatar: c.genero == Genero.mujer
                ? cs.onPrimaryContainer
                : cs.onTertiaryContainer,
          ),
      ],
    );
    if (cliente != null) vm.seleccionarCliente(cliente);
  }

  Future<void> _crearCliente() async {
    final cliente =
        await mostrarFormularioCliente(context, salon: widget.salon);
    if (cliente != null && mounted) _vm!.seleccionarCliente(cliente);
  }

  Future<void> _elegirEstilista() async {
    final vm = _vm!;
    final cs = Theme.of(context).colorScheme;
    final estilista = await mostrarSeleccion<Estilista>(
      context,
      titulo: 'Selecciona un estilista',
      seleccionado: vm.estilista,
      items: [
        for (final e in vm.estilistasDisponibles)
          ItemSeleccion<Estilista>(
            valor: e,
            titulo: e.nombre,
            subtitulo: e
                .categorias(widget.salon.servicios)
                .map((c) => c.etiqueta)
                .join(' · '),
            inicial: e.inicial,
            fondoAvatar: cs.primaryContainer,
            colorAvatar: cs.onPrimaryContainer,
          ),
      ],
    );
    if (estilista != null) vm.seleccionarEstilista(estilista);
  }

  Future<void> _elegirFecha() async {
    final vm = _vm!;
    final hoy = vm.hoy;
    var inicial = (vm.fecha != null && !vm.fecha!.isBefore(hoy)) ? vm.fecha! : hoy;
    while (Fechas.esDomingo(inicial)) {
      inicial = DateTime(inicial.year, inicial.month, inicial.day + 1);
    }
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: hoy, // no se permiten fechas pasadas
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      selectableDayPredicate: (dia) => !Fechas.esDomingo(dia), // ni domingos
    );
    if (fecha != null) vm.seleccionarFecha(fecha);
  }

  // --- Guardar y salir ------------------------------------------------------

  /// Primer campo con error, en el orden en que aparecen en pantalla.
  FocusNode? _primerCampoConError() {
    final vm = _vm!;
    if (vm.errorCliente != null) return _fnCliente;
    if (vm.errorServicios != null) return _fnServicios;
    if (vm.errorEstilista != null) return _fnEstilista;
    if (vm.errorFecha != null) return _fnFecha;
    if (vm.errorHora != null) return _fnHora;
    return null;
  }

  void _enfocar(FocusNode nodo) {
    nodo.requestFocus();
    final contexto = nodo.context;
    if (contexto != null) {
      Scrollable.ensureVisible(
        contexto,
        alignment: 0.2,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  void _guardar() {
    setState(() => _intentoGuardar = true);

    final formularioValido = _formKey.currentState!.validate();
    final conError = _primerCampoConError();
    if (!formularioValido || conError != null) {
      // Se espera al siguiente cuadro para que ya estén los mensajes de error.
      final destino = conError ?? _fnNotas;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _enfocar(destino);
      });
      return;
    }

    final resultado = _vm!.guardar();
    if (!resultado.exito) {
      _mostrarMensaje(resultado.error!);
      return;
    }
    // El turno guardado viaja de vuelta a la pantalla anterior.
    context.pop(resultado.turno);
  }

  /// Cancelar, flecha de volver y botón atrás: si hay cambios, se pregunta.
  Future<void> _intentarSalir() async {
    if (!_vm!.hayCambios) {
      context.pop();
      return;
    }
    final cs = Theme.of(context).colorScheme;
    final descartar = await mostrarConfirmacion(
      context,
      titulo: '¿Descartar los cambios?',
      mensaje:
          'Tienes cambios sin guardar en este turno. Si sales ahora se perderán.',
      textoAccion: 'Descartar',
      colorAccion: cs.error,
      textoVolver: 'Seguir editando',
    );
    if (descartar && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _vm;
    if (vm == null) return const _TurnoNoEditable();

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return PopScope(
          // Sin cambios se sale normal; con cambios se pide confirmación.
          canPop: !vm.hayCambios,
          onPopInvokedWithResult: (salio, _) {
            if (!salio) _intentarSalir();
          },
          child: Scaffold(
            appBar: BarraConVolver(titulo: vm.titulo, alVolver: _intentarSalir),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._seccionCliente(vm),
                    const SizedBox(height: AppSpacing.lg),
                    ..._seccionServicios(vm),
                    const SizedBox(height: AppSpacing.lg),
                    ..._seccionEstilista(vm),
                    const SizedBox(height: AppSpacing.xl),
                    ..._seccionFecha(vm),
                    const SizedBox(height: AppSpacing.xl),
                    ..._seccionHora(vm),
                    const SizedBox(height: AppSpacing.xl),
                    ..._seccionNotas(),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _BarraInferior(
              vm: vm,
              onCancelar: _intentarSalir,
              onGuardar: _guardar,
            ),
          ),
        );
      },
    );
  }

  // --- Secciones ------------------------------------------------------------

  List<Widget> _seccionCliente(TurnoFormViewModel vm) {
    final cs = Theme.of(context).colorScheme;
    return [
      CampoSelector(
        etiqueta: 'Cliente',
        icono: AppIcons.persona,
        textoAyuda: 'Selecciona un cliente',
        valor: vm.cliente?.nombre,
        error: _error(vm.errorCliente),
        focusNode: _fnCliente,
        onTap: _elegirCliente,
      ),
      const SizedBox(height: AppSpacing.lg),
      Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: _crearCliente,
          borderRadius: AppRadius.deChip,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.personaNueva, size: 16, color: cs.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Crear cliente nuevo',
                style: AppTextStyles.chipFuerte.copyWith(color: cs.primary),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _seccionServicios(TurnoFormViewModel vm) {
    final cs = Theme.of(context).colorScheme;
    final error = _error(vm.errorServicios);
    return [
      // Filtro por público
      Text(
        'Servicios para',
        style: AppTextStyles.etiquetaCampo.copyWith(color: cs.onSurfaceVariant),
      ),
      const SizedBox(height: AppSpacing.xs),
      SelectorSegmentado<Publico?>(
        opciones: const <(String, Publico?)>[
          ('Todos', null),
          ('Mujeres', Publico.mujeres),
          ('Hombres', Publico.hombres),
        ],
        seleccionado: vm.publico,
        onChanged: vm.cambiarPublico,
      ),
      const SizedBox(height: AppSpacing.lg),
      // Servicios agrupados por categoría (selección múltiple)
      Focus(
        focusNode: _fnServicios,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Servicios',
              style: AppTextStyles.seccion.copyWith(color: cs.onSurface),
            ),
            for (final entrada in vm.serviciosPorCategoria.entries) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                entrada.key.etiqueta.toUpperCase(),
                style: AppTextStyles.etiquetaFuerte
                    .copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (final servicio in entrada.value)
                    ChipFiltro(
                      etiqueta: servicio.nombre,
                      seleccionado: vm.servicioIds.contains(servicio.id),
                      onTap: () => vm.alternarServicio(servicio.id),
                    ),
                ],
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilaError(error),
            ],
          ],
        ),
      ),
    ];
  }

  List<Widget> _seccionEstilista(TurnoFormViewModel vm) {
    final cs = Theme.of(context).colorScheme;
    final sinServicios = vm.servicioIds.isEmpty;
    return [
      CampoSelector(
        etiqueta: 'Estilista',
        icono: AppIcons.tijera,
        textoAyuda:
            sinServicios ? 'Primero elige los servicios' : 'Selecciona un estilista',
        valor: vm.estilista?.primerNombre,
        error: _error(vm.errorEstilista),
        focusNode: _fnEstilista,
        onTap: sinServicios ? null : _elegirEstilista,
      ),
      const SizedBox(height: AppSpacing.lg),
      Row(
        children: [
          Icon(AppIcons.info, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Solo se muestran estilistas que realizan todos los servicios elegidos.',
              style: AppTextStyles.pie.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _seccionFecha(TurnoFormViewModel vm) {
    return [
      CampoSelector(
        etiqueta: 'Fecha',
        icono: AppIcons.calendario,
        textoAyuda: 'Selecciona una fecha',
        valor: vm.fecha == null ? null : Formato.fechaLarga(vm.fecha!),
        error: _error(vm.errorFecha),
        focusNode: _fnFecha,
        onTap: _elegirFecha,
      ),
    ];
  }

  List<Widget> _seccionHora(TurnoFormViewModel vm) {
    final cs = Theme.of(context).colorScheme;
    final franjas = vm.franjas;
    final error = _error(vm.errorHora);

    return [
      Focus(
        focusNode: _fnHora,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hora de inicio',
              style: AppTextStyles.seccion.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            // Leyenda
            Row(
              children: [
                _Leyenda(
                  texto: 'Libre',
                  borde: BorderSide(color: cs.outline),
                ),
                const SizedBox(width: AppSpacing.xxl),
                _Leyenda(texto: 'No disponible', color: cs.surfaceContainerHigh),
                const SizedBox(width: AppSpacing.xxl),
                _Leyenda(texto: 'Elegida', color: cs.primary),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Cuadrícula de franjas de 30 minutos
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                mainAxisExtent: AppSizes.franja,
              ),
              itemCount: franjas.length,
              itemBuilder: (context, i) {
                final franja = franjas[i];
                return _CeldaFranja(
                  franja: franja,
                  elegida: vm.horaMin == franja.minutos,
                  conError: error != null,
                  onTap: franja.disponible
                      ? () => vm.seleccionarHora(franja.minutos)
                      : null,
                );
              },
            ),
            if (vm.sinFranjasLibres) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(AppIcons.info, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'No hay horarios libres. Prueba con otra fecha, otro estilista o menos servicios.',
                      style: AppTextStyles.pie
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilaError(error),
            ],
          ],
        ),
      ),
    ];
  }

  List<Widget> _seccionNotas() {
    final cs = Theme.of(context).colorScheme;
    return [
      CampoTexto(
        etiqueta: 'Notas (opcional)',
        controller: _notasCtl,
        focusNode: _fnNotas,
        multilinea: true,
        alto: AppSizes.notas,
        maxLength: TurnoFormViewModel.maxNotas,
        onChanged: _vm!.cambiarNotas,
        validator: (texto) => (texto ?? '').length > TurnoFormViewModel.maxNotas
            ? 'Máximo ${TurnoFormViewModel.maxNotas} caracteres'
            : null,
      ),
      const SizedBox(height: AppSpacing.xs),
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: _notasCtl,
        builder: (context, valor, _) => Text(
          '${valor.text.length} / ${TurnoFormViewModel.maxNotas}',
          textAlign: TextAlign.right,
          style: AppTextStyles.pie.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
    ];
  }
}

/// Franja de hora: libre, no disponible o elegida.
class _CeldaFranja extends StatelessWidget {
  const _CeldaFranja({
    required this.franja,
    required this.elegida,
    required this.conError,
    required this.onTap,
  });

  final Franja franja;
  final bool elegida;
  final bool conError;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (elegida) {
      return Material(
        color: cs.primary,
        borderRadius: AppRadius.deFranja,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.deFranja,
          child: Center(
            child: Text(
              franja.etiqueta,
              style: AppTextStyles.chipFuerte.copyWith(color: cs.onPrimary),
            ),
          ),
        ),
      );
    }

    if (!franja.disponible) {
      return Opacity(
        opacity: 0.55,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: AppRadius.deFranja,
          ),
          child: Text(
            franja.etiqueta,
            style: AppTextStyles.chip.copyWith(color: cs.outline),
          ),
        ),
      );
    }

    final forma = RoundedRectangleBorder(
      borderRadius: AppRadius.deFranja,
      side: BorderSide(color: conError ? cs.error : cs.outline),
    );
    return Material(
      color: cs.surface,
      shape: forma,
      child: InkWell(
        onTap: onTap,
        customBorder: forma,
        child: Center(
          child: Text(
            franja.etiqueta,
            style: AppTextStyles.chip.copyWith(color: cs.onSurface),
          ),
        ),
      ),
    );
  }
}

/// Cuadro de color + texto de la leyenda de la cuadrícula.
class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.texto, this.color, this.borde});

  final String texto;
  final Color? color;
  final BorderSide? borde;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: borde == null
                ? null
                : Border.all(color: borde!.color, width: borde!.width),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          texto,
          style: AppTextStyles.pie.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Barra fija de abajo: resumen (duración, fin, precio) y los dos botones.
class _BarraInferior extends StatelessWidget {
  const _BarraInferior({
    required this.vm,
    required this.onCancelar,
    required this.onGuardar,
  });

  final TurnoFormViewModel vm;
  final VoidCallback onCancelar;
  final VoidCallback onGuardar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fin = vm.fin;

    return Container(
      color: cs.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: AppRadius.deCampo,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DatoResumen(
                      icono: AppIcons.reloj,
                      texto: Formato.duracion(vm.duracionMin),
                      estilo: AppTextStyles.chipFuerte,
                    ),
                    _DatoResumen(
                      icono: AppIcons.flecha,
                      texto: 'Fin ${fin == null ? '--:--' : Formato.hora(fin)}',
                      estilo: AppTextStyles.chipFuerte,
                    ),
                    _DatoResumen(
                      icono: AppIcons.precio,
                      texto: Formato.dinero(vm.precioTotal),
                      estilo: AppTextStyles.precio,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancelar,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onGuardar,
                      icon: const Icon(AppIcons.marcar, size: 18),
                      label: const Text('Guardar turno'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatoResumen extends StatelessWidget {
  const _DatoResumen({
    required this.icono,
    required this.texto,
    required this.estilo,
  });

  final IconData icono;
  final String texto;
  final TextStyle estilo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 14, color: cs.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(texto, style: estilo.copyWith(color: cs.onSurface)),
      ],
    );
  }
}

/// Se muestra si se abre /turno/:id/editar con un turno que no existe o que
/// ya no está programado.
class _TurnoNoEditable extends StatelessWidget {
  const _TurnoNoEditable();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const BarraConVolver(titulo: 'Editar turno'),
      body: Align(
        alignment: Alignment.topCenter,
        child: EstadoVacio(
          icono: AppIcons.sinResultados,
          titulo: 'No se puede editar este turno',
          mensaje: 'El turno no existe o ya no está programado.',
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
      ),
    );
  }
}
