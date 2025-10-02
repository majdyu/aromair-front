import 'dart:convert';
import 'package:intl/intl.dart';

/// Model for one item in the response array
class IncidentItem {
  final int id;
  final DateTime date; // parsed from "dd/MM/yyyy"
  final String probleme;
  final String cause;
  final bool etatResolution;
  final String clientNom;
  final String diffuseurDesignation;

  static final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  IncidentItem({
    required this.id,
    required this.date,
    required this.probleme,
    required this.cause,
    required this.etatResolution,
    required this.clientNom,
    required this.diffuseurDesignation,
  });

  factory IncidentItem.fromJson(Map<String, dynamic> json) {
    return IncidentItem(
      id: json['id'] as int,
      date: _fmt.parse(json['date'] as String),
      probleme: (json['probleme'] ?? '') as String,
      cause: (json['cause'] ?? '') as String,
      etatResolution: (json['etatResolution'] ?? false) as bool,
      clientNom: (json['clientNom'] ?? '') as String,
      diffuseurDesignation: (json['diffuseurDesignation'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': _fmt.format(date),
    'probleme': probleme,
    'cause': cause,
    'etatResolution': etatResolution,
    'clientNom': clientNom,
    'diffuseurDesignation': diffuseurDesignation,
  };

  IncidentItem copyWith({
    int? id,
    DateTime? date,
    String? probleme,
    String? cause,
    bool? etatResolution,
    String? clientNom,
    String? diffuseurDesignation,
  }) {
    return IncidentItem(
      id: id ?? this.id,
      date: date ?? this.date,
      probleme: probleme ?? this.probleme,
      cause: cause ?? this.cause,
      etatResolution: etatResolution ?? this.etatResolution,
      clientNom: clientNom ?? this.clientNom,
      diffuseurDesignation: diffuseurDesignation ?? this.diffuseurDesignation,
    );
  }

  @override
  String toString() =>
      'IncidentItem(id: $id, date: ${_fmt.format(date)}, probleme: $probleme, cause: $cause, etatResolution: $etatResolution, clientNom: $clientNom, diffuseurDesignation: $diffuseurDesignation)';

  // Convenience: parse a JSON array string into a list of IncidentItem
  static List<IncidentItem> listFromJsonString(String source) {
    final dynamic data = jsonDecode(source);
    if (data is List) {
      return data
          .map((e) => IncidentItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw const FormatException('Expected a JSON array');
  }
}

List<IncidentItem> incidentListFromDynamicList(List<dynamic> data) {
  return data
      .map((e) => IncidentItem.fromJson(e as Map<String, dynamic>))
      .toList();
}
