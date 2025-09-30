class InterventionDetail {
  final int id;
  final DateTime date;
  final DateTime? derniereIntervention;
  final bool estPayementObligatoire;
  final String statut;
  final String? remarque;
  final double? payement;
  final int? clientId;
  final String clientNom;
  final int? equipeId;
  final String equipeNom;
  final String? titreFicheMaintenance;
  final String? ficheMaintenance;
  final List<ClientDiffuseurRow> diffuseurs;
  final List<AlerteRow> alertes;
  final List<TafRow> tafs;
  final List<String> techniciens;

  InterventionDetail({
    required this.id,
    required this.date,
    required this.derniereIntervention,
    required this.estPayementObligatoire,
    required this.statut,
    required this.remarque,
    required this.payement,
    required this.clientId,
    required this.clientNom,
    required this.equipeId,
    required this.equipeNom,
    required this.titreFicheMaintenance,
    required this.ficheMaintenance,
    required this.diffuseurs,
    required this.alertes,
    required this.tafs,
    required this.techniciens,
  });

  /// ✅ Ajout: copyWith pour permettre l’update optimiste
  InterventionDetail copyWith({
    int? id,
    DateTime? date,
    DateTime? derniereIntervention,
    bool? estPayementObligatoire,
    String? statut,
    String? remarque,
    double? payement,
    int? clientId,
    String? clientNom,
    int? equipeId,
    String? equipeNom,
    String? titreFicheMaintenance,
    String? ficheMaintenance,
    List<ClientDiffuseurRow>? diffuseurs,
    List<AlerteRow>? alertes,
    List<TafRow>? tafs,
    List<String>? techniciens,
  }) {
    return InterventionDetail(
      id: id ?? this.id,
      date: date ?? this.date,
      derniereIntervention: derniereIntervention ?? this.derniereIntervention,
      estPayementObligatoire:
          estPayementObligatoire ?? this.estPayementObligatoire,
      statut: statut ?? this.statut,
      remarque: remarque ?? this.remarque,
      payement: payement ?? this.payement,
      clientId: clientId ?? this.clientId,
      clientNom: clientNom ?? this.clientNom,
      equipeId: equipeId ?? this.equipeId,
      equipeNom: equipeNom ?? this.equipeNom,
      titreFicheMaintenance:
          titreFicheMaintenance ?? this.titreFicheMaintenance,
      ficheMaintenance: ficheMaintenance ?? this.ficheMaintenance,
      diffuseurs: diffuseurs ?? this.diffuseurs,
      alertes: alertes ?? this.alertes,
      tafs: tafs ?? this.tafs,
      techniciens: this.techniciens,
    );
  }

  factory InterventionDetail.fromJson(Map<String, dynamic> j) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.parse(v);
      if (v is List && v.length >= 3) {
        final y = v[0] as int, m = v[1] as int, d = v[2] as int;
        final hh = v.length > 3 ? v[3] as int : 0;
        final mm = v.length > 4 ? v[4] as int : 0;
        return DateTime(y, m, d, hh, mm);
      }
      return null;
    }

    final diffs = (j['diffuseurs'] as List? ?? [])
        .map((e) => ClientDiffuseurRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final al = (j['alertes'] as List? ?? [])
        .map((e) => AlerteRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final tafRows = (j['tafs'] as List? ?? [])
        .map((e) => TafRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return InterventionDetail(
      id: j['id'] as int,
      date: parseDate(j['date'])!,
      derniereIntervention: parseDate(j['derniereIntervention']),
      estPayementObligatoire: (j['estPayementObligatoire'] as bool?) ?? false,
      statut: (j['statut'] as String?) ?? 'EN_COURS',
      remarque: j['remarque'] as String?,
      payement: (j['payement'] as num?)?.toDouble(),
      clientId: j['clientId'] as int?,
      clientNom: (j['clientNom'] as String?) ?? '-',
      equipeId: j['equipeId'] as int?,
      equipeNom: (j['equipeNom'] as String?) ?? '-',
      titreFicheMaintenance: j['titreFicheMaintenance'] as String?,
      ficheMaintenance: j['ficheMaintenance'] as String?,
      diffuseurs: diffs,
      alertes: al,
      tafs: tafRows,
      techniciens: parseTechniciens(j['techniciens']), // ✅ NEW
    );
  }
}

List<String> parseTechniciens(dynamic v) {
  if (v == null) return const [];
  if (v is List) {
    final res = v
        .map((e) {
          if (e == null) return null;
          if (e is String) return e;
          if (e is Map) {
            final m = Map<String, dynamic>.from(e);
            final val =
                m['nom'] ??
                m['name'] ??
                m['username'] ??
                m['label'] ??
                (m.isNotEmpty ? m.values.first : null);
            return val?.toString();
          }
          return e.toString();
        })
        .whereType<String>()
        .toList();
    return List.unmodifiable(res);
  }
  if (v is String) {
    final res = v
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return List.unmodifiable(res);
  }
  return const [];
}

class TafRow {
  final int id;
  final String type; // "CONTROLE", "DEMO", ...
  final int? clientDiffuseurId;
  final String clientDiffuseurLabel;

  TafRow({
    required this.id,
    required this.type,
    required this.clientDiffuseurId,
    required this.clientDiffuseurLabel,
  });

  factory TafRow.fromJson(Map<String, dynamic> j) => TafRow(
    id: j['id'] as int,
    type: (j['type'] as String?) ?? '-',
    clientDiffuseurId: j['clientDiffuseurId'] as int?,
    clientDiffuseurLabel: (j['clientDiffuseurLabel'] as String?) ?? '-',
  );
}

class ClientDiffuseurRow {
  final int id;
  final String cab;
  final String modeleDiffuseur;
  final String _type;
  final String emplacement;

  ClientDiffuseurRow({
    required this.id,
    required this.cab,
    required this.modeleDiffuseur,
    required String type,
    required this.emplacement,
  }) : _type = type;

  String get typeDiffuseur => _type; // getter canonique
  String get typeCarte => _type; // alias

  factory ClientDiffuseurRow.fromJson(Map<String, dynamic> j) {
    return ClientDiffuseurRow(
      id: j['id'] as int,
      cab: (j['cab'] as String?) ?? '-',
      modeleDiffuseur: (j['modeleDiffuseur'] as String?) ?? '-',
      type:
          (j['typeDiffuseur'] as String?) ?? (j['typeCarte'] as String?) ?? '-',
      emplacement: (j['emplacement'] as String?) ?? '-',
    );
  }
}

class AlerteRow {
  final int id;
  final String date; // "dd/MM/yyyy" (ou ce que renvoie l'API)
  final String? probleme;
  final String? cause;
  final String etatResolution;

  AlerteRow({
    required this.id,
    required this.date,
    required this.probleme,
    required this.cause,
    required this.etatResolution,
  });

  factory AlerteRow.fromJson(Map<String, dynamic> j) => AlerteRow(
    id: (j['id'] as num).toInt(),
    date: (j['date'] ?? '-').toString(),
    probleme: j['probleme']?.toString(),
    cause: j['cause']?.toString(),
    etatResolution: (j['etatResolution'] ?? '-').toString(),
  );
}
