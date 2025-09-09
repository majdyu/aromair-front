import 'package:dio/dio.dart';
import '../../utils/storage_helper.dart';

class AlertesService {
  final Dio _dio;
  AlertesService(this._dio);

  /// GET /api/alertes/{id}
  Future<Map<String, dynamic>> getDetail(int id) async {
    final token = (await StorageHelper.getUser())?['token'];

    final resp = await _dio.get(
      'alertes/$id',
      options: Options(
        responseType: ResponseType.json,
        headers: { if (token != null) 'Authorization': 'Bearer $token' },
      ),
    );

    // Défense : si backend renvoie du HTML (erreur de baseUrl/chemin), on lève une erreur claire
    if (resp.data is! Map) {
      throw StateError(
        'Réponse non-JSON reçue pour GET alertes/$id. '
        'Vérifie baseUrl (doit finir par /api/) et l’URL appelée.',
      );
    }
    return Map<String, dynamic>.from(resp.data as Map);
  }

  /// PATCH /api/alertes/{id}/toggle
  /// Body optionnel: { "decisionPrise": "..." }
  Future<void> toggle(int id, {String? decisionPrise}) async {
    final token = (await StorageHelper.getUser())?['token'];

    await _dio.patch(
      'alertes/$id/toggle',
      data: decisionPrise == null ? null : {'decisionPrise': decisionPrise},
      options: Options(
        responseType: ResponseType.json, // même si 204, on force json pour homogénéité
        headers: { if (token != null) 'Authorization': 'Bearer $token' },
      ),
    );
  }
}
