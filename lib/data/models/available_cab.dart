class AvailableCab {
  final int id;          // id ClientDiffuseur
  final String cab;
  final String designation; // peut être vide

  AvailableCab({required this.id, required this.cab, required this.designation});

  factory AvailableCab.fromJson(Map<String, dynamic> j) => AvailableCab(
    id: (j['id'] as num).toInt(),
    cab: j['cab']?.toString() ?? '',
    designation: j['designation']?.toString() ?? '',
  );

  String get label => designation.isEmpty ? cab : '$cab — $designation';
}
