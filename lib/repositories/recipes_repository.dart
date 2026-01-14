import 'package:papeeta/models/models.dart';

abstract class RecipesRepository {
  Future<void> createRecipe({
    required Map<String, dynamic> payload,
    required List<MyImageModel> images,
  });
}
