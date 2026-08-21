import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe_image_upload.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:papeeta/pages/recipe_list_page.dart';

const _categoria = Category(id: 1, name: 'Pastas');

const _receta = Recipe(
  id: 10,
  title: 'Ñoquis de papa',
  subtitle: 'El clásico del 29',
  images: [],
  ingredients: [],
  categories: [],
  steps: [],
);

const _recetas = [_receta];

/// El bloc real, pero con emisión manual para poder reproducir la secuencia de
/// estados que produce navegar al detalle y volver.
class _TestRecipeBloc extends RecipeBloc {
  _TestRecipeBloc() : super(_FakeRepository());

  void emitir(RecipeState state) => emit(state);
}

class _FakeRepository implements RecipesRepository {
  @override
  Future<List<Recipe>> getRecipesByCategory(int categoryId) async => _recetas;

  @override
  Future<List<Recipe>> getHomeRecipeList() async => _recetas;

  @override
  Future<List<Recipe>> getRecipes() async => _recetas;

  @override
  Future<Recipe> getRecipeById(int id) async => _recetas.first;

  @override
  Future<int> createRecipe(Recipe recipe) async => 0;

  @override
  Future<void> uploadRecipeImages({
    required int recipeId,
    required List<RecipeImageUpload> images,
  }) async {}
}


/// Monta la pantalla en un viewport de teléfono.
///
/// El default de `flutter_test` (800x600) es más ancho y mucho más bajo que
/// cualquier teléfono, y con tarjetas de foto a ancho completo eso desborda.
Future<void> _montar(WidgetTester tester, RecipeBloc bloc) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: BlocProvider<RecipeBloc>.value(
        value: bloc,
        child: const RecipeListPage(category: _categoria),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'la lista sigue visible cuando el bloc pasa por los estados del detalle',
    (tester) async {
      final bloc = _TestRecipeBloc();
      addTearDown(bloc.close);

      await _montar(tester, bloc);

      // Estado inicial: la categoría cargó su lista.
      expect(find.text('Ñoquis de papa'), findsOneWidget);

      // Se abre una receta. El bloc es compartido, así que esta pantalla —que
      // sigue montada abajo— se reconstruye con estados que no son de lista.
      bloc.emitir(const RecipeDetailLoading(recipeId: 10));
      await tester.pump();
      expect(
        find.text('Ñoquis de papa'),
        findsOneWidget,
        reason: 'RecipeDetailLoading no transporta lista: debe usarse la cacheada',
      );

      // El detalle terminó de cargar. Este es el estado con el que queda la
      // pantalla al volver atrás — el que antes la dejaba en blanco.
      bloc.emitir(const RecipeDetailLoaded(_receta, _recetas));
      await tester.pump();
      expect(
        find.text('Ñoquis de papa'),
        findsOneWidget,
        reason: 'al volver del detalle la lista tiene que seguir dibujada',
      );
    },
  );

  testWidgets('un error del detalle no tapa la lista ya cargada', (
    tester,
  ) async {
    final bloc = _TestRecipeBloc();
    addTearDown(bloc.close);

    await _montar(tester, bloc);
    expect(find.text('Ñoquis de papa'), findsOneWidget);

    bloc.emitir(const RecipeError('Error al cargar la receta'));
    await tester.pump();

    expect(find.text('Ñoquis de papa'), findsOneWidget);
    expect(find.text('No pudimos cargar las recetas'), findsNothing);
  });
}
