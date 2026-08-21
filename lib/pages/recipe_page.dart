import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:papeeta/core/domain/entities/user.dart';
import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient.dart';
import 'package:papeeta/features/recipes/domain/entities/preparation_step.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:papeeta/helpers/helpers.dart';
import 'package:papeeta/widgets/ds/ds.dart';
import 'package:papeeta/widgets/my_image_widget.dart';

/// Regla de color de los títulos de sección ("Ingredientes", "Preparación").
///
/// La Fase 1 y la Fase 2 del diseño se contradicen acá:
///  · Fase 1 (decisión "El teal tiene una regla") dice explícitamente que los
///    títulos de sección **dejan de ser teal**, para que el acento tenga un
///    único rol: acciones secundarias, links y la feature Grupos.
///  · Fase 2 los dibuja en teal.
///
/// Se implementa la regla del sistema (Fase 1) por ser la normativa. Poner esto
/// en `true` vuelve al teal del mockup.
const bool _seccionesEnTeal = false;

class RecipePage extends StatefulWidget {
  const RecipePage({
    super.key,
    this.recipeId,
    this.previewRecipe,
    this.previewImages = const [],
  }) : assert(
         (recipeId != null) != (previewRecipe != null),
         'Debes enviar recipeId o previewRecipe',
       );

  final int? recipeId;
  final Recipe? previewRecipe;
  final List<File> previewImages;

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  @override
  void initState() {
    super.initState();
    if (widget.recipeId != null) _cargar();
  }

  void _cargar() {
    context.read<RecipeBloc>().add(LoadRecipeDetail(widget.recipeId!));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.previewRecipe != null) {
      return Scaffold(
        body: _RecipeContent(
          recipe: widget.previewRecipe!,
          previewImages: widget.previewImages,
        ),
      );
    }

    return Scaffold(
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeDetailLoading ||
              state is RecipeInitial ||
              state is RecipeListLoading) {
            return const _RecipeSkeleton();
          }

          if (state is RecipeError) {
            return SafeArea(
              child: ErrorStateView(
                icon: Icons.error_outline_rounded,
                title: 'No pudimos abrir la receta',
                message:
                    'Puede que ya no exista o que se haya perdido la conexión.',
                onRetry: _cargar,
                onSecondary: () => context.pop(),
                secondaryLabel: 'Volver',
              ),
            );
          }

          if (state is RecipeDetailLoaded) {
            return _RecipeContent(recipe: state.recipe);
          }

          return const _RecipeSkeleton();
        },
      ),
    );
  }
}

class _RecipeContent extends StatelessWidget {
  const _RecipeContent({required this.recipe, this.previewImages = const []});

  final Recipe recipe;
  final List<File> previewImages;

