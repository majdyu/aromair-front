import 'package:front_erp_aromair/data/enums/status_commandes.dart';

/// Commande potentielle (ligne de liste)
class CommandePotentielleRow {
  final int id;
  final StatusCommande status;

  /// LocalDate from backend – can be "YYYY-MM-DD" or [YYYY,MM,DD]
  final DateTime? date;

  final bool bouteilleVide;

  /// Optionnel (peut être null)
  final int? nbrBouteilles;

  /// Quantité demandée / prévue (optionnel)
  final int? quantite;

  /// Optionnel
  final String? typeTete;

  /// Peut être manquant dans certaines réponses -> on met 0 par défaut
  final int clientId;
  final String? clientNom;

  /// Peut venir en int/string -> on garde toujours String
  final String? telephone;

  /// Peut arriver sous "clientDiffuseurId" ou "clientDiffuseur"
  final int clientDiffuseurId;

  final String? diffuseurCab;
  final String? diffuseurDesignation;
  final String? emplacement;

  /// LocalDateTime ou null, ex. "2025-10-24T09:48:09"
  final DateTime? datePlanification;

  /// Peut arriver sous "parfumId" ou "parfum"
  final int? parfumId;
  final String? parfumNom;

  const CommandePotentielleRow({
    required this.id,
    required this.status,
    required this.date,
    required this.bouteilleVide,
    this.nbrBouteilles,
    this.quantite,
    this.typeTete,
    required this.clientId,
    this.clientNom,
    this.telephone,
    required this.clientDiffuseurId,
    this.diffuseurCab,
    this.diffuseurDesignation,
    this.emplacement,
    this.datePlanification,
    this.parfumId,
    this.parfumNom,
  });

  CommandePotentielleRow copyWith({
    int? id,
    StatusCommande? status,
    DateTime? date,
    bool? bouteilleVide,
    int? nbrBouteilles,
    int? quantite,
    String? typeTete,
    int? clientId,
    String? clientNom,
    String? telephone,
    int? clientDiffuseurId,
    String? diffuseurCab,
    String? diffuseurDesignation,
    String? emplacement,
    DateTime? datePlanification,
    int? parfumId,
    String? parfumNom,
  }) {
    return CommandePotentielleRow(
      id: id ?? this.id,
      status: status ?? this.status,
      date: date ?? this.date,
      bouteilleVide: bouteilleVide ?? this.bouteilleVide,
      nbrBouteilles: nbrBouteilles ?? this.nbrBouteilles,
      quantite: quantite ?? this.quantite,
      typeTete: typeTete ?? this.typeTete,
      clientId: clientId ?? this.clientId,
      clientNom: clientNom ?? this.clientNom,
      telephone: telephone ?? this.telephone,
      clientDiffuseurId: clientDiffuseurId ?? this.clientDiffuseurId,
      diffuseurCab: diffuseurCab ?? this.diffuseurCab,
      diffuseurDesignation: diffuseurDesignation ?? this.diffuseurDesignation,
      emplacement: emplacement ?? this.emplacement,
      datePlanification: datePlanification ?? this.datePlanification,
      parfumId: parfumId ?? this.parfumId,
      parfumNom: parfumNom ?? this.parfumNom,
    );
  }

  factory CommandePotentielleRow.fromJson(Map<String, dynamic> j) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      if (v is List && v.length >= 3) {
        final y = int.tryParse(v[0].toString());
        final m = int.tryParse(v[1].toString());
        final d = int.tryParse(v[2].toString());
        if (y != null && m != null && d != null) return DateTime(y, m, d);
      }
      return null;
    }

    int? _toIntOrNull(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      final s = v.toString().trim();
      return s.isEmpty ? null : int.tryParse(s);
    }

    String? _toStringOrNull(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return s.isEmpty ? null : s;
    }

    // Status: utilise votre extension si dispo, sinon fallback simple
    StatusCommande _parseStatus(dynamic v) {
      try {
        final s = v?.toString();
        final parsed = StatusCommandeX.fromString(s);
        if (parsed != null) return parsed;
      } catch (_) {
        /* ignore and fallback */
      }
      switch ((v ?? '').toString()) {
        case 'VALIDE':
          return StatusCommande.VALIDE;
        case 'PRODUIS':
          return StatusCommande.PRODUIS;
        case 'EN_ATTENTE':
          return StatusCommande.EN_ATTENTE;
        default:
          return StatusCommande.EN_ATTENTE;
      }
    }

    // Champs pouvant manquer selon l’endpoint
    final clientIdSafe = _toIntOrNull(j['clientId']) ?? 0;
    final clientDiffuseurIdSafe =
        _toIntOrNull(j['clientDiffuseurId']) ??
        _toIntOrNull(j['clientDiffuseur']) ??
        0;
    final parfumIdSafe =
        _toIntOrNull(j['parfumId']) ?? _toIntOrNull(j['parfum']);

    return CommandePotentielleRow(
      id: (j['id'] as num).toInt(),
      status: _parseStatus(j['status']),
      date: _parseDate(j['date']),
      bouteilleVide: (j['bouteilleVide'] as bool?) ?? false,

      nbrBouteilles: _toIntOrNull(j['nbrBouteilles']),
      quantite: _toIntOrNull(j['quantite']),
      typeTete: _toStringOrNull(j['typeTete']),

      clientId: clientIdSafe,
      clientNom: _toStringOrNull(j['clientNom']),
      telephone: _toStringOrNull(j['telephone']),

      clientDiffuseurId: clientDiffuseurIdSafe,
      diffuseurCab: _toStringOrNull(j['diffuseurCab']),
      diffuseurDesignation: _toStringOrNull(j['diffuseurDesignation']),
      emplacement: _toStringOrNull(j['emplacement']),

      datePlanification: _parseDate(j['datePlanification']),
      parfumId: parfumIdSafe,
      parfumNom: _toStringOrNull(j['parfumNom']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status.name,
    'date': date?.toIso8601String().split('T').first,
    'bouteilleVide': bouteilleVide,
    'nbrBouteilles': nbrBouteilles,
    'quantite': quantite,
    'typeTete': typeTete,
    'clientId': clientId,
    'clientNom': clientNom,
    'telephone': telephone,
    'clientDiffuseurId': clientDiffuseurId,
    'diffuseurCab': diffuseurCab,
    'diffuseurDesignation': diffuseurDesignation,
    'emplacement': emplacement,
    'datePlanification': datePlanification?.toIso8601String(),
    'parfumId': parfumId,
    'parfumNom': parfumNom,
  };

  /// Convenience: parse list payloads
  static List<CommandePotentielleRow> listFromJson(List<dynamic> arr) => arr
      .map((e) => CommandePotentielleRow.fromJson(e as Map<String, dynamic>))
      .toList();
}
