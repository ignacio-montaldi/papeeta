import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/models/models.dart';
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
                  final categories = state.categories ?? [];

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
                            groupName: entry.value.first.group?.name ?? "",
                            categories: entry.value,
                            selected: formCubit.state.categories,
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

  Map<int, List<CategoryModel>> _groupByGroupId(
    List<CategoryModel> categories,
  ) {
    final map = <int, List<CategoryModel>>{};

    for (final c in categories) {
      map.putIfAbsent(c.groupId!, () => []).add(c);
    }

    return map;
  }
}

class _CategoryGroup extends StatelessWidget {
  final String groupName;
  final List<CategoryModel> categories;
  final List<CategoryModel> selected;
  final void Function(CategoryModel) onToggle;

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
