import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/turno.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../utils/formato.dart';
import '../viewmodels/agenda_viewmodel.dart';
import '../viewmodels/salon_viewmodel.dart';
import '../viewmodels/tema_viewmodel.dart';
import '../viewmodels/turno_form_viewmodel.dart';
import '../widgets/acciones_rapidas.dart';
import '../widgets/boton_tema.dart';
import '../widgets/chip_filtro.dart';
import '../widgets/dialogos_turno.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/resumen_dia.dart';
import '../widgets/selector_segmentado.dart';
import '../widgets/tarjeta_turno.dart';
import '../widgets/tira_dias.dart';

/// Pantalla inicial: turnos de un día con filtros y acciones rápidas.
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({
    super.key,
    required this.agenda,
    required this.salon,
    required this.tema,
    this.estilistaId,
  });

  final AgendaViewModel agenda;
  final SalonViewModel salon;
  final TemaViewModel tema;

  /// Viene del parámetro de consulta de la ruta: /agenda?estilista=3
  final int? estilistaId;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  @override
  void initState() {
    super.initState();
    _aplicarFiltroDeRuta();
  }

  @override
  void didUpdateWidget(AgendaScreen anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.estilistaId != widget.estilistaId) _aplicarFiltroDeRuta();
  }

  /// La ruta manda: el filtro de estilista del ViewModel sigue a la URL.
  void _aplicarFiltroDeRuta() {
    if (widget.agenda.estilistaId == widget.estilistaId) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.agenda.filtrarEstilista(widget.estilistaId);
    });
  }

  void _filtrarEstilista(int? id) {
    context.go(id == null ? '/agenda' : '/agenda?estilista=$id');
  }

  Future<void> _nuevoTurno() async {
    final turno = await context.push<Turno>(
      '/turno/nuevo',
      extra: TurnoInicial(fecha: widget.agenda.fecha),
    );
    if (!mounted || turno == null) return;
    _confirmarGuardado(turno);
  }

  /// Abre el detalle. Si desde allí se edita y se guarda, el detalle se cierra
  /// y devuelve el turno guardado.
  Future<void> _abrirDetalle(int turnoId) async {
    final turno = await context.push<Turno>('/turno/$turnoId');
    if (!mounted || turno == null) return;
    _confirmarGuardado(turno);
  }

  /// Se ubica en la fecha del turno guardado y muestra el SnackBar.
  void _confirmarGuardado(Turno turno) {
    widget.agenda.seleccionarFecha(turno.inicio);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Turno guardado para el ${Formato.fechaConfirmacion(turno.inicio)}',
          ),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () => _abrirDetalle(turno.id),
          ),
        ),
      );
  }

  Future<void> _accionesRapidas(Turno turno) async {
    final salon = widget.salon;
    final cliente = salon.clientePorId(turno.clienteId)?.nombre ?? '';
    final estilista = salon.estilistaPorId(turno.estilistaId)?.primerNombre ?? '';

    final accion = await mostrarAccionesRapidas(
      context,
      titulo: '$cliente · ${Formato.hora(turno.inicio)}',
      subtitulo: '${turno.serviciosTexto} · $estilista',
    );
    if (accion == null || !mounted) return;

    if (accion == EstadoTurno.completado) {
      final confirmado =
          await confirmarCompletarTurno(context, cliente: cliente, turno: turno);
      if (confirmado) salon.completarTurno(turno.id);
    } else {
      final confirmado =
          await confirmarCancelarTurno(context, cliente: cliente, turno: turno);
      if (confirmado) salon.cancelarTurno(turno.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.logo,
              height: AppSizes.logo,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(AppIcons.tijera, size: 18, color: cs.onPrimary),
            ),
            const SizedBox(width: AppSpacing.xl),
            const Text('Turco', style: AppTextStyles.tituloApp),
          ],
        ),
        actions: [
          BotonTema(tema: widget.tema),
          const SizedBox(width: 3),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoTurno,
        icon: const Icon(AppIcons.agregar),
        label: const Text('Nuevo turno'),
      ),
      body: ListenableBuilder(
        listenable: widget.agenda,
        builder: (context, _) {
          final agenda = widget.agenda;
          final salon = widget.salon;
          final visibles = agenda.turnosVisibles;

          // Un solo ListView.builder: la cabecera es el primer elemento y
          // después van los turnos (o el mensaje de lista vacía).
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
            itemCount: 1 + (visibles.isEmpty ? 1 : visibles.length),
            itemBuilder: (context, i) {
              if (i == 0) return _Cabecera(agenda: agenda, salon: salon, onEstilista: _filtrarEstilista);

              if (visibles.isEmpty) {
                return const EstadoVacio(
                  icono: AppIcons.sinTurnos,
                  titulo: 'No hay turnos para este día',
                  mensaje:
                      'Crea el primer turno con el botón de abajo o cambia los filtros.',
                );
              }

              final turno = visibles[i - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: TarjetaTurno(
                  turno: turno,
                  cliente: salon.clientePorId(turno.clienteId)?.nombre ?? '',
                  estilista:
                      salon.estilistaPorId(turno.estilistaId)?.primerNombre ?? '',
                  onTap: () => _abrirDetalle(turno.id),
                  onLongPress:
                      turno.esProgramado ? () => _accionesRapidas(turno) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Parte fija de arriba: tira de días, resumen y filtros.
class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.agenda,
    required this.salon,
    required this.onEstilista,
  });

  final AgendaViewModel agenda;
  final SalonViewModel salon;
  final ValueChanged<int?> onEstilista;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TiraDias(agenda: agenda),
        const SizedBox(height: AppSpacing.lg),
        if (agenda.mostrarResumen) ...[
          ResumenDia(agenda: agenda),
          const SizedBox(height: AppSpacing.lg),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChipFiltro(
                etiqueta: 'Todos',
                seleccionado: agenda.estilistaId == null,
                onTap: () => onEstilista(null),
              ),
              for (final estilista in salon.estilistas) ...[
                const SizedBox(width: AppSpacing.md),
                ChipFiltro(
                  etiqueta: estilista.primerNombre,
                  seleccionado: agenda.estilistaId == estilista.id,
                  onTap: () => onEstilista(estilista.id),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SelectorSegmentado<EstadoTurno?>(
          opciones: const [
            ('Todos', null),
            ('Program.', EstadoTurno.programado),
            ('Complet.', EstadoTurno.completado),
            ('Cancel.', EstadoTurno.cancelado),
          ],
          seleccionado: agenda.estado,
          onChanged: agenda.filtrarEstado,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
