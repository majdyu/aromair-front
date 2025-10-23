import 'dart:convert';

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}

class EquipeMembre {
  final int id;
  final String nom;

  const EquipeMembre({required this.id, required this.nom});

  factory EquipeMembre.fromJson(Map<String, dynamic> json) {
    return EquipeMembre(
      id: _asInt(json['id']),
      nom: (json['nom'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nom': nom};
}

class Equipe {
  final int id;
  final String nom;
  final String? description;
  final int? respectPlanification;
  final int? chefId;
  final String? chefNom;
  final List<EquipeMembre> membres;

  const Equipe({
    required this.id,
    required this.nom,
    this.description,
    this.respectPlanification,
    this.chefId,
    this.chefNom,
    this.membres = const [],
  });

  /// Compat: retourne seulement les noms des membres
  List<String> get techniciens => membres.map((m) => m.nom).toList();

  factory Equipe.fromJson(Map<String, dynamic> json) {
    final rawMembres = json['membres'];
    final parsedMembres = (rawMembres is List)
        ? rawMembres
              .whereType<Map<String, dynamic>>()
              .map(EquipeMembre.fromJson)
              .toList()
        : const <EquipeMembre>[];

    return Equipe(
      id: _asInt(json['id']),
      nom: (json['nom'] ?? '').toString(),
      description: json['description']?.toString(),
      respectPlanification: json['respectPlanification'] != null
          ? _asInt(json['respectPlanification'])
          : null,
      chefId: json['chefId'] != null ? _asInt(json['chefId']) : null,
      chefNom: json['chefNom']?.toString(),
      membres: parsedMembres,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    if (description != null) 'description': description,
    if (respectPlanification != null)
      'respectPlanification': respectPlanification,
    if (chefId != null) 'chefId': chefId,
    if (chefNom != null) 'chefNom': chefNom,
    'membres': membres.map((m) => m.toJson()).toList(),
  };

  static List<Equipe> listFromJson(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Equipe.fromJson)
          .toList();
    }
    try {
      final decoded = jsonDecode(data.toString());
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(Equipe.fromJson)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  @override
  String toString() => 'Equipe($id, $nom, membres=${membres.length})';
}
