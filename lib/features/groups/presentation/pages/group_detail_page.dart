import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:papeeta/core/domain/entities/recipe_share_group.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_event.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_state.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe_image.dart';
import 'package:papeeta/widgets/widgets.dart';

class GroupDetailPage extends StatefulWidget {
  final int groupId;

  const GroupDetailPage({super.key, required this.groupId});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  RecipeShareGroup? _lastGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupo', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<GroupsBloc, GroupsState>(
        listener: (context, state) {
          if (state is GroupDetailLoaded) {
            setState(() {
              _lastGroup = state.group;
            });
          }
        },
        builder: (context, state) {
          if (state is GroupsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GroupDetailLoaded) {
            return _GroupDetailContent(group: state.group);
          }

          if (state is UserRecipesLoaded && _lastGroup != null) {
            return _GroupDetailContent(group: _lastGroup!);
          }

          if (state is GroupsError) {
            return Center(child: Text(state.message));
          }

          if (_lastGroup != null) {
            return _GroupDetailContent(group: _lastGroup!);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _GroupDetailContent extends StatelessWidget {
  final RecipeShareGroup group;

  const _GroupDetailContent({required this.group});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.id : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(group: group),
          _MembersSection(
            members: group.members,
            owner: group.owner,
            groupId: group.id ?? 0,
            currentUserId: currentUserId,
            ownerId: group.owner?.id ?? '',
          ),
          const SizedBox(height: 8),
          _RecipesSection(recipes: group.recipes, groupId: group.id ?? 0),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final RecipeShareGroup group;

  const _HeaderSection({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (group.imageUrl != null && group.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: MyImageWidget(
              image: RecipeImage(url: group.imageUrl!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.group,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          group.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (group.description != null && group.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            group.description!,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}

class _MembersSection extends StatelessWidget {
  final List<dynamic> members;
  final dynamic owner;
  final int groupId;
  final String currentUserId;
  final String ownerId;

  const _MembersSection({
    required this.members,
    required this.owner,
    required this.groupId,
    required this.currentUserId,
    required this.ownerId,
  });

  bool get _isOwner => currentUserId == ownerId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Miembros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (_isOwner)
              TextButton.icon(
                onPressed: () => _showAddMemberDialog(context),
                icon: const Icon(Icons.person_add, size: 20),
                label: const Text('Agregar'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _MemberChip(
              name: owner.alias ?? owner.nombreUsuario,
              isOwner: true,
            ),
            ...members
                .where((m) => m.id != owner.id)
                .map(
                  (m) => _MemberChip(
                    name: m.alias ?? m.nombreUsuario,
                    isOwner: false,
                    onRemove: _isOwner ? () => _showRemoveMemberDialog(context, m) : null,
                  ),
                ),
          ],
        ),
      ],
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Agregar miembro'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ingresa el nombre de usuario',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<GroupsBloc>().add(
                  AddMemberToGroup(
                    groupId: groupId,
                    nombreUsuario: controller.text.trim(),
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, dynamic member) {
    final memberName = member.alias ?? member.nombreUsuario;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a $memberName del grupo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GroupsBloc>().add(
                RemoveMemberFromGroup(groupId: groupId, userId: member.id),
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  final String name;
  final bool isOwner;
  final VoidCallback? onRemove;

  const _MemberChip({required this.name, required this.isOwner, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: isOwner
            ? Theme.of(context).colorScheme.secondary
            : Colors.grey[400],
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      label: Text(name),
      deleteIcon: onRemove != null ? const Icon(Icons.close, size: 18) : null,
      onDeleted: onRemove,
    );
  }
}

class _RecipesSection extends StatelessWidget {
  final List<dynamic> recipes;
  final int groupId;

  const _RecipesSection({required this.recipes, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recetas Compartidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: () => _showAddRecipeSheet(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recipes.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay recetas compartidas',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final imageUrl = recipe.images.isNotEmpty
                  ? recipe.images.first.url
                  : '';
              return GestureDetector(
                onTap: () => context.push('/recipe/${recipe.id}'),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 240, 240, 240),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: recipe.images.isNotEmpty
                                ? MyImageWidget(
                                    image: RecipeImage(url: imageUrl),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.restaurant,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                        Text(
                          recipe.categories
                              .map((category) => category.name)
                              .toList()
                              .join(' | '),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff999999),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          recipe.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAddRecipeSheet(BuildContext context) {
    context.read<GroupsBloc>().add(LoadUserRecipes());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GroupsBloc>(),
        child: _RecipeSelectorSheet(
          groupId: groupId,
          existingRecipeIds: recipes.map((r) => r.id as int).toList(),
        ),
      ),
    );
  }
}

class _RecipeSelectorSheet extends StatefulWidget {
  final int groupId;
  final List<int> existingRecipeIds;

  const _RecipeSelectorSheet({
    required this.groupId,
    required this.existingRecipeIds,
  });

  @override
  State<_RecipeSelectorSheet> createState() => _RecipeSelectorSheetState();
}

class _RecipeSelectorSheetState extends State<_RecipeSelectorSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        List<Recipe> allRecipes = [];
        if (state is UserRecipesLoaded) {
          allRecipes = state.recipes;
        }

        final filteredRecipes = allRecipes.where((recipe) {
          final isNotInGroup = !widget.existingRecipeIds.contains(recipe.id);
          final matchesSearch =
              _searchQuery.isEmpty ||
              recipe.title.toLowerCase().contains(_searchQuery.toLowerCase());
          return isNotInGroup && matchesSearch;
        }).toList();

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 1,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Agregar Receta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'Buscar recetas...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: state is UserRecipesLoaded
                        ? filteredRecipes.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 48,
                                        color: Colors.green[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Todas tus recetas ya están en el grupo',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  controller: scrollController,
                                  itemCount: filteredRecipes.length,
                                  itemBuilder: (context, index) {
                                    final recipe = filteredRecipes[index];
                                    return ListTile(
                                      leading: recipe.images.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: MyImageWidget(
                                                image: RecipeImage(
                                                  url: recipe.images.first.url,
                                                ),
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.restaurant,
                                              ),
                                            ),
                                      title: Text(recipe.title),
                                      subtitle: recipe.subtitle.isNotEmpty
                                          ? Text(
                                              recipe.subtitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : null,
                                      onTap: () {
                                        context.read<GroupsBloc>().add(
                                          ShareRecipeToGroup(
                                            groupId: widget.groupId,
                                            recipeId: recipe.id,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
