import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/estilistas_viewmodel.dart';
import '../widgets/tarjeta_estilista.dart';

/// Estilistas con cabecera plegable (CustomScrollView + SliverAppBar + SliverList).
/// Al tocar un estilista se va a la Agenda con su filtro: /agenda?estilista=3
class EstilistasScreen extends StatelessWidget {
  const EstilistasScreen({super.key, required this.estilistas});

  final EstilistasViewModel estilistas;

  String _subtitulo() {
    final n = estilistas.estilistas.length;
    final turnos = estilistas.totalProgramadosHoy;
    return '$n ${n == 1 ? 'profesional' : 'profesionales'} · '
        '$turnos ${turnos == 1 ? 'turno programado' : 'turnos programados'} hoy';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListenableBuilder(
        listenable: estilistas,
        builder: (context, _) {
          final lista = estilistas.estilistas;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: AppSizes.cabeceraEstilistas,
                automaticallyImplyLeading: false,
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                scrolledUnderElevation: 0,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    // 1 = cabecera abierta, 0 = cabecera plegada
                    final arriba = MediaQuery.paddingOf(context).top;
                    final plegada = arriba + AppSizes.barraSuperior;
                    final abierta = arriba + AppSizes.cabeceraEstilistas;
                    final t = ((constraints.maxHeight - plegada) /
                            (abierta - plegada))
                        .clamp(0.0, 1.0);

                    return Stack(
                      children: [
                        // Cabecera abierta: icono, título y subtítulo
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 24,
                          child: Opacity(
                            opacity: t,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(AppIcons.estilistas,
                                    size: 28, color: cs.onPrimary),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Estilistas',
                                  style: AppTextStyles.cabecera
                                      .copyWith(color: cs.onPrimary),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _subtitulo(),
                                  style: AppTextStyles.nota.copyWith(
                                    color: cs.onPrimary.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Cabecera plegada: solo el título
                        Positioned(
                          left: 20,
                          right: 20,
                          top: arriba,
                          height: AppSizes.barraSuperior,
                          child: Opacity(
                            opacity: 1 - t,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Estilistas',
                                style: AppTextStyles.tituloPantalla
                                    .copyWith(color: cs.onPrimary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                sliver: SliverList.separated(
                  itemCount: lista.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, i) {
                    final estilista = lista[i];
                    return TarjetaEstilista(
                      estilista: estilista,
                      categorias: estilistas.categorias(estilista),
                      turnosHoy: estilistas.programadosHoy(estilista),
                      onTap: () => context.go('/agenda?estilista=${estilista.id}'),
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
