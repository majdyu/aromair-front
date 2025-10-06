// lib/data/services/reclamation_service.dart
import 'package:dio/dio.dart';
import 'package:front_erp_aromair/data/models/create_reclamation_request.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';
import 'package:intl/intl.dart';

class ReclamationService {
  final Dio _dio;
  ReclamationService(this._dio);

  static String? _fmtDate(DateTime? d) {
    if (d == null) return null;
    final local = DateTime(d.year, d.month, d.day);
    return DateFormat('yyyy-MM-dd').format(local);
  }

  Future<List<Map<String, dynamic>>> getListByDate({
    DateTime? du,
    DateTime? jusqua,
    CancelToken? cancelToken,
  }) async {
    final params = <String, dynamic>{};
    final duStr = _fmtDate(du);
    final jsqStr = _fmtDate(jusqua);
    if (duStr != null) params['du'] = duStr;
    if (jsqStr != null) params['jusqua'] = jsqStr;

    try {
      final res = await _dio.get(
        'reclamations/list',
        queryParameters: params.isEmpty ? null : params,
        cancelToken: cancelToken,
      );

      final data = res.data;
      if (data is List) {
        return data
            .where((e) => e is Map)
            .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e as Map),
            )
            .toList();
      }
      return const <Map<String, dynamic>>[];
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      final code = (body is Map && body['code'] is String)
          ? body['code'] as String
          : 'HTTP_$status';
      final msg = (body is Map && body['error'] is String)
          ? body['error'] as String
          : (e.message ?? 'Request error');
      throw Exception('$code: $msg');
    }
  }

  Future<Map<String, dynamic>> getDetail(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final res = await _dio.get('reclamations/$id', cancelToken: cancelToken);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> patch(
    int id, {
    required Map<String, dynamic> body,
    CancelToken? cancelToken,
  }) async {
    await _dio.patch('reclamations/$id', data: body, cancelToken: cancelToken);
  }

  Future<void> create(CreateReclamationRequest body) async {
    final user = await StorageHelper.getUser();
    final token = user?['token'];
    await _dio.post(
      "reclamations/create",
      data: body.toJson(),
      options: Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
