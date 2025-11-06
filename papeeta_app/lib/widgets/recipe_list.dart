import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/models/models.dart';
import 'package:papeeta/widgets/widgets.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({super.key, required this.recipes});

  final List<RecipeModel> recipes;

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  late final List<RecipeModel> recipes;
  @override
  void initState() {
    recipes = widget.recipes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final RecipeBloc recipeBloc = BlocProvider.of<RecipeBloc>(context);
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...recipes.map<Widget>((recipe) {
            return GestureDetector(
              onTap: () {
                recipeBloc.add(SelectedRecipe(recipe: recipe));
                Navigator.pushNamed(context, 'recipe');
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 243, 243, 243),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MyImageWidget(
                          image: MyImageModel(url: recipe.imagesUrl.first),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          height: 190,
                          width: double.infinity,
                        ),
                        SizedBox(height: 10),
                        Text(
                          recipe.categories
                              .map((category) => category.name)
                              .toList()
                              .join(' | '),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xff999999),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          recipe.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
