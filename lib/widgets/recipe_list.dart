import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/models/my_image_model.dart';
import 'package:papeeta/widgets/widgets.dart';

class RecipeList extends StatelessWidget {
  const RecipeList({super.key, required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          final imageUrl = recipe.images.isNotEmpty
              ? recipe.images.first.url
              : '';
          return GestureDetector(
            onTap: () {
              context.push('/recipe/${recipe.id}');
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
                          image: MyImageModel(url: imageUrl),
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
        },
      ),
    );
  }
}
