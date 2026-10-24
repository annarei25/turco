import 'package:flutter/foundation.dart';

import '../models/servicio.dart';
import 'salon_viewmodel.dart';

/// Estado de la pantalla Servicios: filtros de categoría y público.
class ServiciosViewModel extends ChangeNotifier {
  ServiciosViewModel(this._salon);

  final SalonViewModel _salon;
  Categoria? _categoria; // null = Todas
  Publico? _publico; // null = Todos

  Categoria? get categoria => _categoria;
  Publico? get publico => _publico;

  void filtrarCategoria(Categoria? categoria) {
    if (_categoria == categoria) return;
    _categoria = categoria;
    notifyListeners();
  }

  void filtrarPublico(Publico? publico) {
    if (_publico == publico) return;
    _publico = publico;
    notifyListeners();
  }

  List<Servicio> get serviciosFiltrados => _salon.servicios
      .where((s) =>
          (_categoria == null || s.categoria == _categoria) &&
          s.coincideConPublico(_publico))
      .toList();
}
