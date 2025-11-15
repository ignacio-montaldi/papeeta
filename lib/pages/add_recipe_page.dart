import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/models/models.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  // 🔥 NUEVO: lista dinámica de ingredientes
  List<IngredientModel> ingredients = [];

  // 🔥 NUEVO: medidas cargadas desde tu API
  List<IngredientUnitModel> units = [];

  @override
  void initState() {
    BlocProvider.of<IngredientBloc>(context).add(LoadUnitsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar receta'),
        backgroundColor: primaryColor,
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
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la receta',
                          prefixIcon: Icon(Icons.fastfood_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ingrese un nombre'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // 📜 Subtítulo
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Subtítulo',
                          hintText: 'Breve descripción',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.description_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🧂 Ingredientes (Material 3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ingredientes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Lista de tarjetas
                          ...ingredients.asMap().entries.map((entry) {
                            final index = entry.key;
                            final ing = entry.value;

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  5,
                                  16,
                                  16,
                                ),
                                child: Column(
                                  children: [
                                    // Header con título + borrar
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Ingrediente ${index + 1}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(
                                              () => ingredients.removeAt(index),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),

                                    // Cantidad
                                    TextFormField(
                                      initialValue:
                                          ing.ammount?.toString() ?? "",
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: const InputDecoration(
                                        labelText: "Cantidad",
                                        prefixIcon: Icon(Icons.numbers),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (v) {
                                        final parsed = double.tryParse(v);
                                        ingredients[index] = IngredientModel(
                                          ammount: parsed,
                                          measure: ing.measure,
                                          name: ing.name,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Unidad (dropdown)
                                    DropdownButtonFormField<String>(
                                      value: ing.measure,
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
                                      onChanged: (value) {
                                        ingredients[index] = IngredientModel(
                                          ammount: ing.ammount,
                                          measure: value,
                                          name: ing.name,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Nombre del ingrediente
                                    TextFormField(
                                      initialValue: ing.name,
                                      decoration: const InputDecoration(
                                        labelText: "Nombre del ingrediente",
                                        prefixIcon: Icon(
                                          Icons.rice_bowl_outlined,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (v) {
                                        ingredients[index] = IngredientModel(
                                          ammount: ing.ammount,
                                          measure: ing.measure,
                                          name: v,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Botón agregar ingrediente
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                ingredients.add(
                                  IngredientModel(
                                    ammount: null,
                                    measure: null,
                                    name: "",
                                  ),
                                );
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Agregar ingrediente"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // 🔪 Pasos
                      TextFormField(
                        controller: _stepsController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Pasos de preparación',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.format_list_numbered_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 📸 Imagen
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text('Agregar imagen'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),
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
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Guardar receta'),
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;

          // 👇 Aquí ya tenés ingredients listo para enviar a tu backend
          // print(ingredients);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Receta guardada')));
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    super.dispose();
  }
}
