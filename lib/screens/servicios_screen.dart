import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/servicio.dart';
import '../models/turno.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/servicios_viewmodel.dart';
import '../viewmodels/turno_form_viewmodel.dart';
import '../widgets/chip_filtro.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/selector_segmentado.dart';
import '../widgets/snackbar_turno.dart';
import '../widgets/tarjeta_servicio.dart';

/// Catálogo de servicios en cuadrícula. Al tocar uno se abre el formulario
/// de turno con ese servicio ya elegido (el dato viaja con extra).
class ServiciosScreen extends StatelessWidget {
  const ServiciosScreen({super.key, required this.servicios});

  final ServiciosViewModel servicios;

  /// Columnas según el ancho disponible: 2 (menos de 600 dp),
  /// 3 (de 600 a 840 dp) y 4 (más de 840 dp).
  int _columnas(double ancho) {
    if (ancho < 600) return 2;
    if (ancho <= 840) return 3;
    return 4;
  }

  Future<void> _reservar(BuildContext context, Servicio servicio) async {
    final turno = await context.push<Turno>(
      '/turno/nuevo',
      extra: TurnoInicial(servicioId: servicio.id),
    );
    if (turno != null && context.mounted) mostrarTurnoGuardado(context, turno);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Servicios'),
            Text(
              'Toca un servicio para reservar',
              style: AppTextStyles.secundario
                  .copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: servicios,
        builder: (context, _) {
          final lista = servicios.serviciosFiltrados;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filtros: categoría y público
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChipFiltro(
                            etiqueta: 'Todas',
                            seleccionado: servicios.categoria == null,
                            onTap: () => servicios.filtrarCategoria(null),
                          ),
                          for (final categoria in Categoria.values) ...[
                            const SizedBox(width: AppSpacing.md),
                            ChipFiltro(
                              etiqueta: categoria.etiqueta,
                              seleccionado: servicios.categoria == categoria,
                              onTap: () => servicios.filtrarCategoria(categoria),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SelectorSegmentado<Publico?>(
                      opciones: const <(String, Publico?)>[
                        ('Todos', null),
                        ('Mujeres', Publico.mujeres),
                        ('Hombres', Publico.hombres),
                      ],
                      seleccionado: servicios.publico,
                      onChanged: servicios.filtrarPublico,
                    ),
                  ],
                ),
              ),
              // Cuadrícula
              Expanded(
                child: lista.isEmpty
                    ? const SingleChildScrollView(
                        child: EstadoVacio(
                          icono: AppIcons.sinResultados,
                          titulo: 'No hay servicios',
                          mensaje:
                              'Prueba con otra categoría u otro público.',
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // El alto de la tarjeta crece con el tamaño de letra del sistema.
                          final alto = 122 +
                              MediaQuery.textScalerOf(context).scale(62);
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _columnas(constraints.maxWidth),
                              mainAxisSpacing: AppSpacing.xl,
                              crossAxisSpacing: AppSpacing.xl,
                              mainAxisExtent: alto,
                            ),
                            itemCount: lista.length,
                            itemBuilder: (context, i) => TarjetaServicio(
                              servicio: lista[i],
                              onTap: () => _reservar(context, lista[i]),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
