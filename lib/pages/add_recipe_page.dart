import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/features/ingredients/presentation/bloc/ingredient_bloc.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient_unit.dart';
import 'package:papeeta/features/recipes/domain/entities/preparation_step.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_form/recipe_form_cubit.dart';
import 'package:papeeta/widgets/category_selector_sheet.dart';
import 'package:papeeta/widgets/ds/ds.dart';
import 'package:papeeta/widgets/image_source_sheet.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();

  List<IngredientUnit> _units = [];

  @override
  void initState() {
    super.initState();
    context.read<IngredientBloc>().add(LoadUnitsEvent());
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipeFormCubit, RecipeFormState>(
      listenWhen: (prev, curr) =>
          prev.submitSuccess != curr.submitSuccess ||
          prev.submitError != curr.submitError ||
          prev.errors != curr.errors,
      listener: (context, state) {
        if (state.submitSuccess) {
          showAppSnackBar(
            context,
            message: 'Receta guardada',
            intent: SnackIntent.success,
          );
          context.pop();
          return;
        }

        if (state.submitError != null) {
          showAppSnackBar(
            context,
            message: state.submitError!,
            intent: SnackIntent.error,
            actionLabel: 'Reintentar',
            onAction: () => context.read<RecipeFormCubit>().submit(),
          );
          return;
        }

        if (state.errors.isNotEmpty) {
          showAppSnackBar(
            context,
            message: 'Revisá los campos marcados',
            intent: SnackIntent.error,
          );
        }
      },
      child: BlocBuilder<RecipeFormCubit, RecipeFormState>(
        builder: (context, formState) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              final salir = await _confirmarSalida(context);
              if (salir && context.mounted) Navigator.of(context).pop();
            },
            child: Scaffold(
              appBar: _appBar(context, formState),
              body: SafeArea(
                child: Stack(
                  children: [
                    _contenido(formState),
                    if (formState.isSubmitting) _overlayGuardando(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, RecipeFormState formState) {
    final colors = context.colors;
    final vacio = formState.title.trim().isEmpty &&
        formState.ingredients.isEmpty &&
        formState.steps.isEmpty &&
        formState.images.isEmpty;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: formState.isSubmitting ? null : () => Navigator.maybePop(context),
        tooltip: 'Cancelar',
      ),
      title: const Text('Nueva receta'),
      actions: formState.isSubmitting
          ? const []
          : [
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'Vista previa',
                onPressed: () => _abrirPreview(context),
              ),
              TextButton(
                onPressed: () => context.read<RecipeFormCubit>().submit(),
                child: Text(
                  'Guardar',
                  style: AppTypography.button.copyWith(
                    fontSize: 14,
                    color: colors.onPrimary.withValues(alpha: vacio ? 0.5 : 1),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
    );
  }

  Widget _contenido(RecipeFormState formState) {
    return BlocBuilder<IngredientBloc, IngredientState>(
      builder: (context, state) {
        if (state is IngredientLoading || state is IngredientInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is IngredientError) {
          return ErrorStateView(
            title: 'No pudimos cargar las unidades',
            message: 'Sin ellas no se puede cargar una receta. Probá de nuevo.',
            onRetry: () => context.read<IngredientBloc>().add(LoadUnitsEvent()),
          );
        }

        if (state is! IngredientUnitsLoaded) return const SizedBox.shrink();
        _units = state.units;

        return AnimatedOpacity(
          duration: AppMotion.base,
          opacity: formState.isSubmitting ? 0.5 : 1,
          child: IgnorePointer(
            ignoring: formState.isSubmitting,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxxl * 2,
                ),
                children: [
                  _ImagesField(images: formState.images, error: formState.errors['images']),
                  const SizedBox(height: AppSpacing.lg),
                  _TitleField(error: formState.errors['title']),
                  const SizedBox(height: AppSpacing.lg),
                  const _SubtitleField(),
                  const SizedBox(height: AppSpacing.lg),
                  _SourceField(error: formState.errors['link']),
                  const SizedBox(height: AppSpacing.xl),
                  _CategoriesField(error: formState.errors['categories']),
                  const SizedBox(height: AppSpacing.xl),
                  _IngredientsSection(
                    ingredients: formState.ingredients,
                    uiKeys: formState.ingredientUiKeys,
                    units: _units,
                    errors: formState.errors,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _StepsSection(
                    steps: formState.steps,
                    uiKeys: formState.stepUiKeys,
                    errors: formState.errors,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _overlayGuardando() {
    return Positioned.fill(
      child: ColoredBox(
        color: context.colors.surface.withValues(alpha: 0.35),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppButton(
              label: 'Guardando receta…',
              isLoading: true,
              onPressed: null,
              height: AppSizes.buttonHeightLarge,
            ),
          ),
        ),
      ),
    );
  }

  void _abrirPreview(BuildContext context) {
    final cubit = context.read<RecipeFormCubit>();
    cubit.validateForm();
    if (!cubit.state.isValid) return;

    context.push(
      '/preview',
      extra: {
        'recipe': cubit.buildRecipe(),
        'images': cubit.state.images.map((img) => img.file).toList(),
      },
    );
  }
}

// ---------------------------------------------------------------- campos ---

class _TitleField extends StatelessWidget {
  const _TitleField({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Nombre de la receta',
      hint: 'Ej. Ñoquis de papa',
      errorText: error,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (value) => context.read<RecipeFormCubit>().setTitle(value),
    );
  }
}

class _SubtitleField extends StatelessWidget {
  const _SubtitleField();

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Subtítulo',
      hint: 'Ej. El clásico de los domingos',
      maxLines: 3,
      minLines: 1,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (value) =>
          context.read<RecipeFormCubit>().setDescription(value),
    );
  }
}

class _SourceField extends StatelessWidget {
  const _SourceField({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Fuente',
      hint: 'https://www.ejemplo.com',
      icon: Icons.link_rounded,
      keyboardType: TextInputType.url,
      errorText: error,
      onChanged: (value) => context.read<RecipeFormCubit>().setSourceLink(value),
    );
  }
}

/// Zona de fotos: recuadro punteado vacío, o fila de miniaturas + "agregar".
class _ImagesField extends StatelessWidget {
  const _ImagesField({required this.images, this.error});

  final List<dynamic> images;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantic = context.semantic;
    final hasError = error != null;

    void elegirFoto() {
      ImageSourceSheet.show(
        context,
        onImageSourceSelected: (source) =>
            context.read<RecipeFormCubit>().pickImage(source),
      );
    }

    if (images.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: elegirFoto,
            child: Container(
              height: 96,
              decoration: BoxDecoration(
                color: hasError ? AppColors.errorFieldFill : semantic.dashedFill,
                borderRadius: AppRadius.lgAll,
                border: Border.all(
                  color: hasError ? colors.error : semantic.dashedBorder,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 28,
                    color: hasError ? colors.error : colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.sm - 2),
                  Text(
                    error ?? 'Agregar foto',
                    style: AppTypography.label.copyWith(
                      fontSize: 12,
                      color: hasError ? colors.error : colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == images.length) {
            return GestureDetector(
              onTap: elegirFoto,
              child: Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: semantic.dashedFill,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: semantic.dashedBorder, width: 1.5),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 22,
                  color: colors.onSurfaceVariant,
                ),
              ),
            );
          }

          return _Thumbnail(
            file: images[index].file as File,
            onRemove: () => context.read<RecipeFormCubit>().removeImage(index),
          );
        },
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.file, required this.onRemove});

  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: AppRadius.mdAll,
          child: Image.file(file, width: 64, height: 64, fit: BoxFit.cover),
        ),
        Positioned(
          top: -5,
          right: -5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 13, color: colors.onError),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoriesField extends StatelessWidget {
  const _CategoriesField({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<RecipeFormCubit, RecipeFormState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Categorías',
              onAdd: () => _abrirSelector(context),
              addIcon: Icons.edit_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.categories.isEmpty)
              Text(
                'Elegí al menos una categoría',
                style: AppTypography.label.copyWith(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final category in state.categories)
                    AppChip(
                      label: category.name,
                      selected: true,
                      onTap: () => context
                          .read<RecipeFormCubit>()
                          .toggleCategory(category),
                    ),
                ],
              ),
            if (error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _FieldError(message: error!),
            ],
          ],
        );
      },
    );
  }

  void _abrirSelector(BuildContext context) {
    final cubit = context.read<RecipeFormCubit>();
    showAppBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const CategorySelectorSheet(),
      ),
    );
  }
}

