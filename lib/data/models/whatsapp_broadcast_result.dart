// lib/data/models/whatsapp_broadcast_result.dart
class WhatsappBroadcastResult {
  final int totalTargets;
  final int sent;
  final int failed;

  WhatsappBroadcastResult({
    required this.totalTargets,
    required this.sent,
    required this.failed,
  });

  factory WhatsappBroadcastResult.fromJson(Map<String, dynamic> json) {
    return WhatsappBroadcastResult(
      totalTargets: (json['totalTargets'] ?? 0) as int,
      sent: (json['sent'] ?? 0) as int,
      failed: (json['failed'] ?? 0) as int,
    );
  }
}
