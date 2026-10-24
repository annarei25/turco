import 'package:flutter/widgets.dart';

import '../models/servicio.dart';

/// Iconos del diseño. Son los mismos Lucide que usa el archivo .pen,
/// tomados de la fuente lucide.ttf (assets/fonts, declarada en pubspec.yaml).
///
/// Regla del proyecto: en pantallas y widgets NO se usa Icons.xxx de Material.
/// Todo icono sale de aquí. Para agregar uno nuevo: buscar su nombre en
/// lucide.dev y copiar su código desde codepoints.json de lucide-static.
class AppIcons {
  AppIcons._();

  static const String _fuente = 'Lucide';

  // Marca y tema
  static const IconData tijera = IconData(0xe14e, fontFamily: _fuente); // scissors
  static const IconData tema = IconData(0xe2b2, fontFamily: _fuente); // sun-moon
  static const IconData temaClaro = IconData(0xe178, fontFamily: _fuente); // sun
  static const IconData temaOscuro = IconData(0xe11e, fontFamily: _fuente); // moon
  static const IconData temaSistema = IconData(0xe163, fontFamily: _fuente); // smartphone

  // Barra inferior
  static const IconData agenda = IconData(0xe2b9, fontFamily: _fuente); // calendar-days
  static const IconData clientes = IconData(0xe1a4, fontFamily: _fuente); // users
  static const IconData estilistas = IconData(0xe09c, fontFamily: _fuente); // contact

  // Fechas y horas
  static const IconData calendario = IconData(0xe063, fontFamily: _fuente); // calendar
  static const IconData sinTurnos = IconData(0xe2be, fontFamily: _fuente); // calendar-x
  static const IconData reloj = IconData(0xe087, fontFamily: _fuente); // clock
  static const IconData flecha = IconData(0xe0d1, fontFamily: _fuente); // flag

  // Navegación
  static const IconData izquierda = IconData(0xe06e, fontFamily: _fuente); // chevron-left
  static const IconData derecha = IconData(0xe06f, fontFamily: _fuente); // chevron-right
  static const IconData abajo = IconData(0xe06d, fontFamily: _fuente); // chevron-down
  static const IconData volver = IconData(0xe048, fontFamily: _fuente); // arrow-left

  // Acciones
  static const IconData marcar = IconData(0xe06c, fontFamily: _fuente); // check
  static const IconData agregar = IconData(0xe13d, fontFamily: _fuente); // plus
  static const IconData editar = IconData(0xe1f9, fontFamily: _fuente); // pencil
  static const IconData completar = IconData(0xe226, fontFamily: _fuente); // circle-check
  static const IconData cancelar = IconData(0xe051, fontFamily: _fuente); // ban
  static const IconData eliminar = IconData(0xe18e, fontFamily: _fuente); // trash-2
  static const IconData buscar = IconData(0xe151, fontFamily: _fuente); // search
  static const IconData sinResultados = IconData(0xe4ad, fontFamily: _fuente); // search-x

  // Personas y datos
  static const IconData persona = IconData(0xe19f, fontFamily: _fuente); // user
  static const IconData personaNueva = IconData(0xe1a2, fontFamily: _fuente); // user-plus
  static const IconData telefono = IconData(0xe133, fontFamily: _fuente); // phone
  static const IconData correo = IconData(0xe10f, fontFamily: _fuente); // mail
  static const IconData precio = IconData(0xe476, fontFamily: _fuente); // badge-dollar-sign

  // Avisos
  static const IconData alerta = IconData(0xe193, fontFamily: _fuente); // triangle-alert
  static const IconData errorCampo = IconData(0xe077, fontFamily: _fuente); // circle-alert
  static const IconData info = IconData(0xe0f9, fontFamily: _fuente); // info
  static const IconData candado = IconData(0xe10b, fontFamily: _fuente); // lock

  // Categorías de servicio
  static const IconData corte = IconData(0xe14e, fontFamily: _fuente); // scissors
  static const IconData color = IconData(0xe1dd, fontFamily: _fuente); // palette
  static const IconData barba = IconData(0xe412, fontFamily: _fuente); // sparkles
  static const IconData peinado = IconData(0xe357, fontFamily: _fuente); // wand-sparkles
  static const IconData tratamiento = IconData(0xe0b5, fontFamily: _fuente); // droplets

  /// Icono de cada categoría de servicio.
  static IconData deCategoria(Categoria categoria) => switch (categoria) {
        Categoria.corte => corte,
        Categoria.color => color,
        Categoria.barba => barba,
        Categoria.peinado => peinado,
        Categoria.tratamiento => tratamiento,
      };
}
