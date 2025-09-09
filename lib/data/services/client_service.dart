import 'package:dio/dio.dart';
import 'package:front_erp_aromair/utils/api_constants.dart';

class ClientService {
  final Dio _dio;
  ClientService(this._dio);

  Future<Map<String, dynamic>> getClientDetail(int clientId) async {
    final res = await _dio.get('${ApiConstants.baseUrl}clients/$clientId/detail');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> updateClient(int id, Map<String, dynamic> body) async {
    await _dio.patch('/clients/$id', data: body);
  }
}
