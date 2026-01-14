import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/models/models.dart';
import 'package:papeeta/widgets/widgets.dart';

class RecipeList extends StatelessWidget {
  const RecipeList({super.key, required this.recipes});

  final List<RecipeModel> recipes;

  @override
  Widget build(BuildContext context) {
    final RecipeBloc recipeBloc = BlocProvider.of<RecipeBloc>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: recipes.map((recipe) {
          return GestureDetector(
            onTap: () {
              recipeBloc.add(SelectedRecipe(recipe: recipe));
              Navigator.pushNamed(context, 'recipe');
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 240, 240),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🔹 La imagen ocupa el alto restante
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: MyImageWidget(
                          image: MyImageModel(
                            url: recipe.images.isNotEmpty
                                ? recipe.images.map((image) => image.url).first
                                : '',
                          ),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover, // para que llene sin deformarse
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      recipe.categories
                          .map((category) => category.name)
                          .toList()
                          .join(' | '),
                      textAlign: TextAlign.center,
                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff999999),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      recipe.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
