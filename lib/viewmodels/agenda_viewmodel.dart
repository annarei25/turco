import 'package:flutter/foundation.dart';

import '../models/horario_salon.dart';
import '../models/turno.dart';
import '../utils/fechas.dart';
import 'salon_viewmodel.dart';

/// Estado de la pantalla Agenda: día elegido y filtros.
/// Vive fuera de la pantalla, por eso se conserva al cambiar de pestaña.
class AgendaViewModel extends ChangeNotifier {
  AgendaViewModel(SalonViewModel salon)
      : _salon = salon,
        _fecha = Fechas.soloDia(salon.ahora) {
    _salon.addListener(notifyListeners);
  }

  final SalonViewModel _salon;
  DateTime _fecha;
  int? _estilistaId; // null = Todos
  EstadoTurno? _estado; // null = Todos

  DateTime get fecha => _fecha;
  int? get estilistaId => _estilistaId;
  EstadoTurno? get estado => _estado;

  /// Los siete días (lunes a domingo) de la semana de la fecha elegida.
  List<DateTime> get diasSemana {
    final lunes = Fechas.lunesDeSemana(_fecha);
    return List.generate(
      7,
      (i) => DateTime(lunes.year, lunes.month, lunes.day + i),
    );
  }

  bool get diaCerrado => !HorarioSalon.estaAbierto(_fecha);

  // --- Cambios --------------------------------------------------------------

  void seleccionarFecha(DateTime fecha) {
    _fecha = Fechas.soloDia(fecha);
    notifyListeners();
  }

  void semanaAnterior() =>
      seleccionarFecha(DateTime(_fecha.year, _fecha.month, _fecha.day - 7));

  void semanaSiguiente() =>
      seleccionarFecha(DateTime(_fecha.year, _fecha.month, _fecha.day + 7));

  void filtrarEstilista(int? id) {
    if (_estilistaId == id) return;
    _estilistaId = id;
    notifyListeners();
  }

  void filtrarEstado(EstadoTurno? estado) {
    if (_estado == estado) return;
    _estado = estado;
    notifyListeners();
  }

  // --- Datos del día --------------------------------------------------------

  /// Todos los turnos del día, sin filtros (para el resumen).
  List<Turno> get turnosDelDia => _salon.turnosDelDia(_fecha);

  /// Turnos del día con los filtros de estilista y estado aplicados.
  List<Turno> get turnosVisibles => turnosDelDia.where((t) {
        if (_estilistaId != null && t.estilistaId != _estilistaId) return false;
        if (_estado != null && t.estado != _estado) return false;
        return true;
      }).toList();

  int get programados =>
      turnosDelDia.where((t) => t.estado == EstadoTurno.programado).length;

  int get completados =>
      turnosDelDia.where((t) => t.estado == EstadoTurno.completado).length;

  /// Suma de los totales de turnos programados y completados (sin cancelados).
  int get ingresoEstimado => turnosDelDia
      .where((t) => t.estado != EstadoTurno.cancelado)
      .fold(0, (suma, t) => suma + t.precioTotal);

  /// El resumen se muestra solo si el día tiene turnos.
  bool get mostrarResumen => turnosDelDia.isNotEmpty;

  @override
  void dispose() {
    _salon.removeListener(notifyListeners);
    super.dispose();
  }
}
