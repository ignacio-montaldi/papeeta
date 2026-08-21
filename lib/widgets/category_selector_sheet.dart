import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_form/recipe_form_cubit.dart';
import 'package:papeeta/widgets/ds/ds.dart';

/// Selector múltiple de categorías, agrupadas por grupo.
class CategorySelectorSheet extends StatefulWidget {
  const CategorySelectorSheet({super.key});

  @override
  State<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<CategorySelectorSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final formCubit = context.read<RecipeFormCubit>();

    return AppBottomSheet(
      title: 'Categorías',
      onClose: () => Navigator.pop(context),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Column(
          children: [
            AppSearchField(
              hint: 'Buscar categoría…',
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading || state is CategoryInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CategoryError) {
                    return ErrorStateView(
                      title: 'No pudimos cargar las categorías',
                      message: 'Revisá tu conexión e intentá de nuevo.',
                      onRetry: () =>
                          context.read<CategoryBloc>().add(LoadCategories()),
                    );
                  }

                  final categories =
                      state is CategoryLoaded ? state.categories : <Category>[];
                  final filtered = categories
                      .where((c) =>
                          c.name.toLowerCase().contains(_query.toLowerCase()))
                      .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'Sin resultados para "$_query"',
                        style: AppTypography.body.copyWith(
                          fontSize: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  final grouped = <int, List<Category>>{};
                  for (final c in filtered) {
                    grouped.putIfAbsent(c.groupId ?? -1, () => []).add(c);
                  }
                  final entries = grouped.entries.toList()
                    ..sort((a, b) => a.key.compareTo(b.key));

                  return BlocBuilder<RecipeFormCubit, RecipeFormState>(
                    builder: (context, formState) {
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          for (final entry in entries)
                            _Grupo(
                              nombre: entry.value.first.group?.name ?? 'Otras',
                              categorias: entry.value,
                              seleccionadas: formState.categories,
                              onToggle: formCubit.toggleCategory,
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Listo',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo({
    required this.nombre,
    required this.categorias,
    required this.seleccionadas,
    required this.onToggle,
  });

  final String nombre;
  final List<Category> categorias;
  final List<Category> seleccionadas;
  final ValueChanged<Category> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nombre.toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final categoria in categorias)
                AppChip(
                  label: categoria.name,
                  selected: seleccionadas.any((s) => s.id == categoria.id),
                  onTap: () => onToggle(categoria),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
