class InterventionDetail {
  final int id;
  final DateTime date;
  final DateTime? derniereIntervention;
  final bool estPayementObligatoire;
  final String statut;
  final String? remarque;
  final int? clientId;
  final String clientNom;
  final int? userId;
  final String userNom;
  final String? titreFicheMaintenance;
  final String? ficheMaintenance;
  final List<ClientDiffuseurRow> diffuseurs;
  final List<AlerteRow> alertes;
  final List<TafRow> tafs; // <-- AJOUT

  InterventionDetail({
    required this.id,
    required this.date,
    required this.derniereIntervention,
    required this.estPayementObligatoire,
    required this.statut,
    required this.remarque,
    required this.clientId,
    required this.clientNom,
    required this.userId,
    required this.userNom,
    required this.titreFicheMaintenance,
    required this.ficheMaintenance,
    required this.diffuseurs,
    required this.alertes,
    required this.tafs, // <-- AJOUT
  });

  factory InterventionDetail.fromJson(Map<String, dynamic> j) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.parse(v); // ISO
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
      clientId: j['clientId'] as int?,
      clientNom: (j['clientNom'] as String?) ?? '-',
      userId: j['userId'] as int?,
      userNom: (j['userNom'] as String?) ?? '-',
      titreFicheMaintenance: j['titreFicheMaintenance'] as String?,
      ficheMaintenance: j['ficheMaintenance'] as String?,
      diffuseurs: diffs,
      alertes: al,
      tafs: tafRows, // <-- AJOUT
    );
  }
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
  /// Peut venir sous la clé `typeDiffuseur` **ou** `typeCarte` côté API.
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
  String get typeCarte => _type;     // alias

  factory ClientDiffuseurRow.fromJson(Map<String, dynamic> j) {
    return ClientDiffuseurRow(
      id: j['id'] as int,
      cab: (j['cab'] as String?) ?? '-',
      modeleDiffuseur: (j['modeleDiffuseur'] as String?) ?? '-',
      type: (j['typeDiffuseur'] as String?) ??
          (j['typeCarte'] as String?) ??
          '-',
      emplacement: (j['emplacement'] as String?) ?? '-',
    );
  }
}

class AlerteRow {
  final int id;
  final String cab;
  final String typeDiffuseur;
  final String etatResolution;

  AlerteRow({
    required this.id,
    required this.cab,
    required this.typeDiffuseur,
    required this.etatResolution,
  });

  factory AlerteRow.fromJson(Map<String, dynamic> j) {
    return AlerteRow(
      id: j['id'] as int,
      cab: (j['cab'] as String?) ?? '-',
      typeDiffuseur:
          (j['typeDiffuseur'] as String?) ?? (j['typeCarte'] as String?) ?? '-',
      etatResolution: (j['etatResolution'] as String?) ?? '-',
    );
  }
}
