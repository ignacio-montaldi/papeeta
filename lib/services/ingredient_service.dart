import 'package:dio/dio.dart';
import 'package:papeeta/global/enviroment.dart';
import 'package:papeeta/models/response/ingredients_units_response_model.dart';
import 'package:papeeta/services/services.dart';

class IngredientService {
  final Dio _dio;
  final String _baseIngredientsUrl = '${Enviroment.apiUrl}/ingredients';

  IngredientService() : _dio = Dio()..interceptors.add(PapeetaInterceptor());

  Future<IngredientsUnitsResponseModel> getUnits() async {
    final url = "$_baseIngredientsUrl/units";

    final resp = await _dio.get(url);

    final data = IngredientsUnitsResponseModel.fromJson(resp.data);

    return data;
  }
}
