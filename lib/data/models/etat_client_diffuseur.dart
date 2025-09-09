class EtatClientDiffuseur {
  final int interventionId;
  final int clientDiffuseurId;

  // En-tête CD
  final String cab;
  final String modele;
  final String typeCarte;
  final String emplacement;
  final DateTime? dateMiseEnMarche; // DateTime? pour format propre
  final int? maxMinutesParJour;

  // Détails pivot (dans l’intervention)
  final List<ProgrammeEtat> programmes;
  final BouteilleEtat? bouteille;

  // Flags pivot (dans l’intervention)
  final bool? qualiteBonne;
  final bool? fuite;
  final bool? enMarche;

  // Alertes liées à ce CD
  final List<AlerteEtat> alertes;

  EtatClientDiffuseur({
    required this.interventionId,
    required this.clientDiffuseurId,
    required this.cab,
    required this.modele,
    required this.typeCarte,
    required this.emplacement,
    required this.dateMiseEnMarche,
    required this.maxMinutesParJour,
    required this.programmes,
    required this.bouteille,
    required this.qualiteBonne,
    required this.fuite,
    required this.enMarche,
    required this.alertes,
  });

  EtatClientDiffuseur copyWith({
    String? cab,
    String? modele,
    String? typeCarte,
    String? emplacement,
    DateTime? dateMiseEnMarche,
    int? maxMinutesParJour,
    List<ProgrammeEtat>? programmes,
    BouteilleEtat? bouteille,
    bool? qualiteBonne,
    bool? fuite,
    bool? enMarche,
    List<AlerteEtat>? alertes,
  }) {
    return EtatClientDiffuseur(
      interventionId: interventionId,
      clientDiffuseurId: clientDiffuseurId,
      cab: cab ?? this.cab,
      modele: modele ?? this.modele,
      typeCarte: typeCarte ?? this.typeCarte,
      emplacement: emplacement ?? this.emplacement,
      dateMiseEnMarche: dateMiseEnMarche ?? this.dateMiseEnMarche,
      maxMinutesParJour: maxMinutesParJour ?? this.maxMinutesParJour,
      programmes: programmes ?? this.programmes,
      bouteille: bouteille ?? this.bouteille,
      qualiteBonne: qualiteBonne ?? this.qualiteBonne,
      fuite: fuite ?? this.fuite,
      enMarche: enMarche ?? this.enMarche,
      alertes: alertes ?? this.alertes,
    );
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {}
    }
    if (v is List && v.length >= 3) {
      final y = v[0] as int, m = v[1] as int, d = v[2] as int;
      final hh = v.length > 3 ? v[3] as int : 0;
      final mm = v.length > 4 ? v[4] as int : 0;
      final ss = v.length > 5 ? v[5] as int : 0;
      return DateTime(y, m, d, hh, mm, ss);
    }
    return null;
  }

  factory EtatClientDiffuseur.fromJson(Map<String, dynamic> j) {
    List<T> _list<T>(dynamic v, T Function(dynamic) map) {
      if (v is List) return v.map(map).toList();
      return const [];
    }

    final programmes = _list<ProgrammeEtat>(
      j['programmes'],
      (e) => ProgrammeEtat.fromJson(Map<String, dynamic>.from(e as Map)),
    );

    final bouteille = j['bouteille'] == null
        ? null
        : BouteilleEtat.fromJson(Map<String, dynamic>.from(j['bouteille'] as Map));

    final alertes = _list<AlerteEtat>(
      j['alertes'],
      (e) => AlerteEtat.fromJson(Map<String, dynamic>.from(e as Map)),
    );

    return EtatClientDiffuseur(
      interventionId: (j['interventionId'] as num).toInt(),
      clientDiffuseurId: (j['clientDiffuseurId'] as num).toInt(),
      cab: (j['cab'] as String?) ?? '-',
      modele: (j['modele'] as String?) ?? '-',
      typeCarte: (j['typeCarte'] as String?) ?? '-',
      emplacement: (j['emplacement'] as String?) ?? '-',
      dateMiseEnMarche: _parseDateTime(j['dateMiseEnMarche']),
      maxMinutesParJour: (j['maxMinutesParJour'] as num?)?.toInt(),
      programmes: programmes,
      bouteille: bouteille,
      qualiteBonne: j['qualiteBonne'] as bool?,
      fuite: j['fuite'] as bool?,
      enMarche: j['enMarche'] as bool?,
      alertes: alertes,
    );
  }

  Map<String, dynamic> toJson() => {
        'interventionId': interventionId,
        'clientDiffuseurId': clientDiffuseurId,
        'cab': cab,
        'modele': modele,
        'typeCarte': typeCarte,
        'emplacement': emplacement,
        'dateMiseEnMarche': dateMiseEnMarche?.toIso8601String(),
        'maxMinutesParJour': maxMinutesParJour,
        'programmes': programmes.map((e) => e.toJson()).toList(),
        'bouteille': bouteille?.toJson(),
        'qualiteBonne': qualiteBonne,
        'fuite': fuite,
        'enMarche': enMarche,
        'alertes': alertes.map((e) => e.toJson()).toList(),
      };
}

