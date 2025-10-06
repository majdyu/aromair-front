// lib/data/models/reclamation_row.dart
import 'package:front_erp_aromair/data/enums/statut_reclamation.dart';
import 'package:intl/intl.dart';

StatutReclamation StatutReclamationFromJson(dynamic value) {
  if (value == null) return StatutReclamation.unknown;
  final s = value.toString().trim();
  for (final v in StatutReclamation.values) {
    if (v.name == s) return v;
  }
  return StatutReclamation.unknown;
}

String StatutReclamationToJson(StatutReclamation v) => v.name;

DateTime? _parseDateFlexible(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  final s = v.toString().trim();
  if (s.isEmpty) return null;

  try {
    return DateFormat('dd/MM/yyyy').parseStrict(s);
  } catch (_) {}

  try {
    return DateTime.parse(s);
  } catch (_) {}

  return null;
}

String? _formatDateDdMMyyyy(DateTime? d) {
  if (d == null) return null;
  return DateFormat('dd/MM/yyyy').format(d);
}

class ReclamationRow {
  final int id;
  final DateTime? date;
  final String probleme;
  final StatutReclamation statutReclamation;
  final String? decisionPrise;
  final bool? etapes;
  final String? clientNom;
  final String? derniereEquipeNom;
  final List<String> techniciens;

  const ReclamationRow({
    required this.id,
    required this.date,
    required this.probleme,
    required this.statutReclamation,
    this.decisionPrise,
    this.etapes,
    this.clientNom,
    this.derniereEquipeNom,
    this.techniciens = const [],
  });

  factory ReclamationRow.fromJson(Map<String, dynamic> json) {
    return ReclamationRow(
      id: (json['id'] as num).toInt(),
      date: _parseDateFlexible(json['date']),
      probleme: (json['probleme'] ?? '') as String,
      statutReclamation: StatutReclamationFromJson(json['statutReclammation']),
      decisionPrise: json['decisionPrise'] as String?,
      etapes: json['etapes'] as bool?,
      clientNom: json['clientNom'] as String?,
      derniereEquipeNom: json['derniereEquipeNom'] as String?,
      techniciens:
          (json['techniciens'] as List?)
              ?.map((e) => e?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    // Keep backend format dd/MM/yyyy to match @JsonFormat
    'date': _formatDateDdMMyyyy(date),
    'probleme': probleme,
    'StatutReclamation': StatutReclamationToJson(statutReclamation),
    'decisionPrise': decisionPrise,
    'etapes': etapes,
    'clientNom': clientNom,
    'derniereEquipeNom': derniereEquipeNom,
    'techniciens': techniciens,
  };

  ReclamationRow copyWith({
    int? id,
    DateTime? date,
    String? probleme,
    StatutReclamation? statutReclamation,
    String? decisionPrise,
    bool? etapes,
    String? clientNom,
    String? derniereEquipeNom,
    List<String>? techniciens,
  }) {
    return ReclamationRow(
      id: id ?? this.id,
      date: date ?? this.date,
      probleme: probleme ?? this.probleme,
      statutReclamation: statutReclamation ?? this.statutReclamation,
      decisionPrise: decisionPrise ?? this.decisionPrise,
      etapes: etapes ?? this.etapes,
      clientNom: clientNom ?? this.clientNom,
      derniereEquipeNom: derniereEquipeNom ?? this.derniereEquipeNom,
      techniciens: techniciens ?? this.techniciens,
    );
  }

  // Convenience for UI
  String get formattedDate => _formatDateDdMMyyyy(date) ?? '-';
}
