import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/caisse_sav_detail.dart';

class CaisseService {
  final Dio _dio;
  CaisseService(this._dio);

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(DateTime(d.year, d.month, d.day));

  Future<CaisseSavDetail> getDetail({
    required int userId,
    required DateTime du,
    required DateTime jusqua,
    CancelToken? cancelToken,
  }) async {
    final res = await _dio.get(
      'users/$userId/caisse-sav',
      queryParameters: {'du': _fmt(du), 'jusqua': _fmt(jusqua)},
      cancelToken: cancelToken,
    );
    return CaisseSavDetail.fromJson(res.data as Map<String, dynamic>);
  }


     Future<Map<String, dynamic>> addTransaction({
    required int userId,
    required String type,      // ENTREE | DEPENSE | TRANSFERT
    required double montant,
    String? designation,
    required DateTime date,    // will be sent as dd-MM-yyyy
  }) async {
    final payload = {
      "date": DateFormat('dd-MM-yyyy').format(date),
      "type": type,
      "montant": montant,
      if (designation != null && designation.trim().isNotEmpty)
        "designation": designation.trim(),
    };

    final res = await _dio.post(
      'users/$userId/transactions',
      data: payload,
      options: Options(
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        validateStatus: (code) => code != null && code >= 200 && code < 500,
      ),
    );

    if (res.statusCode == 201 && res.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    print("Response status: ${res.data}");

    // Error: bubble up backend "details"
    final details = (res.data is Map && (res.data as Map)['details'] != null)
        ? (res.data as Map)['details'].toString()
        : 'Erreur inconnue (${res.statusCode})';

    throw Exception(details);
  }
}

