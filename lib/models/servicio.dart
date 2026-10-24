enum Categoria {
  corte,
  color,
  barba,
  peinado,
  tratamiento;

  String get etiqueta => switch (this) {
        Categoria.corte => 'Corte',
        Categoria.color => 'Color',
        Categoria.barba => 'Barba',
        Categoria.peinado => 'Peinado',
        Categoria.tratamiento => 'Tratamiento',
      };
}

enum Publico {
  mujeres,
  hombres,
  unisex;

  String get etiqueta => switch (this) {
        Publico.mujeres => 'Mujeres',
        Publico.hombres => 'Hombres',
        Publico.unisex => 'Unisex',
      };
}

/// Servicio del catálogo (solo lectura).
class Servicio {
  final int id;
  final String nombre;
  final Categoria categoria;
  final int duracionMin;
  final int precio;
  final Publico publico;

  const Servicio({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracionMin,
    required this.precio,
    required this.publico,
  });

  /// Filtro por público de las pantallas Servicios y Formulario de turno.
  /// Sin filtro (null) entran todos. Los servicios unisex entran siempre.
  bool coincideConPublico(Publico? filtro) =>
      filtro == null || publico == Publico.unisex || publico == filtro;
}
