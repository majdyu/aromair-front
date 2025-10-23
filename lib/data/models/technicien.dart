class TechnicienConsultation {
  final String nom;
  final String dateAjout; // server sends "DateAjout" (capital D)
  final int nbrInterventionsDiffuseurs;
  final int rondementTAF; // 0..100
  final double recetteActuelle;
  final double caisseActuelle;

  TechnicienConsultation({
    required this.nom,
    required this.dateAjout,
    required this.nbrInterventionsDiffuseurs,
    required this.rondementTAF,
    required this.recetteActuelle,
    required this.caisseActuelle,
  });

  factory TechnicienConsultation.fromJson(Map<String, dynamic> j) {
    // BigDecimal -> number -> double
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return TechnicienConsultation(
      nom: (j['nom'] ?? '').toString(),
      dateAjout: (j['DateAjout'] ?? '').toString(),
      nbrInterventionsDiffuseurs:
          (j['nbrInterventionsDiffuseurs'] as num?)?.toInt() ?? 0,
      rondementTAF: (j['rondementTAF'] as num?)?.toInt() ?? 0,
      recetteActuelle: _toDouble(j['recetteActuelle']),
      caisseActuelle: _toDouble(j['caisseActuelle']),
    );
  }
}
