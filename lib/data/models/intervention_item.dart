import 'package:intl/intl.dart';

class InterventionItem {
  final int id;
  final String client;
  final String equipe;
  final DateTime? derniereIntervention;
  final String statutRaw;
  final int tafCount;

  InterventionItem({
    required this.id,
    required this.client,
    required this.equipe,
    required this.derniereIntervention,
    required this.statutRaw,
    required this.tafCount,
  });

  factory InterventionItem.fromJson(Map<String, dynamic> j) {
    return InterventionItem(
      id: j['id'] as int,
      client: (j['client'] ?? '-') as String,
      equipe: (j['equipe'] ?? '-') as String,
      derniereIntervention: parseBackendDate(j['derniereIntervention']),
      statutRaw: ((j['statut'] ?? 'EN_COURS') as String).trim(),
      tafCount: (j['tafCount'] ?? 0) as int,
    );
  }
}

DateTime? parseBackendDate(String? v) {
  if (v == null) return null;
  final s = v.trim();

  // dd-MM-yyyy
  if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(s)) {
    final dt = DateFormat('dd-MM-yyyy').parseStrict(s);
    return DateTime(dt.year, dt.month, dt.day);
  }

  // dd/MM/yyyy
  if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(s)) {
    final dt = DateFormat('dd/MM/yyyy').parseStrict(s);
    return DateTime(dt.year, dt.month, dt.day);
  }

  // yyyy-MM-dd
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
    final p = s.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  // ISO full
  final iso = DateTime.tryParse(s);
  if (iso != null) return iso.toLocal();

  for (final f in ["yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd HH:mm:ss"]) {
    try {
      return DateFormat(f).parseUtc(s).toLocal();
    } catch (_) {}
  }

  return null;
}
