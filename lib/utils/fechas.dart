/// Funciones para trabajar con fechas (solo el día, sin la hora).
class Fechas {
  Fechas._();

  static DateTime soloDia(DateTime f) => DateTime(f.year, f.month, f.day);

  static bool mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool esDomingo(DateTime f) => f.weekday == DateTime.sunday;

  /// Lunes de la semana de [f].
  static DateTime lunesDeSemana(DateTime f) {
    final dia = soloDia(f);
    return DateTime(dia.year, dia.month, dia.day - (dia.weekday - 1));
  }

  /// Día de referencia de los datos de prueba: hoy, o el lunes si hoy es
  /// domingo (el salón cierra los domingos).
  static DateTime diaBase(DateTime ahora) {
    final hoy = soloDia(ahora);
    return esDomingo(hoy) ? DateTime(hoy.year, hoy.month, hoy.day + 1) : hoy;
  }

  /// Día hábil que está [delta] días hábiles después (o antes) de [base].
  /// Los domingos no cuentan.
  static DateTime diaHabil(DateTime base, int delta) {
    final paso = delta < 0 ? -1 : 1;
    var fecha = soloDia(base);
    var faltan = delta.abs();
    while (faltan > 0) {
      fecha = DateTime(fecha.year, fecha.month, fecha.day + paso);
      if (!esDomingo(fecha)) faltan--;
    }
    return fecha;
  }
}
