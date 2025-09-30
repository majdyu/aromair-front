import 'package:intl/intl.dart';

class InterventionItem {
  final int id;
  final String client;
  final String equipe;
  final DateTime? derniereIntervention;
  final String statutRaw; // <— renomme explicitement

  InterventionItem({
    required this.id,
    required this.client,
    required this.equipe,
    required this.derniereIntervention,
    required this.statutRaw,
  });

  factory InterventionItem.fromJson(Map<String, dynamic> j) {
    return InterventionItem(
      id: j['id'] as int,
      client: (j['client'] ?? '-') as String,
      equipe: (j['equipe'] ?? '-') as String,
      derniereIntervention: parseBackendDate(j['derniereIntervention']),
      // NE PAS mettre "Tout Statut" ici
      statutRaw: ((j['statut'] ?? 'EN_COURS') as String).trim(),
    );
  }
}

DateTime? parseBackendDate(String? v) {
  if (v == null) return null;
  final s = v.trim();

  // dd-MM-yyyy (e.g., 18-09-2025)
  final dmyDash = RegExp(r'^\d{2}-\d{2}-\d{4}$');
  if (dmyDash.hasMatch(s)) {
    final dt = DateFormat('dd-MM-yyyy').parseStrict(s);
    return DateTime(dt.year, dt.month, dt.day); // local midnight
  }

  // dd/MM/yyyy (just in case)
  final dmySlash = RegExp(r'^\d{2}/\d{2}/\d{4}$');
  if (dmySlash.hasMatch(s)) {
    final dt = DateFormat('dd/MM/yyyy').parseStrict(s);
    return DateTime(dt.year, dt.month, dt.day);
  }

  // yyyy-MM-dd (ISO date only)
  final ymd = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  if (ymd.hasMatch(s)) {
    final p = s.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  // Full ISO timestamps -> let Dart handle and convert to local
  final iso = DateTime.tryParse(s);
  if (iso != null) return iso.toLocal();

  // Fallbacks
  for (final f in ["yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd HH:mm:ss"]) {
    try {
      return DateFormat(f).parseUtc(s).toLocal();
    } catch (_) {}
  }

  return null;
}
