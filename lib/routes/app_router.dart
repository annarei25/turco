import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/agenda_screen.dart';
import '../screens/clientes_screen.dart';
import '../screens/detalle_turno_screen.dart';
import '../screens/estilistas_screen.dart';
import '../screens/servicios_screen.dart';
import '../screens/shell_screen.dart';
import '../screens/turno_form_screen.dart';
import '../viewmodels/app_viewmodels.dart';
import '../viewmodels/turno_form_viewmodel.dart';

/// Rutas de la app (solo go_router).
///
/// - /agenda?estilista=3      Agenda con el filtro de estilista (parámetro de consulta)
/// - /turno/nuevo             Formulario de turno nuevo (datos iniciales con extra)
/// - /turno/:id               Detalle (parámetro de ruta)
/// - /turno/:id/editar        Formulario de turno en edición
///
/// Detalle y Formulario se abren por encima de la barra inferior
/// porque usan el navegador raíz (parentNavigatorKey).
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _raiz =
      GlobalKey<NavigatorState>(debugLabel: 'raiz');

  static GoRouter crear(AppViewModels vm) {
    return GoRouter(
      navigatorKey: _raiz,
      initialLocation: '/agenda',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => ShellScreen(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/agenda',
                builder: (context, state) => AgendaScreen(
                  agenda: vm.agenda,
                  salon: vm.salon,
                  tema: vm.tema,
                  estilistaId: int.tryParse(
                    state.uri.queryParameters['estilista'] ?? '',
                  ),
                ),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/clientes',
                builder: (context, state) =>
                    ClientesScreen(clientes: vm.clientes, salon: vm.salon),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/servicios',
                builder: (context, state) =>
                    ServiciosScreen(servicios: vm.servicios),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/estilistas',
                builder: (context, state) =>
                    EstilistasScreen(estilistas: vm.estilistas),
              ),
            ]),
          ],
        ),
        // "nuevo" va antes que ":id" para que no se tome como un identificador.
        GoRoute(
          path: '/turno/nuevo',
          parentNavigatorKey: _raiz,
          builder: (context, state) => TurnoFormScreen(
            salon: vm.salon,
            inicial: state.extra as TurnoInicial?,
          ),
        ),
        GoRoute(
          path: '/turno/:id',
          parentNavigatorKey: _raiz,
          builder: (context, state) => DetalleTurnoScreen(
            salon: vm.salon,
            turnoId: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
          routes: [
            GoRoute(
              path: 'editar',
              parentNavigatorKey: _raiz,
              builder: (context, state) => TurnoFormScreen(
                salon: vm.salon,
                turnoId: int.tryParse(state.pathParameters['id'] ?? ''),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
