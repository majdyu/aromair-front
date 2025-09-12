import 'package:dio/dio.dart';

class ClientDiffuseurService {
  final Dio _dio;
  ClientDiffuseurService(this._dio);

  // Détail (utile si tu as besoin ailleurs)
  Future<Map<String, dynamic>> getDetail(int id) async {
    final res = await _dio.get('/client-diffuseurs/$id/detail');
    return Map<String, dynamic>.from(res.data as Map);
  }

  // Affectation initiale : /client-diffuseurs/{cab}/affecter-client/{clientId}/init
  Future<void> affecterInit({
    required int clientId,
    required String cab,
    required Map<String, dynamic> body,
  }) async {
    final res = await _dio.put(
      'client-diffuseurs/$cab/affecter-client/$clientId/init',
      data: body,
    );
    if (res.statusCode != 200) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: 'Affectation échouée (${res.statusCode})',
      );
    }
  }

// Affectation modification : /client-diffuseurs/{cab}
  Future<void> retirerClient({required String cab}) async {
    final res = await _dio.put('/client-diffuseurs/$cab/retirer-client');
    if (res.statusCode != 200) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: 'Retrait échoué (${res.statusCode})',
      );
    }
  }
}
