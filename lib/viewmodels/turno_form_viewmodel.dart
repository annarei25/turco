import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../models/estilista.dart';
import '../models/horario_salon.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import '../utils/fechas.dart';
import 'salon_viewmodel.dart';

/// Datos con los que otras pantallas abren el formulario (viajan con extra).
class TurnoInicial {
  final int? clienteId;
  final int? servicioId;
  final DateTime? fecha;

  const TurnoInicial({this.clienteId, this.servicioId, this.fecha});
}

/// Estado del formulario de turno (crear y editar).
/// Se crea al abrir el formulario y se descarta al cerrarlo.
class TurnoFormViewModel extends ChangeNotifier {
  TurnoFormViewModel(
    this._salon, {
    this.editando,
    TurnoInicial? inicial,
  }) {
    final turno = editando;
    if (turno != null) {
      _cliente = _salon.clientePorId(turno.clienteId);
      _servicioIds.addAll(turno.servicios.map((s) => s.id));
      _estilista = _salon.estilistaPorId(turno.estilistaId);
      _fecha = Fechas.soloDia(turno.inicio);
      _horaMin = turno.inicio.hour * 60 + turno.inicio.minute;
      _notas = turno.notas ?? '';
    } else if (inicial != null) {
      final clienteId = inicial.clienteId;
      if (clienteId != null) _cliente = _salon.clientePorId(clienteId);
      final servicioId = inicial.servicioId;
      if (servicioId != null) _servicioIds.add(servicioId);
      final fecha = inicial.fecha;
      if (fecha != null) _fecha = Fechas.soloDia(fecha);
    }

    // El filtro de público parte del género del cliente. Si un servicio ya
    // elegido no entra en ese filtro, se muestra todo.
    _publico = _cliente?.genero.publicoPorDefecto;
    if (serviciosElegidos.any((s) => !_visibleParaPublico(s))) {
      _publico = null;
    }
    _guardarPuntoInicial();
  }

  static const int maxNotas = 500;

  final SalonViewModel _salon;

  /// Turno que se edita (null si es uno nuevo).
  final Turno? editando;

  Cliente? _cliente;
  final Set<int> _servicioIds = {};
  Publico? _publico;
  Estilista? _estilista;
  DateTime? _fecha;
  int? _horaMin; // minutos desde las 00:00
  String _notas = '';
  String? _aviso;

  // Valores al abrir el formulario, para saber si hay cambios sin guardar.
  late final int? _clienteIni;
  late final Set<int> _serviciosIni;
  late final int? _estilistaIni;
  late final DateTime? _fechaIni;
  late final int? _horaIni;
  late final String _notasIni;

  void _guardarPuntoInicial() {
    _clienteIni = _cliente?.id;
    _serviciosIni = Set.of(_servicioIds);
    _estilistaIni = _estilista?.id;
    _fechaIni = _fecha;
    _horaIni = _horaMin;
    _notasIni = _notas;
  }

  // --- Lectura --------------------------------------------------------------

  bool get esEdicion => editando != null;

  /// Hoy, sin hora (primer día que se puede elegir).
  DateTime get hoy => Fechas.soloDia(_salon.ahora);
  String get titulo => esEdicion ? 'Editar turno' : 'Nuevo turno';

  Cliente? get cliente => _cliente;
  Estilista? get estilista => _estilista;
  DateTime? get fecha => _fecha;
  int? get horaMin => _horaMin;
  String get notas => _notas;
  Publico? get publico => _publico;
  Set<int> get servicioIds => Set.unmodifiable(_servicioIds);

  List<Servicio> get serviciosElegidos =>
      _salon.servicios.where((s) => _servicioIds.contains(s.id)).toList();

  /// Servicios visibles (según el filtro de público) agrupados por categoría.
  Map<Categoria, List<Servicio>> get serviciosPorCategoria {
    final mapa = <Categoria, List<Servicio>>{};
    for (final categoria in Categoria.values) {
      final lista = _salon.servicios
          .where((s) => s.categoria == categoria && _visibleParaPublico(s))
          .toList();
      if (lista.isNotEmpty) mapa[categoria] = lista;
    }
    return mapa;
  }

  /// Estilistas que realizan todos los servicios elegidos.
  List<Estilista> get estilistasDisponibles =>
      _salon.estilistasParaServicios(serviciosElegidos);

  // Resumen (siempre visible)
  int get duracionMin =>
      serviciosElegidos.fold(0, (suma, s) => suma + s.duracionMin);
  int get precioTotal =>
      serviciosElegidos.fold(0, (suma, s) => suma + s.precio);

  /// Fecha y hora de inicio, o null si falta alguna.
  DateTime? get inicio {
    final f = _fecha;
    final m = _horaMin;
    if (f == null || m == null) return null;
    return DateTime(f.year, f.month, f.day, m ~/ 60, m % 60);
  }

  /// Hora de fin (null si todavía no hay hora de inicio).
  DateTime? get fin => inicio?.add(Duration(minutes: duracionMin));

  /// Cuadrícula de franjas, recalculada con servicios, estilista, cliente y fecha.
  List<Franja> get franjas => _salon.franjas(
        fecha: _fecha,
        duracionMin: duracionMin,
        estilistaId: _estilista?.id,
        clienteId: _cliente?.id,
        excluirTurnoId: editando?.id,
        inicioOriginal: editando?.inicio,
      );

