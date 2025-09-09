// lib/data/services/bouteilles_service.dart
import 'package:dio/dio.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';

class BouteillesService {
  final Dio _dio;
  BouteillesService(this._dio);

  Future<Map<String, dynamic>> getDetail(int id) async {
    final token = (await StorageHelper.getUser())?['token'];
    final resp = await _dio.get(
      'bouteilles/$id',
      options: Options(headers: { if (token != null) 'Authorization': 'Bearer $token' }),
    );
    return Map<String, dynamic>.from(resp.data);
  }
}
