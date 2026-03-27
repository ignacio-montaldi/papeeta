import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/core/domain/entities/category_group.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe_image.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:papeeta/widgets/widgets.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías', style: TextStyle(color: Colors.white)),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryInitial || state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryError) {
            return Center(child: Text(state.message));
          }

          if (state is CategoryLoaded) {
            final categories = state.categories;
            final groups = state.groups;

            if (categories.isEmpty && groups.isEmpty) {
              return const Center(
                child: Text('No se encontraron categorías ni grupos.'),
              );
            }

            final filteredCategories = _selectedGroupId == null
                ? categories
                : categories
                      .where(
                        (c) =>
                            c.groupId == _selectedGroupId ||
                            c.group?.id == _selectedGroupId,
                      )
                      .toList();

            return ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                if (groups.isNotEmpty)
                  _GroupsList(
                    groups: groups,
                    selectedGroupId: _selectedGroupId,
                    onGroupSelected: (groupId) {
                      setState(() => _selectedGroupId = groupId);
                    },
                  ),
                const SizedBox(height: 20),
                if (filteredCategories.isNotEmpty)
                  _CategoryGrid(
                    categories: filteredCategories,
                    onCategoryTap: (category) {
                      context.read<RecipeBloc>().add(
                        LoadRecipesByCategory(category.id),
                      );
                      context.push(
                        '/categories/${category.id}',
                        extra: category,
                      );
                    },
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No se encontraron categorías para este grupo.',
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.onCategoryTap});

  final List<Category> categories;
  final void Function(Category category) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        mainAxisExtent: 150,
      ),
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () => onCategoryTap(category),
          child: Container(
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  spreadRadius: 0.3,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child:
                      category.imageUrl != null && category.imageUrl!.isNotEmpty
                      ? MyImageWidget(
                          image: RecipeImage(url: category.imageUrl!),
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.broken_image, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: category.name.length < 25 ? 15 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({
    required this.groups,
    required this.selectedGroupId,
    required this.onGroupSelected,
  });

  final List<CategoryGroup> groups;
  final int? selectedGroupId;
  final void Function(int? groupId) onGroupSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        itemCount: groups.length + 1,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedGroupId == null;
            return _GroupItem(
              label: 'Todas',
              icon: Icons.restaurant_menu,
              selected: isSelected,
              onTap: () => onGroupSelected(null),
            );
          }

          final group = groups[index - 1];
          final isSelected = selectedGroupId == group.id;
          return _GroupItem(
            label: group.name,
            imageUrl: group.imageUrl,
            selected: isSelected,
            onTap: () => onGroupSelected(group.id),
          );
        },
      ),
    );
  }
}

class _GroupItem extends StatelessWidget {
  const _GroupItem({
    required this.label,
    this.imageUrl,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? imageUrl;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: selected ? 6 : 3,
                  spreadRadius: selected ? 1 : 0.3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: selected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSecondary,
                        width: 3,
                      ),
                    )
                  : null,
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? MyImageWidget(
                        image: RecipeImage(url: imageUrl!),
                        width: 45,
                        height: 45,
                      )
                    : Icon(icon, color: Colors.black54, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 88,
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
