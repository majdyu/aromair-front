import 'package:intl/intl.dart';

class IdRef {
  final int id;
  IdRef(this.id);
  Map<String, dynamic> toJson() => {'id': id};
}

class TafCreate {
  final String typeInterventions;
  final IdRef? clientDiffuseur;
  TafCreate({required this.typeInterventions, this.clientDiffuseur});
  Map<String, dynamic> toJson() => {
    'typeInterventions': typeInterventions,
    if (clientDiffuseur != null) 'clientDiffuseur': clientDiffuseur!.toJson(),
  };
}

class CreateInterventionRequest {
  final DateTime date;
  final bool estPayementObligatoire;
  final String? remarque;
  final IdRef client;
  final IdRef equipe;
  final List<TafCreate> tafList;

  CreateInterventionRequest({
    required this.date,
    required this.estPayementObligatoire,
    required this.client,
    required this.equipe,
    required this.tafList,
    this.remarque,
  });

  String _fmt(DateTime d) =>
      DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(d.toLocal());

  Map<String, dynamic> toJson() => {
    'date': _fmt(date),
    'estPayementObligatoire': estPayementObligatoire,
    if (remarque != null && remarque!.isNotEmpty) 'remarque': remarque,
    'client': client.toJson(),
    'equipe': equipe.toJson(),
    'tafList': tafList.map((e) => e.toJson()).toList(),
  };
}
