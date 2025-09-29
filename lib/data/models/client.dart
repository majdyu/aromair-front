import 'dart:convert';
import 'package:intl/intl.dart';

enum TypeClient { achat, convention, mad, unknown }

TypeClient typeClientFromString(String? s) {
  switch ((s ?? '').toUpperCase()) {
    case 'ACHAT':
      return TypeClient.achat;
    case 'CONVENTION':
      return TypeClient.convention;
    case 'MAD':
      return TypeClient.mad;
    default:
      return TypeClient.unknown;
  }
}

String typeClientToString(TypeClient t) {
  switch (t) {
    case TypeClient.achat:
      return 'ACHAT';
    case TypeClient.convention:
      return 'CONVENTION';
    case TypeClient.mad:
      return 'MAD';
    case TypeClient.unknown:
      return 'UNKNOWN';
  }
}

class ClientRow {
  final int id;
  final String nom;
  final TypeClient type;
  final DateTime? derniereIntervention;
  final bool estActive;

  static final _fmt = DateFormat('dd-MM-yyyy');

  ClientRow({
    required this.id,
    required this.nom,
    required this.type,
    required this.derniereIntervention,
    required this.estActive,
  });

  factory ClientRow.fromJson(Map<String, dynamic> json) {
    final rawDate = json['derniereIntervention'] as String?;
    DateTime? parsedDate;
    if (rawDate != null && rawDate.trim().isNotEmpty) {
      parsedDate = _fmt.parseStrict(rawDate);
    }
    return ClientRow(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      type: typeClientFromString(json['type'] as String?),
      derniereIntervention: parsedDate,
      estActive: json['estActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'type': typeClientToString(type),
    'derniereIntervention': derniereIntervention == null
        ? null
        : _fmt.format(derniereIntervention!),
    'estActive': estActive,
  };

  ClientRow copyWith({
    int? id,
    String? nom,
    TypeClient? type,
    DateTime? derniereIntervention,
    bool? estActive,
  }) {
    return ClientRow(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      derniereIntervention: derniereIntervention ?? this.derniereIntervention,
      estActive: estActive ?? this.estActive,
    );
  }

  // Helpers for list responses
  static List<ClientRow> listFromJsonString(String jsonStr) {
    final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
    return data
        .map((e) => ClientRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<ClientRow> listFromJson(List<dynamic> data) {
    return data
        .map((e) => ClientRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
