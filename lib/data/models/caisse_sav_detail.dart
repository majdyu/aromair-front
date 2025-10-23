class CaisseSavDetail {
  final String technicien;
  final double actuelle;
  final List<Map<String, dynamic>> transactions;
  final double totalEntree;
  final double totalDepense;

  CaisseSavDetail({
    required this.technicien,
    required this.actuelle,
    required this.transactions,
    required this.totalEntree,
    required this.totalDepense,
  });

  factory CaisseSavDetail.fromJson(Map<String, dynamic> j) => CaisseSavDetail(
    technicien: j['technicien'] ?? '',
    actuelle: (j['actuelle'] ?? 0).toDouble(),
    transactions: (j['transactions'] as List? ?? [])
        .map<Map<String, dynamic>>((e) => (e as Map).cast<String, dynamic>())
        .toList(),
    totalEntree: (j['totalEntree'] ?? 0).toDouble(),
    totalDepense: (j['totalDepense'] ?? 0).toDouble(),
  );
}
