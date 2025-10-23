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

  /// ✅ NEW
  final List<ContactLite> contacts;

  /// ✅ NEW
  final List<BouteilleRow> bouteilles;

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
    required this.contacts, // NEW
    required this.bouteilles, // NEW
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
      frequenceLivraisonParJour: (j['frequenceLivraisonParJour'] as num?)
          ?.toInt(),
      frequenceVisiteParJour: (j['frequenceVisiteParJour'] as num?)?.toInt(),
      importance: j['importance']?.toString(),
      algoPlan: j['algoPlan']?.toString(),
      satisfaction: (j['satisfaction'] as num?)?.toInt(),

      diffuseurs: _list(
        j['diffuseurs'],
        (e) => ClientDiffuseurRow.fromJson(Map<String, dynamic>.from(e)),
      ),
      interventions: _list(
        j['interventions'],
        (e) => InterventionRow.fromJson(Map<String, dynamic>.from(e)),
      ),
      reclamations: _list(
        j['reclamations'],
        (e) => ReclamationRow.fromJson(Map<String, dynamic>.from(e)),
      ),

      // ✅ NEW lists
      contacts: _list(
        j['contacts'],
        (e) => ContactLite.fromJson(Map<String, dynamic>.from(e)),
      ),
      bouteilles: _list(
        j['bouteilles'],
        (e) => BouteilleRow.fromJson(Map<String, dynamic>.from(e)),
      ),
    );
  }
  ClientDetail copyWith({
    int? id,
    String? nature,
    String? type,
    String? nom,
    String? telephone,
    String? coordonateur,
    String? adresse,
    int? frequenceLivraisonParJour,
    int? frequenceVisiteParJour,
    String? importance,
    String? algoPlan,
    int? satisfaction,
    List<ClientDiffuseurRow>? diffuseurs,
    List<InterventionRow>? interventions,
    List<ReclamationRow>? reclamations,
    List<ContactLite>? contacts,
    List<BouteilleRow>? bouteilles,
  }) {
    return ClientDetail(
      id: id ?? this.id,
      nature: nature ?? this.nature,
      type: type ?? this.type,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      coordonateur: coordonateur ?? this.coordonateur,
      adresse: adresse ?? this.adresse,
      frequenceLivraisonParJour:
          frequenceLivraisonParJour ?? this.frequenceLivraisonParJour,
      frequenceVisiteParJour:
          frequenceVisiteParJour ?? this.frequenceVisiteParJour,
      importance: importance ?? this.importance,
      algoPlan: algoPlan ?? this.algoPlan,
      satisfaction: satisfaction ?? this.satisfaction,
      diffuseurs: diffuseurs ?? this.diffuseurs,
      interventions: interventions ?? this.interventions,
      reclamations: reclamations ?? this.reclamations,
      contacts: contacts ?? this.contacts,
      bouteilles: bouteilles ?? this.bouteilles,
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

  factory ClientDiffuseurRow.fromJson(Map<String, dynamic> j) =>
      ClientDiffuseurRow(
        id: (j['id'] as num).toInt(),
        cab: j['cab']?.toString() ?? '-',
        modele: j['modele']?.toString() ?? '-',
        typeCarte: j['typeCarte']?.toString() ?? '-',
        emplacement: j['emplacement']?.toString() ?? '-',
      );
}

class InterventionRow {
  final int id;
  final String? date; // backend: "dd/MM/yyyy" (LocalDateTime serialized)
  final String? equipe; // ✅ renamed from technicien
  final bool? alertes;
  final String? statut;

  InterventionRow({
    required this.id,
    required this.date,
    required this.equipe,
    required this.alertes,
    required this.statut,
  });

  factory InterventionRow.fromJson(Map<String, dynamic> j) => InterventionRow(
    id: (j['id'] as num).toInt(),
    date: j['date']?.toString(),
    equipe: j['equipe']?.toString(), // ✅
    alertes: j['alertes'] as bool?,
    statut: j['statut']?.toString(),
  );
}

class ReclamationRow {
  final int id;
  final String? date; // "dd/MM/yyyy"
  final String? probleme;
  final String? equipe; // ✅ renamed from technicien
  final String? statut;

  ReclamationRow({
    required this.id,
    required this.date,
    required this.probleme,
    required this.equipe,
    required this.statut,
  });

  factory ReclamationRow.fromJson(Map<String, dynamic> j) => ReclamationRow(
    id: (j['id'] as num).toInt(),
    date: j['date']?.toString(),
    probleme: j['probleme']?.toString(),
    equipe: j['equipe']?.toString(), // ✅
    statut: j['statut']?.toString(),
  );
}

/// ✅ NEW: mirrors your backend BouteilleRow
class BouteilleRow {
  final int id;
  final String cab;
  final String type; // TypeBouteille (String)
  final String etat; // EtatBouteille  (String)
  final String parfum; // Nom du parfum
  final String? dateProd; // "dd/MM/yyyy"
  final int? qteInitiale;

  BouteilleRow({
    required this.id,
    required this.cab,
    required this.type,
    required this.etat,
    required this.parfum,
    required this.dateProd,
    required this.qteInitiale,
  });

  factory BouteilleRow.fromJson(Map<String, dynamic> j) => BouteilleRow(
    id: (j['id'] as num).toInt(),
    cab: j['cab']?.toString() ?? '-',
    type: j['type']?.toString() ?? '-',
    etat: j['etat']?.toString() ?? '-',
    parfum: j['parfum']?.toString() ?? '-',
    dateProd: j['dateProd']?.toString(),
    qteInitiale: (j['qteInitiale'] as num?)?.toInt(),
  );
}

class ContactLite {
  final int id;
  final String? nom;
  final String? prenom;
  final String? tel;
  final String? email;
  final int? age;
  final String? whatsapp;
  final String? sexe; // "HOMME" | "FEMME" | ...
  final String? poste; // rôle/fonction
  final int? clientId; // "client"

  ContactLite({
    required this.id,
    this.nom,
    this.prenom,
    this.tel,
    this.email,
    this.age,
    this.sexe,
    this.poste,
    this.clientId,
    this.whatsapp,
  });

  String get fullName {
    final p = (prenom ?? '').trim();
    final n = (nom ?? '').trim();
    return [p, n].where((s) => s.isNotEmpty).join(' ').trim();
  }

  factory ContactLite.fromJson(Map<String, dynamic> j) => ContactLite(
    id: (j['id'] as num).toInt(),
    nom: j['nom']?.toString(),
    prenom: j['prenom']?.toString(),
    tel:
        j['tel']?.toString() ??
        j['telephone']?.toString() ??
        j['phone']?.toString(),
    email: j['email']?.toString(),
    age: (j['age'] as num?)?.toInt(),
    sexe: j['sexe']?.toString(),
    poste: j['poste']?.toString() ?? j['fonction']?.toString(),
    clientId: (j['client'] as num?)?.toInt(),
    whatsapp: j['whatsapp']?.toString(),
  );
  ContactLite copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? tel,
    String? whatsapp,
    String? email,
    String? sexe,
    String? poste,
    int? age,
  }) {
    return ContactLite(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      tel: tel ?? this.tel,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      sexe: sexe ?? this.sexe,
      poste: poste ?? this.poste,
      age: age ?? this.age,
    );
  }
}