  bool get sinFranjasLibres => !franjas.any((f) => f.disponible);

  /// ¿Hay cambios sin guardar? (para el aviso al salir)
  bool get hayCambios =>
      _cliente?.id != _clienteIni ||
      !setEquals(_servicioIds, _serviciosIni) ||
      _estilista?.id != _estilistaIni ||
      _fecha != _fechaIni ||
      _horaMin != _horaIni ||
      _notas != _notasIni;

  /// Mensaje que la pantalla debe mostrar (SnackBar) y luego borrar.
  String? tomarAviso() {
    final aviso = _aviso;
    _aviso = null;
    return aviso;
  }

  // --- Cambios --------------------------------------------------------------

  void seleccionarCliente(Cliente cliente) {
    _cliente = cliente;
    _publico = cliente.genero.publicoPorDefecto; // por defecto, su género
    _quitarServiciosFueraDelFiltro();
    _revisar();
    notifyListeners();
  }

  void cambiarPublico(Publico? publico) {
    _publico = publico;
    _quitarServiciosFueraDelFiltro();
    _revisar();
    notifyListeners();
  }

  void alternarServicio(int id) {
    if (!_servicioIds.remove(id)) _servicioIds.add(id);
    _revisar();
    notifyListeners();
  }

  void seleccionarEstilista(Estilista estilista) {
    _estilista = estilista;
    _revisarHora();
    notifyListeners();
  }

  void seleccionarFecha(DateTime fecha) {
    _fecha = Fechas.soloDia(fecha);
    _revisarHora();
    notifyListeners();
  }

  void seleccionarHora(int minutos) {
    final franja = franjas.where((f) => f.minutos == minutos);
    if (franja.isEmpty || !franja.first.disponible) return;
    _horaMin = minutos;
    notifyListeners();
  }

  /// Las notas avisan a la pantalla solo cuando cambia el estado de
  /// "hay cambios sin guardar" (no en cada letra).
  void cambiarNotas(String texto) {
    final habiaCambios = hayCambios;
    _notas = texto;
    if (habiaCambios != hayCambios) notifyListeners();
  }

  /// ¿Se ofrece este servicio con el filtro de público actual?
  /// Con "Hombres" no se ofrecen peinados (así está en el diseño).
  bool _visibleParaPublico(Servicio servicio) {
    if (_publico == Publico.hombres && servicio.categoria == Categoria.peinado) {
      return false;
    }
    return servicio.coincideConPublico(_publico);
  }

  void _quitarServiciosFueraDelFiltro() {
    _servicioIds.removeWhere((id) {
      final servicio = _salon.servicios.firstWhere((s) => s.id == id);
      return !_visibleParaPublico(servicio);
    });
  }

  /// Si el estilista elegido ya no realiza los servicios, se limpia y se avisa.
  void _revisar() {
    final estilista = _estilista;
    if (estilista != null) {
      final elegidos = serviciosElegidos;
      if (elegidos.isEmpty) {
        _estilista = null;
      } else if (!estilista.realizaTodos(elegidos)) {
        _estilista = null;
        _aviso = '${estilista.nombre} no realiza los servicios elegidos. '
            'Elige otro estilista.';
      }
    }
    _revisarHora();
  }

  /// Si la hora elegida ya no está libre, se limpia y se avisa.
  void _revisarHora() {
    final minutos = _horaMin;
    if (minutos == null) return;
    final sigueLibre =
        franjas.any((f) => f.minutos == minutos && f.disponible);
    if (!sigueLibre) {
      _horaMin = null;
      _aviso ??= 'La hora elegida ya no está disponible. Elige otra.';
    }
  }

  // --- Validación (mensajes del diseño) -------------------------------------

  String? get errorCliente =>
      _cliente == null ? 'Selecciona un cliente' : null;

  String? get errorServicios =>
      _servicioIds.isEmpty ? 'Elige al menos un servicio' : null;

  String? get errorEstilista =>
      _estilista == null ? 'Selecciona un estilista' : null;

  String? get errorFecha {
    final f = _fecha;
    if (f == null || !HorarioSalon.estaAbierto(f)) {
      return 'Elige una fecha válida (no domingos)';
    }
    final esEdicionSinCambio = editando != null && f == _fechaIni;
    if (!esEdicionSinCambio && f.isBefore(Fechas.soloDia(_salon.ahora))) {
      return 'La fecha ya pasó';
    }
    return null;
  }

  String? get errorHora =>
      _horaMin == null ? 'Elige una hora para el turno' : null;

  // --- Guardar --------------------------------------------------------------

  /// Guarda el turno (nuevo o editado) aplicando todas las reglas.
  ResultadoTurno guardar() {
    final cliente = _cliente;
    final estilista = _estilista;
    final inicioTurno = inicio;
    if (cliente == null || estilista == null || inicioTurno == null) {
      return const ResultadoTurno.error('Completa los campos obligatorios');
    }
    return _salon.guardarTurno(
      id: editando?.id,
      clienteId: cliente.id,
      estilistaId: estilista.id,
      servicios: serviciosElegidos,
      inicio: inicioTurno,
      notas: _notas,
    );
  }
}
