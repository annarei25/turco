import 'package:flutter_test/flutter_test.dart';
import 'package:turco/data/datos_prueba.dart';
import 'package:turco/models/cliente.dart';
import 'package:turco/models/servicio.dart';
import 'package:turco/models/turno.dart';
import 'package:turco/utils/formato.dart';
import 'package:turco/viewmodels/salon_viewmodel.dart';

// Lunes 19 de octubre de 2026, 08:00.
final ahora = DateTime(2026, 10, 19, 8);
final martes = DateTime(2026, 10, 20);

Servicio servicio(int id) =>
    DatosPrueba.servicios.firstWhere((s) => s.id == id);

Cliente cliente(int id, String nombre, String tel, Genero genero) => Cliente(
      id: id,
      nombre: nombre,
      telefono: tel,
      genero: genero,
      fechaRegistro: DateTime(2026, 1, 1),
    );

Turno turno({
  required int id,
  required int clienteId,
  required int estilistaId,
  required List<int> servicios,
  required DateTime inicio,
  EstadoTurno estado = EstadoTurno.programado,
}) =>
    Turno(
      id: id,
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicios: servicios.map(servicio).toList(),
      inicio: inicio,
      estado: estado,
      creadoEn: ahora,
      modificadoEn: ahora,
    );

SalonViewModel crearSalon(List<Turno> turnos) => SalonViewModel(
      servicios: DatosPrueba.servicios,
      estilistas: DatosPrueba.estilistas,
      clientes: [
        cliente(1, 'Laura Gómez', '52111222', Genero.mujer),
        cliente(2, 'Carlos Ruiz', '52345678', Genero.hombre),
        cliente(3, 'Ana Martín', '53220140', Genero.mujer),
      ],
      turnos: turnos,
      reloj: () => ahora,
    );

