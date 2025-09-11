import 'etat_client_diffuseur.dart' show ProgrammeEtat, BouteilleEtat, AlerteEtat;

class ClientDiffuseurDetail {
  final int clientDiffuseurId;
  final String cab;
  final String modele;
  final String typeCarte;
  final String emplacement;
  final DateTime? dateMiseEnMarche;
  final int? maxMinutesParJour;
  final List<ProgrammeEtat> programmes;
  final BouteilleEtat? bouteille;
  final List<AlerteEtat> alertes;

  ClientDiffuseurDetail({
    required this.clientDiffuseurId,
    required this.cab,
    required this.modele,
    required this.typeCarte,
    required this.emplacement,
    required this.dateMiseEnMarche,
    required this.maxMinutesParJour,
    required this.programmes,
    required this.bouteille,
    required this.alertes,
  });

  static DateTime? _parseDT(dynamic v) {
    if (v == null) return null;
    try { return DateTime.parse(v.toString()); } catch (_) { return null; }
  }

  factory ClientDiffuseurDetail.fromJson(Map<String, dynamic> j) {
    List<T> _list<T>(dynamic v, T Function(dynamic) f) =>
        v is List ? v.map(f).toList() : const [];

    return ClientDiffuseurDetail(
      clientDiffuseurId: (j['clientDiffuseurId'] as num).toInt(),
      cab: (j['cab'] ?? '-').toString(),
      modele: (j['modele'] ?? '-').toString(),
      typeCarte: (j['typeCarte'] ?? '-').toString(),
      emplacement: (j['emplacement'] ?? '-').toString(),
      dateMiseEnMarche: _parseDT(j['dateMiseEnMarche']),
      maxMinutesParJour: (j['maxMinutesParJour'] as num?)?.toInt(),
      programmes: _list(j['programmes'], (e) => ProgrammeEtat.fromJson(Map<String, dynamic>.from(e))),
      bouteille: j['bouteille'] == null ? null : BouteilleEtat.fromJson(Map<String, dynamic>.from(j['bouteille'])),
      alertes: _list(j['alertes'], (e) => AlerteEtat.fromJson(Map<String, dynamic>.from(e))),
    );
  }
}
