import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/models/models.dart';
import 'package:papeeta/services/auth_service.dart';
import 'package:papeeta/widgets/category_selector_sheet.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();

  // 🔥 NUEVO: medidas cargadas desde tu API
  List<IngredientUnitModel> units = [];

  // Categorías cargadas desde API
  List<CategoryModel> categories = [];

  // IDs seleccionados
  List<int> selectedCategoryIds = [];

  @override
  void initState() {
    BlocProvider.of<IngredientBloc>(context).add(LoadUnitsEvent());
    context.read<CategoryBloc>().getCategoriesList();
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

          Navigator.pop(context); // volver
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
                          return Center(
                            child: const CircularProgressIndicator(),
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
                                  // 🧁 Nombre de la receta
                                  _RecipeName(),
                                  const SizedBox(height: 20),
                                  // 📜 Subtítulo
                                  _RecipeSubtitle(),
                                  const SizedBox(height: 20),
                                  // ⛓️‍💥 Fuente de la receta original
                                  _RecipeSourceLink(),
                                  const SizedBox(height: 20),
                                  //Categorias
                                  _RecipeCategoriesField(),
                                  const SizedBox(height: 20),
                                  // 🧂 Ingredientes
                                  BlocBuilder<RecipeFormCubit, RecipeFormState>(
                                    builder: (context, state) {
                                      return _RecipeIngredients(
                                        ingredients: state.ingredients,
                                        units: units,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  BlocBuilder<RecipeFormCubit, RecipeFormState>(
                                    builder: (context, state) {
                                      return _RecipeSteps(steps: state.steps);
                                    },
                                  ),
                                  // 🔪 Pasos
                                  const SizedBox(height: 20),

                                  // Carrusel de imágenes
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
                                              image: state.images
                                                  .map((image) => image.file!)
                                                  .toList()[index],
                                              onRemove: () => context
                                                  .read<RecipeFormCubit>()
                                                  .removeImage(index),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                  // 📸 Imagen
                                  BlocBuilder<RecipeFormCubit, RecipeFormState>(
                                    builder: (context, state) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (state.errors.containsKey(
                                            'images',
                                          ))
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
                          return Text("Error: ${state.message}");
                        }
                        return Text("Error inesperado");
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
                        shape: CircleBorder(),
                        onTap: () => context.read<RecipeFormCubit>().submit(),
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.remove_red_eye),
                        label: 'Preview',
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        foregroundColor: Colors.white,
                        shape: CircleBorder(),
                        onTap: () {
                          final cubit = context.read<RecipeFormCubit>();
                          cubit.validateForm();

                          if (!cubit.state.isValid) return;

                          final authService = context.read<AuthService>();
                          context.read<RecipeFormCubit>().setAuthor(
                            authService.usuario,
                          );

                          final recipe = context
                              .read<RecipeFormCubit>()
                              .buildPreviewRecipe();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipePage(previewRecipe: recipe),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // OVERLAY DE LOADING
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

  @override
  void dispose() {
    super.dispose();
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

              // Handle visual
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
            prefixIcon: Icon(Icons.fastfood_outlined),
            border: OutlineInputBorder(),
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
            hintStyle: TextStyle(),
            prefixIcon: Icon(Icons.link),
            border: OutlineInputBorder(),
            errorText: state.errors['link'],
          ),
          onChanged: (value) =>
              context.read<RecipeFormCubit>().setSourceLink(value),
        );
      },
    );
  }
}

class _RecipeIngredients extends StatefulWidget {
  final List<IngredientModel> ingredients;
  final List<IngredientUnitModel> units;
  const _RecipeIngredients({required this.ingredients, required this.units});

  @override
  State<_RecipeIngredients> createState() => _RecipeIngredientsState();
}