void main() {
  // Marta (estilista 1) tiene Corte mujer (60 min) de 09:00 a 10:00 el martes.
  final turnoMarta = turno(
    id: 1,
    clienteId: 1,
    estilistaId: 1,
    servicios: [1],
    inicio: DateTime(2026, 10, 20, 9),
  );

  test('un turno que termina a las 10:00 no se solapa con uno que empieza a las 10:00', () {
    final salon = crearSalon([turnoMarta]);
    final errorExacto = salon.errorDeTurno(
      clienteId: 3,
      estilistaId: 1,
      servicios: [servicio(1)],
      inicio: DateTime(2026, 10, 20, 10),
    );
    final errorSolape = salon.errorDeTurno(
      clienteId: 3,
      estilistaId: 1,
      servicios: [servicio(1)],
      inicio: DateTime(2026, 10, 20, 9, 30),
    );
    expect(errorExacto, isNull);
    expect(errorSolape, isNotNull);
  });

  test('un cliente no puede tener dos turnos a la vez con estilistas distintos', () {
    final salon = crearSalon([turnoMarta]);
    final error = salon.errorDeTurno(
      clienteId: 1, // Laura ya tiene turno a las 09:00
      estilistaId: 3, // Lucía realiza Corte mujer
      servicios: [servicio(1)],
      inicio: DateTime(2026, 10, 20, 9, 30),
    );
    expect(error, isNotNull);
  });

  test('los domingos el salón está cerrado', () {
    final salon = crearSalon([]);
    final error = salon.errorDeTurno(
      clienteId: 1,
      estilistaId: 1,
      servicios: [servicio(1)],
      inicio: DateTime(2026, 10, 25, 10),
    );
    expect(error, isNotNull);
  });

  test('el turno no puede terminar después de las 19:00', () {
    final salon = crearSalon([]);
    // Color completo dura 120 min.
    final tarde = salon.errorDeTurno(
      clienteId: 1,
      estilistaId: 1,
      servicios: [servicio(4)],
      inicio: DateTime(2026, 10, 20, 17, 30),
    );
    final justo = salon.errorDeTurno(
      clienteId: 1,
      estilistaId: 1,
      servicios: [servicio(4)],
      inicio: DateTime(2026, 10, 20, 17),
    );
    expect(tarde, isNotNull);
    expect(justo, isNull);
  });

  test('no se pueden crear turnos en el pasado', () {
    final salon = crearSalon([]);
    final error = salon.errorDeTurno(
      clienteId: 1,
      estilistaId: 1,
      servicios: [servicio(1)],
      inicio: DateTime(2026, 10, 17, 10), // sábado pasado
    );
    expect(error, isNotNull);
  });

  test('un estilista solo recibe servicios que realiza', () {
    final salon = crearSalon([]);
    // Pedro (2) solo realiza servicios de hombres.
    final error = salon.errorDeTurno(
      clienteId: 1,
      estilistaId: 2,
      servicios: [servicio(1)],
      inicio: DateTime(2026, 10, 20, 10),
    );
    expect(error, isNotNull);
  });

  test('las franjas llegan hasta las 18:30 y respetan la duración', () {
    final salon = crearSalon([]);
    final todas = salon.franjas(fecha: martes, duracionMin: 30);
    expect(todas.length, 20);
    expect(todas.first.etiqueta, '09:00');
    expect(todas.last.etiqueta, '18:30');

    final dosHoras = salon.franjas(fecha: martes, duracionMin: 120);
    expect(dosHoras.where((f) => f.disponible).last.etiqueta, '17:00');
  });

  test('cancelar un turno deja libre su horario', () {
    final salon = crearSalon([turnoMarta]);
    bool primeraLibre() => salon
        .franjas(fecha: martes, duracionMin: 60, estilistaId: 1)
        .first
        .disponible;

    expect(primeraLibre(), isFalse);
    expect(salon.cancelarTurno(1), isTrue);
    expect(primeraLibre(), isTrue);
  });

  test('solo los turnos programados se completan o cancelan', () {
    final salon = crearSalon([
      turno(
        id: 1,
        clienteId: 1,
        estilistaId: 1,
        servicios: [1],
        inicio: DateTime(2026, 10, 20, 9),
        estado: EstadoTurno.completado,
      ),
    ]);
    expect(salon.cancelarTurno(1), isFalse);
    expect(salon.completarTurno(1), isFalse);
  });

  test('guardar un turno nuevo y editarlo', () {
    final salon = crearSalon([]);
    final nuevo = salon.guardarTurno(
      clienteId: 1,
      estilistaId: 1,
      servicios: [servicio(1)],
      inicio: DateTime(2026, 10, 20, 9),
      notas: '  hola  ',
    );
    expect(nuevo.exito, isTrue);
    expect(nuevo.turno!.notas, 'hola');

    // Al editar, el propio turno no cuenta como solape consigo mismo.
    final editado = salon.guardarTurno(
      id: nuevo.turno!.id,
      clienteId: 1,
      estilistaId: 1,
      servicios: [servicio(1)],
      inicio: DateTime(2026, 10, 20, 9, 30),
    );
    expect(editado.exito, isTrue);
    expect(salon.turnoPorId(nuevo.turno!.id)!.notas, isNull);
  });

  test('no se elimina un cliente con turnos programados', () {
    final salon = crearSalon([
      turnoMarta,
      turno(
        id: 2,
        clienteId: 2,
        estilistaId: 2,
        servicios: [2],
        inicio: DateTime(2026, 10, 16, 10),
        estado: EstadoTurno.completado,
      ),
    ]);
    expect(salon.puedeEliminarCliente(1), isFalse);
    expect(salon.eliminarCliente(1), isFalse);

    expect(salon.eliminarCliente(2), isTrue);
    expect(salon.clientePorId(2), isNull);
    expect(salon.turnoPorId(2), isNull); // su historial también se elimina
  });

  test('el teléfono es único', () {
    final salon = crearSalon([]);
    expect(salon.telefonoEnUso('52111222'), isTrue);
    expect(salon.telefonoEnUso('52111222', excluirClienteId: 1), isFalse);
    expect(salon.telefonoEnUso('50000000'), isFalse);
  });

  test('formatos del diseño', () {
    expect(Formato.duracion(90), '1 h 30 min');
    expect(Formato.duracion(45), '45 min');
    expect(Formato.telefono('52345678'), '52 345 678');
    expect(Formato.fechaLarga(DateTime(2026, 10, 21)),
        'Miércoles 21 de octubre de 2026');
    expect(Formato.normalizar('Sofía DÍAZ'), 'sofia diaz');
  });
}
