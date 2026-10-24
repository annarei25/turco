import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../models/cliente.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../utils/validadores.dart';
import '../viewmodels/salon_viewmodel.dart';
import 'asa_hoja.dart';
import 'campo_texto.dart';
import 'fila_error.dart';
import 'selector_segmentado.dart';

/// Hoja inferior con el formulario de cliente (alta o edición).
/// La usan la pantalla Clientes y el formulario de turno ("Crear cliente nuevo").
/// Devuelve el cliente guardado, o null si se cancela.
Future<Cliente?> mostrarFormularioCliente(
  BuildContext context, {
  required SalonViewModel salon,
  Cliente? editando,
}) {
  return showModalBottomSheet<Cliente>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _HojaCliente(salon: salon, editando: editando),
  );
}

class _HojaCliente extends StatefulWidget {
  const _HojaCliente({required this.salon, this.editando});

  final SalonViewModel salon;
  final Cliente? editando;

  @override
  State<_HojaCliente> createState() => _HojaClienteState();
}

class _HojaClienteState extends State<_HojaCliente> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _fnNombre = FocusNode();
  final _fnTelefono = FocusNode();
  final _fnCorreo = FocusNode();
  Genero? _genero;

  @override
  void initState() {
    super.initState();
    final cliente = widget.editando;
    if (cliente != null) {
      _nombre.text = cliente.nombre;
      _telefono.text = cliente.telefono;
      _correo.text = cliente.correo ?? '';
      _genero = cliente.genero;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    _fnNombre.dispose();
    _fnTelefono.dispose();
    _fnCorreo.dispose();
    super.dispose();
  }

  String? _errorTelefono(String? valor) => Validadores.telefono(
        valor,
        enUso: (t) => widget.salon
            .telefonoEnUso(t, excluirClienteId: widget.editando?.id),
      );

  void _guardar() {
    if (!_formKey.currentState!.validate()) {
      // El foco va al primer campo con error.
      if (Validadores.nombre(_nombre.text) != null) {
        _fnNombre.requestFocus();
      } else if (_errorTelefono(_telefono.text) != null) {
        _fnTelefono.requestFocus();
      } else if (_genero != null &&
          Validadores.correo(_correo.text) != null) {
        _fnCorreo.requestFocus();
      }
      return;
    }

    final genero = _genero!;
    final salon = widget.salon;
    final editando = widget.editando;
    final guardado = editando == null
        ? salon.crearCliente(
            nombre: _nombre.text,
            telefono: _telefono.text,
            genero: genero,
            correo: _correo.text,
          )
        : salon.editarCliente(
            editando.id,
            nombre: _nombre.text,
            telefono: _telefono.text,
            genero: genero,
            correo: _correo.text,
          );
    context.pop(guardado);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      // Sube la hoja cuando se abre el teclado.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AsaHoja()),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  widget.editando == null ? 'Nuevo cliente' : 'Editar cliente',
                  style: AppTextStyles.tituloHoja.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: AppSpacing.xxl),
                CampoTexto(
                  etiqueta: 'Nombre',
                  controller: _nombre,
                  focusNode: _fnNombre,
                  validator: Validadores.nombre,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onSubmitted: _fnTelefono.requestFocus,
                ),
                const SizedBox(height: AppSpacing.xxl),
                CampoTexto(
                  etiqueta: 'Teléfono',
                  controller: _telefono,
                  focusNode: _fnTelefono,
                  validator: _errorTelefono,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  onSubmitted: _fnCorreo.requestFocus,
                ),
                const SizedBox(height: AppSpacing.xxl),
                FormField<Genero>(
                  validator: (_) => Validadores.genero(_genero),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  builder: (estado) {
                    final error = estado.errorText;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Género',
                          style: AppTextStyles.etiquetaCampo.copyWith(
                            color: error != null
                                ? cs.error
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SelectorSegmentado<Genero?>(
                          opciones: const <(String, Genero?)>[
                            ('Mujer', Genero.mujer),
                            ('Hombre', Genero.hombre),
                          ],
                          seleccionado: _genero,
                          onChanged: (genero) {
                            setState(() => _genero = genero);
                            estado.didChange(genero);
                          },
                        ),
                        if (error != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          FilaError(error),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                CampoTexto(
                  etiqueta: 'Correo (opcional)',
                  controller: _correo,
                  focusNode: _fnCorreo,
                  validator: Validadores.correo,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _guardar,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: FilledButton(
                        onPressed: _guardar,
                        child: const Text('Guardar cliente'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
