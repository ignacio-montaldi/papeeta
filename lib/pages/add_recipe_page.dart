import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/models/models.dart';

import '../helpers/helpers.dart';

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
    return Scaffold(
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
              return const CircularProgressIndicator();
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
                      // 🧁 Fuente de la receta original
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Fuente',
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          // Validar si es URL
                          if (value != null &&
                              value.isNotEmpty &&
                              !isValidUrl(value.trim())) {
                            return 'Ingrese una URL válida';
                          }

                          return null;
                        },
                        onChanged: (value) => context
                            .read<RecipeFormCubit>()
                            .setSourceLink(value),
                      ),
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
                          if (state.images.isEmpty) return const SizedBox();

                          return SizedBox(
                            height: 110,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.images.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return _ImageThumbnail(
                                  image: state.images[index],
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state.errors.containsKey('images'))
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    state.errors['images']!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              OutlinedButton.icon(
                                onPressed: () => _showImageSourceSheet(context),
                                icon: const Icon(Icons.add_a_photo_outlined),
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
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Guardar receta'),
        onPressed: () {
          final cubit = context.read<RecipeFormCubit>();
          cubit.validateForm();

          if (!cubit.state.isValid) return;

          // TODO: ✅ Guardar receta

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Receta guardada')));
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
          // validator: (value) =>
          //     value == null || value.isEmpty ? 'Ingrese un nombre' : null,
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
    return Card(
      key: ValueKey(index.toString()),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      foregroundColor: Colors.white,
                      child: Text("${index + 1}"),
                    ),
                  ],
                ),
                // Botón eliminar
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      context.read<RecipeFormCubit>().removeIngredient(index),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Cantidad
            TextFormField(
              initialValue: ingredient.ammount?.toString() ?? "",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Cantidad",
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  cubit.updateIngredient(index, ammount: double.tryParse(v)),
            ),
            const SizedBox(height: 12),

            // Unidad (dropdown)
            DropdownButtonFormField<String>(
              value: ingredient.measure,
              items: units.map((u) {
                return DropdownMenuItem(
                  value: u.unitKey,
                  child: Text(u.displayName),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: "Unidad",
                prefixIcon: Icon(Icons.straighten),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => cubit.updateIngredient(index, measure: v),
            ),
            const SizedBox(height: 12),

            // Nombre del ingrediente
            TextFormField(
              initialValue: ingredient.name,
              decoration: const InputDecoration(
                labelText: "Nombre del ingrediente",
                hint: Text('En singular. Ej: Huevo'),
                prefixIcon: Icon(Icons.rice_bowl_outlined),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => cubit.updateIngredient(index, name: v),
            ),
          ],
        ),
      ),
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
                                decoration: const InputDecoration(
                                  labelText: "Descripción del paso",
                                  border: OutlineInputBorder(),
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
