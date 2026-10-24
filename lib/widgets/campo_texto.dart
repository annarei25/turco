import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import 'fila_error.dart';

/// Campo de texto del diseño: etiqueta arriba, caja de alto 52 (o el alto
/// indicado) y mensaje de error con icono debajo.
///
/// Dentro lleva un TextFormField. El validator va en un FormField que lo
/// rodea, así formKey.currentState!.validate() lo revisa y el mensaje se
/// dibuja con el estilo del diseño.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.focusNode,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.alto = AppSizes.campo,
    this.multilinea = false,
    this.onChanged,
    this.onSubmitted,
  });

  final String etiqueta;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final double alto;
  final bool multilinea;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    OutlineInputBorder borde(Color color, double ancho) => OutlineInputBorder(
          borderRadius: AppRadius.deCampo,
          borderSide: BorderSide(color: color, width: ancho),
        );

    return FormField<String>(
      initialValue: controller.text,
      validator: (_) => validator?.call(controller.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (estado) {
        final error = estado.errorText;
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
            SizedBox(
              height: alto,
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                keyboardType:
                    multilinea ? TextInputType.multiline : keyboardType,
                textInputAction: multilinea
                    ? TextInputAction.newline
                    : textInputAction,
                textCapitalization: textCapitalization,
                inputFormatters: inputFormatters,
                maxLength: maxLength,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical:
                    multilinea ? TextAlignVertical.top : TextAlignVertical.center,
                style: AppTextStyles.cuerpo.copyWith(color: cs.onSurface),
                onChanged: (texto) {
                  estado.didChange(texto);
                  onChanged?.call(texto);
                },
                onFieldSubmitted: (_) => onSubmitted?.call(),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: multilinea
                      ? const EdgeInsets.all(14)
                      : const EdgeInsets.symmetric(horizontal: 14),
                  enabledBorder:
                      hayError ? borde(cs.error, 2) : borde(cs.outline, 1),
                  focusedBorder:
                      hayError ? borde(cs.error, 2) : borde(cs.primary, 2),
                ),
              ),
            ),
            if (hayError) ...[
              const SizedBox(height: AppSpacing.xs),
              FilaError(error),
            ],
          ],
        );
      },
    );
  }
}
