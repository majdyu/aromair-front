import 'package:dio/dio.dart';

class AlertesService {
  final Dio _dio;
  AlertesService(this._dio);

  /// GET /api/alertes/{id}
  Future<Map<String, dynamic>> getDetail(int id) async {
    final resp = await _dio.get(
      'alertes/$id',
      options: Options(responseType: ResponseType.json),
    );

    if (resp.data is! Map) {
      throw StateError(
        'Réponse non-JSON reçue pour GET alertes/$id. '
        'Vérifie baseUrl (doit finir par /api/) et l’URL appelée.',
      );
    }
    return Map<String, dynamic>.from(resp.data as Map);
  }

  /// PATCH /api/alertes/{id}/toggle
  Future<void> toggle(int id, {String? decisionPrise}) async {
    await _dio.patch(
      'alertes/$id/toggle',
      data: decisionPrise == null ? null : {'decisionPrise': decisionPrise},
      options: Options(responseType: ResponseType.json),
    );
  }

  Future<List<Map<String, dynamic>>> getList() async {
    final resp = await _dio.get(
      'alertes/list',
      options: Options(responseType: ResponseType.json),
    );

    final data = resp.data;
    if (data is! List) {
      throw StateError(
        'Réponse inattendue pour GET alertes/list: attendu une liste JSON [].',
      );
    }

    return data
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }
}
