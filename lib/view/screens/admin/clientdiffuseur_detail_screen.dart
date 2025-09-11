import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/etat_client_diffuseur.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';
import 'package:front_erp_aromair/viewmodel/admin/clientdiffuseur_detail_controller.dart';

class ClientDiffuseurDetailScreen extends StatelessWidget {
  final int clientDiffuseurId;
  const ClientDiffuseurDetailScreen({super.key, required this.clientDiffuseurId});

  @override
  Widget build(BuildContext context) {
    final tag = 'cdd_$clientDiffuseurId';
    return GetX<ClientDiffuseurDetailController>(
      init: Get.put(ClientDiffuseurDetailController(clientDiffuseurId), tag: tag),
      tag: tag,
      builder: (c) {
        final data = c.dto.value;

        return Scaffold(
          drawer: const AdminDrawer(),
          appBar: AppBar(
            backgroundColor: const Color(0xFF75A6D1),
            centerTitle: true,
            title: const Text("Client Diffuseur"),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                        // ---------- En-tête ----------
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
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
                                                  _kv("Max minutes / jour", data.maxMinutesParJour?.toString() ?? "-"),
                                                ],
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
                                                          final id = data.bouteille?.id;
                                                          if (id != null) {
                                                            Get.toNamed('/bouteilles/$id');
                                                          } else {
                                                            Get.snackbar("Indisponible",
                                                                "Cette bouteille n’a pas d’identifiant.");
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

  // ---- helpers réutilisés (identiques à ton autre écran)
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

  static Widget _sectionTitle(String t) => Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(color: const Color(0xFF5DB7A1), borderRadius: BorderRadius.circular(2)),
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
        child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      );
}