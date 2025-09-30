import 'package:dio/dio.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/equipe.dart';
import 'package:front_erp_aromair/utils/api_constants.dart';

class EquipesService {
  final Dio _dio;

  EquipesService({Dio? dio}) : _dio = dio ?? buildDio();

  Future<List<Equipe>> getEquipes() async {
    final res = await _dio.get('${ApiConstants.baseUrl}equipes/getEquipes');

    if (res.statusCode != null &&
        res.statusCode! >= 200 &&
        res.statusCode! < 300) {
      return Equipe.listFromJson(res.data);
    }
    throw Exception(
      'Erreur ${res.statusCode}: ${res.statusMessage ?? 'échec de récupération des équipes'}',
    );
  }
}
