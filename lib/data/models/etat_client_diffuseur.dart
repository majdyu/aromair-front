// lib/data/models/etat_client_diffuseur.dart

import 'package:front_erp_aromair/data/models/parfum.dart';

class EtatClientDiffuseur {
  final int interventionId;
  final int clientDiffuseurId;

  // En-tête CD
  final String cab;
  final String modele;
  final String typeCarte;
  final String emplacement;
  final DateTime? dateMiseEnMarche; // nullable
  final int? maxMinutesParJour;
  final double? rythmeConsomParJour;

  // Détails pivot (dans l’intervention)
  final List<ProgrammeEtat> programmes;
  final BouteilleEtat? bouteille;

  // Compat legacy (toujours renvoyés par le back à partir du bloc embedded)
  final bool? qualiteBonne;
  final bool? fuite;
  final bool? enMarche;

  // Nouveau bloc embarqué
  final InfosInterCD? infos;

  // Alertes liées à ce CD
  final List<AlerteEtat> alertes;

  const EtatClientDiffuseur({
    required this.interventionId,
    required this.clientDiffuseurId,
    required this.cab,
    required this.modele,
    required this.typeCarte,
    required this.emplacement,
    required this.dateMiseEnMarche,
    required this.maxMinutesParJour,
    required this.rythmeConsomParJour,
    required this.programmes,
    required this.bouteille,
    required this.qualiteBonne,
    required this.fuite,
    required this.enMarche,
    required this.infos,
    required this.alertes,
  });

  EtatClientDiffuseur copyWith({
    String? cab,
    String? modele,
    String? typeCarte,
    String? emplacement,
    DateTime? dateMiseEnMarche,
    int? maxMinutesParJour,
    double? rythmeConsomParJour,
    List<ProgrammeEtat>? programmes,
    BouteilleEtat? bouteille,
    bool? qualiteBonne,
    bool? fuite,
    bool? enMarche,
    InfosInterCD? infos,
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
      rythmeConsomParJour: rythmeConsomParJour ?? this.rythmeConsomParJour,
      programmes: programmes ?? this.programmes,
      bouteille: bouteille ?? this.bouteille,
      qualiteBonne: qualiteBonne ?? this.qualiteBonne,
      fuite: fuite ?? this.fuite,
      enMarche: enMarche ?? this.enMarche,
      infos: infos ?? this.infos,
      alertes: alertes ?? this.alertes,
    );
  }

  // ------------------------ JSON ------------------------

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;

    // ISO string (yyyy-MM-dd or yyyy-MM-ddTHH:mm:ss)
    if (v is String) {
      // dd/MM/yyyy (optionnellement avec hh:mm[:ss])
      if (v.contains('/')) {
        final parts = v.split(' ');
        final datePart = parts.first;
        final ddmmyyyy = datePart.split('/');
        if (ddmmyyyy.length == 3) {
          final dd = int.tryParse(ddmmyyyy[0]);
          final mm = int.tryParse(ddmmyyyy[1]);
          final yy = int.tryParse(ddmmyyyy[2]);
          if (dd != null && mm != null && yy != null) {
            int hh = 0, mi = 0, ss = 0;
            if (parts.length > 1) {
              final t = parts[1].split(':');
              if (t.isNotEmpty) hh = int.tryParse(t[0]) ?? 0;
              if (t.length > 1) mi = int.tryParse(t[1]) ?? 0;
              if (t.length > 2) ss = int.tryParse(t[2]) ?? 0;
            }
            return DateTime(yy, mm, dd, hh, mi, ss);
          }
        }
      }
      try {
        return DateTime.parse(v);
      } catch (_) {}
    }

