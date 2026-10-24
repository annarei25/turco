import '../models/cliente.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import '../utils/fechas.dart';

/// Datos de prueba en memoria.
/// Las fechas de los turnos se calculan con DateTime.now(), así no quedan vencidas.
class DatosPrueba {
  DatosPrueba._();

  // --- Servicios: 12 (4 mujeres, 4 hombres, 4 unisex) -----------------------

  static const List<Servicio> servicios = [
    Servicio(id: 1, nombre: 'Corte mujer', categoria: Categoria.corte, duracionMin: 60, precio: 30, publico: Publico.mujeres),
    Servicio(id: 2, nombre: 'Corte caballero', categoria: Categoria.corte, duracionMin: 45, precio: 25, publico: Publico.hombres),
    Servicio(id: 3, nombre: 'Corte clásico', categoria: Categoria.corte, duracionMin: 30, precio: 18, publico: Publico.hombres),
    Servicio(id: 4, nombre: 'Color completo', categoria: Categoria.color, duracionMin: 120, precio: 70, publico: Publico.mujeres),
    Servicio(id: 5, nombre: 'Mechas', categoria: Categoria.color, duracionMin: 150, precio: 85, publico: Publico.mujeres),
    Servicio(id: 6, nombre: 'Tinte de raíz', categoria: Categoria.color, duracionMin: 60, precio: 35, publico: Publico.mujeres),
    Servicio(id: 7, nombre: 'Barba', categoria: Categoria.barba, duracionMin: 45, precio: 20, publico: Publico.hombres),
    Servicio(id: 8, nombre: 'Afeitado', categoria: Categoria.barba, duracionMin: 30, precio: 15, publico: Publico.hombres),
    Servicio(id: 9, nombre: 'Peinado evento', categoria: Categoria.peinado, duracionMin: 60, precio: 40, publico: Publico.unisex),
    Servicio(id: 10, nombre: 'Brushing', categoria: Categoria.peinado, duracionMin: 30, precio: 15, publico: Publico.unisex),
    Servicio(id: 11, nombre: 'Hidratación', categoria: Categoria.tratamiento, duracionMin: 45, precio: 28, publico: Publico.unisex),
    Servicio(id: 12, nombre: 'Keratina', categoria: Categoria.tratamiento, duracionMin: 90, precio: 55, publico: Publico.unisex),
  ];

  // --- Estilistas: 5 --------------------------------------------------------
  // Marta: solo mujeres. Pedro y Rafael: solo hombres. Lucía: ambos.
  // Valeria: peinados y tratamientos (unisex). Rafael no tiene turnos hoy.

  static const List<Estilista> estilistas = [
    Estilista(id: 1, nombre: 'Marta Salazar', avatar: '', servicioIds: [1, 4, 5, 6]),
    Estilista(id: 2, nombre: 'Pedro Vega', avatar: '', servicioIds: [2, 3, 7, 8]),
    Estilista(id: 3, nombre: 'Lucía Torres', avatar: '', servicioIds: [1, 2, 11, 12]),
    Estilista(id: 4, nombre: 'Rafael Núñez', avatar: '', servicioIds: [2, 3, 7, 8]),
    Estilista(id: 5, nombre: 'Valeria Ortiz', avatar: '', servicioIds: [9, 10, 11, 12]),
  ];

  // --- Clientes: 10 (5 mujeres, 5 hombres). Javier no tiene turnos ----------

