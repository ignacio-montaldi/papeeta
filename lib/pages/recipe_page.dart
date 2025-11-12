import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/recipe/recipe_bloc.dart';
import 'package:papeeta/helpers/helpers.dart';
import 'package:papeeta/models/models.dart';
import 'package:papeeta/models/response/preparation_step_model.dart';
import 'package:papeeta/widgets/my_image_widget.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeBloc = BlocProvider.of<RecipeBloc>(context);
    final double appBarExpandedHeight = 300;

    return SafeArea(
      top: false,
      child: Scaffold(
        body: BlocBuilder<RecipeBloc, RecipeState>(
          builder: (context, state) {
            RecipeModel selectedRecipe = state.selectedRecipe!;
            if (selectedRecipe.ingredients.isEmpty ||
                selectedRecipe.preparationSteps.isEmpty) {
              recipeBloc.getRecipeDetail(state.selectedRecipe!.id);
              return Center(child: CircularProgressIndicator());
            }

            selectedRecipe = state.selectedRecipe!;

            return CustomScrollView(
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
                  expandedHeight: appBarExpandedHeight,
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  iconTheme: IconThemeData(color: Colors.white),
                  flexibleSpace: _AppBarBody(
                    selectedRecipe: selectedRecipe,
                    appBarExpandedHeight: appBarExpandedHeight,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(20),
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(0),
                      children: [
                        _CategoriesList(
                          categories: selectedRecipe.categories
                              .map((category) => category.name)
                              .toList(),
                        ),
                        SizedBox(height: 10),
                        _SectionTitle(title: 'Ingredientes'),
                        SizedBox(height: 5),
                        _IngredientList(
                          ingredients: selectedRecipe.ingredients,
                        ),
                        SizedBox(height: 10),
                        _SectionTitle(title: 'Preparación'),
                        SizedBox(height: 5),
                        _PreparationStepsList(
                          preparationSteps: selectedRecipe.preparationSteps,
                        ),
                        SizedBox(height: 10),
                        _SectionTitle(title: 'Fuente'),
                        SizedBox(height: 5),
                        _Link(link: selectedRecipe.link),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.link});

  final String? link;

  @override
  Widget build(BuildContext context) {
    return link != null
        ? GestureDetector(
            onTap: () => launchUrl(link!),
            child: Text(
              link!,
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
              ),
            ),
          )
        : Text(
            "Parece que esta es una receta original, recuerda agradecerle a quien te la envió 😊",
          );
  }
}

class _AppBarBody extends StatefulWidget {
  final RecipeModel selectedRecipe;
  final double appBarExpandedHeight;

  const _AppBarBody({
    required this.selectedRecipe,
    required this.appBarExpandedHeight,
  });

  @override
  State<_AppBarBody> createState() => _AppBarBodyState();
}

class _AppBarBodyState extends State<_AppBarBody> {
  int currentIndex = 0;

  bool needsSecondLine(String title) {
    final textSpan = TextSpan(
      text: title,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    final screenWidth = MediaQuery.of(context).size.width;
    return tp.width >
        screenWidth -
            80; // number is horizontal padding value for the actual widget
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = widget.selectedRecipe.imagesUrl;

    return LayoutBuilder(
      builder: (context, constraints) {
        // constraints.maxHeight varía entre toolbarHeight y expandedHeight
        final double currentHeight = constraints.maxHeight;
        final double maxHeight = widget.appBarExpandedHeight;
        const double minHeight =
            kToolbarHeight + 20; // coincidir con tu cálculo
        final double t = ((currentHeight - minHeight) / (maxHeight - minHeight))
            .clamp(0.0, 1.0);

        return FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax, // o CollapseMode.pin
          stretchModes: const [StretchMode.zoomBackground],
          titlePadding: EdgeInsets.lerp(
            EdgeInsets.only(
              left: 60,
              bottom: needsSecondLine(widget.selectedRecipe.title) ? 8 : 15,
              right: 16,
            ), // colapsado
            const EdgeInsets.only(left: 16, bottom: 32, right: 16), // expandido
            t,
          ),
          title: Text(
            widget.selectedRecipe.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          background: Stack(
            fit: StackFit.expand,
            children: [
              SizedBox.expand(
                child: CarouselSlider.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index, realIndex) {
                    final imageUrl = images[index];
                    return SizedBox.expand(
                      child: MyImageWidget(
                        image: MyImageModel(url: imageUrl),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: double.infinity,
                    viewportFraction: 1.0,
                    scrollPhysics: const BouncingScrollPhysics(),
                    onPageChanged: (index, reason) {
                      setState(() => currentIndex = index);
                    },
                  ),
                ),
              ),
              // capa de gradiente
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withAlpha(0),
                        Colors.black.withAlpha(180),
                      ],
                    ),
                  ),
                ),
              ),
              // indicadores
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: currentIndex == index ? 10 : 8,
                      height: currentIndex == index ? 10 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndex == index
                            ? Colors.white
                            : Colors.white.withAlpha(100),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
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
          if (ingredient.ammount != null && ingredient.ammount != 0) {
            boldText += formatDouble(ingredient.ammount ?? 0);
          }

          if (ingredient.measure != null) {
            boldText += ' ${ingredient.measure!}';
          }
          if (ingredient.measure != null &&
              ingredient.measure != null &&
              ingredient.ammount != 1) {
            boldText += 's';
          }

          if (ingredient.ammount != null && ingredient.ammount != 0) {
            regularText += ' ';
          }
          if (ingredient.measure != null && ingredient.measure != '') {
            regularText += 'de ';
          }
          final bool noMeasureOrAmmount = (boldText == '\u2022 ');

          regularText += noMeasureOrAmmount
              ? ingredient.name.capitalize()
              : ingredient.name;

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

class _PreparationStepsList extends StatelessWidget {
  final List<PreparationStepModel> preparationSteps;
  const _PreparationStepsList({required this.preparationSteps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...preparationSteps.map((step) {
          return Column(
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${step.stepNumber}. ',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
