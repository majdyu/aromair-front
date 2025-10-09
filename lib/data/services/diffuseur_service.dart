import 'package:dio/dio.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';

class DiffuseurService {
  final Dio _dio;
  DiffuseurService(this._dio);

  Future<List<Map<String, dynamic>>> getList() async {
    final token = (await StorageHelper.getUser())?['token'];

    final resp = await _dio.get(
      'diffuseurs/list',
      options: Options(
        responseType: ResponseType.json,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
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

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final token = (await StorageHelper.getUser())?['token'];

    final resp = await _dio.post(
      'diffuseurs/create',
      data: body,
      options: Options(
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        // let us handle 4xx with a nice error
        validateStatus: (code) => code != null && code < 500,
      ),
    );

    if (resp.statusCode == 201) {
      final data = resp.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      throw StateError('Réponse inattendue: objet JSON attendu {}.');
    }

    // extract a readable error if server returns message/error
    final data = resp.data;
    final msg = (data is Map && (data['error'] ?? data['message']) != null)
        ? (data['error'] ?? data['message']).toString()
        : 'Erreur HTTP ${resp.statusCode} lors de la création';
    throw DioException(
      requestOptions: resp.requestOptions,
      response: resp,
      type: DioExceptionType.badResponse,
      error: msg,
    );
  }

  Future<void> deleteById(int id) async {
    final token = (await StorageHelper.getUser())?['token'];

    final resp = await _dio.delete(
      'diffuseurs/delete/$id',
      options: Options(
        responseType: ResponseType.json,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
        // let us handle 4xx gracefully
        validateStatus: (code) => code != null && code < 500,
      ),
    );

    // 204 => success, nothing in body
    if (resp.statusCode == 204) return;

    // other handled errors: 404 / 409 with a body {error, code}
    final data = resp.data;
    final errMsg = (data is Map && data['error'] != null)
        ? data['error'].toString()
        : 'Erreur HTTP ${resp.statusCode}';
    throw DioException(
      requestOptions: resp.requestOptions,
      response: resp,
      type: DioExceptionType.badResponse,
      error: errMsg,
    );
  }
}