// ----------------------------------------------------------- ingredientes --

class _IngredientsSection extends StatelessWidget {
  const _IngredientsSection({
    required this.ingredients,
    required this.uiKeys,
    required this.units,
    required this.errors,
  });

  final List<Ingredient> ingredients;
  final List<int> uiKeys;
  final List<IngredientUnit> units;
  final Map<String, String> errors;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<RecipeFormCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Ingredientes', onAdd: cubit.addIngredient),
        const SizedBox(height: AppSpacing.md),
        if (ingredients.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Sumá tu primer ingrediente',
                style: AppTypography.label.copyWith(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ingredients.length,
            onReorder: cubit.reorderIngredients,
            itemBuilder: (context, index) {
              return Padding(
                key: ValueKey(uiKeys[index]),
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _IngredientRow(
                  index: index,
                  ingredient: ingredients[index],
                  units: units,
                  amountError: errors['ingredient_amount_$index'],
                  unitError: errors['ingredient_unit_$index'],
                ),
              );
            },
          ),
        if (errors.containsKey('ingredients')) ...[
          const SizedBox(height: AppSpacing.sm),
          _FieldError(message: errors['ingredients']!),
        ],
      ],
    );
  }
}

/// Fila compacta: cantidad · unidad · nombre.
///
/// Se mantiene el reordenamiento que tenía la versión anterior, pero con
/// arrastre por pulsación larga en vez de un handle visible, para no romper la
/// fila compacta del diseño.
class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.index,
    required this.ingredient,
    required this.units,
    this.amountError,
    this.unitError,
  });

  final int index;
  final Ingredient ingredient;
  final List<IngredientUnit> units;
  final String? amountError;
  final String? unitError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<RecipeFormCubit>();
    final hasError = amountError != null || unitError != null;

    return ReorderableDelayedDragStartListener(
      index: index,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 52,
                child: _CompactField(
                  initialValue: ingredient.amount?.toString() ?? '',
                  hint: 'Cant.',
                  textAlign: TextAlign.center,
                  hasError: amountError != null,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) =>
                      cubit.updateIngredient(index, amount: double.tryParse(v)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm - 2),
              SizedBox(
                width: 72,
                child: _UnitDropdown(
                  units: units,
                  value: ingredient.unit,
                  hasError: unitError != null,
                  onChanged: (u) => cubit.updateIngredient(index, unit: u),
                ),
              ),
              const SizedBox(width: AppSpacing.sm - 2),
              Expanded(
                child: _CompactField(
                  initialValue: ingredient.name,
                  hint: 'Ingrediente',
                  onChanged: (v) => cubit.updateIngredient(index, name: v),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: colors.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
                onPressed: () => cubit.removeIngredient(index),
                tooltip: 'Quitar ingrediente',
              ),
            ],
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: _FieldError(message: (amountError ?? unitError)!),
            ),
        ],
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({
    required this.units,
    required this.value,
    required this.onChanged,
    this.hasError = false,
  });

  final List<IngredientUnit> units;
  final IngredientUnit? value;
  final ValueChanged<IngredientUnit?> onChanged;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: hasError ? AppColors.errorFieldFill : colors.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: hasError ? colors.error : colors.outlineVariant,
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<IngredientUnit>(
          value: value,
          isExpanded: true,
          isDense: true,
          hint: Text(
            'Un.',
            style: AppTypography.body.copyWith(
              fontSize: 13,
              color: colors.onSurfaceVariant,
            ),
          ),
          icon: Icon(
            Icons.expand_more_rounded,
            size: 16,
            color: colors.onSurfaceVariant,
          ),
          style: AppTypography.body.copyWith(
            fontSize: 13,
            color: colors.onSurface,
          ),
          // En la fila se muestra la abreviatura ("kg"); en el menú, el nombre
          // completo ("kilogramo"), que es lo que hace falta para elegir.
          selectedItemBuilder: (context) => [
            for (final unit in units)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  unit.key,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    color: colors.onSurface,
                  ),
                ),
              ),
          ],
          items: [
            for (final unit in units)
              DropdownMenuItem(value: unit, child: Text(unit.name)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ pasos --

class _StepsSection extends StatelessWidget {
  const _StepsSection({
    required this.steps,
    required this.uiKeys,
    required this.errors,
  });

  final List<PreparationStep> steps;
  final List<int> uiKeys;
  final Map<String, String> errors;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<RecipeFormCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Preparación', onAdd: cubit.addStep),
        const SizedBox(height: AppSpacing.md),
        if (steps.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Sumá el primer paso',
                style: AppTypography.label.copyWith(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            onReorder: cubit.reorderSteps,
            itemBuilder: (context, index) {
              return Padding(
                key: ValueKey(uiKeys[index]),
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _StepRow(
                  index: index,
                  step: steps[index],
                  error: errors['step_$index'],
                ),
              );
            },
          ),
        if (errors.containsKey('steps')) ...[
          const SizedBox(height: AppSpacing.sm),
          _FieldError(message: errors['steps']!),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.step, this.error});

  final int index;
  final PreparationStep step;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<RecipeFormCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // El número es también el asa de arrastre.
            ReorderableDragStartListener(
              index: index,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: AppSpacing.sm + 1),
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${step.order}',
                  style: AppTypography.label.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _CompactField(
                initialValue: step.description,
                hint: 'Describí el paso',
                maxLines: null,
                hasError: error != null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (v) => cubit.updateStep(index, v),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: colors.onSurfaceVariant,
              visualDensity: VisualDensity.compact,
              onPressed: () => cubit.removeStep(index),
              tooltip: 'Quitar paso',
            ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 30, top: AppSpacing.xs),
            child: _FieldError(message: error!),
          ),
      ],
    );
  }
}

