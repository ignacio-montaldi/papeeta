import 'package:flutter/material.dart';
import 'package:papeeta/helpers/formateadores.dart';
import 'package:papeeta/models/models.dart';

class PreparationStep {
  final int step;
  final String description;

  PreparationStep({required this.step, required this.description});
}

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Mexicana',
      'Pastas',
      'Asiática',
      'Entradas',
      'Carne Vacuna',
      'Frutas',
    ];

    final List<IngredientModel> ingredients = [
      IngredientModel(ammount: 250, measure: 'g.', ingredient: 'Harina 0000'),
      IngredientModel(
        ammount: 250,
        measure: 'g.',
        ingredient: 'Harina Integral 0000',
      ),
      IngredientModel(ammount: 10, measure: 'g.', ingredient: 'Sal'),
      IngredientModel(ammount: 25, measure: 'g.', ingredient: 'Azucar'),
      IngredientModel(ammount: 5, measure: 'g.', ingredient: 'Levadura Seca'),
      IngredientModel(ammount: 300, measure: 'ml.', ingredient: 'Leche'),
      IngredientModel(ammount: 50, measure: 'g.', ingredient: 'Manteca'),
      IngredientModel(ammount: 0, measure: '', ingredient: 'Semillas a gusto'),
      IngredientModel(ammount: 1, measure: '', ingredient: 'Huevo'),
    ];

    List<PreparationStep> preparationSteps = [
      PreparationStep(
        step: 1,
        description:
            'Herví agua en una olla grande con una pizca de sal. Cuando rompa el hervor, agregá la pasta y cociná según las instrucciones del paquete.',
      ),
      PreparationStep(
        step: 2,
        description:
            'Mientras tanto, calentá una sartén con un poco de aceite de oliva y agregá la cebolla picada. Cociná hasta que esté transparente.',
      ),
      PreparationStep(
        step: 3,
        description:
            'Agregá el ajo picado y cociná por 1 minuto más, sin dejar que se queme.',
      ),
      PreparationStep(
        step: 4,
        description:
            'Incorporá los tomates triturados, una pizca de azúcar, sal y pimienta. Cociná a fuego lento durante 10-15 minutos.',
      ),
      PreparationStep(
        step: 5,
        description:
            'Escurrí la pasta y agregala a la sartén con la salsa. Mezclá bien para que se impregne.',
      ),
      PreparationStep(
        step: 6,
        description:
            'Serví caliente con hojas de albahaca fresca y queso rallado por encima.',
      ),
    ];

    return SafeArea(
      top: false,
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              stretch: true,
              pinned: true,
              centerTitle: true,
              onStretchTrigger: () async {
                // Triggers when stretching past offset
                // print('Stretch');
              },
              stretchTriggerOffset: 300.0,
              expandedHeight: 300.0,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: _AppBarBody(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(0),
                  children: [
                    _CategoriesList(categories: categories),
                    SizedBox(height: 10),
                    _SectionTitle(title: 'Ingredientes'),
                    SizedBox(height: 5),
                    _IngredientList(ingredients: ingredients),
                    SizedBox(height: 10),
                    _SectionTitle(title: 'Preparación'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...preparationSteps.map((step) {
                          return Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${step.step}. ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: step.description),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      title: Text(
        'Receta Título',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      // centerTitle: true,
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image(image: AssetImage('images/example.jpg'), fit: BoxFit.cover),
          // Capa semi-transparente para mejorar el contraste del texto
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.black.withAlpha(0),
                  Colors.black.withAlpha(60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesList extends StatelessWidget {
  const _CategoriesList({required this.categories});

  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.start,
      children: [
        ...categories.map(
          (category) => Chip(
            label: Text(category),
            elevation: 2,
            shape: StadiumBorder(),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _IngredientList extends StatelessWidget {
  const _IngredientList({required this.ingredients});

  final List<IngredientModel> ingredients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...ingredients.map((ingredient) {
          String boldText = '';
          String regularText = '';

          boldText += '\u2022 ';
          if (ingredient.ammount != 0) {
            boldText += formatDouble(ingredient.ammount);
          }
          boldText += ingredient.measure;

          if (ingredient.ammount != 0) {
            regularText += ' ';
          }
          if (ingredient.measure != '') {
            regularText += 'de ';
          }
          regularText += ingredient.ingredient;

          return Column(
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                  children: <TextSpan>[
                    TextSpan(
                      text: boldText,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: regularText),
                  ],
                ),
              ),
              SizedBox(height: 5),
            ],
          );
        }),
      ],
    );
  }
}