    // [yyyy,MM,dd,hh,mm,ss]
    if (v is List && v.length >= 3) {
      final y = (v[0] as num?)?.toInt() ?? 0;
      final m = (v[1] as num?)?.toInt() ?? 1;
      final d = (v[2] as num?)?.toInt() ?? 1;
      final hh = (v.length > 3 ? v[3] as num? : null)?.toInt() ?? 0;
      final mm = (v.length > 4 ? v[4] as num? : null)?.toInt() ?? 0;
      final ss = (v.length > 5 ? v[5] as num? : null)?.toInt() ?? 0;
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
        : BouteilleEtat.fromJson(
            Map<String, dynamic>.from(j['bouteille'] as Map),
          );

    final alertes = _list<AlerteEtat>(
      j['alertes'],
      (e) => AlerteEtat.fromJson(Map<String, dynamic>.from(e as Map)),
    );

    final infos = j['infos'] == null
        ? null
        : InfosInterCD.fromJson(Map<String, dynamic>.from(j['infos'] as Map));

    return EtatClientDiffuseur(
      interventionId: (j['interventionId'] as num).toInt(),
      clientDiffuseurId: (j['clientDiffuseurId'] as num).toInt(),
      cab: (j['cab'] as String?) ?? '-',
      modele: (j['modele'] as String?) ?? '-',
      typeCarte: (j['typeCarte'] as String?) ?? '-',
      emplacement: (j['emplacement'] as String?) ?? '-',
      dateMiseEnMarche: _parseDateTime(j['dateMiseEnMarche']),
      maxMinutesParJour: (j['maxMinutesParJour'] as num?)?.toInt(),
      rythmeConsomParJour: (j['rythmeConsomParJour'] as num?)?.toDouble(),
      programmes: programmes,
      bouteille: bouteille,
      // legacy flags (toujours présents dans le DTO pour compat)
      qualiteBonne: j['qualiteBonne'] as bool?,
      fuite: j['fuite'] as bool?,
      enMarche: j['enMarche'] as bool?,
      infos: infos,
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
    'rythmeConsomParJour': rythmeConsomParJour,
    'programmes': programmes.map((e) => e.toJson()).toList(),
    'bouteille': bouteille?.toJson(),
    // legacy
    'qualiteBonne': qualiteBonne,
    'fuite': fuite,
    'enMarche': enMarche,
    // bloc embedded
    'infos': infos == null ? null : infos!.toJson(),
    'alertes': alertes.map((e) => e.toJson()).toList(),
  };
}

// ------------------------------------------------------------

class ProgrammeEtat {
  final int? tempsEnMarche;
  final int? tempsDeRepos;
  final String? unite;
  final String? heureDebut;
  final String? heureFin;
  final List<String> joursActifs;

  const ProgrammeEtat({
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

// ------------------------------------------------------------

class BouteilleEtat {
  final int? id;
  final String? type;
  final Parfum? parfum;
  final int? qteInitiale;
  final int? qtePrevu;
  final int? qteExistante;

  const BouteilleEtat({
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
      parfum: j['parfum'] == null
          ? null
          : Parfum.fromJson(Map<String, dynamic>.from(j['parfum'] as Map)),
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

// ------------------------------------------------------------

/// Spécifique à cet écran (évite la collision avec AlerteRow)
class AlerteEtat {
  final int id;
  final String date; // ex: "16/07/2025"
  final String? probleme;
  final String? cause;
  final String etatResolution;

  const AlerteEtat({
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

// ------------------------------------------------------------

class InfosInterCD {
  final bool? qualiteBonne;
  final bool? fuite;
  final bool? enMarche;

  final bool? tuyeauPosition; // true=intérieur / false=extérieur
  final bool? estEnPlace;
  final bool? estAutocolantApplique;
  final bool? estDommage;
  final bool? branchement; // true=branché
  final bool? estLivraisonEffectue;
  final bool? estProgrammeChange;

  final String? etatSoftware; // "DECALE" | "CORRECTE" | "DEFAILLANT"
  final String? motifArret;
  final String? motifDebranchement;
  final String? motifInsatisfaction;

  const InfosInterCD({
    this.qualiteBonne,
    this.fuite,
    this.enMarche,
    this.tuyeauPosition,
    this.estEnPlace,
    this.estAutocolantApplique,
    this.estDommage,
    this.branchement,
    this.estLivraisonEffectue,
    this.estProgrammeChange,
    this.etatSoftware,
    this.motifArret,
    this.motifDebranchement,
    this.motifInsatisfaction,
  });

  factory InfosInterCD.fromJson(Map<String, dynamic> j) => InfosInterCD(
    qualiteBonne: j['qualiteBonne'] as bool?,
    fuite: j['fuite'] as bool?,
    enMarche: j['enMarche'] as bool?,
    tuyeauPosition: j['tuyeauPosition'] as bool?,
    estEnPlace: j['estEnPlace'] as bool?,
    estAutocolantApplique: j['estAutocolantApplique'] as bool?,
    estDommage: j['estDommage'] as bool?,
    branchement: j['branchement'] as bool?,
    estLivraisonEffectue: j['estLivraisonEffectue'] as bool?,
    estProgrammeChange: j['estProgrammeChange'] as bool?,
    etatSoftware: j['etatSoftware']?.toString(),
    motifArret: j['motifArret']?.toString(),
    motifDebranchement: j['motifDebranchement']?.toString(),
    motifInsatisfaction: j['motifInsatisfaction']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'qualiteBonne': qualiteBonne,
    'fuite': fuite,
    'enMarche': enMarche,
    'tuyeauPosition': tuyeauPosition,
    'estEnPlace': estEnPlace,
    'estAutocolantApplique': estAutocolantApplique,
    'estDommage': estDommage,
    'branchement': branchement,
    'estLivraisonEffectue': estLivraisonEffectue,
    'estProgrammeChange': estProgrammeChange,
    'etatSoftware': etatSoftware,
    'motifArret': motifArret,
    'motifDebranchement': motifDebranchement,
    'motifInsatisfaction': motifInsatisfaction,
  };
}
