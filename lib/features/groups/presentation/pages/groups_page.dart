import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:papeeta/core/domain/entities/recipe_share_group.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_event.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_state.dart';
import 'package:papeeta/features/groups/presentation/widgets/group_card.dart';
import 'package:papeeta/features/groups/presentation/widgets/create_group_sheet.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Grupos', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupSheet(context),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<GroupsBloc, GroupsState>(
        listener: (context, state) {
          if (state is GroupCreated) {
            context.read<GroupsBloc>().add(LoadMyGroups());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Grupo "${state.group.name}" creado')),
            );
          }
          if (state is GroupsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is GroupsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GroupsLoaded) {
            if (state.groups.isEmpty) {
              return _EmptyState(
                onCreateTap: () => _showCreateGroupSheet(context),
              );
            }
            return _GroupsList(groups: state.groups);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GroupsBloc>(),
        child: const CreateGroupSheet(),
      ),
    );
  }
}

class _GroupsList extends StatelessWidget {
  final List<RecipeShareGroup> groups;

  const _GroupsList({required this.groups});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GroupCard(
            group: group,
            onTap: () => context.push('/groups/${group.id}'),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;

  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tienes grupos aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea un grupo para compartir recetas con amigos',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add),
            label: const Text('Crear Grupo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
