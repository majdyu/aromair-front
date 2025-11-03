// lib/data/repositories/messaging_broadcast_repository.dart
import 'package:front_erp_aromair/data/models/whatsapp_broadcast_request.dart';
import 'package:front_erp_aromair/data/models/whatsapp_broadcast_result.dart';
import 'package:front_erp_aromair/data/services/message_broadcast_service.dart';

class MessagingBroadcastRepository {
  final MessagingBroadcastService _service;

  MessagingBroadcastRepository(this._service);

  /// envoie un broadcast whatsapp (template-first)
  Future<WhatsappBroadcastResult> sendTemplateFirst(
    WhatsappBroadcastRequest request,
  ) {
    return _service.sendTemplateFirst(request);
  }
}
