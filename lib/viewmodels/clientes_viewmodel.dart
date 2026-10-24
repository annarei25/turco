import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../utils/formato.dart';
import 'salon_viewmodel.dart';

/// Estado de la pantalla Clientes: búsqueda y filtro de género.
class ClientesViewModel extends ChangeNotifier {
  ClientesViewModel(SalonViewModel salon) : _salon = salon {
    _salon.addListener(notifyListeners);
  }

  final SalonViewModel _salon;
  String _busqueda = '';
  Genero? _genero; // null = Todos

  String get busqueda => _busqueda;
  Genero? get genero => _genero;

  void buscar(String texto) {
    _busqueda = texto;
    notifyListeners();
  }

  void filtrarGenero(Genero? genero) {
    if (_genero == genero) return;
    _genero = genero;
    notifyListeners();
  }

  /// Búsqueda por nombre o teléfono (sin distinguir mayúsculas ni acentos),
  /// combinada con el filtro de género.
  List<Cliente> get clientesFiltrados {
    final consulta = Formato.normalizar(_busqueda.trim());
    final digitos = consulta.replaceAll(' ', '');
    return _salon.clientes.where((c) {
      if (_genero != null && c.genero != _genero) return false;
      if (consulta.isEmpty) return true;
      return Formato.normalizar(c.nombre).contains(consulta) ||
          c.telefono.contains(digitos);
    }).toList();
  }

  // Totales de todos los clientes (no cambian con el filtro).
  int get total => _salon.clientes.length;
  int get totalMujeres =>
      _salon.clientes.where((c) => c.genero == Genero.mujer).length;
  int get totalHombres =>
      _salon.clientes.where((c) => c.genero == Genero.hombre).length;

  int cantidadTurnos(Cliente cliente) =>
      _salon.cantidadTurnosDeCliente(cliente.id);

  @override
  void dispose() {
    _salon.removeListener(notifyListeners);
    super.dispose();
  }
}