  static List<Cliente> clientes() {
    final ahora = DateTime.now();
    Cliente c(int id, String nombre, String tel, Genero genero, int dias,
        {String? correo}) {
      return Cliente(
        id: id,
        nombre: nombre,
        telefono: tel,
        genero: genero,
        correo: correo,
        fechaRegistro: ahora.subtract(Duration(days: dias)),
      );
    }

    return [
      c(1, 'Laura Gómez', '52111222', Genero.mujer, 120, correo: 'laura.gomez@correo.com'),
      c(2, 'Carlos Ruiz', '52345678', Genero.hombre, 90, correo: 'carlos.ruiz@correo.com'),
      c(3, 'Ana Martín', '53220140', Genero.mujer, 200),
      c(4, 'Diego Pérez', '55908771', Genero.hombre, 60),
      c(5, 'Sofía Díaz', '54667310', Genero.mujer, 150),
      c(6, 'Javier Soto', '52774009', Genero.hombre, 30),
      c(7, 'Marta Peña', '53441902', Genero.mujer, 45),
      c(8, 'Lucas Herrera', '54221877', Genero.hombre, 75),
      c(9, 'Mateo Rivas', '53780412', Genero.hombre, 20),
      c(10, 'Elena Castro', '55123690', Genero.mujer, 10),
    ];
  }

  // --- Turnos: 16 en siete días hábiles alrededor de hoy --------------------
  // Días: -3, -2, -1, 0 (hoy), +1, +2, +3 (sin contar domingos).
  // Un turno cancelado se marca a mano. Los demás quedan Completados si ya
  // empezaron y Programados si todavía no.

  static const String _notaCarlos =
      'Prefiere la máquina en el número 2 a los lados. '
      'Llega siempre diez minutos antes y pide agua.';

  static const String _notaLarga =
      'Clienta de color desde hace dos años. Quiere mantener el tono cobrizo '
      'de la última visita, pero un poco más claro en las puntas. Es sensible '
      'al olor del amoníaco, por eso hay que usar la línea sin amoníaco y '
      'ventilar la cabina. Prefiere que no se le pase el secador muy caliente. '
      'Suele venir acompañada de su hija y pide que le avisen por teléfono si '
      'el turno se atrasa más de diez minutos.';

  static List<Turno> turnos() {
    final ahora = DateTime.now();
    final base = Fechas.diaBase(ahora);

    Turno t(int id, int dia, int hora, int minuto, int cliente, int estilista,
        List<int> idsServicios,
        {String? notas, bool cancelado = false}) {
      final fecha = Fechas.diaHabil(base, dia);
      final inicio = DateTime(fecha.year, fecha.month, fecha.day, hora, minuto);
      final EstadoTurno estado;
      if (cancelado) {
        estado = EstadoTurno.cancelado;
      } else if (inicio.isBefore(ahora)) {
        estado = EstadoTurno.completado;
      } else {
        estado = EstadoTurno.programado;
      }
      final creado = inicio.subtract(const Duration(days: 7));
      return Turno(
        id: id,
        clienteId: cliente,
        estilistaId: estilista,
        servicios: [
          for (final sid in idsServicios)
            servicios.firstWhere((s) => s.id == sid),
        ],
        inicio: inicio,
        notas: notas,
        estado: estado,
        creadoEn: creado,
        modificadoEn: creado.add(const Duration(days: 1)),
      );
    }

    return [
      // Días pasados
      t(1, -3, 9, 0, 1, 1, [1]),
      t(2, -3, 10, 0, 2, 2, [2, 7], notas: _notaCarlos),
      t(3, -2, 11, 0, 4, 4, [8], cancelado: true),
      t(4, -2, 14, 0, 3, 1, [4], notas: _notaLarga),
      t(5, -1, 9, 30, 5, 3, [11], cancelado: true),
      t(6, -1, 16, 0, 8, 2, [3]),
      // Hoy
      t(7, 0, 9, 0, 10, 1, [1]),
      t(8, 0, 10, 0, 2, 2, [2, 7], notas: _notaCarlos),
      t(9, 0, 10, 30, 3, 1, [4]),
      t(10, 0, 12, 0, 4, 2, [8], cancelado: true),
      t(11, 0, 14, 0, 5, 3, [11, 1]),
      // Días siguientes
      t(12, 1, 11, 0, 9, 2, [2, 7, 8]), // 3 servicios
      t(13, 1, 15, 0, 1, 3, [12]),
      t(14, 2, 10, 0, 7, 5, [9, 10]),
      t(15, 3, 17, 30, 3, 3, [12]), // termina a las 19:00
      t(16, 3, 9, 0, 2, 4, [2]),
    ];
  }
}
