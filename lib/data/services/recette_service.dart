import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/recette_clients_detail.dart';

class RecetteService {
  final Dio _dio;
  RecetteService(this._dio);

  String _fmt(DateTime d) =>
      DateFormat('yyyy-MM-dd').format(DateTime(d.year, d.month, d.day));

  Future<RecetteClientsDetail> getDetail({
    required int userId,
    required DateTime du,
    required DateTime jusqua,
    CancelToken? cancelToken,
  }) async {
    final res = await _dio.get(
      'users/$userId/recette-clients',
      queryParameters: {'du': _fmt(du), 'jusqua': _fmt(jusqua)},
      cancelToken: cancelToken,
    );
    return RecetteClientsDetail.fromJson(res.data as Map<String, dynamic>);
  }

  Future<RecetteClientsDetail> updatePaymentReceiptStatus({
    required int transactionId,
  }) async {
    final res = await _dio.patch('users/$transactionId/recu/toggle');
    return RecetteClientsDetail.fromJson(res.data as Map<String, dynamic>);
  }
}
