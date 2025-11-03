class Parfum {
  final int id;
  final String nom;

  Parfum({required this.id, required this.nom});

  factory Parfum.fromJson(Map<String, dynamic> json) {
    return Parfum(id: json['id'] as int, nom: json['nom'] as String);
  }

  static List<Parfum> listFromJson(List<dynamic> json) {
    return json.map((e) => Parfum.fromJson(e as Map<String, dynamic>)).toList();
  }
}
