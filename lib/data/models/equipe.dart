import 'dart:convert';

class Equipe {
  final int id;
  final String nom;
  final List<String> techniciens;

  Equipe({required this.id, required this.nom, required this.techniciens});

  factory Equipe.fromJson(Map<String, dynamic> json) {
    return Equipe(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      nom: (json['nom'] ?? '').toString(),
      techniciens:
          (json['techniciens'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }

  static List<Equipe> listFromJson(dynamic data) {
    if (data is List) {
      return data
          .map((e) => Equipe.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    try {
      final decoded = jsonDecode(data.toString());
      if (decoded is List) {
        return decoded
            .map((e) => Equipe.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  @override
  String toString() => 'Equipe($id, $nom, techniciens=${techniciens.length})';
}
