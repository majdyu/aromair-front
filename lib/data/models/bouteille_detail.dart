// lib/data/models/bouteille_detail.dart
class BouteilleDetail {
  final int id;
  final String cab;
  final String type;
  final String parfum;

  final String? dateProd;          // backend renvoie “dd/MM/yyyy”
  final String? dateMiseEnMarche;
  final double? rythmeConsomParJour;
  final String etat;

  final int? qteInitiale;
  final int? qtePrevu;
  final int? qteExistante;

  final String client;
  final String emplacement;

  final List<ProgrammeRow> programmes;

  BouteilleDetail({
    required this.id,
    required this.cab,
    required this.type,
    required this.parfum,
    required this.dateProd,
    required this.dateMiseEnMarche,
    required this.rythmeConsomParJour,
    required this.etat,
    required this.qteInitiale,
    required this.qtePrevu,
    required this.qteExistante,
    required this.client,
    required this.emplacement,
    required this.programmes,
  });

  factory BouteilleDetail.fromJson(Map<String, dynamic> j) {
    List<ProgrammeRow> _progs(dynamic v) {
      if (v is List) {
        return v.map((e) => ProgrammeRow.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return const [];
    }

    return BouteilleDetail(
      id: (j['id'] as num).toInt(),
      cab: (j['cab'] as String?) ?? '-',
      type: (j['type'] as String?) ?? '-',
      parfum: (j['parfum'] as String?) ?? '-',
      dateProd: j['dateProd']?.toString(),
      dateMiseEnMarche: j['dateMiseEnMarche']?.toString(),
      rythmeConsomParJour: (j['rythmeConsomParJour'] as num?)?.toDouble(),
      etat: (j['etat'] as String?) ?? '-',
      qteInitiale: (j['qteInitiale'] as num?)?.toInt(),
      qtePrevu: (j['qtePrevu'] as num?)?.toInt(),
      qteExistante: (j['qteExistante'] as num?)?.toInt(),
      client: (j['client'] as String?) ?? '-',
      emplacement: (j['emplacement'] as String?) ?? '-',
      programmes: _progs(j['programmes']),
    );
  }
}

class ProgrammeRow {
  final int? tempsEnMarche;
  final int? tempsDeRepos;
  final String? unite;
  final String? heureDebut;
  final String? heureFin;
  final List<String> joursActifs;

  ProgrammeRow({
    required this.tempsEnMarche,
    required this.tempsDeRepos,
    required this.unite,
    required this.heureDebut,
    required this.heureFin,
    required this.joursActifs,
  });

  factory ProgrammeRow.fromJson(Map<String, dynamic> j) => ProgrammeRow(
        tempsEnMarche: (j['tempsEnMarche'] as num?)?.toInt(),
        tempsDeRepos: (j['tempsDeRepos'] as num?)?.toInt(),
        unite: j['unite']?.toString(),
        heureDebut: j['heureDebut']?.toString(),
        heureFin: j['heureFin']?.toString(),
        joursActifs: (j['joursActifs'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );
}
