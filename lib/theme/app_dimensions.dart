import 'package:flutter/material.dart';

/// Espacios en dp (medidas del diseño).
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
  static const double xxl = 14;
  static const double pantalla = 16; // margen horizontal de las pantallas
  static const double xxxl = 20;
  static const double hoja = 24;

  /// Contenido de las pantallas: arriba 4, lados 16, abajo 16.
  static const EdgeInsets contenido = EdgeInsets.fromLTRB(16, 4, 16, 16);
}

/// Radios de borde.
class AppRadius {
  AppRadius._();

  static const double chip = 8; // chips y píldoras de estado
  static const double franja = 10; // franjas de hora
  static const double campo = 12; // campos de texto y resumen del formulario
  static const double resumen = 14; // tarjetas del resumen del día
  static const double tarjeta = 16; // tarjetas y botón flotante
  static const double dia = 18; // días de la tira
  static const double hoja = 28; // diálogos y hojas inferiores

  static BorderRadius get deChip => BorderRadius.circular(chip);
  static BorderRadius get deFranja => BorderRadius.circular(franja);
  static BorderRadius get deCampo => BorderRadius.circular(campo);
  static BorderRadius get deResumen => BorderRadius.circular(resumen);
  static BorderRadius get deTarjeta => BorderRadius.circular(tarjeta);
  static BorderRadius get deDia => BorderRadius.circular(dia);
  static BorderRadius get deHoja => BorderRadius.circular(hoja);
}

/// Tamaños fijos de componentes.
class AppSizes {
  AppSizes._();

  static const double barraSuperior = 56;
  static const double barraNavegacion = 76;
  static const double botonFlotante = 56;
  static const double chip = 32;
  static const double segmento = 40;
  static const double campo = 52;
  static const double buscador = 48;
  static const double boton = 46;
  static const double botonDetalle = 44;
  static const double franja = 40;
  static const double diaTira = 60;
  static const double notas = 84; // caja de notas del formulario
  static const double notasMax = 160; // alto máximo de las notas en el detalle
  static const double logo = 32;
  static const double avatarLista = 44;
  static const double avatarDetalle = 48;
  static const double avatarHoja = 56;
  static const double avatarEstilista = 56;
  static const double circuloVacio = 120;
  static const double circuloNoEncontrado = 112;
  static const double imagenServicio = 84;
  static const double cabeceraEstilistas = 170;
  static const double barraEstado = 4; // barra lateral de la tarjeta de turno
  static const double horasTurno = 48; // ancho de la columna de horas
  static const double anchoDialogo = 310;
  static const double anchoMenuTema = 180;
  static const double altoFilaMenu = 44;
  static const double altoAccionRapida = 52;
}
