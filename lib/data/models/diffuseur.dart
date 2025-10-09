class Diffuseur {
  final int id;
  final String modele;
  final String typCarte;
  final String designation;
  final double consommation;

  const Diffuseur({
    required this.id,
    required this.modele,
    required this.typCarte,
    required this.designation,
    required this.consommation,
  });

  /// Create from a JSON-like map
  factory Diffuseur.fromMap(Map<String, dynamic> map) {
    return Diffuseur(
      id: (map['id'] as num?)?.toInt() ?? 0,
      modele: (map['modele'] ?? '').toString(),
      typCarte: (map['typCarte'] ?? '').toString(),
      designation: (map['designation'] ?? '').toString(),
      consommation: _toDouble(map['consommation']),
    );
  }

  /// Create from dynamic json (when you aren’t sure about the type)
  factory Diffuseur.fromJson(dynamic json) {
    return Diffuseur.fromMap(
      json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'modele': modele,
    'typCarte': typCarte,
    'designation': designation,
    'consommation': consommation,
  };

  Diffuseur copyWith({
    int? id,
    String? modele,
    String? typCarte,
    String? designation,
    double? consommation,
  }) {
    return Diffuseur(
      id: id ?? this.id,
      modele: modele ?? this.modele,
      typCarte: typCarte ?? this.typCarte,
      designation: designation ?? this.designation,
      consommation: consommation ?? this.consommation,
    );
  }

  // Helpers
  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  /// Parse a list response: List<dynamic> -> List<Diffuseur>
  static List<Diffuseur> listFromJson(List<dynamic> data) {
    return data.map((e) => Diffuseur.fromJson(e)).toList(growable: false);
  }
}
