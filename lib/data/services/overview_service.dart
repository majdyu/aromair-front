import 'package:dio/dio.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';

class OverviewService {
  final Dio _dio = buildDio(); 

  Future<List<int>> fetchOverview() async {
    print("[OverviewService] Fetch /overview");
    try {
      final user = await StorageHelper.getUser(); // ton helper existant
      final token = user?['token'];

      final response = await _dio.get(
        "clients/overview",
        options: Options(headers: {
          if (token != null && token.toString().isNotEmpty)
            'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      final raw = response.data as List<dynamic>;
      final data = raw.map((e) => (e as num).toInt()).toList();
      print("[OverviewService] Data: $data");

      if (data.length != 8) {
        throw Exception("Réponse inattendue: ${data.length} éléments (8 attendus)");
      }
      return data;
    } catch (e) {
      print("[OverviewService] Error: $e");
      rethrow;
    }
  }
}
