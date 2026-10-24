import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Círculo con la inicial de una persona (el diseño no usa imágenes).
/// El tamaño de la letra es el 40% del diámetro.
class AvatarInicial extends StatelessWidget {
  const AvatarInicial({
    super.key,
    required this.inicial,
    required this.diametro,
    required this.fondo,
    required this.colorTexto,
  });

  final String inicial;
  final double diametro;
  final Color fondo;
  final Color colorTexto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diametro,
      height: diametro,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fondo, shape: BoxShape.circle),
      child: Text(
        inicial,
        style: AppTextStyles.tituloItem.copyWith(
          fontSize: diametro * 0.4,
          color: colorTexto,
        ),
      ),
    );
  }
}
