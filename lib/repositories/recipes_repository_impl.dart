import 'package:papeeta/models/models.dart';
import 'package:papeeta/repositories/recipes_repository.dart';
import 'package:papeeta/services/recipes_service.dart';

class RecipesRepositoryImpl implements RecipesRepository {
  final RecipesService service;

  RecipesRepositoryImpl(this.service);

  @override
  Future<void> createRecipe({
    required Map<String, dynamic> payload,
    required List<MyImageModel> images,
  }) async {
    // 1️⃣ Crear receta
    final recipeId = await service.createRecipe(payload);

    // 2️⃣ Subir imágenes si hay
    if (images.isNotEmpty) {
      await service.uploadRecipeImages(recipeId: recipeId, images: images);
    }
  }
}
