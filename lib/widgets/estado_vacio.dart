import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Mensaje con ilustración (círculo con icono) para listas vacías.
/// Por defecto usa el estilo de la Agenda; "No encontrado" lo cambia con los parámetros.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.fondo,
    this.colorIcono,
    this.diametro = AppSizes.circuloVacio,
    this.tamanoIcono = 56,
    this.estiloTitulo = AppTextStyles.tituloVacio,
    this.separacion = 12,
    this.espacioSuperior = 28,
    this.accion,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final Color? fondo;
  final Color? colorIcono;
  final double diametro;
  final double tamanoIcono;
  final TextStyle estiloTitulo;
  final double separacion;
  final double espacioSuperior;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: espacioSuperior),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: diametro,
            height: diametro,
            decoration: BoxDecoration(
              color: fondo ?? cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: tamanoIcono, color: colorIcono ?? cs.primary),
          ),
          SizedBox(height: separacion),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: estiloTitulo.copyWith(color: cs.onSurface),
          ),
          SizedBox(height: separacion),
          SizedBox(
            width: 260,
            child: Text(
              mensaje,
              textAlign: TextAlign.center,
              style: AppTextStyles.nota.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          if (accion != null) ...[SizedBox(height: separacion + 2), accion!],
        ],
      ),
    );
  }
}
