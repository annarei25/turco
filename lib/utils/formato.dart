/// Textos con el formato del diseño (fechas en español, dinero, teléfono...).
class Formato {
  Formato._();

  static const _dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];
  static const _diasCortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
    'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static String _dos(int n) => n.toString().padLeft(2, '0');

  /// 09:30
  static String hora(DateTime f) => '${_dos(f.hour)}:${_dos(f.minute)}';

  /// Miércoles 21 de octubre de 2026
  static String fechaLarga(DateTime f) =>
      '${_dias[f.weekday - 1]} ${f.day} de ${_meses[f.month - 1]} de ${f.year}';

  /// mié 21 de octubre
  static String fechaConfirmacion(DateTime f) =>
      '${_diasCortos[f.weekday - 1].toLowerCase()} ${f.day} de ${_meses[f.month - 1]}';

  /// Octubre 2026
  static String mesAnio(DateTime f) {
    final mes = _meses[f.month - 1];
    return '${mes[0].toUpperCase()}${mes.substring(1)} ${f.year}';
  }

  /// Mié
  static String diaCorto(DateTime f) => _diasCortos[f.weekday - 1];

  /// 21/10
  static String fechaCorta(DateTime f) => '${_dos(f.day)}/${_dos(f.month)}';

  /// 21/10/2026
  static String fechaNumerica(DateTime f) => '${fechaCorta(f)}/${f.year}';

  /// $ 45
  static String dinero(int valor) => '\$ $valor';

  /// 45 min, 2 h, 1 h 30 min
  static String duracion(int minutos) {
    final h = minutos ~/ 60;
    final m = minutos % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '$h h';
    return '$h h $m min';
  }

  /// 52345678 -> 52 345 678
  static String telefono(String t) {
    if (t.length != 8) return t;
    return '${t.substring(0, 2)} ${t.substring(2, 5)} ${t.substring(5)}';
  }

  /// "1 turno", "3 turnos"
  static String turnos(int n) => n == 1 ? '1 turno' : '$n turnos';

  /// Minúsculas y sin acentos, para buscar sin distinguir mayúsculas ni tildes.
  static String normalizar(String texto) {
    const con = 'áàäâéèëêíìïîóòöôúùüûñ';
    const sin = 'aaaaeeeeiiiioooouuuun';
    final buffer = StringBuffer();
    for (final c in texto.toLowerCase().split('')) {
      final i = con.indexOf(c);
      buffer.write(i == -1 ? c : sin[i]);
    }
    return buffer.toString();
  }
}
