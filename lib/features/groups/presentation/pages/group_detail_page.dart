import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:papeeta/core/domain/entities/recipe_share_group.dart';
import 'package:papeeta/core/theme/theme.dart';
// Ojo: los miembros de un grupo son el `User` de auth (el que sí trae
// `imagenPerfil`), no el de `core/` que usa `Recipe.author`. Son dos clases
// distintas con el mismo nombre.
import 'package:papeeta/features/auth/domain/entities/user.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/global/enviroment.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_event.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_state.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/widgets/ds/ds.dart';
import 'package:papeeta/widgets/image_source_sheet.dart';
import 'package:papeeta/widgets/my_image_widget.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key, required this.groupId});

  final int groupId;

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  /// El bloc emite `UserRecipesLoaded` al abrir el selector de recetas, que no
  /// trae el grupo. Se cachea el último para no vaciar la pantalla.
  RecipeShareGroup? _ultimoGrupo;

  void _cargar() {
    context.read<GroupsBloc>().add(LoadGroupDetail(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<GroupsBloc, GroupsState>(
        listener: (context, state) {
          if (state is GroupDetailLoaded) {
            setState(() => _ultimoGrupo = state.group);
          }
        },
        builder: (context, state) {
          if (state is GroupDetailLoaded) {
            return _Contenido(group: state.group);
          }

          if (_ultimoGrupo != null) {
            return _Contenido(group: _ultimoGrupo!);
          }

          if (state is GroupsError) {
            return ErrorStateView(
              icon: Icons.cloud_off_rounded,
              title: 'No pudimos abrir el grupo',
              message: 'Puede que ya no exista o que se haya perdido la conexión.',
              onRetry: _cargar,
              onSecondary: () => context.pop(),
              secondaryLabel: 'Volver',
            );
          }

          return const _DetailSkeleton();
        },
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.group});

  final RecipeShareGroup group;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.id : '';
    final isOwner = currentUserId == (group.owner?.id ?? '');
    final groupId = group.id ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: [
        _Header(group: group, isOwner: isOwner),
        const SizedBox(height: AppSpacing.xl),
        _MembersSection(
          members: group.members,
          owner: group.owner,
          groupId: groupId,
          isOwner: isOwner,
        ),
        const SizedBox(height: AppSpacing.xl),
        _RecipesSection(recipes: group.recipes, groupId: groupId),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.group, required this.isOwner});

  final RecipeShareGroup group;
  final bool isOwner;

  Future<void> _cambiarPortada(BuildContext context) async {
    final bloc = context.read<GroupsBloc>();
    final groupId = group.id ?? 0;

    await ImageSourceSheet.show(
      context,
      onImageSourceSelected: (source) async {
        final picked = await ImagePicker().pickImage(
          source: source,
          imageQuality: 80,
        );
        if (picked == null) return;
        bloc.add(UpdateGroupImage(groupId: groupId, imagePath: picked.path));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasImage = group.images.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: AppRadius.lgAll,
              child: SizedBox(
                height: hasImage ? 180 : 120,
                width: double.infinity,
                child: hasImage
                    ? MyImageWidget(
                        image: group.images.first,
                        fit: BoxFit.cover,
                      )
                    : ColoredBox(
                        color: colors.primaryContainer,
                        child: Center(
                          child: Icon(
                            Icons.group_rounded,
                            size: 56,
                            color: context.semantic.emptyIcon,
                          ),
                        ),
                      ),
              ),
            ),
            if (isOwner)
              Positioned(
                bottom: AppSpacing.sm,
                right: AppSpacing.sm,
                child: GestureDetector(
                  onTap: () => _cambiarPortada(context),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: AppElevation.e1,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          group.name,
          style: AppTypography.headline.copyWith(color: colors.onSurface),
        ),
        if (group.description != null && group.description!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            group.description!,
            style: AppTypography.body.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

// -------------------------------------------------------------- miembros ---

class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.members,
    required this.owner,
    required this.groupId,
    required this.isOwner,
  });

  final List<User> members;
  final User? owner;
  final int groupId;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final otros = members.where((m) => m.id != owner?.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Miembros',
          actionLabel: isOwner ? 'Agregar' : null,
          actionIcon: Icons.person_add_rounded,
          onAction: isOwner ? () => _agregarMiembro(context) : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (owner != null)
              _MemberChip(
                name: owner!.alias ?? owner!.nombreUsuario,
                imagenPerfil: owner!.imagenPerfil,
                isOwner: true,
              ),
            for (final member in otros)
              _MemberChip(
                name: member.alias ?? member.nombreUsuario,
                imagenPerfil: member.imagenPerfil,
                isOwner: false,
                onRemove: isOwner
                    ? () => _quitarMiembro(context, member)
                    : null,
              ),
          ],
        ),
      ],
    );
  }

  void _agregarMiembro(BuildContext context) {
    final controller = TextEditingController();
    final bloc = context.read<GroupsBloc>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Agregar miembro'),
        content: AppTextField(
          label: 'Nombre de usuario',
          hint: 'Ej. sofia',
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nombre = controller.text.trim();
              if (nombre.isEmpty) return;
              bloc.add(
                AddMemberToGroup(groupId: groupId, nombreUsuario: nombre),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _quitarMiembro(BuildContext context, User member) {
    final nombre = member.alias ?? member.nombreUsuario;
    final bloc = context.read<GroupsBloc>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quitar miembro'),
        content: Text('¿Seguro que querés quitar a $nombre del grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              bloc.add(
                RemoveMemberFromGroup(groupId: groupId, userId: member.id),
              );
              Navigator.pop(dialogContext);
            },
            child: Text(
              'Quitar',
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({
    required this.name,
    required this.isOwner,
    this.imagenPerfil,
    this.onRemove,
  });

  final String name;
  final bool isOwner;
  final String? imagenPerfil;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xs,
        right: onRemove != null ? AppSpacing.xs : AppSpacing.md,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isOwner ? colors.secondaryContainer : colors.surfaceContainer,
        borderRadius: AppRadius.fullAll,
        border: Border.all(
          color: isOwner ? colors.secondary : colors.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAvatar(
            name: name,
            size: 26,
            imageUrl: imagenPerfil == null || imagenPerfil!.isEmpty
                ? null
                : '${Enviroment.uploadsUrl}$imagenPerfil',
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            name,
            style: AppTypography.label.copyWith(
              fontWeight: isOwner ? FontWeight.w600 : FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
          if (isOwner) ...[
            const SizedBox(width: 5),
            Text(
              '· dueño',
              style: AppTypography.label.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- recetas ---

class _RecipesSection extends StatelessWidget {
  const _RecipesSection({required this.recipes, required this.groupId});

  final List<Recipe> recipes;
  final int groupId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Recetas compartidas',
          actionLabel: 'Agregar',
          actionIcon: Icons.add_rounded,
          onAction: () => _abrirSelector(context),
        ),
        const SizedBox(height: AppSpacing.md),
        if (recipes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: AppRadius.lgAll,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.restaurant_menu_rounded,
                  size: 40,
                  color: context.semantic.emptyIcon,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Todavía no hay recetas acá',
                  style: AppTypography.label.copyWith(
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          for (final recipe in recipes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Dismissible(
                key: ValueKey(recipe.id),
                direction: DismissDirection.endToStart,
                background: _FondoEliminar(),
                confirmDismiss: (_) => _confirmarQuitar(context, recipe),
                onDismissed: (_) => context.read<GroupsBloc>().add(
                      RemoveRecipeFromGroup(
                        groupId: groupId,
                        recipeId: recipe.id,
                      ),
                    ),
                child: RecipeCard(
                  recipe: recipe,
                  onTap: () => context.push('/recipe/${recipe.id}'),
                ),
              ),
            ),
      ],
    );
  }

  Future<bool> _confirmarQuitar(BuildContext context, Recipe recipe) async {
    final quitar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quitar receta'),
        content: Text('¿Seguro que querés quitar "${recipe.title}" del grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Quitar',
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );

    return quitar ?? false;
  }

  void _abrirSelector(BuildContext context) {
    final bloc = context.read<GroupsBloc>()..add(LoadUserRecipes());

    showAppBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _RecipeSelectorSheet(
          groupId: groupId,
          existingRecipeIds: recipes.map((r) => r.id).toList(),
        ),
      ),
    );
  }
}

class _FondoEliminar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: AppRadius.lgAll,
      ),
      child: Icon(Icons.delete_rounded, color: colors.onError, size: 26),
    );
  }
}

class _RecipeSelectorSheet extends StatefulWidget {
  const _RecipeSelectorSheet({
    required this.groupId,
    required this.existingRecipeIds,
  });

  final int groupId;
  final List<int> existingRecipeIds;

  @override
  State<_RecipeSelectorSheet> createState() => _RecipeSelectorSheetState();
}

class _RecipeSelectorSheetState extends State<_RecipeSelectorSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBottomSheet(
      title: 'Agregar receta',
      onClose: () => Navigator.pop(context),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Column(
          children: [
            AppSearchField(
              hint: 'Buscar en tus recetas…',
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: BlocBuilder<GroupsBloc, GroupsState>(
                builder: (context, state) {
                  if (state is! UserRecipesLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final disponibles = state.recipes.where((recipe) {
                    final noEstaEnGrupo =
                        !widget.existingRecipeIds.contains(recipe.id);
                    final coincide = _query.isEmpty ||
                        recipe.title
                            .toLowerCase()
                            .contains(_query.toLowerCase());
                    return noEstaEnGrupo && coincide;
                  }).toList();

                  if (disponibles.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 44,
                              color: context.semantic.success,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _query.isEmpty
                                  ? 'Todas tus recetas ya están en el grupo'
                                  : 'Sin resultados para "$_query"',
                              textAlign: TextAlign.center,
                              style: AppTypography.body.copyWith(
                                fontSize: 14,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: disponibles.length,
                    separatorBuilder: (_, __) => const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    itemBuilder: (context, index) {
                      final recipe = disponibles[index];
                      return _RecipeOption(
                        recipe: recipe,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeOption extends StatelessWidget {
  const _RecipeOption({required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadius.smAll,
              child: SizedBox(
                width: 52,
                height: 52,
                child: recipe.images.isNotEmpty
                    ? MyImageWidget(
                        image: recipe.images.first,
                        fit: BoxFit.cover,
                      )
                    : ColoredBox(
                        color: colors.primaryContainer,
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          color: context.semantic.emptyIcon,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  if (recipe.subtitle.isNotEmpty)
                    Text(
                      recipe.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w400,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.add_circle_outline_rounded,
              color: colors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------- compartidos ---

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.title.copyWith(color: colors.onSurface),
        ),
        if (actionLabel != null && onAction != null)
          TextButton.icon(
            onPressed: onAction,
            icon: Icon(actionIcon, size: 18),
            label: Text(actionLabel!),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              textStyle: AppTypography.button.copyWith(fontSize: 14),
            ),
          ),
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonized(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SkeletonBox(height: 180, borderRadius: AppRadius.lgAll),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonBox.line(width: 180, height: 20),
          const SizedBox(height: AppSpacing.md),
          const SkeletonBox.line(width: 240, height: 12),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: const [
              SkeletonBox(width: 110, height: 34, borderRadius: AppRadius.fullAll),
              SizedBox(width: AppSpacing.sm),
              SkeletonBox(width: 96, height: 34, borderRadius: AppRadius.fullAll),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const RecipeCardSkeleton(),
        ],
      ),
    );
  }
}