class ProgrammeEtat {
  final int? tempsEnMarche;
  final int? tempsDeRepos;
  final String? unite;
  final String? heureDebut;
  final String? heureFin;
  final List<String> joursActifs;

  ProgrammeEtat({
    required this.tempsEnMarche,
    required this.tempsDeRepos,
    required this.unite,
    required this.heureDebut,
    required this.heureFin,
    required this.joursActifs,
  });

  factory ProgrammeEtat.fromJson(Map<String, dynamic> j) {
    List<String> _days(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    return ProgrammeEtat(
      tempsEnMarche: (j['tempsEnMarche'] as num?)?.toInt(),
      tempsDeRepos: (j['tempsDeRepos'] as num?)?.toInt(),
      unite: j['unite']?.toString(),
      heureDebut: j['heureDebut']?.toString(),
      heureFin: j['heureFin']?.toString(),
      joursActifs: _days(j['joursActifs']),
    );
  }

  Map<String, dynamic> toJson() => {
        'tempsEnMarche': tempsEnMarche,
        'tempsDeRepos': tempsDeRepos,
        'unite': unite,
        'heureDebut': heureDebut,
        'heureFin': heureFin,
        'joursActifs': joursActifs,
      };
}

class BouteilleEtat {
  final int? id; 
  final String? type;
  final String? parfum;
  final int? qteInitiale;
  final int? qtePrevu;
  final int? qteExistante;

  BouteilleEtat({
    required this.id,   
    required this.type,
    required this.parfum,
    required this.qteInitiale,
    required this.qtePrevu,
    required this.qteExistante,
  });

  /// Alias pour compatibilité UI existante
  int? get qteLaisse => qteExistante;

  factory BouteilleEtat.fromJson(Map<String, dynamic> j) {
    final exist = (j['qteExistante'] ?? j['qteLaisse']) as num?;
    return BouteilleEtat(
      id: (j['id'] as num?)?.toInt(), 
      type: j['type']?.toString(),
      parfum: j['parfum']?.toString(),
      qteInitiale: (j['qteInitiale'] as num?)?.toInt(),
      qtePrevu: (j['qtePrevu'] as num?)?.toInt(),
      qteExistante: exist?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,              
        'type': type,
        'parfum': parfum,
        'qteInitiale': qteInitiale,
        'qtePrevu': qtePrevu,
        'qteExistante': qteExistante,
      };
}

/// Spécifique à cet écran (évite la collision avec AlerteRow)
class AlerteEtat {
  final int id;   
  final String date; // ex: "16/07/2025"
  final String? probleme;
  final String? cause;
  final String etatResolution;

  AlerteEtat({
    required this.id,
    required this.date,
    required this.probleme,
    required this.cause,
    required this.etatResolution,
  });

  factory AlerteEtat.fromJson(Map<String, dynamic> j) {
    String _etat(dynamic v) {
      if (v == null) return "-";
      if (v is bool) return v ? "Résolu" : "Non résolu";
      return v.toString();
    }

    return AlerteEtat(
      id: (j['id'] as num).toInt(), 
      date: (j['date'] ?? "-").toString(),
      probleme: j['probleme']?.toString(),
      cause: j['cause']?.toString(),
      etatResolution: _etat(j['etatResolution']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,   
        'date': date,
        'probleme': probleme,
        'cause': cause,
        'etatResolution': etatResolution,
      };
}
