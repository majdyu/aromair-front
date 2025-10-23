import 'package:front_erp_aromair/data/enums/status_commandes.dart';

/// Commande potentielle (ligne de liste)
class CommandePotentielleRow {
  final int id;
  final StatusCommande status;
  final DateTime? date; // "2025-10-17" (LocalDate)
  final bool bouteilleVide;
  final int clientId;
  final String? clientNom;
  final String? telephone;
  final int clientDiffuseurId;
  final String? diffuseurCab;
  final String? diffuseurDesignation;
  final String? emplacement;
  final DateTime? datePlanification; // (LocalDateTime) peut être null
  final int parfumId;
  final String? parfumNom;

  const CommandePotentielleRow({
    required this.id,
    required this.status,
    required this.date,
    required this.bouteilleVide,
    required this.clientId,
    required this.clientNom,
    required this.telephone,
    required this.clientDiffuseurId,
    required this.diffuseurCab,
    required this.diffuseurDesignation,
    required this.emplacement,
    required this.datePlanification,
    required this.parfumId,
    required this.parfumNom,
  });

  CommandePotentielleRow copyWith({
    int? id,
    StatusCommande? status,
    DateTime? date,
    bool? bouteilleVide,
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
      // Handles "YYYY-MM-DD" and full ISO strings.
      return DateTime.tryParse(v.toString());
    }

    return CommandePotentielleRow(
      id: j['id'] as int,
      status: StatusCommandeX.fromString(j['status']),
      date: _parseDate(j['date']),
      bouteilleVide: (j['bouteilleVide'] as bool?) ?? false,
      clientId: j['clientId'] as int,
      clientNom: j['clientNom'] as String?,
      telephone: j['telephone'] as String?,
      clientDiffuseurId: j['clientDiffuseurId'] as int,
      diffuseurCab: j['diffuseurCab'] as String?,
      diffuseurDesignation: j['diffuseurDesignation'] as String?,
      emplacement: j['emplacement'] as String?,
      datePlanification: _parseDate(j['datePlanification']),
      parfumId: j['parfumId'] as int,
      parfumNom: j['parfumNom'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status.name, // same strings as backend
    'date': date?.toIso8601String().split('T').first, // keep LocalDate format
    'bouteilleVide': bouteilleVide,
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

  // Convenience: parse a list payload
  static List<CommandePotentielleRow> listFromJson(List<dynamic> arr) => arr
      .map((e) => CommandePotentielleRow.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// Énumération statuts (avec fallback sûr)
