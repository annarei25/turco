import 'package:flutter/foundation.dart';

import '../models/estilista.dart';
import '../models/servicio.dart';
import 'salon_viewmodel.dart';

/// Datos de la pantalla Estilistas.
class EstilistasViewModel extends ChangeNotifier {
  EstilistasViewModel(SalonViewModel salon) : _salon = salon {
    _salon.addListener(notifyListeners);
  }

  final SalonViewModel _salon;

  List<Estilista> get estilistas => _salon.estilistas;

  /// Turnos programados que tiene el estilista hoy.
  int programadosHoy(Estilista estilista) =>
      _salon.programadosHoyDeEstilista(estilista.id);

  int get totalProgramadosHoy => _salon.totalProgramadosHoy;

  /// Categorías en las que trabaja el estilista (para los chips).
  List<Categoria> categorias(Estilista estilista) =>
      estilista.categorias(_salon.servicios);

  @override
  void dispose() {
    _salon.removeListener(notifyListeners);
    super.dispose();
  }
}
