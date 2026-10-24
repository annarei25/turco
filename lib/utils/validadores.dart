import '../models/cliente.dart';

/// Validadores del formulario de cliente. Devuelven el mensaje de error
/// o null si el valor es válido (así lo espera el validator de un TextFormField).
class Validadores {
  Validadores._();

  static final RegExp _correo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _ochoDigitos = RegExp(r'^\d{8}$');

  static String? nombre(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'Campo obligatorio';
    if (texto.length < 3 || texto.length > 60) {
      return 'Escribe entre 3 y 60 caracteres';
    }
    return null;
  }

  /// [enUso] dice si otro cliente ya tiene ese teléfono.
  static String? telefono(String? valor, {required bool Function(String) enUso}) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'Campo obligatorio';
    if (!_ochoDigitos.hasMatch(texto)) return 'Debe tener exactamente 8 dígitos';
    if (enUso(texto)) return 'Este teléfono ya está registrado';
    return null;
  }

  static String? genero(Genero? valor) =>
      valor == null ? 'Selecciona un género' : null;

  /// El correo es opcional: solo se valida el formato si se escribió algo.
  static String? correo(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return null;
    if (!_correo.hasMatch(texto)) return 'Escribe un correo válido';
    return null;
  }
}
