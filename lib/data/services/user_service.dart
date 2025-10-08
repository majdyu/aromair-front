import 'package:dio/dio.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';

class UserService {
  final Dio _dio;
  UserService(this._dio);

  Future<List<Map<String, dynamic>>> getListUser() async {
    final token = (await StorageHelper.getUser())?['token'];
    final resp = await _dio.get(
      'users/list',
      options: Options(
        responseType: ResponseType.json,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
    final data = resp.data;
    if (data is! List) {
      throw StateError(
        'Réponse inattendue pour GET users/list: attendu un tableau JSON [].',
      );
    }
    return List<Map<String, dynamic>>.from(
      data.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  Future<Map<String, dynamic>> updateUser({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    final token = (await StorageHelper.getUser())?['token'];
    final resp = await _dio.put(
      'users/update/$id',
      data: body,
      options: Options(
        responseType: ResponseType.json,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    final data = resp.data;
    if (data is! Map) {
      throw StateError(
        'Réponse inattendue pour PUT users/$id: attendu un objet JSON {}.',
      );
    }
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> createUser({
    required Map<String, dynamic> body,
  }) async {
    final token = (await StorageHelper.getUser())?['token'];
    final resp = await _dio.post(
      'v1/auth/register',
      data: body,
      options: Options(
        responseType: ResponseType.json,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    final data = resp.data;
    if (data is! Map) {
      throw StateError(
        'Réponse inattendue pour POST users: attendu un objet JSON {}.',
      );
    }
    return Map<String, dynamic>.from(data);
  }
}
