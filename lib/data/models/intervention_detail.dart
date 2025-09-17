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
  final int? userId;
  final String userNom;
  final String? titreFicheMaintenance;
  final String? ficheMaintenance;
  final List<ClientDiffuseurRow> diffuseurs;
  final List<AlerteRow> alertes;
  final List<TafRow> tafs;

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
    required this.userId,
    required this.userNom,
    required this.titreFicheMaintenance,
    required this.ficheMaintenance,
    required this.diffuseurs,
    required this.alertes,
    required this.tafs,
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
    int? userId,
    String? userNom,
    String? titreFicheMaintenance,
    String? ficheMaintenance,
    List<ClientDiffuseurRow>? diffuseurs,
    List<AlerteRow>? alertes,
    List<TafRow>? tafs,
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
      userId: userId ?? this.userId,
      userNom: userNom ?? this.userNom,
      titreFicheMaintenance:
          titreFicheMaintenance ?? this.titreFicheMaintenance,
      ficheMaintenance: ficheMaintenance ?? this.ficheMaintenance,
      diffuseurs: diffuseurs ?? this.diffuseurs,
      alertes: alertes ?? this.alertes,
      tafs: tafs ?? this.tafs,
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
      payement: (j['payement'] as num?)?.toDouble(), // ✅ parse paiement
      clientId: j['clientId'] as int?,
      clientNom: (j['clientNom'] as String?) ?? '-',
      userId: j['userId'] as int?,
      userNom: (j['userNom'] as String?) ?? '-',
      titreFicheMaintenance: j['titreFicheMaintenance'] as String?,
      ficheMaintenance: j['ficheMaintenance'] as String?,
      diffuseurs: diffs,
      alertes: al,
      tafs: tafRows,
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
  final String date;        // "dd/MM/yyyy" (ou ce que renvoie l'API)
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

