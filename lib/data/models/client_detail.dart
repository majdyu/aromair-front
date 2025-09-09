class ClientDetail {
  final int id;
  final String? nature;
  final String? type;
  final String nom;
  final String telephone;
  final String coordonateur;
  final String adresse;
  final int? frequenceLivraisonParJour;
  final int? frequenceVisiteParJour;
  final String? importance;
  final String? algoPlan;
  final int? satisfaction;
  final List<ClientDiffuseurRow> diffuseurs;
  final List<InterventionRow> interventions;
  final List<ReclamationRow> reclamations;

  ClientDetail({
    required this.id,
    required this.nature,
    required this.type,
    required this.nom,
    required this.telephone,
    required this.coordonateur,
    required this.adresse,
    required this.frequenceLivraisonParJour,
    required this.frequenceVisiteParJour,
    required this.importance,
    required this.algoPlan,
    required this.satisfaction,
    required this.diffuseurs,
    required this.interventions,
    required this.reclamations,
  });

  factory ClientDetail.fromJson(Map<String, dynamic> j) {
    List<T> _list<T>(dynamic v, T Function(dynamic) map) =>
        v is List ? v.map(map).toList() : const [];
    return ClientDetail(
      id: (j['id'] as num).toInt(),
      nature: j['nature']?.toString(),
      type: j['type']?.toString(),
      nom: j['nom']?.toString() ?? '-',
      telephone: j['telephone']?.toString() ?? '-',
      coordonateur: j['coordonateur']?.toString() ?? '-',
      adresse: j['adresse']?.toString() ?? '-',
      frequenceLivraisonParJour: (j['frequenceLivraisonParJour'] as num?)?.toInt(),
      frequenceVisiteParJour: (j['frequenceVisiteParJour'] as num?)?.toInt(),
      importance: j['importance']?.toString(),
      algoPlan: j['algoPlan']?.toString(),
      satisfaction: (j['satisfaction'] as num?)?.toInt(),
      diffuseurs: _list(j['diffuseurs'],
        (e) => ClientDiffuseurRow.fromJson(Map<String, dynamic>.from(e))),
      interventions: _list(j['interventions'],
        (e) => InterventionRow.fromJson(Map<String, dynamic>.from(e))),
      reclamations: _list(j['reclamations'],
        (e) => ReclamationRow.fromJson(Map<String, dynamic>.from(e))),
    );
  }
}

class ClientDiffuseurRow {
  final int id;
  final String cab;
  final String modele;
  final String typeCarte;
  final String emplacement;

  ClientDiffuseurRow({
    required this.id,
    required this.cab,
    required this.modele,
    required this.typeCarte,
    required this.emplacement,
  });

  factory ClientDiffuseurRow.fromJson(Map<String, dynamic> j) => ClientDiffuseurRow(
    id: (j['id'] as num).toInt(),
    cab: j['cab']?.toString() ?? '-',
    modele: j['modele']?.toString() ?? '-',
    typeCarte: j['typeCarte']?.toString() ?? '-',
    emplacement: j['emplacement']?.toString() ?? '-',
  );
}

class InterventionRow {
  final int id;
  final String? date;        // "dd/MM/yyyy"
  final String? technicien;  // Nom/username
  final bool? alertes;       // Oui/Non
  final String? statut;      // StatutIntervention

  InterventionRow({
    required this.id,
    required this.date,
    required this.technicien,
    required this.alertes,
    required this.statut,
  });

  factory InterventionRow.fromJson(Map<String, dynamic> j) => InterventionRow(
    id: (j['id'] as num).toInt(),
    date: j['date']?.toString(),
    technicien: j['technicien']?.toString(),
    alertes: j['alertes'] as bool?,
    statut: j['statut']?.toString(),
  );
}

class ReclamationRow {
  final int id;
  final String? date;        // "dd/MM/yyyy"
  final String? probleme;
  final String? technicien;  // dernierTechnicien
  final String? statut;      // statutReclammation

  ReclamationRow({
    required this.id,
    required this.date,
    required this.probleme,
    required this.technicien,
    required this.statut,
  });

  factory ReclamationRow.fromJson(Map<String, dynamic> j) => ReclamationRow(
    id: (j['id'] as num).toInt(),
    date: j['date']?.toString(),
    probleme: j['probleme']?.toString(),
    technicien: j['technicien']?.toString(),
    statut: j['statut']?.toString(),
  );
}
