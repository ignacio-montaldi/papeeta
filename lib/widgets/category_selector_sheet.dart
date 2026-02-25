import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/recipe_form/recipe_form_cubit.dart';
import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/widgets/search_field.dart';

class CategorySelectorSheet extends StatefulWidget {
  const CategorySelectorSheet({super.key});

  @override
  State<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<CategorySelectorSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final formCubit = context.read<RecipeFormCubit>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            SearchField(
              onChanged: (v) {
                setState(() => query = v);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CategoryError) {
                    return Center(child: Text(state.message));
                  }

                  final categories = state is CategoryLoaded
                      ? state.categories
                      : <Category>[];

                  final filtered = categories
                      .where(
                        (c) =>
                            c.name.toLowerCase().contains(query.toLowerCase()),
                      )
                      .toList();

                  final grouped = _groupByGroupId(filtered);
                  final sortedEntries = grouped.entries.toList()
                    ..sort((a, b) => a.key.compareTo(b.key));

                  return BlocBuilder<RecipeFormCubit, RecipeFormState>(
                    builder: (context, formState) {
                      return ListView(
                        children: sortedEntries.map((entry) {
                          return _CategoryGroup(
                            groupName: entry.value.first.group?.name ?? '',
                            categories: entry.value,
                            selected: formState.categories,
                            onToggle: formCubit.toggleCategory,
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Listo'),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, List<Category>> _groupByGroupId(List<Category> categories) {
    final map = <int, List<Category>>{};

    for (final c in categories) {
      map.putIfAbsent(c.groupId ?? -1, () => []).add(c);
    }

    return map;
  }
}

class _CategoryGroup extends StatelessWidget {
  final String groupName;
  final List<Category> categories;
  final List<Category> selected;
  final void Function(Category) onToggle;

  const _CategoryGroup({
    required this.groupName,
    required this.categories,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(groupName),
      children: categories.map((c) {
        final isSelected = selected.any((s) => s.id == c.id);

        return CheckboxListTile(
          value: isSelected,
          title: Text(c.name),
          onChanged: (_) => onToggle(c),
          checkColor: Colors.white,
        );
      }).toList(),
    );
  }
}
