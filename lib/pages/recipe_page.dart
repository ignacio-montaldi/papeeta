import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:papeeta/helpers/helpers.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient.dart';
import 'package:papeeta/features/recipes/domain/entities/preparation_step.dart';
import 'package:papeeta/core/domain/entities/user.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';

class RecipePage extends StatefulWidget {
  final int? recipeId;
  final Recipe? previewRecipe;
  final List<File> previewImages;

  const RecipePage({
    super.key,
    this.recipeId,
    this.previewRecipe,
    this.previewImages = const [],
  }) : assert(
         (recipeId != null) != (previewRecipe != null),
         'Debes enviar recipeId o previewRecipe',
       );

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  @override
  void initState() {
    super.initState();
    if (widget.recipeId != null) {
      context.read<RecipeBloc>().add(LoadRecipeDetail(widget.recipeId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double appBarExpandedHeight = 300;

    if (widget.previewRecipe != null) {
      return Scaffold(
        body: _RecipeContent(
          recipe: widget.previewRecipe!,
          appBarExpandedHeight: appBarExpandedHeight,
          previewImages: widget.previewImages,
        ),
      );
    }

    return Scaffold(
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeLoading || state is RecipeInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecipeError) {
            return Center(child: Text(state.message));
          }

          // Según la estrategia de Bloc que elijas (si mantienes las clases selladas actuales)
          Recipe? recipe;
          if (state is RecipeDetailLoaded) {
            recipe = state.recipe;
          } else if (state is RecipeListLoaded) {
            recipe = state.selectedRecipe;
          }

          if (recipe == null) {
            return const Center(child: Text('Cargando receta...'));
          }

          return _RecipeContent(
            recipe: recipe,
            appBarExpandedHeight: appBarExpandedHeight,
          );
        },
      ),
    );
  }
}

class _RecipeContent extends StatelessWidget {
  final Recipe recipe;
  final double appBarExpandedHeight;
  final List<File> previewImages;

  const _RecipeContent({
    required this.recipe,
    required this.appBarExpandedHeight,
    this.previewImages = const [],
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverAppBar(
          stretch: true,
          pinned: true,
          centerTitle: true,
          expandedHeight: appBarExpandedHeight,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: _AppBarBody(
            recipe: recipe,
            appBarExpandedHeight: appBarExpandedHeight,
            previewImages: previewImages,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _CategoriesList(
                  categories: recipe.categories.map((c) => c.name).toList(),
                ),
                const SizedBox(height: 10),
                const _SectionTitle(title: 'Ingredientes'),
                const SizedBox(height: 5),
                _IngredientList(ingredients: recipe.ingredients),
                const SizedBox(height: 10),
                const _SectionTitle(title: 'Preparación'),
                const SizedBox(height: 5),
                _PreparationStepsList(preparationSteps: recipe.steps),
                const SizedBox(height: 10),
                const _SectionTitle(title: 'Fuente'),
                const SizedBox(height: 5),
                _Link(link: recipe.link),
                const SizedBox(height: 10),
                if (recipe.author != null)
                  _AuthorWidget(author: recipe.author!),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AppBarBody extends StatefulWidget {
  final Recipe recipe;
  final double appBarExpandedHeight;
  final List<File> previewImages;

  const _AppBarBody({
    required this.recipe,
    required this.appBarExpandedHeight,
    this.previewImages = const [],
  });

  @override
  State<_AppBarBody> createState() => _AppBarBodyState();
}

class _AppBarBodyState extends State<_AppBarBody> {
  int currentIndex = 0;

  bool needsSecondLine(String title) {
    final textSpan = TextSpan(
      text: title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    final screenWidth = MediaQuery.of(context).size.width;
    return tp.width > screenWidth - 80;
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.recipe.images;
    final hasPreviewImages = widget.previewImages.isNotEmpty;
    final imageCount = hasPreviewImages
        ? widget.previewImages.length
        : images.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double currentHeight = constraints.maxHeight;
        final double maxHeight = widget.appBarExpandedHeight;
        const double minHeight = kToolbarHeight + 20;
        final double t = ((currentHeight - minHeight) / (maxHeight - minHeight))
            .clamp(0.0, 1.0);

        return FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
          stretchModes: const [StretchMode.zoomBackground],
          titlePadding: EdgeInsets.lerp(
            EdgeInsets.only(
              left: 60,
              bottom: needsSecondLine(widget.recipe.title) ? 8 : 15,
              right: 16,
            ),
            const EdgeInsets.only(left: 16, bottom: 32, right: 16),
            t,
          ),
          title: Text(
            widget.recipe.title,
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
                child: imageCount == 0
                    ? Container(color: Theme.of(context).colorScheme.onPrimary)
                    : CarouselSlider.builder(
                        itemCount: imageCount,
                        itemBuilder: (context, index, _) {
                          if (hasPreviewImages) {
                            return SizedBox.expand(
                              child: Image.file(
                                widget.previewImages[index],
                                fit: BoxFit.cover,
                              ),
                            );
                          }

                          return SizedBox.expand(
                            child: CachedNetworkImage(
                              imageUrl: images[index].url,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.broken_image),
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
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(0),
                        Colors.black.withAlpha(180),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(imageCount, (index) {
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
            shape: const StadiumBorder(),
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

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...ingredients.map((ingredient) {
          String boldText = '\u2022 ';
          String regularText = '';

          // Asumimos que 11 sigue siendo el ID "unidad"
          if (ingredient.amount != null && ingredient.amount != 0) {
            boldText += formatDouble(ingredient.amount ?? 0);
          }

          if (ingredient.unit != null &&
              ingredient.unit?.id != null &&
              ingredient.unit?.id != 11) {
            boldText += ' ${ingredient.unit!.key}';
            if (ingredient.amount != null && ingredient.amount != 1) {
              boldText += 's';
            }
          }

          if (ingredient.amount != null && ingredient.amount != 0) {
            regularText += ' ';
          }
          if (ingredient.unit != null &&
              ingredient.unit?.id != null &&
              ingredient.unit?.id != 11 &&
              ingredient.unit!.name.isNotEmpty) {
            regularText += 'de ';
          }

          final bool noMeasureOrAmmount = (boldText == '\u2022 ');

          regularText += noMeasureOrAmmount
              ? ingredient.name.capitalize()
              : ingredient.name;

          return Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black54, fontSize: 15),
                children: <TextSpan>[
                  TextSpan(
                    text: boldText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: regularText),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PreparationStepsList extends StatelessWidget {
  final List<PreparationStep> preparationSteps;
  const _PreparationStepsList({required this.preparationSteps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...preparationSteps.map((step) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black54, fontSize: 15),
                children: <TextSpan>[
                  TextSpan(
                    text: '${step.order}. ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: step.description),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.link});

  final String? link;

  @override
  Widget build(BuildContext context) {
    return link != null && link!.isNotEmpty
        ? GestureDetector(
            onTap: () => launchUrl(link!),
            child: Text(
              link!,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
              ),
            ),
          )
        : const Text(
            "Parece que esta es una receta original, recuerda agradecerle a quien te la envió 😊",
          );
  }
}

class _AuthorWidget extends StatelessWidget {
  const _AuthorWidget({required this.author});

  final User author;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
          radius: 18,
          child: Text(
            author.name.isNotEmpty ? author.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "agregada por ${author.name}",
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
