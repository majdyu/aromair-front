import 'package:dio/dio.dart';

class ReclamationService {
  final Dio _dio;
  ReclamationService(this._dio);

  Future<Map<String, dynamic>> getDetail(int id) async {
    final res = await _dio.get('reclamations/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> patch(int id, {required Map<String, dynamic> body}) async {
    await _dio.patch('reclamations/$id', data: body);
  }
}
