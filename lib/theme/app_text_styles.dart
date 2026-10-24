import 'package:flutter/material.dart';

/// Estilos de texto del diseño (fuente Poppins, definida en el tema).
///
/// Solo llevan tamaño y peso. El color no va aquí: se pone en la pantalla con
/// colorScheme, por ejemplo:
/// AppTextStyles.secundario.copyWith(color: cs.onSurfaceVariant)
class AppTextStyles {
  AppTextStyles._();

  /// La fuente va en cada estilo porque los botones, chips y selectores
  /// reemplazan el estilo del tema en lugar de combinarlo con él.
  static const String _fuente = 'Poppins';

  // 28
  static const TextStyle cabecera =
      TextStyle(fontFamily: _fuente, fontSize: 28, fontWeight: FontWeight.w600);

  // 22
  static const TextStyle tituloApp =
      TextStyle(fontFamily: _fuente, fontSize: 22, fontWeight: FontWeight.w600);

  // 20: barras superiores, títulos de diálogo, números del resumen
  static const TextStyle tituloPantalla =
      TextStyle(fontFamily: _fuente, fontSize: 20, fontWeight: FontWeight.w600);

  // 18: títulos de hoja, "No encontramos este turno"
  static const TextStyle tituloHoja =
      TextStyle(fontFamily: _fuente, fontSize: 18, fontWeight: FontWeight.w600);

  // 17: título del estado vacío, nombre en el detalle
  static const TextStyle tituloVacio =
      TextStyle(fontFamily: _fuente, fontSize: 17, fontWeight: FontWeight.w600);

  // 16: número del día, nombre de estilista
  static const TextStyle tituloItem =
      TextStyle(fontFamily: _fuente, fontSize: 16, fontWeight: FontWeight.w600);
  static const TextStyle total =
      TextStyle(fontFamily: _fuente, fontSize: 16, fontWeight: FontWeight.w700);

  // 15: hora de inicio, cliente, mes
  static const TextStyle nombre =
      TextStyle(fontFamily: _fuente, fontSize: 15, fontWeight: FontWeight.w600);
  static const TextStyle opcion =
      TextStyle(fontFamily: _fuente, fontSize: 15, fontWeight: FontWeight.w500);

  // 14: títulos de sección, botones, nombre de servicio
  static const TextStyle seccion =
      TextStyle(fontFamily: _fuente, fontSize: 14, fontWeight: FontWeight.w600);
  static const TextStyle valor =
      TextStyle(fontFamily: _fuente, fontSize: 14, fontWeight: FontWeight.w500);
  static const TextStyle cuerpo =
      TextStyle(fontFamily: _fuente, fontSize: 14, fontWeight: FontWeight.w400);
  static const TextStyle cuerpoDialogo =
      TextStyle(fontFamily: _fuente, fontSize: 14, fontWeight: FontWeight.w400, height: 1.45);

  // 13: chips, segmentos, franjas, precios, notas
  static const TextStyle chip =
      TextStyle(fontFamily: _fuente, fontSize: 13, fontWeight: FontWeight.w500);
  static const TextStyle chipFuerte =
      TextStyle(fontFamily: _fuente, fontSize: 13, fontWeight: FontWeight.w600);
  static const TextStyle precio =
      TextStyle(fontFamily: _fuente, fontSize: 13, fontWeight: FontWeight.w700);
  static const TextStyle nota =
      TextStyle(fontFamily: _fuente, fontSize: 13, fontWeight: FontWeight.w400);
  static const TextStyle notaLarga =
      TextStyle(fontFamily: _fuente, fontSize: 13, fontWeight: FontWeight.w400, height: 1.45);

  // 12: etiquetas de campo, estilista en tarjeta, hora de fin, errores
  static const TextStyle etiquetaCampo =
      TextStyle(fontFamily: _fuente, fontSize: 12, fontWeight: FontWeight.w500);
  static const TextStyle etiquetaFuerte =
      TextStyle(fontFamily: _fuente, fontSize: 12, fontWeight: FontWeight.w600); // CORTE, BARBA...
  static const TextStyle secundario =
      TextStyle(fontFamily: _fuente, fontSize: 12, fontWeight: FontWeight.w400);

  // 11: nombre del día, píldoras, leyendas, contador
  static const TextStyle dia =
      TextStyle(fontFamily: _fuente, fontSize: 11, fontWeight: FontWeight.w500);
  static const TextStyle pastilla =
      TextStyle(fontFamily: _fuente, fontSize: 11, fontWeight: FontWeight.w600);
  static const TextStyle pie =
      TextStyle(fontFamily: _fuente, fontSize: 11, fontWeight: FontWeight.w400);
}
