/// Horario del salón: lunes a sábado, de 9:00 a 19:00. Domingo cerrado.
/// Los turnos empiezan en franjas de 30 minutos.
class HorarioSalon {
  HorarioSalon._();

  static const int horaApertura = 9;
  static const int horaCierre = 19;
  static const int minutosPorFranja = 30;

  static bool estaAbierto(DateTime fecha) => fecha.weekday != DateTime.sunday;
}
