// lib/data/services/messaging_broadcast_service.dart
import 'package:dio/dio.dart';
import 'package:front_erp_aromair/data/models/whatsapp_broadcast_request.dart';
import 'package:front_erp_aromair/data/models/whatsapp_broadcast_result.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';

class MessagingBroadcastService {
  final Dio _dio;

  MessagingBroadcastService(Dio dio) : _dio = dio;

  Future<WhatsappBroadcastResult> sendTemplateFirst(
    WhatsappBroadcastRequest request,
  ) async {
    final user = await StorageHelper.getUser();
    final token = user?['token'];

    try {
      final resp = await _dio.post(
        'messaging/whatsapp/broadcast/template-first',
        data: request.toJson(),
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (resp.data is Map<String, dynamic>) {
        return WhatsappBroadcastResult.fromJson(
          resp.data as Map<String, dynamic>,
        );
      }

      throw const FormatException('Réponse inattendue du serveur');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final backendMsg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['error'] ??
                e.response?.data['message'] ??
                'Erreur serveur')
          : 'Erreur réseau';

      throw Exception('Échec envoi broadcast (HTTP $status): $backendMsg');
    }
  }
}
