class AffecterClientDiffuseurRequest {
  final String emplacement;
  final int? maxMinParJour;                 // si client.type == MAD
  final List<ProgrammeReq> programmes;      // optionnel (peut être vide)

  AffecterClientDiffuseurRequest({
    required this.emplacement,
    this.maxMinParJour,
    this.programmes = const [],
  });

  Map<String, dynamic> toJson() => {
        'emplacement': emplacement,
        if (maxMinParJour != null) 'maxMinParJour': maxMinParJour,
        'programmes': programmes.map((e) => e.toJson()).toList(),
      };
}

class ProgrammeReq {
  final FrequenceReq frequence;
  final PlageHoraireReq plageHoraire;
  final List<String> joursActifs; // ex: ["MONDAY","TUESDAY"]

  ProgrammeReq({
    required this.frequence,
    required this.plageHoraire,
    required this.joursActifs,
  });

  Map<String, dynamic> toJson() => {
        'frequence': frequence.toJson(),
        'plageHoraire': plageHoraire.toJson(),
        'joursActifs': joursActifs,
      };
}

class FrequenceReq {
  final int tempsEnMarche;
  final int tempsDeRepos;
  final String unite; // "MINUTE" | "SECONDE"

  FrequenceReq({
    required this.tempsEnMarche,
    required this.tempsDeRepos,
    required this.unite,
  });

  Map<String, dynamic> toJson() => {
        'tempsEnMarche': tempsEnMarche,
        'tempsDeRepos': tempsDeRepos,
        'unite': unite,
      };
}

class PlageHoraireReq {
  final String heureDebut; // "HH:mm:ss"
  final String heureFin;   // "HH:mm:ss"

  PlageHoraireReq({required this.heureDebut, required this.heureFin});

  Map<String, dynamic> toJson() => {
        'heureDebut': heureDebut,
        'heureFin': heureFin,
      };
}


