import 'servicio.dart';

enum Genero {
  mujer,
  hombre;

  String get etiqueta => switch (this) {
        Genero.mujer => 'Mujer',
        Genero.hombre => 'Hombre',
      };

  /// Público de servicios que se elige por defecto para este género.
  Publico get publicoPorDefecto => switch (this) {
        Genero.mujer => Publico.mujeres,
        Genero.hombre => Publico.hombres,
      };
}

class Cliente {
  final int id;
  final String nombre;
  final String telefono; // 8 dígitos, único
  final Genero genero;
  final String? correo;
  final DateTime fechaRegistro;

  const Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.genero,
    this.correo,
    required this.fechaRegistro,
  });

  String get inicial => nombre.substring(0, 1).toUpperCase();
}