class _RecipeIngredientsState extends State<_RecipeIngredients> {
  @override
  void initState() {
    super.initState();
  }

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
              "Ingredientes",
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
                for (int index = 0; index < widget.ingredients.length; index++)
                  _IngredientCard(
                    key: ValueKey(widget.ingredients[index].tempId),
                    index: index,
                    ingredient: widget.ingredients[index],
                    units: widget.units,
                    cubit: cubit,
                  ),
              ],
            ),

            // Botón agregar ingrediente
            OutlinedButton.icon(
              onPressed: () => context.read<RecipeFormCubit>().addIngredient(),
              icon: const Icon(Icons.add),
              label: const Text("Agregar ingrediente"),
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
  final IngredientModel ingredient;
  final List<IngredientUnitModel> units;
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
                    // Número de paso
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
                          child: Text("${index + 1}"),
                        ),
                      ],
                    ),
                    // Botón eliminar
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => context
                          .read<RecipeFormCubit>()
                          .removeIngredient(index),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Cantidad
                TextFormField(
                  initialValue: ingredient.amount?.toString() ?? "",
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: "Cantidad",
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                    errorText: state.errors['ingredient_amount_$index'],
                  ),
                  onChanged: (v) =>
                      cubit.updateIngredient(index, amount: double.tryParse(v)),
                ),
                const SizedBox(height: 12),

                // Unidad (dropdown)
                DropdownButtonFormField<IngredientUnitModel>(
                  value: ingredient.measure,
                  items: units.map((u) {
                    return DropdownMenuItem(
                      value: u,
                      child: Text(u.displayName),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: "Unidad",
                    prefixIcon: Icon(Icons.straighten),
                    border: OutlineInputBorder(),
                    errorText: state.errors['ingredient_unit_$index'],
                  ),
                  onChanged: (u) => cubit.updateIngredient(index, measure: u),
                ),
                const SizedBox(height: 12),

                // Nombre del ingrediente
                TextFormField(
                  initialValue: ingredient.name,
                  decoration: InputDecoration(
                    labelText: "Nombre del ingrediente",
                    hint: Text('En singular. Ej: Huevo'),
                    prefixIcon: Icon(Icons.rice_bowl_outlined),
                    border: OutlineInputBorder(),
                    errorText: state.errors['ingredient_$index'],
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

class _RecipeSteps extends StatefulWidget {
  final List<PreparationStepModel> steps;
  const _RecipeSteps({required this.steps});

  @override
  State<_RecipeSteps> createState() => __RecipeStepsState();
}

class __RecipeStepsState extends State<_RecipeSteps> {
  @override
  void initState() {
    super.initState();
  }

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
              "Pasos de preparación",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),

            const SizedBox(height: 12),

            // Lista de pasos
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                context.read<RecipeFormCubit>().reorderSteps(
                  oldIndex,
                  newIndex,
                );
              },
              children: widget.steps.map((step) {
                return Card(
                  key: ValueKey(step.tempId),
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
                            // Número de paso
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
                                  child: Text("${step.stepNumber}"),
                                ),
                              ],
                            ),
                            // Botón eliminar
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => context
                                  .read<RecipeFormCubit>()
                                  .removeStepById(step.tempId!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // TextField de descripción
                            Expanded(
                              child: TextFormField(
                                initialValue: step.description,
                                maxLines: null,
                                decoration: InputDecoration(
                                  labelText: "Descripción del paso",
                                  border: OutlineInputBorder(),
                                  errorText: state
                                      .errors['step_${step.stepNumber - 1}'],
                                ),
                                onChanged: (v) => context
                                    .read<RecipeFormCubit>()
                                    .updateStepById(step.tempId!, v),
                              ),
                            ),

                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Botón agregar ingrediente
            OutlinedButton.icon(
              onPressed: () => context.read<RecipeFormCubit>().addStep(),
              icon: const Icon(Icons.add),
              label: const Text("Agregar paso de preparación"),

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
              decoration: BoxDecoration(
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
                final selected = state.categories.any(
                  (c) => c.id == category.id,
                );

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
                        Text(
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
