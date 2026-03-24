import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:papeeta/features/ingredients/presentation/bloc/ingredient_bloc.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_form/recipe_form_cubit.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient_unit.dart';
import 'package:papeeta/features/recipes/domain/entities/preparation_step.dart';
import 'package:papeeta/pages/recipe_page.dart';
import 'package:papeeta/widgets/category_selector_sheet.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();

  List<IngredientUnit> units = [];

  @override
  void initState() {
    context.read<IngredientBloc>().add(LoadUnitsEvent());
    context.read<CategoryBloc>().add(const LoadCategories());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipeFormCubit, RecipeFormState>(
      listenWhen: (prev, curr) =>
          prev.submitSuccess != curr.submitSuccess ||
          prev.submitError != curr.submitError,
      listener: (context, state) {
        if (state.submitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receta guardada correctamente')),
          );

          Navigator.pop(context);
        }

        if (state.submitError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.submitError!)));
        }
      },
      child: BlocBuilder<RecipeFormCubit, RecipeFormState>(
        builder: (context, formState) {
          return Stack(
            children: [
              PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) async {
                  if (didPop) return;

                  final shouldExit = await _showExitDialog(context);
                  if (shouldExit && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Agregar receta'),
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),

                  body: SafeArea(
                    child: BlocBuilder<IngredientBloc, IngredientState>(
                      builder: (context, state) {
                        if (state is IngredientLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is IngredientUnitsLoaded) {
                          units = state.units;

                          return Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _RecipeName(),
                                  const SizedBox(height: 20),
                                  const _RecipeSubtitle(),
                                  const SizedBox(height: 20),
                                  const _RecipeSourceLink(),
                                  const SizedBox(height: 20),
                                  const _RecipeCategoriesField(),
                                  const SizedBox(height: 20),
                                  BlocBuilder<RecipeFormCubit, RecipeFormState>(
                                    builder: (context, state) {
                                      return _RecipeIngredients(
                                        ingredients: state.ingredients,
                                        ingredientUiKeys: state.ingredientUiKeys,
                                        units: units,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  BlocBuilder<RecipeFormCubit, RecipeFormState>(
                                    builder: (context, state) {
                                      return _RecipeSteps(
                                        steps: state.steps,
                                        stepUiKeys: state.stepUiKeys,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  BlocBuilder<RecipeFormCubit, RecipeFormState>(
                                    builder: (context, state) {
                                      if (state.images.isEmpty) {
                                        return const SizedBox();
                                      }

                                      return SizedBox(
                                        height: 110,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: state.images.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 12),
                                          itemBuilder: (context, index) {
                                            return _ImageThumbnail(
                                              image: state.images[index].file,
                                              onRemove: () => context
                                                  .read<RecipeFormCubit>()
                                                  .removeImage(index),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  BlocBuilder<RecipeFormCubit, RecipeFormState>(
                                    builder: (context, state) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (state.errors.containsKey('images'))
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              child: Text(
                                                state.errors['images']!,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          OutlinedButton.icon(
                                            onPressed: () =>
                                                _showImageSourceSheet(context),
                                            icon: const Icon(
                                              Icons.add_a_photo_outlined,
                                            ),
                                            label: const Text('Agregar imagen'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                              side: BorderSide(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary,
                                              ),
                                              minimumSize: const Size(
                                                double.infinity,
                                                50,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (state is IngredientError) {
                          return Text('Error: ${state.message}');
                        }
                        return const Text('Error inesperado');
                      },
                    ),
                  ),
                  floatingActionButton: SpeedDial(
                    icon: Icons.save_as,
                    activeIcon: Icons.close,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    spacing: 12,
                    children: [
                      SpeedDialChild(
                        child: const Icon(Icons.check),
                        label: 'Guardar',
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        onTap: () => context.read<RecipeFormCubit>().submit(),
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.remove_red_eye),
                        label: 'Preview',
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        onTap: () {
                          final cubit = context.read<RecipeFormCubit>();
                          cubit.validateForm();
                          if (!cubit.state.isValid) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipePage(
                                previewRecipe: cubit.buildRecipe(),
                                previewImages: cubit.state.images
                                    .map((img) => img.file)
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (formState.isSubmitting)
                Container(
                  color: Colors.black.withAlpha(90),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<RecipeFormCubit>().pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Elegir de la galería'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<RecipeFormCubit>().pickImage(
                    ImageSource.gallery,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _RecipeName extends StatelessWidget {
  const _RecipeName();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeFormCubit, RecipeFormState>(
      builder: (context, state) {
        return TextFormField(
          decoration: InputDecoration(
            labelText: 'Nombre de la receta',
            prefixIcon: const Icon(Icons.fastfood_outlined),
            border: const OutlineInputBorder(),
            errorText: state.errors['title'],
          ),
          onChanged: (value) => context.read<RecipeFormCubit>().setTitle(value),
        );
      },
    );
  }
}

class _RecipeSubtitle extends StatelessWidget {
  const _RecipeSubtitle();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Subtítulo',
        hintText: 'Breve descripción',
        alignLabelWithHint: true,
        prefixIcon: Icon(Icons.description_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) =>
          context.read<RecipeFormCubit>().setDescription(value),
    );
  }
}

class _RecipeSourceLink extends StatelessWidget {
  const _RecipeSourceLink();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeFormCubit, RecipeFormState>(
      builder: (context, state) {
        return TextFormField(
          decoration: InputDecoration(
            labelText: 'Fuente',
            hintText: 'https://www.ejemplo.com',
            prefixIcon: const Icon(Icons.link),
            border: const OutlineInputBorder(),
            errorText: state.errors['link'],
          ),
          onChanged: (value) =>
              context.read<RecipeFormCubit>().setSourceLink(value),
        );
      },
    );
  }
}

class _RecipeIngredients extends StatelessWidget {
  final List<Ingredient> ingredients;
  final List<int> ingredientUiKeys;
  final List<IngredientUnit> units;

  const _RecipeIngredients({
    required this.ingredients,
    required this.ingredientUiKeys,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RecipeFormCubit>();
    return BlocBuilder<RecipeFormCubit, RecipeFormState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.errors.containsKey('ingredients'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.errors['ingredients']!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Text(
              'Ingredientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                context.read<RecipeFormCubit>().reorderIngredients(
                  oldIndex,
                  newIndex,
                );
              },
              children: [
                for (int index = 0; index < ingredients.length; index++)
                  _IngredientCard(
                    key: ValueKey(ingredientUiKeys[index]),
                    index: index,
                    ingredient: ingredients[index],
                    units: units,
                    cubit: cubit,
                  ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => context.read<RecipeFormCubit>().addIngredient(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar ingrediente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IngredientCard extends StatelessWidget {
  final int index;
  final Ingredient ingredient;
  final List<IngredientUnit> units;
  final RecipeFormCubit cubit;

  const _IngredientCard({
    super.key,
    required this.index,
    required this.ingredient,
    required this.units,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeFormCubit, RecipeFormState>(
      builder: (context, state) {
        return Card(
          key: ValueKey(index.toString()),
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.drag_handle, color: Colors.grey),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          foregroundColor: Colors.white,
                          child: Text('${index + 1}'),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          context.read<RecipeFormCubit>().removeIngredient(index),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: ingredient.amount?.toString() ?? '',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    prefixIcon: const Icon(Icons.numbers),
                    border: const OutlineInputBorder(),
                    errorText: state.errors['ingredient_amount_$index'],
                  ),
                  onChanged: (v) => cubit.updateIngredient(
                    index,
                    amount: double.tryParse(v),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<IngredientUnit>(
                  initialValue: ingredient.unit,
                  items: units.map((u) {
                    return DropdownMenuItem(
                      value: u,
                      child: Text(u.name),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Unidad',
                    prefixIcon: const Icon(Icons.straighten),
                    border: const OutlineInputBorder(),
                    errorText: state.errors['ingredient_unit_$index'],
                  ),
                  onChanged: (u) => cubit.updateIngredient(index, unit: u),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: ingredient.name,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del ingrediente',
                    hintText: 'En singular. Ej: Huevo',
                    prefixIcon: Icon(Icons.rice_bowl_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => cubit.updateIngredient(index, name: v),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecipeSteps extends StatelessWidget {
  final List<PreparationStep> steps;
  final List<int> stepUiKeys;

  const _RecipeSteps({required this.steps, required this.stepUiKeys});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeFormCubit, RecipeFormState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.errors.containsKey('steps'))
              Text(
                state.errors['steps']!,
                style: const TextStyle(color: Colors.red),
              ),
            Text(
              'Pasos de preparación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                context.read<RecipeFormCubit>().reorderSteps(
                  oldIndex,
                  newIndex,
                );
              },
              children: [
                for (int index = 0; index < steps.length; index++)
                  Card(
                    key: ValueKey(stepUiKeys[index]),
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.drag_handle,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    foregroundColor: Colors.white,
                                    child: Text('${steps[index].order}'),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    context.read<RecipeFormCubit>().removeStep(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: steps[index].description,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    labelText: 'Descripción del paso',
                                    border: const OutlineInputBorder(),
                                    errorText: state.errors['step_$index'],
                                  ),
                                  onChanged: (v) => context
                                      .read<RecipeFormCubit>()
                                      .updateStep(index, v),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => context.read<RecipeFormCubit>().addStep(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar paso de preparación'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _ImageThumbnail({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(image, width: 96, height: 96, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipeCategoriesField extends StatelessWidget {
  const _RecipeCategoriesField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeFormCubit, RecipeFormState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categorías',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: state.categories.map((category) {
                final selected = state.categories.any((c) => c.id == category.id);
                return IgnorePointer(
                  child: FilterChip(
                    label: Text(category.name),
                    selected: selected,
                    onSelected: (_) {},
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _openCategorySelector(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.category_outlined),
                        const SizedBox(width: 8),
                        const Text(
                          'Seleccionar categorías',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_outlined),
                ],
              ),
            ),
            if (state.errors.containsKey('categories'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.errors['categories']!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openCategorySelector(BuildContext context) {
    final formCubit = context.read<RecipeFormCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: formCubit,
          child: const CategorySelectorSheet(),
        );
      },
    );
  }
}

Future<bool> _showExitDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('¿Cancelar receta?'),
            content: const Text('Si salís ahora, se perderán los cambios.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Seguir editando',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Salir',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      ) ??
      false;
}