// ----------------------------------------------------------- compartidos ---

/// Encabezado de sección con botón cuadrado de agregar.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onAdd,
    this.addIcon = Icons.add_rounded,
  });

  final String title;
  final VoidCallback onAdd;
  final IconData addIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.title.copyWith(
            fontSize: 16,
            color: colors.onSurface,
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Icon(addIcon, size: 19, color: colors.primary),
          ),
        ),
      ],
    );
  }
}

/// Campo de texto reducido para las filas de ingredientes y pasos.
class _CompactField extends StatelessWidget {
  const _CompactField({
    required this.initialValue,
    required this.onChanged,
    this.hint,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.maxLines = 1,
    this.hasError = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hint;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool hasError;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      textAlign: textAlign,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      style: AppTypography.body.copyWith(fontSize: 13, color: colors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body.copyWith(
          fontSize: 13,
          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        isDense: true,
        filled: true,
        fillColor: hasError ? AppColors.errorFieldFill : colors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: AppSpacing.sm + 2,
        ),
        border: _borde(colors.outlineVariant),
        enabledBorder: _borde(hasError ? colors.error : colors.outlineVariant),
        focusedBorder: _borde(hasError ? colors.error : colors.primary),
        errorStyle: const TextStyle(height: 0, fontSize: 0),
      ),
    );
  }

  OutlineInputBorder _borde(Color color) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(Icons.error_rounded, size: 14, color: colors.error),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            message,
            style: AppTypography.label.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: colors.error,
            ),
          ),
        ),
      ],
    );
  }
}

Future<bool> _confirmarSalida(BuildContext context) async {
  final salir = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Cancelar receta?'),
      content: const Text('Si salís ahora, se pierden los cambios.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Seguir editando'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Salir',
            style: TextStyle(color: context.colors.error),
          ),
        ),
      ],
    ),
  );

  return salir ?? false;
}
