import '../data/datos_prueba.dart';
import 'agenda_viewmodel.dart';
import 'clientes_viewmodel.dart';
import 'estilistas_viewmodel.dart';
import 'salon_viewmodel.dart';
import 'servicios_viewmodel.dart';
import 'tema_viewmodel.dart';

/// Reúne los ViewModels de la app. Se crea una vez en main.dart y se pasa
/// al router, que se lo entrega a cada pantalla por el constructor.
class AppViewModels {
  AppViewModels._(this.salon)
      : agenda = AgendaViewModel(salon),
        clientes = ClientesViewModel(salon),
        servicios = ServiciosViewModel(salon),
        estilistas = EstilistasViewModel(salon),
        tema = TemaViewModel();

  factory AppViewModels() {
    return AppViewModels._(SalonViewModel(
      servicios: DatosPrueba.servicios,
      estilistas: DatosPrueba.estilistas,
      clientes: DatosPrueba.clientes(),
      turnos: DatosPrueba.turnos(),
    ));
  }

  final SalonViewModel salon;
  final AgendaViewModel agenda;
  final ClientesViewModel clientes;
  final ServiciosViewModel servicios;
  final EstilistasViewModel estilistas;
  final TemaViewModel tema;
}
