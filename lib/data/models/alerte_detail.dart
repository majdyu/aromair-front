class AlerteDetail {
  final int id;
  final String date;              // ex: "02/09/2025"
  final String? probleme;
  final String? cause;
  final bool etatResolution;      // true = résolu
  final String? decisionPrise;

  // libellés UI
  final int? clientId;
  final String client;            // nom du client
  final String diffuseurCab;
  final String diffuseurModele;
  final String diffuseurTypeCarte;
  final String emplacement;

  AlerteDetail({
    required this.id,
    required this.date,
    required this.probleme,
    required this.cause,
    required this.etatResolution,
    required this.decisionPrise,
    required this.clientId,
    required this.client,
    required this.diffuseurCab,
    required this.diffuseurModele,
    required this.diffuseurTypeCarte,
    required this.emplacement,
  });

  factory AlerteDetail.fromJson(Map<String, dynamic> j) {
    return AlerteDetail(
      id: (j['id'] as num).toInt(),
      date: j['date']?.toString() ?? '-',
      probleme: j['probleme']?.toString(),
      cause: j['cause']?.toString(),
      etatResolution: j['etatResolution'] == true,
      decisionPrise: j['decisionPrise']?.toString(),
      clientId: (j['clientId'] as num?)?.toInt(),
      client: (j['client']?.toString() ?? '-'),
      diffuseurCab: (j['diffuseurCab']?.toString() ?? '-'),
      diffuseurModele: (j['diffuseurModele']?.toString() ?? '-'),
      diffuseurTypeCarte: (j['diffuseurTypeCarte']?.toString() ?? '-'),
      emplacement: (j['emplacement']?.toString() ?? '-'),
    );
  }
}
