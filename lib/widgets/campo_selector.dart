import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import 'fila_error.dart';

/// Campo que no se escribe, se elige (Cliente, Estilista, Fecha).
/// Etiqueta arriba, caja de alto 52 con icono, valor y flecha abajo.
/// Con error: etiqueta y borde (2) en error y el mensaje debajo.
class CampoSelector extends StatelessWidget {
  const CampoSelector({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.textoAyuda,
    this.valor,
    this.error,
    this.onTap,
    this.focusNode,
  });

  final String etiqueta;
  final IconData icono;
  final String textoAyuda;
  final String? valor;
  final String? error;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hayError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: AppTextStyles.etiquetaCampo
              .copyWith(color: hayError ? cs.error : cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          focusNode: focusNode,
          onTap: onTap,
          borderRadius: AppRadius.deCampo,
          child: Container(
            height: AppSizes.campo,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: AppRadius.deCampo,
              border: Border.all(
                color: hayError ? cs.error : cs.outline,
                width: hayError ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icono, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    valor ?? textoAyuda,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cuerpo.copyWith(
                      color: valor == null ? cs.outline : cs.onSurface,
                    ),
                  ),
                ),
                Icon(AppIcons.abajo, size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
        if (hayError) ...[
          const SizedBox(height: AppSpacing.xs),
          FilaError(error!),
        ],
      ],
    );
  }
}
