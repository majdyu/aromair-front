// lib/data/recommendations/alerte_recos.dart
class AlerteRecos {
  /// Clés = intitulés exacts des problèmes (ou bien des fragments).
  static const Map<String, List<String>> map = {
    'qte prévu < qte existante': [
      'Vérifier le relevé des quantités et recalculer le prévu.',
      'Contrôler les erreurs de saisie et corriger la fiche.',
      'Valider la quantité existante avec une mesure réelle.',
    ],
    'fuite': [
      'Inspecter joints/embouts et resserrer si nécessaire.',
      'Remplacer le tuyau ou le connecteur défectueux.',
      'Faire un test pression pour confirmer l’étanchéité.',
    ],
    'bouchage': [
      'Nettoyer le diffuseur et purger la ligne.',
      'Remplacer la buse si l’obstruction persiste.',
      'Vérifier la viscosité du parfum et l’adapter.',
    ],
    // Ajoute ici d’autres cas “problème” bien précis...
  };

  /// Trouve des recos en essayant d’abord un match exact, sinon un match "contient".
  static List<String> forProblem(String? probleme) {
    if (probleme == null || probleme.trim().isEmpty) return const [];
    final p = probleme.toLowerCase().trim();

    // 1) match exact (insensible à la casse)
    for (final e in map.entries) {
      if (e.key.toLowerCase() == p) return e.value;
    }
    // 2) match "contient"
    for (final e in map.entries) {
      if (p.contains(e.key.toLowerCase())) return e.value;
    }
    return const [];
  }
}
