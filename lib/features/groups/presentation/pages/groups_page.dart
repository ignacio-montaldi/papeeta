import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:papeeta/core/domain/entities/recipe_share_group.dart';
import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_event.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_state.dart';
import 'package:papeeta/features/groups/presentation/widgets/create_group_sheet.dart';
import 'package:papeeta/widgets/ds/ds.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis grupos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      // El teal es el acento de la feature Grupos: acá el FAB es secondary.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirCrearGrupo(context),
        backgroundColor: colors.secondary,
        foregroundColor: colors.onSecondary,
        tooltip: 'Crear grupo',
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocConsumer<GroupsBloc, GroupsState>(
        listener: (context, state) {
          if (state is GroupCreated) {
            context.read<GroupsBloc>().add(LoadMyGroups());
            showAppSnackBar(
              context,
              message: 'Grupo "${state.group.name}" creado',
              intent: SnackIntent.success,
            );
          }
          if (state is GroupsError) {
            showAppSnackBar(
              context,
              message: state.message,
              intent: SnackIntent.error,
              actionLabel: 'Reintentar',
              onAction: () => context.read<GroupsBloc>().add(LoadMyGroups()),
            );
          }
        },
        builder: (context, state) {
          if (state is GroupsLoading || state is GroupsInitial) {
            return const _GroupsSkeleton();
          }

          if (state is GroupsError) {
            return ErrorStateView(
              icon: Icons.cloud_off_rounded,
              title: 'No pudimos cargar tus grupos',
              message: 'Algo salió mal de nuestro lado. Probá de nuevo en un momento.',
              onRetry: () => context.read<GroupsBloc>().add(LoadMyGroups()),
            );
          }

          if (state is GroupsLoaded) {
            if (state.groups.isEmpty) {
              return EmptyStateView(
                icon: Icons.group_rounded,
                tone: EmptyStateTone.accent,
                title: 'Todavía no tenés grupos',
                message: 'Creá un grupo para compartir recetas con tu familia o amigos.',
                actionLabel: 'Crear grupo',
                actionIcon: Icons.group_add_rounded,
                onAction: () => _abrirCrearGrupo(context),
              );
            }
            return _GroupsList(groups: state.groups);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _abrirCrearGrupo(BuildContext context) {
    showAppBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<GroupsBloc>(),
        child: const CreateGroupSheet(),
      ),
    );
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({required this.groups});

  final List<RecipeShareGroup> groups;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl * 2,
      ),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final group = groups[index];
        return GroupCard(
          group: group,
          onTap: () => context.push('/groups/${group.id}'),
        );
      },
    );
  }
}

class _GroupsSkeleton extends StatelessWidget {
  const _GroupsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonized(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          GroupCardSkeleton(),
          SizedBox(height: AppSpacing.lg),
          GroupCardSkeleton(),
        ],
      ),
    );
  }
}
