class InterventionItem {
  final int id;
  final String client;
  final String technicien;
  final DateTime? derniereIntervention;
  final String statutRaw; // <— renomme explicitement

  InterventionItem({
    required this.id,
    required this.client,
    required this.technicien,
    required this.derniereIntervention,
    required this.statutRaw,
  });

  factory InterventionItem.fromJson(Map<String, dynamic> j) {
    return InterventionItem(
      id: j['id'] as int,
      client: (j['client'] ?? '-') as String,
      technicien: (j['technicien'] ?? '-') as String,
      derniereIntervention: j['derniereIntervention'] != null
          ? DateTime.parse(j['derniereIntervention'])
          : null,
      // NE PAS mettre "Tout Statut" ici
      statutRaw: ((j['statut'] ?? 'EN_COURS') as String).trim(),
    );
  }
}
