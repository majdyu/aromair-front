import 'package:intl/intl.dart';

enum StatutReclamation { EN_COURS, TRAITE, FAUSSE_RECLAMATION, DEPASSE_48H }

extension StatutReclamationX on StatutReclamation {
  String get apiValue {
    switch (this) {
      case StatutReclamation.EN_COURS: return 'EN_COURS';
      case StatutReclamation.TRAITE: return 'TRAITE';
      case StatutReclamation.FAUSSE_RECLAMATION: return 'FAUSSE_RECLAMATION';
      case StatutReclamation.DEPASSE_48H: return 'DEPASSE_48H';
    }
  }
  static StatutReclamation fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'TRAITE': return StatutReclamation.TRAITE;
      case 'FAUSSE_RECLAMATION': return StatutReclamation.FAUSSE_RECLAMATION;
      case 'DEPASSE_48H': return StatutReclamation.DEPASSE_48H;
      case 'EN_COURS':
      default: return StatutReclamation.EN_COURS;
    }
  }
}

class ReclamationDetail {
  final int id;
  final DateTime date;
  final String? probleme;
  final String? dernierTechnicien;
  final int? clientId;
  final String? client;
  final bool etapes;
  final StatutReclamation statut;

  const ReclamationDetail({
    required this.id,
    required this.date,
    required this.probleme,
    required this.dernierTechnicien,
    required this.clientId,
    required this.client,
    required this.etapes,
    required this.statut,
  });

  ReclamationDetail copyWith({
    int? id,
    DateTime? date,
    String? probleme,
    String? dernierTechnicien,
    int? clientId,
    String? client,
    bool? etapes,
    StatutReclamation? statut,
  }) {
    return ReclamationDetail(
      id: id ?? this.id,
      date: date ?? this.date,
      probleme: probleme ?? this.probleme,
      dernierTechnicien: dernierTechnicien ?? this.dernierTechnicien,
      clientId: clientId ?? this.clientId,
      client: client ?? this.client,
      etapes: etapes ?? this.etapes,
      statut: statut ?? this.statut,
    );
  }

  String get dateLabel => DateFormat('dd/MM/yyyy').format(date);
  bool get canPlanifier => etapes == true;

  factory ReclamationDetail.fromJson(Map<String, dynamic> j) {
    DateTime _parseDate(dynamic v) {
      if (v is String) {
        final s = v.trim();
        // d'abord dd/MM/yyyy
        try { return DateFormat('dd/MM/yyyy').parse(s); } catch (_) {}
        // puis ISO
        try { return DateTime.parse(s).toLocal(); } catch (_) {}
      }
      if (v is List && v.isNotEmpty) {
        final y  = v.length > 0 ? (v[0] as num?)?.toInt() ?? 0 : 0;
        final m  = v.length > 1 ? (v[1] as num?)?.toInt() ?? 1 : 1;
        final d  = v.length > 2 ? (v[2] as num?)?.toInt() ?? 1 : 1;
        final hh = v.length > 3 ? (v[3] as num?)?.toInt() ?? 0 : 0;
        final mm = v.length > 4 ? (v[4] as num?)?.toInt() ?? 0 : 0;
        final ss = v.length > 5 ? (v[5] as num?)?.toInt() ?? 0 : 0;
        return DateTime(y, m, d, hh, mm, ss);
      }
      return DateTime.now();
    }

    final rawStatut = (j['statutReclammation'] ?? j['statut'] ?? j['status'])?.toString();

    // On lit "clientNom" si présent; sinon on tente "client" (string ou objet)
    String? _clientName() {
      if (j['clientNom'] != null) return j['clientNom'].toString();
      final c = j['client'];
      if (c == null) return null;
      if (c is Map) return (c['nom'] ?? c['name'])?.toString();
      return c.toString();
    }

    int? _clientId() {
      final v = j['clientId'] ?? j['client'];
      if (v == null) return null;
      if (v is Map) return (v['id'] as num?)?.toInt();
      return (v as num?)?.toInt();
    }

    return ReclamationDetail(
      id: (j['id'] as num).toInt(),
      date: _parseDate(j['date']),
      probleme: j['probleme']?.toString(),
      dernierTechnicien: j['dernierTechnicien']?.toString(),
      clientId: _clientId(),
      client: _clientName(),
      etapes: j['etapes'] == true,
      statut: StatutReclamationX.fromApi(rawStatut),
    );
  }


  Map<String, dynamic> toPatch({bool? etapes, StatutReclamation? statut}) {
    final m = <String, dynamic>{};
    if (etapes != null) m['etapes'] = etapes;
    if (statut != null) m['statutReclammation'] = statut.apiValue;
    return m;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'probleme': probleme,
    'dernierTechnicien': dernierTechnicien,
    'clientId': clientId,
    'client': client,
    'etapes': etapes,
    'statutReclammation': statut.apiValue,
  };
}
