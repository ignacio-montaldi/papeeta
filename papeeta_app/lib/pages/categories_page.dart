import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/models/models.dart';
import 'package:papeeta/widgets/widgets.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    final categoryBloc = BlocProvider.of<CategoryBloc>(context, listen: false);
    categoryBloc.getCategoriesList();
    categoryBloc.getCategoriesGroupList();
  }

  @override
  Widget build(BuildContext context) {
    final categoryBloc = BlocProvider.of<CategoryBloc>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Categorías', style: const TextStyle(color: Colors.white)),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.only(top: 20),
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            final categories = state.categories;
            final groups = state.groups;

            if (categories == null || groups == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (categories.isEmpty && groups.isEmpty) {
              return const Center(
                child: Text('No se encontraron categorías ni grupos.'),
              );
            }

            return ListView(
              children: [
                if (groups.isNotEmpty) _GroupsList(groups: groups),
                const SizedBox(height: 20),
                if (categories.isNotEmpty)
                  _CategoryGrid(
                    categories: categories,
                    categoryBloc: categoryBloc,
                  )
                else
                  const Center(
                    child: Text(
                      'No se encontraron categorías para este grupo.',
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.categoryBloc});

  final List<CategoryModel> categories;
  final CategoryBloc categoryBloc;

  @override
  Widget build(BuildContext context) {
    final List<CategoryModel> filteredCategories = categories
        .where(
          (category) =>
              category.groupId ==
              (categoryBloc.state.groupId ?? category.groupId),
        )
        .toList();
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        mainAxisExtent: 200,
      ),
      padding: EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final categoryName = filteredCategories[index].name;
        final categoryImageUrl = filteredCategories[index].imageUrl;
        return GestureDetector(
          onTap: () {
            categoryBloc.add(
              SelectedCategory(category: filteredCategories[index]),
            );
            Navigator.pushNamed(context, 'recipeList');
          },
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
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 30),
                  child: categoryImageUrl != null
                      ? MyImageWidget(
                          image: MyImageModel(url: categoryImageUrl),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.broken_image, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                  child: Text(
                    categoryName,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: categoryName.length < 25 ? 15 : 14,
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

class _GroupsList extends StatefulWidget {
  final List<GroupModel> groups;

  const _GroupsList({required this.groups});

  @override
  State<_GroupsList> createState() => _GroupsListState();
}

class _GroupsListState extends State<_GroupsList> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups;

    return SizedBox(
      height: 156,
      child: ListView.separated(
        itemCount: groups.length + 1,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final bool isSelected = selectedIndex == index;

          if (index == 0) {
            return _GroupItem(
              label: 'Todas',
              icon: Icons.restaurant_menu,
              selected: isSelected,
              onTap: () {
                setState(() => selectedIndex = index);
              },
            );
          }

          final group = groups[index - 1];
          return _GroupItem(
            label: group.name,
            imageUrl: group.imageUrl,
            selected: isSelected,
            onTap: () {
              setState(() => selectedIndex = index);
              context.read<CategoryBloc>().add(
                FilterByGroup(groupId: group.id),
              );
            },
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
                radius: 50,
                backgroundColor: Colors.white,
                child: imageUrl != null
                    ? MyImageWidget(
                        image: MyImageModel(url: imageUrl!),
                        width: 65,
                        height: 65,
                      )
                    : Icon(icon, color: Colors.black54, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 110,
          child: Text(label, maxLines: 2, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
