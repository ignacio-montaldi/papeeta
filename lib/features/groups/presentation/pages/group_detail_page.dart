import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:papeeta/core/domain/entities/recipe_share_group.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_event.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_state.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe_image.dart';
import 'package:papeeta/widgets/widgets.dart';

class GroupDetailPage extends StatelessWidget {
  final int groupId;

  const GroupDetailPage({super.key, required this.groupId});

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
      body: BlocBuilder<GroupsBloc, GroupsState>(
        builder: (context, state) {
          if (state is GroupsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GroupDetailLoaded) {
            return _GroupDetailContent(group: state.group);
          }

          if (state is GroupsError) {
            return Center(child: Text(state.message));
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(group: group),
          const SizedBox(height: 24),
          _MembersSection(
            members: group.members,
            owner: group.owner,
            groupId: group.id ?? 0,
          ),
          const SizedBox(height: 24),
          _RecipesSection(recipes: group.recipes),
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

  const _MembersSection({
    required this.members,
    required this.owner,
    required this.groupId,
  });

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
          runSpacing: 8,
          children: [
            _MemberChip(name: owner.name, isOwner: true),
            ...members.where((m) => m.id != owner.id).map(
              (m) => _MemberChip(
                name: m.name,
                isOwner: false,
                onRemove: () => context.read<GroupsBloc>().add(
                  RemoveMemberFromGroup(groupId: groupId, userId: m.id),
                ),
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
            hintText: 'Ingresa el email del usuario',
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
                    email: controller.text.trim(),
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

  const _RecipesSection({required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recetas Compartidas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
              return ListTile(
                leading: recipe.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: MyImageWidget(
                          image: RecipeImage(url: recipe.images.first.url),
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.restaurant),
                      ),
                title: Text(recipe.title),
                subtitle: Text(recipe.subtitle ?? ''),
                onTap: () => context.push('/recipe/${recipe.id}'),
              );
            },
          ),
      ],
    );
  }
}
