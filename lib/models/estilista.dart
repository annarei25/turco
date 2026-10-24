import 'servicio.dart';

/// Estilista del salón (solo lectura).
class Estilista {
  final int id;
  final String nombre;

  /// Ruta del avatar. El diseño no usa imágenes: la pantalla muestra la inicial.
  final String avatar;

  /// Identificadores de los servicios que realiza.
  final List<int> servicioIds;

  const Estilista({
    required this.id,
    required this.nombre,
    required this.avatar,
    required this.servicioIds,
  });

  String get primerNombre => nombre.split(' ').first;
  String get inicial => nombre.substring(0, 1).toUpperCase();

  bool realiza(Servicio servicio) => servicioIds.contains(servicio.id);

  /// Un estilista solo puede recibir turnos con servicios que realiza.
  bool realizaTodos(Iterable<Servicio> servicios) =>
      servicios.every(realiza);

  /// Categorías en las que trabaja, en el orden del enum.
  List<Categoria> categorias(List<Servicio> catalogo) {
    final propias = catalogo.where(realiza).map((s) => s.categoria).toSet();
    return Categoria.values.where(propias.contains).toList();
  }
}