  bool get _incompleta => recipe.ingredients.isEmpty && recipe.steps.isEmpty;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: AppSizes.recipeHeaderHeight,
          backgroundColor: context.colors.primary,
          foregroundColor: context.colors.onPrimary,
          automaticallyImplyLeading: false,
          leading: const _CircleBackButton(),
          flexibleSpace: _PhotoHeader(
            recipe: recipe,
            previewImages: previewImages,
          ),
        ),
        if (_incompleta)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: const EmptyStateView(
                icon: Icons.receipt_long_rounded,
                title: 'Esta receta está incompleta',
                message: 'Todavía no tiene ingredientes ni pasos cargados.',
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recipe.categories.isNotEmpty) ...[
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        for (final category in recipe.categories)
                          AppCategoryChip(label: category.name),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (recipe.ingredients.isNotEmpty) ...[
                    const _SectionTitle('Ingredientes'),
                    const SizedBox(height: AppSpacing.sm),
                    _IngredientList(ingredients: recipe.ingredients),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (recipe.steps.isNotEmpty) ...[
                    const _SectionTitle('Preparación'),
                    const SizedBox(height: AppSpacing.sm),
                    _StepList(steps: recipe.steps),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  const _SectionTitle('Fuente'),
                  const SizedBox(height: AppSpacing.sm),
                  _SourceLink(link: recipe.link),
                  if (recipe.author != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    _AuthorRow(author: recipe.author!),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Header de foto: carrusel, degradado y título sobre la imagen.
class _PhotoHeader extends StatefulWidget {
  const _PhotoHeader({required this.recipe, required this.previewImages});

  final Recipe recipe;
  final List<File> previewImages;

  @override
  State<_PhotoHeader> createState() => _PhotoHeaderState();
}

class _PhotoHeaderState extends State<_PhotoHeader> {
  int _current = 0;

  int get _count => widget.previewImages.isNotEmpty
      ? widget.previewImages.length
      : widget.recipe.images.length;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,
      stretchModes: const [StretchMode.zoomBackground],
      background: Stack(
        fit: StackFit.expand,
        children: [
          if (_count == 0)
            ColoredBox(
              color: colors.primaryContainer,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_rounded,
                  size: 46,
                  color: context.semantic.emptyIcon,
                ),
              ),
            )
          else
            CarouselSlider.builder(
              itemCount: _count,
              itemBuilder: (context, index, _) {
                if (widget.previewImages.isNotEmpty) {
                  return SizedBox.expand(
                    child: Image.file(
                      widget.previewImages[index],
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return SizedBox.expand(
                  child: MyImageWidget(
                    image: widget.recipe.images[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1,
                scrollPhysics: const BouncingScrollPhysics(),
                onPageChanged: (index, _) => setState(() => _current = index),
              ),
            ),

          // Degradado: oscurece arriba para el botón de volver y abajo para el
          // título, dejando el centro de la foto limpio.
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x59140A16),
                    Color(0x00140A16),
                    Color(0x00140A16),
                    Color(0xC7140A16),
                  ],
                  stops: [0, 0.3, 0.55, 1],
                ),
              ),
            ),
          ),

          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.recipe.title,
                  style: AppTypography.headline.copyWith(color: Colors.white),
                ),
                if (widget.recipe.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    widget.recipe.subtitle,
                    style: AppTypography.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (_count > 1)
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _count; i++)
                    AnimatedContainer(
                      duration: AppMotion.emphasized,
                      curve: AppMotion.standard,
                      width: _current == i ? 9 : 7,
                      height: _current == i ? 9 : 7,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == i
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Botón de volver sobre la foto: círculo blanco translúcido.
class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Text(
      title,
      style: AppTypography.title.copyWith(
        color: _seccionesEnTeal ? colors.secondary : colors.onSurface,
      ),
    );
  }
}

class _IngredientList extends StatelessWidget {
  const _IngredientList({required this.ingredients});

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final ingredient in ingredients)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text.rich(
              _spans(ingredient),
              style: AppTypography.body.copyWith(color: colors.onSurface),
            ),
          ),
      ],
    );
  }

  /// "• **4 unid.** de milanesas" — cantidad y unidad en negrita.
  ///
  /// Mantiene las reglas de formato existentes: si no hay ni cantidad ni
  /// unidad, el nombre del ingrediente se capitaliza.
  TextSpan _spans(Ingredient ingredient) {
    final buffer = StringBuffer('• ');
    final hasAmount = ingredient.amount != null && ingredient.amount != 0;
    final unit = ingredient.unit;
    // La unidad 11 es "unidad": no se escribe.
    final hasUnit = unit != null && unit.id != 11;

    if (hasAmount) buffer.write(formatDouble(ingredient.amount ?? 0));
    if (hasUnit) {
      buffer.write(' ${unit.key}');
      if (hasAmount && ingredient.amount != 1) buffer.write('s');
    }

    final bold = buffer.toString();
    final rest = StringBuffer();

    if (hasAmount) rest.write(' ');
    if (hasUnit && unit.name.isNotEmpty) rest.write('de ');

    final sinMedida = bold == '• ';
    rest.write(sinMedida ? ingredient.name.capitalize() : ingredient.name);

    return TextSpan(
      children: [
        TextSpan(
          text: bold,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(text: rest.toString()),
      ],
    );
  }
}

class _StepList extends StatelessWidget {
  const _StepList({required this.steps});

  final List<PreparationStep> steps;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final step in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${step.order}. ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: step.description),
                ],
              ),
              style: AppTypography.body.copyWith(color: colors.onSurface),
            ),
          ),
      ],
    );
  }
}

class _SourceLink extends StatelessWidget {
  const _SourceLink({required this.link});

  final String? link;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (link == null || link!.isEmpty) {
      return Text(
        'Es una receta original. Si te la pasaron, acordate de agradecer.',
        style: AppTypography.body.copyWith(color: colors.onSurfaceVariant),
      );
    }

    return GestureDetector(
      onTap: () => launchUrl(link!),
      child: Text(
        link!,
        style: AppTypography.body.copyWith(
          color: colors.secondary,
          decoration: TextDecoration.underline,
          decorationColor: colors.secondary,
        ),
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.author});

  final User author;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = author.alias ?? author.nombreUsuario;

    return Row(
      children: [
        AppAvatar(name: name, size: 32),
        const SizedBox(width: AppSpacing.md - 3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTypography.label.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            Text(
              '@${author.nombreUsuario} · autor/a',
              style: AppTypography.label.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecipeSkeleton extends StatelessWidget {
  const _RecipeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonized(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 230, borderRadius: BorderRadius.zero),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    SkeletonBox(
                      width: 64,
                      height: 26,
                      borderRadius: AppRadius.fullAll,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    SkeletonBox(
                      width: 80,
                      height: 26,
                      borderRadius: AppRadius.fullAll,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg + 2),
                const SkeletonBox.line(width: 130, height: 16),
                const SizedBox(height: AppSpacing.md),
                for (final width in const [0.88, 0.80, 0.84]) ...[
                  FractionallySizedBox(
                    widthFactor: width,
                    alignment: Alignment.centerLeft,
                    child: const SkeletonBox.line(height: 11),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.sm),
                const SkeletonBox.line(width: 110, height: 16),
                const SizedBox(height: AppSpacing.md),
                for (final width in const [0.92, 0.78]) ...[
                  FractionallySizedBox(
                    widthFactor: width,
                    alignment: Alignment.centerLeft,
                    child: const SkeletonBox.line(height: 11),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
