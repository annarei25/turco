import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_icons.dart';

/// Contenedor con la barra de navegación inferior (4 destinos).
/// Cada pestaña conserva su estado gracias a StatefulShellRoute.indexedStack.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    // Botón atrás del sistema: desde Clientes, Servicios o Estilistas vuelve a
    // la Agenda; desde la Agenda cierra la app.
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (salio, _) {
        if (!salio) shell.goBranch(0);
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (indice) => shell.goBranch(
            indice,
            // Al tocar la pestaña activa se vuelve a su pantalla inicial.
            initialLocation: indice == shell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(icon: Icon(AppIcons.agenda), label: 'Agenda'),
            NavigationDestination(icon: Icon(AppIcons.clientes), label: 'Clientes'),
            NavigationDestination(icon: Icon(AppIcons.tijera), label: 'Servicios'),
            NavigationDestination(icon: Icon(AppIcons.estilistas), label: 'Estilistas'),
          ],
        ),
      ),
    );
  }
}
