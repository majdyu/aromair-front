import 'package:dio/dio.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/utils/api_constants.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';

class ClientService {
  final Dio _dio = buildDio();

  Future<Map<String, dynamic>> getClientDetail(int clientId) async {
    final res = await _dio.get(
      '${ApiConstants.baseUrl}clients/$clientId/detail',
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> updateClient(int id, Map<String, dynamic> body) async {
    await _dio.patch('/clients/$id', data: body);
  }

  Future<List<dynamic>> getClients({String? q, String? type}) async {
    final user = await StorageHelper.getUser();
    final token = user?['token'];

    final res = await _dio.get(
      '${ApiConstants.baseUrl}clients/list',
      queryParameters: {
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        if (type != null && type.isNotEmpty) 'type': type,
      },
      options: Options(
        headers: {
          if (token != null && token.toString().isNotEmpty)
            'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    if (res.statusCode == 200 && res.data is List) {
      return res.data as List;
    }
    throw Exception('Unexpected response: ${res.statusCode}');
  }

  Future<bool> toggleActive(int id) async {
    final user = await StorageHelper.getUser();
    final token = user?['token'];
    final resp = await _dio.patch(
      '${ApiConstants.baseUrl}clients/$id/toggle-active',
      options: Options(
        headers: {
          if (token != null && token.toString().isNotEmpty)
            'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    if (resp.statusCode == 200 && resp.data is Map) {
      return (resp.data['estActive'] as bool?) ?? false;
    }
    throw Exception('Toggle failed (${resp.statusCode})');
  }

  Future<void> createClient(Map<String, dynamic> body) async {
    final user = await StorageHelper.getUser();
    final token = user?['token'];

    try {
      final resp = await _dio.post(
        '${ApiConstants.baseUrl}clients/create',
        data: body,
        options: Options(
          headers: {
            if (token != null && token.toString().isNotEmpty)
              'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (resp.statusCode == 201 || resp.statusCode == 204) return;

      if (resp.statusCode == 200) return;

      throw Exception('Unexpected response: ${resp.statusCode}');
    } on DioError catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      String backendMsg;

      if (data is Map && data['message'] is String) {
        backendMsg = data['message'] as String;
      } else if (data is Map && data['error'] is String) {
        backendMsg = data['error'] as String;
      } else {
        backendMsg = 'Erreur lors de la création du client.';
      }
      throw Exception('$backendMsg (HTTP $status)');
    }
  }
}
