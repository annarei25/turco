import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../models/estilista.dart';
import '../models/horario_salon.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import '../utils/fechas.dart';

/// Una franja de 30 minutos de la cuadrícula de horas.
class Franja {
  final int minutos; // minutos desde las 00:00 (09:00 = 540)
  final bool disponible;

  const Franja(this.minutos, this.disponible);

  String get etiqueta {
    final h = (minutos ~/ 60).toString().padLeft(2, '0');
    final m = (minutos % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Resultado de guardar un turno: o trae el turno guardado o un mensaje de error.
class ResultadoTurno {
  final Turno? turno;
  final String? error;

  const ResultadoTurno.ok(this.turno) : error = null;
  const ResultadoTurno.error(this.error) : turno = null;

  bool get exito => turno != null;
}

/// Datos y reglas de negocio del salón. Lo comparten todas las pantallas:
/// cuando algo cambia, avisa con notifyListeners y todas se actualizan.
class SalonViewModel extends ChangeNotifier {
  SalonViewModel({
    required List<Servicio> servicios,
    required List<Estilista> estilistas,
    required List<Cliente> clientes,
    required List<Turno> turnos,
    DateTime Function()? reloj,
  })  : _servicios = List.unmodifiable(servicios),
        _estilistas = List.unmodifiable(estilistas),
        _clientes = List.of(clientes),
        _turnos = List.of(turnos),
        _reloj = reloj ?? DateTime.now {
    _siguienteClienteId = _mayorId(clientes.map((c) => c.id)) + 1;
    _siguienteTurnoId = _mayorId(turnos.map((t) => t.id)) + 1;
  }

  final List<Servicio> _servicios;
  final List<Estilista> _estilistas;
  final List<Cliente> _clientes;
  final List<Turno> _turnos;
  final DateTime Function() _reloj;
  int _siguienteClienteId = 1;
  int _siguienteTurnoId = 1;

  static int _mayorId(Iterable<int> ids) =>
      ids.fold(0, (mayor, id) => id > mayor ? id : mayor);

  // --- Lectura --------------------------------------------------------------

  /// Fecha y hora actual (se puede cambiar en las pruebas).
  DateTime get ahora => _reloj();

  List<Servicio> get servicios => _servicios;
  List<Estilista> get estilistas => _estilistas;
  List<Cliente> get clientes => List.unmodifiable(_clientes);

  Cliente? clientePorId(int id) {
    for (final c in _clientes) {
      if (c.id == id) return c;
    }
    return null;
  }

  Estilista? estilistaPorId(int id) {
    for (final e in _estilistas) {
      if (e.id == id) return e;
    }
    return null;
  }

  Turno? turnoPorId(int id) {
    for (final t in _turnos) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Turnos de un día ordenados por hora de inicio.
  List<Turno> turnosDelDia(DateTime dia) {
    final lista = _turnos.where((t) => Fechas.mismoDia(t.inicio, dia)).toList();
    lista.sort((a, b) => a.inicio.compareTo(b.inicio));
    return lista;
  }

  /// Historial de un cliente, del más reciente al más antiguo.
  List<Turno> turnosDeCliente(int clienteId) {
    final lista = _turnos.where((t) => t.clienteId == clienteId).toList();
    lista.sort((a, b) => b.inicio.compareTo(a.inicio));
    return lista;
  }

  int cantidadTurnosDeCliente(int clienteId) =>
      _turnos.where((t) => t.clienteId == clienteId).length;

  int programadosDeCliente(int clienteId) => _turnos
      .where((t) => t.clienteId == clienteId && t.esProgramado)
      .length;

  /// Turnos programados que tiene un estilista hoy.
  int programadosHoyDeEstilista(int estilistaId) {
    final hoy = ahora;
    return _turnos
        .where((t) =>
            t.estilistaId == estilistaId &&
            t.esProgramado &&
            Fechas.mismoDia(t.inicio, hoy))
        .length;
  }

  /// Total de turnos programados hoy.
  int get totalProgramadosHoy {
    final hoy = ahora;
    return _turnos
        .where((t) => t.esProgramado && Fechas.mismoDia(t.inicio, hoy))
        .length;
  }

  // --- Reglas de turnos -----------------------------------------------------

  /// Estilistas que realizan TODOS los servicios elegidos.
  /// Sin servicios elegidos no se ofrece ninguno.
  List<Estilista> estilistasParaServicios(Iterable<Servicio> elegidos) {
    if (elegidos.isEmpty) return const [];
    return _estilistas.where((e) => e.realizaTodos(elegidos)).toList();
  }

  DateTime _inicioEn(DateTime fecha, int minutos) =>
      DateTime(fecha.year, fecha.month, fecha.day, minutos ~/ 60, minutos % 60);

  /// ¿Algún turno que ocupa horario se solapa con [inicio, fin)?
  /// [coincide] dice si el turno es del mismo estilista o del mismo cliente.
  bool _haySolape(
    DateTime inicio,
    DateTime fin,
    int? excluirTurnoId,
    bool Function(Turno) coincide,
  ) {
    for (final t in _turnos) {
      if (!t.ocupaHorario || t.id == excluirTurnoId || !coincide(t)) continue;
      if (inicio.isBefore(t.fin) && t.inicio.isBefore(fin)) return true;
    }
    return false;
  }

  /// Franjas de 09:00 a 18:30 con su disponibilidad.
  ///
  /// Una franja NO está disponible si:
  /// - el turno terminaría después de las 19:00,
  /// - el día es domingo,
  /// - ya pasó (si la fecha es hoy o anterior),
  /// - el estilista o el cliente ya tienen un turno que se solapa.
  ///
  /// Sin fecha solo se revisa la hora de fin. Sin servicios se usa 30 minutos.
  /// [inicioOriginal] es el inicio del turno que se está editando: esa franja
  /// no se descarta aunque ya haya empezado.
  List<Franja> franjas({
    DateTime? fecha,
    required int duracionMin,
    int? estilistaId,
    int? clienteId,
    int? excluirTurnoId,
    DateTime? inicioOriginal,
  }) {
    final duracion =
        duracionMin <= 0 ? HorarioSalon.minutosPorFranja : duracionMin;
    final apertura = HorarioSalon.horaApertura * 60;
    final cierre = HorarioSalon.horaCierre * 60;
    final momento = ahora;
    final resultado = <Franja>[];

    for (var m = apertura; m < cierre; m += HorarioSalon.minutosPorFranja) {
      var libre = m + duracion <= cierre;
      if (libre && fecha != null) {
        if (!HorarioSalon.estaAbierto(fecha)) {
          libre = false;
        } else {
          final inicio = _inicioEn(fecha, m);
          final fin = inicio.add(Duration(minutes: duracion));
          final yaPaso = inicio.isBefore(momento) && inicio != inicioOriginal;
          if (yaPaso) {
            libre = false;
          } else if (estilistaId != null &&
              _haySolape(inicio, fin, excluirTurnoId,
                  (t) => t.estilistaId == estilistaId)) {
            libre = false;
          } else if (clienteId != null &&
              _haySolape(inicio, fin, excluirTurnoId,
                  (t) => t.clienteId == clienteId)) {
            libre = false;
          }
        }
      }
      resultado.add(Franja(m, libre));
    }
    return resultado;
  }

  /// Revisa todas las reglas de un turno. Devuelve el mensaje del primer
  /// problema o null si el turno es válido.
  String? errorDeTurno({
    required int clienteId,
    required int estilistaId,
    required List<Servicio> servicios,
    required DateTime inicio,
    int? excluirTurnoId,
    bool omitirPasado = false,
  }) {
    final cliente = clientePorId(clienteId);
    if (cliente == null) return 'Selecciona un cliente';
    final estilista = estilistaPorId(estilistaId);
    if (estilista == null) return 'Selecciona un estilista';
    if (servicios.isEmpty) return 'Elige al menos un servicio';
    if (!estilista.realizaTodos(servicios)) {
      return '${estilista.nombre} no realiza todos los servicios elegidos';
    }
    if (!HorarioSalon.estaAbierto(inicio)) {
      return 'El salón está cerrado los domingos';
    }

    final minutos = inicio.hour * 60 + inicio.minute;
    final apertura = HorarioSalon.horaApertura * 60;
    final cierre = HorarioSalon.horaCierre * 60;
    if (minutos < apertura ||
        minutos >= cierre ||
        minutos % HorarioSalon.minutosPorFranja != 0) {
      return 'Elige una franja de 30 minutos entre las 09:00 y las 19:00';
    }

    final duracion = servicios.fold(0, (suma, s) => suma + s.duracionMin);
    if (minutos + duracion > cierre) {
      return 'El turno terminaría después de las 19:00';
    }
    if (!omitirPasado && inicio.isBefore(ahora)) {
      return 'No se pueden crear turnos en una fecha y hora que ya pasaron';
    }

    final fin = inicio.add(Duration(minutes: duracion));
    if (_haySolape(inicio, fin, excluirTurnoId,
        (t) => t.estilistaId == estilistaId)) {
      return '${estilista.nombre} ya tiene un turno en ese horario';
    }
    if (_haySolape(
        inicio, fin, excluirTurnoId, (t) => t.clienteId == clienteId)) {
      return '${cliente.nombre} ya tiene un turno en ese horario';
    }
    return null;
  }

  /// Crea un turno nuevo (id null) o edita uno programado (id del turno).
  ResultadoTurno guardarTurno({
    int? id,
    required int clienteId,
    required int estilistaId,
    required List<Servicio> servicios,
    required DateTime inicio,
    String? notas,
  }) {
    final original = id == null ? null : turnoPorId(id);
    if (id != null && original == null) {
      return const ResultadoTurno.error('El turno no existe');
    }
    if (original != null && !original.esProgramado) {
      return const ResultadoTurno.error(
          'Solo los turnos programados se pueden editar');
    }

    final error = errorDeTurno(
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicios: servicios,
      inicio: inicio,
      excluirTurnoId: id,
      omitirPasado: original != null && original.inicio == inicio,
    );
    if (error != null) return ResultadoTurno.error(error);

    final momento = ahora;
    final texto = notas?.trim();
    final notasLimpias = (texto == null || texto.isEmpty) ? null : texto;
    final Turno turno;

    if (original == null) {
      turno = Turno(
        id: _siguienteTurnoId++,
        clienteId: clienteId,
        estilistaId: estilistaId,
        servicios: List.unmodifiable(servicios),
        inicio: inicio,
        notas: notasLimpias,
        estado: EstadoTurno.programado,
        creadoEn: momento,
        modificadoEn: momento,
      );
      _turnos.add(turno);
    } else {
      turno = Turno(
        id: original.id,
        clienteId: clienteId,
        estilistaId: estilistaId,
        servicios: List.unmodifiable(servicios),
        inicio: inicio,
        notas: notasLimpias,
        estado: original.estado,
        creadoEn: original.creadoEn,
        modificadoEn: momento,
      );
      _turnos[_turnos.indexWhere((t) => t.id == original.id)] = turno;
    }
    notifyListeners();
    return ResultadoTurno.ok(turno);
  }

  /// Solo los turnos programados se pueden completar o cancelar.
  /// Un turno cancelado deja libre su horario porque ya no cuenta como ocupado.
  bool completarTurno(int id) => _cambiarEstado(id, EstadoTurno.completado);
  bool cancelarTurno(int id) => _cambiarEstado(id, EstadoTurno.cancelado);

  bool _cambiarEstado(int id, EstadoTurno nuevo) {
    final i = _turnos.indexWhere((t) => t.id == id);
    if (i == -1 || !_turnos[i].esProgramado) return false;
    _turnos[i] = _turnos[i].conEstado(nuevo, ahora);
    notifyListeners();
    return true;
  }

  // --- Clientes -------------------------------------------------------------

  /// ¿Otro cliente ya tiene este teléfono? (al editar se excluye al propio cliente)
  bool telefonoEnUso(String telefono, {int? excluirClienteId}) => _clientes
      .any((c) => c.telefono == telefono && c.id != excluirClienteId);

  String? _correoLimpio(String? correo) {
    final texto = correo?.trim();
    return (texto == null || texto.isEmpty) ? null : texto;
  }

  Cliente crearCliente({
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    final cliente = Cliente(
      id: _siguienteClienteId++,
      nombre: nombre.trim(),
      telefono: telefono.trim(),
      genero: genero,
      correo: _correoLimpio(correo),
      fechaRegistro: ahora,
    );
    _clientes.add(cliente);
    notifyListeners();
    return cliente;
  }

  Cliente? editarCliente(
    int id, {
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    final i = _clientes.indexWhere((c) => c.id == id);
    if (i == -1) return null;
    final cliente = Cliente(
      id: id,
      nombre: nombre.trim(),
      telefono: telefono.trim(),
      genero: genero,
      correo: _correoLimpio(correo),
      fechaRegistro: _clientes[i].fechaRegistro,
    );
    _clientes[i] = cliente;
    notifyListeners();
    return cliente;
  }

  /// No se puede eliminar un cliente con turnos programados.
  bool puedeEliminarCliente(int id) => programadosDeCliente(id) == 0;

  /// Elimina al cliente junto con su historial (completados y cancelados).
  bool eliminarCliente(int id) {
    if (!puedeEliminarCliente(id)) return false;
    _turnos.removeWhere((t) => t.clienteId == id);
    _clientes.removeWhere((c) => c.id == id);
    notifyListeners();
    return true;
  }
}
