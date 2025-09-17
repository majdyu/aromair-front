import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';
import 'package:front_erp_aromair/viewmodel/admin/interventions/etat_cd_controller.dart';
import 'package:front_erp_aromair/data/models/etat_client_diffuseur.dart';

class EtatClientDiffuseurScreen extends StatelessWidget {
  final int interventionId;
  final int clientDiffuseurId;

  const EtatClientDiffuseurScreen({
    super.key,
    required this.interventionId,
    required this.clientDiffuseurId,
  });

  @override
  Widget build(BuildContext context) {
    final tag = 'cd_${interventionId}_$clientDiffuseurId';
    return GetX<EtatClientDiffuseurController>(
      init: Get.put(EtatClientDiffuseurController(interventionId, clientDiffuseurId), tag: tag),
      tag: tag,
      builder: (c) {
        final data = c.dto.value;

        return Scaffold(
          drawer: const AdminDrawer(),
          appBar: AppBar(
            backgroundColor: const Color(0xFF75A6D1),
            centerTitle: true,
            title: const Text("Etat de Diffuseur"),
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ),
          body: Container(
            color: const Color(0xFF75A6D1),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: c.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : c.error.value != null
                            ? Center(child: Text("Erreur: ${c.error.value}"))
                            : data == null
                                ? const Center(child: Text("Aucune donnée"))
                                : SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ---------- En-tête (2 colonnes) ----------
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _infoBlock([
                                                _kv("Ref", data.cab),
                                                _kv("Modèle", data.modele),
                                                _kv("Type carte", data.typeCarte),
                                                _kv("Emplacement", data.emplacement),
                                                _kv(
                                                  "Date de mise en marche",
                                                  data.dateMiseEnMarche == null
                                                      ? "-"
                                                      : DateFormat('dd/MM/yyyy').format(data.dateMiseEnMarche!),
                                                ),
                                                _kv(
                                                  "Max minutes / jour",
                                                  data.maxMinutesParJour?.toString() ?? "-",
                                                ),
                                                _kv(
                                                  "Rythme conso / jour",
                                                  (data.rythmeConsomParJour == null)
                                                      ? "-"
                                                      : "${data.rythmeConsomParJour!} ml",
                                                ),
                                              ]),
                                            ),
                                            const SizedBox(width: 24),
                                            Expanded(
                                              // Nouveau bloc "Infos intervention" (embedded)
                                              child: _infoBlockInfos(
                                                infos: data.infos,
                                                // Fallback si le back renvoie encore les 3 booleans au niveau root
                                                fallbackQualite: data.qualiteBonne,
                                                fallbackFuite: data.fuite,
                                                fallbackMarche: data.enMarche,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        // ---------- Programmes ----------
                                        _sectionTitle("Programmes"),
                                        const SizedBox(height: 8),
                                        _dataCard(
                                          child: data.programmes.isEmpty
                                              ? const Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: Text("Aucun programme."),
                                                )
                                              : Column(
                                                  children: data.programmes.map(_programmeRow).toList(),
                                                ),
                                        ),

                                        const SizedBox(height: 16),

                                        // ---------- Bouteille ----------
                                        _sectionTitle("Bouteille"),
                                        const SizedBox(height: 8),
                                        _dataCard(
                                          child: data.bouteille == null
                                              ? const Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: Text("Aucune bouteille reliée."),
                                                )
                                              : SingleChildScrollView(
                                                  scrollDirection: Axis.vertical,
                                                  child: DataTable(
                                                    showCheckboxColumn: false,
                                                    columnSpacing: 28,
                                                    headingRowHeight: 42,
                                                    dataRowMinHeight: 50,
                                                    dataRowMaxHeight: 60,
                                                    headingRowColor:
                                                        MaterialStateProperty.all(const Color(0xFF5DB7A1)),
                                                    columns: const [
                                                      DataColumn(label: _Head("Type")),
                                                      DataColumn(label: _Head("Quantité initiale")),
                                                      DataColumn(label: _Head("Quantité prévu")),
                                                      DataColumn(label: _Head("Quantité laissée")),
                                                      DataColumn(label: _Head("Parfum")),
                                                    ],
                                                    rows: [
                                                      DataRow(
                                                        onSelectChanged: (_) {
                                                          if (data.bouteille?.id != null) {
                                                            Get.toNamed('/bouteilles/${data.bouteille!.id}');
                                                          } else {
                                                            Get.snackbar("Indisponible", "Cette bouteille n’a pas d’identifiant.");
                                                          }
                                                        },
                                                        cells: [
                                                          DataCell(Text(data.bouteille!.type ?? "-")),
                                                          DataCell(Text(data.bouteille!.qteInitiale?.toString() ?? "-")),
                                                          DataCell(Text(data.bouteille!.qtePrevu?.toString() ?? "-")),
                                                          DataCell(Text(data.bouteille!.qteExistante?.toString() ?? "-")),
                                                          DataCell(Text(data.bouteille!.parfum ?? "-")),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 16),

                                        // ---------- Alertes ----------
                                        _sectionTitle("Alertes"),
                                        const SizedBox(height: 8),
                                        _dataCard(
                                          child: data.alertes.isEmpty
                                              ? const Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: Text("Aucune alerte enregistrée."),
                                                )
                                              : _alertesTable(data.alertes),
                                        ),
                                      ],
                                    ),
                                  ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- UI helpers ----------------

  static Widget _infoBlock(List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );

  /// Nouveau : affiche le bloc `infos` (embedded), avec repli sur les 3 champs legacy si `infos == null`.
  static Widget _infoBlockInfos({
    required InfosInterCD? infos,
    bool? fallbackQualite,
    bool? fallbackFuite,
    bool? fallbackMarche,
  }) {
    // helpers d'affichage
    String yn(bool? v) => v == null ? "-" : (v ? "Oui" : "Non");
    String quality(bool? v) => v == null ? "-" : (v ? "Bonne" : "Mauvaise");
    String pos(bool? v) => v == null ? "-" : (v ? "Intérieur" : "Extérieur");
    String branchement(bool? v) => v == null ? "-" : (v ? "Branché" : "Débranché");
    String marche(bool? v) => v == null ? "-" : (v ? "En Marche" : "En Arrêt");

    // valeurs à afficher (priorité à infos, sinon fallback)
    final _qualite = infos?.qualiteBonne ?? fallbackQualite;
    final _fuite = infos?.fuite ?? fallbackFuite;
    final _marche = infos?.enMarche ?? fallbackMarche;

    Widget line(String k, String v) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Expanded(child: Text(k)),
              Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Infos intervention :", style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        line("Qualité de diffusion", quality(_qualite)),
        line("Fuite", yn(_fuite)),
        line("En marche", marche(_marche)),
        const SizedBox(height: 8),
        line("Position tuyau", pos(infos?.tuyeauPosition)),
        line("En place", yn(infos?.estEnPlace)),
        line("Autocollant appliqué", yn(infos?.estAutocolantApplique)),
        line("Dommage", yn(infos?.estDommage)),
        line("Branchement", branchement(infos?.branchement)),
        line("Livraison effectuée", yn(infos?.estLivraisonEffectue)),
        line("Programme changé", yn(infos?.estProgrammeChange)),
        const SizedBox(height: 8),
        line("État logiciel", infos?.etatSoftware ?? "-"),
        line("Motif arrêt", infos?.motifArret ?? "-"),
        line("Motif débranchement", infos?.motifDebranchement ?? "-"),
        line("Motif insatisfaction", infos?.motifInsatisfaction ?? "-"),
      ],
    );
  }

  static Widget _sectionTitle(String t) => Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF5DB7A1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      );

  static Widget _dataCard({required Widget child}) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      );

  static Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              TextSpan(text: "$k: ", style: const TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: v),
            ],
          ),
        ),
      );

  static Widget _programmeRow(ProgrammeEtat p) {
    String freq() {
      final on = p.tempsEnMarche, off = p.tempsDeRepos, u = p.unite ?? '';
      if (on == null || off == null) return "-";
      final unit = u.toLowerCase().contains('minute') ? 'minute' : u.toLowerCase();
      return "$on-$off $unit";
    }

    String plage() {
      String _hm(String? t) {
        if (t == null) return "-";
        final parts = t.split(':');
        if (parts.length < 2) return "-";
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return "${h}h${m.toString().padLeft(2, '0')}";
      }

      return "${_hm(p.heureDebut)} → ${_hm(p.heureFin)}";
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Expanded(child: Text("Fréquence: ${freq()}")),
          Expanded(child: Text("Plage: ${plage()}")),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: p.joursActifs.map((j) => Chip(label: Text(j))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _bouteilleTable(BouteilleEtat b) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFF5DB7A1)),
          children: [
            _th("Type"),
            _th("Quantité initiale"),
            _th("Quantité prévu"),
            _th("Quantité existante"),
            _th("Parfum"),
          ],
        ),
        TableRow(
          children: [
            _td(b.type ?? "-"),
            _td(_ml(b.qteInitiale)),
            _td(_ml(b.qtePrevu)),
            _td(_ml(b.qteLaisse)),
            _td(b.parfum ?? "-"),
          ],
        ),
      ],
    );
  }

  static String _ml(int? v) => v == null ? "-" : "${v}ml";

  static Widget _th(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(
          t,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );

  static Widget _td(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(t),
      );

  static Widget _alertesTable(List<AlerteEtat> rows) {
    return DataTable(
      showCheckboxColumn: false,
      columnSpacing: 28,
      headingRowColor: MaterialStateProperty.all(const Color(0xFF5DB7A1)),
      columns: const [
        DataColumn(label: _Head("Date")),
        DataColumn(label: _Head("Problème")),
        DataColumn(label: _Head("Cause")),
        DataColumn(label: _Head("Etat résolution")),
      ],
      rows: rows
          .map(
            (a) => DataRow(
              onSelectChanged: (_) => Get.toNamed('/alertes/${a.id}'),
              cells: [
                DataCell(Text(a.date)),
                DataCell(Text(a.probleme ?? '-')),
                DataCell(Text(a.cause ?? '-')),
                DataCell(Text(a.etatResolution)),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _Head extends StatelessWidget {
  final String t;
  const _Head(this.t);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Text(
          t,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
}
