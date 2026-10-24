import 'servicio.dart';

enum EstadoTurno {
  programado,
  completado,
  cancelado;

  String get etiqueta => switch (this) {
        EstadoTurno.programado => 'Programado',
        EstadoTurno.completado => 'Completado',
        EstadoTurno.cancelado => 'Cancelado',
      };
}

/// Un turno pertenece a un cliente y a un estilista e incluye uno o más
/// servicios. La duración, la hora de fin y el precio se calculan.
class Turno {
  final int id;
  final int clienteId;
  final int estilistaId;
  final List<Servicio> servicios;
  final DateTime inicio;
  final String? notas;
  final EstadoTurno estado;
  final DateTime creadoEn;
  final DateTime modificadoEn;

  const Turno({
    required this.id,
    required this.clienteId,
    required this.estilistaId,
    required this.servicios,
    required this.inicio,
    this.notas,
    required this.estado,
    required this.creadoEn,
    required this.modificadoEn,
  });

  // --- Valores calculados ---------------------------------------------------

  int get duracionMin => servicios.fold(0, (suma, s) => suma + s.duracionMin);
  int get precioTotal => servicios.fold(0, (suma, s) => suma + s.precio);
  DateTime get fin => inicio.add(Duration(minutes: duracionMin));
  String get serviciosTexto => servicios.map((s) => s.nombre).join(' + ');

  // --- Estado ---------------------------------------------------------------

  bool get esProgramado => estado == EstadoTurno.programado;

  /// Los turnos cancelados no ocupan horario.
  bool get ocupaHorario => estado != EstadoTurno.cancelado;

  /// Un turno que termina a las 10:00 no se solapa con otro que empieza a las 10:00.
  bool solapaCon(Turno otro) =>
      inicio.isBefore(otro.fin) && otro.inicio.isBefore(fin);

  /// Cambia el estado (completar o cancelar) y actualiza la fecha de modificación.
  Turno conEstado(EstadoTurno nuevo, DateTime ahora) {
    return Turno(
      id: id,
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicios: servicios,
      inicio: inicio,
      notas: notas,
      estado: nuevo,
      creadoEn: creadoEn,
      modificadoEn: ahora,
    );
  }
}
