// lib/data/models/whatsapp_broadcast_request.dart
class WhatsappBroadcastRequest {
  final List<String>? importances;
  final List<String>? natures;
  final List<String>? types;
  final String message;

  WhatsappBroadcastRequest({
    this.importances,
    this.natures,
    this.types,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      if (importances != null && importances!.isNotEmpty)
        'importances': importances,
      if (natures != null && natures!.isNotEmpty) 'natures': natures,
      if (types != null && types!.isNotEmpty) 'types': types,
      'message': message,
    };
  }
}
