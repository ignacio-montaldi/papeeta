import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/global/enviroment.dart';

import 'package:papeeta/models/models.dart';
import 'package:papeeta/models/response/response_models.dart';
import 'package:papeeta/services/recipes_service.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipesService _recipesService;

  RecipeBloc({required RecipesService recipesService})
    : _recipesService = recipesService,
      super(RecipeState(recipes: null)) {
    on<LoadedRecipeList>(
      (event, emit) => emit(state.copyWith(recipes: event.recipes)),
    );

    on<SelectedRecipe>(
      (event, emit) => emit(state.copyWith(selectedRecipe: event.recipe)),
    );

    on<SelectedRecipeDetailLoaded>(
      (event, emit) => emit(state.copyWith(selectedRecipe: event.recipe)),
    );

    on<LoadedRecipeByCategoryList>(
      (event, emit) =>
          emit(state.copyWith(recipesByCategory: event.recipesByCategory)),
    );

    on<LoadHomeRecipes>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final recipeListResponse = await _recipesService.getHomeRecipeList();

      final List<RecipeModel> recipes = recipeListResponse.recipe
          .map(
            (Recipe recipe) => RecipeModel(
              id: recipe.id,
              title: recipe.title,
              subtitle: recipe.subtitle,
              imagesUrl: recipe.images
                  .map((image) => '${Enviroment.uploadsUrl}${image.url}')
                  .toList(),
              ingredients: [],
              categories: recipe.categories
                  .map(
                    (RecipeCategory category) => CategoryModel(
                      name: category.name,
                      imageUrl: null,
                      id: null,
                      groupId: null,
                    ),
                  )
                  .toList(),
              preparationSteps: [],
              link: recipe.link,
            ),
          )
          .toList();

      emit(state.copyWith(recipes: recipes, isLoading: false));
    });
  }

  Future<void> getRecipeDetail(int recipeId) async {
    final RecipeDetailResponse recipeResponse = await _recipesService
        .getRecipeDetail(recipeId);

    final RecipeModel recipe = RecipeModel(
      id: recipeResponse.recipe.id,
      title: recipeResponse.recipe.title,
      subtitle: recipeResponse.recipe.subtitle,
      imagesUrl: recipeResponse.recipe.images
          .map((image) => '${Enviroment.uploadsUrl}${image.url}')
          .toList(),
      ingredients: recipeResponse.recipe.ingredients != null
          ? recipeResponse.recipe.ingredients!
                .map(
                  (ingredient) => IngredientModel(
                    ammount: ingredient.amount,
                    measure: ingredient.measure,
                    name: ingredient.name,
                  ),
                )
                .toList()
          : [],
      categories: recipeResponse.recipe.categories
          .map(
            (RecipeCategory category) => CategoryModel(
              name: category.name,
              imageUrl: null,
              id: null,
              groupId: null,
            ),
          )
          .toList(),
      preparationSteps: recipeResponse.recipe.preparationSteps != null
          ? recipeResponse.recipe.preparationSteps!
                .map(
                  (preparationStep) => PreparationStepModel(
                    stepNumber: preparationStep.stepNumber,
                    description: preparationStep.description,
                  ),
                )
                .toList()
          : [],
      link: recipeResponse.recipe.link,
      author: UsuarioModel(
        nombre: recipeResponse.recipe.author!.nombre,
        uid: recipeResponse.recipe.author!.id,
      ),
    );

    add(SelectedRecipeDetailLoaded(recipe: recipe));
  }

  Future<void> getRecipesByCategory(int categoryId) async {
    final recipeListResponse = await _recipesService.getRecipesByCategory(
      categoryId,
    );

    final List<RecipeModel> recipes = recipeListResponse.recipe
        .map(
          (Recipe recipe) => RecipeModel(
            id: recipe.id,
            title: recipe.title,
            subtitle: recipe.subtitle,
            imagesUrl: recipe.images
                .map((image) => '${Enviroment.uploadsUrl}${image.url}')
                .toList(),
            ingredients: [], //En este punto no traigo los ingredientes todavía
            categories: recipe.categories
                .map(
                  (RecipeCategory category) => CategoryModel(
                    name: category.name,
                    imageUrl: null,
                    id: null,
                    groupId: null,
                  ),
                )
                .toList(),
            preparationSteps: [], //Idem igredientes
            link: recipe.link,
          ),
        )
        .toList();

    add(LoadedRecipeByCategoryList(recipesByCategory: recipes));
  }
}
