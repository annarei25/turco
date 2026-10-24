import 'package:flutter/material.dart';

/// PANTALLA TEMPORAL para las rutas que todavía no tienen su diseño programado.
/// Se reemplaza pantalla por pantalla en los siguientes pasos.
class PantallaPendiente extends StatelessWidget {
  const PantallaPendiente({super.key, required this.titulo, this.detalle});

  final String titulo;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(child: Text(detalle ?? 'Pantalla en construcción')),
    );
  }
}
