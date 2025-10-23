class RecetteClientsDetail {
  final String technicien;
  final double actuelle;
  final List<Map<String, dynamic>> lignes;
  final double recetteSuppose;
  final double recetteCultive;
  final double recetteRecu;

  final String? nature;
  final String? numeroPiece; // nullable; coerced to String if numeric

  RecetteClientsDetail({
    required this.technicien,
    required this.actuelle,
    required this.lignes,
    required this.recetteSuppose,
    required this.recetteCultive,
    required this.recetteRecu,
    this.nature,
    this.numeroPiece,
  });

  factory RecetteClientsDetail.fromJson(Map<String, dynamic> j) {
    // helper to coerce any value to String?
    String? _asStringOrNull(dynamic v) {
      if (v == null) return null;
      if (v is String) return v;
      return v.toString();
    }

    // lignes parsed first so we can optionally fallback
    final List<Map<String, dynamic>> _lignes = (j['lignes'] as List? ?? [])
        .map<Map<String, dynamic>>((e) => (e as Map).cast<String, dynamic>())
        .toList();

    // optional fallbacks from first line item if top-level missing
    final Map<String, dynamic>? _firstLigne = _lignes.isNotEmpty
        ? _lignes.first
        : null;

    final String? _natureTop = _asStringOrNull(j['nature']);
    final String? _numeroPieceTop = _asStringOrNull(j['numeroPiece']);

    return RecetteClientsDetail(
      technicien: j['technicien'] ?? '',
      actuelle: (j['actuelle'] ?? 0).toDouble(),
      lignes: _lignes,
      recetteSuppose: (j['recetteSuppose'] ?? 0).toDouble(),
      recetteCultive: (j['recetteCultive'] ?? 0).toDouble(),
      recetteRecu: (j['recetteRecu'] ?? 0).toDouble(),
      nature: _natureTop ?? _asStringOrNull(_firstLigne?['nature']),
      numeroPiece:
          _numeroPieceTop ?? _asStringOrNull(_firstLigne?['numeroPiece']),
    );
  }

  Map<String, dynamic> toJson() => {
    'technicien': technicien,
    'actuelle': actuelle,
    'lignes': lignes,
    'recetteSuppose': recetteSuppose,
    'recetteCultive': recetteCultive,
    'recetteRecu': recetteRecu,
    'nature': nature,
    'numeroPiece': numeroPiece,
  };

  RecetteClientsDetail copyWith({
    String? technicien,
    double? actuelle,
    List<Map<String, dynamic>>? lignes,
    double? recetteSuppose,
    double? recetteCultive,
    double? recetteRecu,
    String? nature,
    String? numeroPiece,
  }) {
    return RecetteClientsDetail(
      technicien: technicien ?? this.technicien,
      actuelle: actuelle ?? this.actuelle,
      lignes: lignes ?? this.lignes,
      recetteSuppose: recetteSuppose ?? this.recetteSuppose,
      recetteCultive: recetteCultive ?? this.recetteCultive,
      recetteRecu: recetteRecu ?? this.recetteRecu,
      nature: nature ?? this.nature,
      numeroPiece: numeroPiece ?? this.numeroPiece,
    );
  }
}
