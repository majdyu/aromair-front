import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';
import 'package:front_erp_aromair/viewmodel/admin/interventions/intervention_detail_controller.dart';
import 'package:front_erp_aromair/view/screens/admin/interventions/work_todo_dialog.dart';

class InterventionDetailScreen extends StatelessWidget {
  final int interventionId;
  const InterventionDetailScreen({super.key, required this.interventionId});

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    return GetX<InterventionDetailController>(
      init: InterventionDetailController(interventionId),
      builder: (c) {
        final d = c.detail.value;

        return Scaffold(
          drawer: const AdminDrawer(),
          appBar: AppBar(
            backgroundColor: const Color(0xFF75A6D1),
            centerTitle: true,
            title: const Text("Consulter Intervention"),
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
                            : d == null
                                ? const Center(child: Text("Aucune donnée"))
                                : SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ---------- Bandeau header ----------
                                        Wrap(
                                          spacing: 16,
                                          runSpacing: 16,
                                          children: [
                                            // Colonne gauche : infos clés
                                            SizedBox(
                                              width: 520,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _kv("Date", _fmtDate(d.date)),
                                                  _kv(
                                                    "Dernière intervention",
                                                    d.derniereIntervention != null
                                                        ? _fmtDate(d.derniereIntervention!)
                                                        : "-",
                                                  ),
                                                  _kv("Technicien", d.userNom),
                                                  _kv("Client", d.clientNom),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: [
                                                      _statutChip(d.statut),
                                                      _payChip(d.estPayementObligatoire
                                                          ? "Payement obligatoire"
                                                          : "Payement non obligatoire"),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Colonne droite : remarque + actions
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Remarque / Règlement",
                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: Colors.black12),
                                                    ),
                                                    child: Text(
                                                      (d.remarque?.isNotEmpty ?? false) ? d.remarque! : "-",
                                                      style: const TextStyle(height: 1.3),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: [
                                                      FilledButton.icon(
                                                        onPressed: c.detail.value == null ? null : () async {
                                                          final ok = await showWorkToDoDialog(context, c.detail.value!);
                                                          if (ok == true) {
                                                            await c.fetch(); // ⟵ recharge les données après sauvegarde
                                                          }
                                                        },
                                                        icon: const Icon(Icons.list_alt),
                                                        label: const Text("Travail à faire"),
                                                      ),
                                                      _chipDisabled(Icons.picture_as_pdf,
                                                          d.titreFicheMaintenance ?? "Fiche maintenance"),
                                                      _chipDisabled(
                                                          Icons.photo_library_outlined, "Médias (bientôt)"),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 22),

                                        // ---------- Diffuseurs ----------
                                        _sectionTitle("Diffuseurs"),
                                        const SizedBox(height: 8),
                                        _dataCard(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: DataTable(
                                              showCheckboxColumn: false, // << cache la colonne de checkbox
                                              columnSpacing: 28,
                                              headingRowHeight: 42,
                                              dataRowMinHeight: 44,
                                              dataRowMaxHeight: 56,
                                              headingRowColor:
                                                  MaterialStateProperty.all(const Color(0xFF5DB7A1)),
                                              columns: const [
                                                DataColumn(label: _Head("CAB")),
                                                DataColumn(label: _Head("Modèle")),
                                                DataColumn(label: _Head("Type carte")),
                                                DataColumn(label: _Head("Emplacement")),
                                              ],
                                              rows: d.diffuseurs.map((r) {
                                                return DataRow(
                                                  onSelectChanged: (_) {
                                                    Get.toNamed('/interventions/${d.id}/client-diffuseurs/${r.id}');
                                                  },
                                                  cells: [
                                                    DataCell(Text(r.cab)),
                                                    DataCell(Text(r.modeleDiffuseur)),
                                                    DataCell(Text(r.typeDiffuseur)),
                                                    DataCell(Text(r.emplacement)),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 22),

                                        // ---------- Alertes ----------
                                        _sectionTitle("Alertes"),
                                        const SizedBox(height: 8),
                                        _dataCard(
                                          child: d.alertes.isEmpty
                                              ? const Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: Text("Aucune alerte enregistrée."),
                                                )
                                              : SingleChildScrollView(
                                                  scrollDirection: Axis.vertical,
                                                  child: DataTable(
                                                    columnSpacing: 28,
                                                    headingRowHeight: 42,
                                                    dataRowMinHeight: 44,
                                                    dataRowMaxHeight: 56,
                                                    headingRowColor: MaterialStateProperty.all(
                                                      const Color(0xFF5DB7A1),
                                                    ),
                                                    columns: const [
                                                      DataColumn(label: _Head("Date")),
                                                      DataColumn(label: _Head("Problème")),
                                                      DataColumn(label: _Head("Cause")),
                                                      DataColumn(label: _Head("État résolution")),
                                                    ],
                                                    rows: d.alertes.map((a) => DataRow(cells: [
                                                      DataCell(Text(a.date)),
                                                      DataCell(Text(a.probleme ?? "-")),
                                                      DataCell(Text(a.cause ?? "-")),
                                                      DataCell(Text(a.etatResolution)),
                                                    ])).toList(),
                                                  ),
                                                ),
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

  // ---------- Helpers UI ----------

  Widget _sectionTitle(String t) => Row(
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

  Widget _dataCard({required Widget child}) => ClipRRect(
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

  Widget _kv(String k, String v) => Padding(
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

  static Widget _chipDisabled(IconData i, String label) => Chip(
        avatar: Icon(i, size: 18),
        label: Text(label),
        backgroundColor: const Color(0xFFEFE7F6),
        side: BorderSide.none,
      );

  static Color _statutColor(String s) {
    switch (s) {
      case "TRAITE":
        return const Color(0xFF2EB85C); // vert
      case "EN_RETARD":
        return const Color(0xFFDC3545); // rouge
      case "NON_ACCOMPLIES":
        return const Color(0xFFFF7F50); // corail
      case "EN_COURS":
      default:
        return const Color(0xFFFFC107); // amber
    }
  }

  static Widget _statutChip(String statut) => Chip(
        avatar: Icon(Icons.brightness_1, size: 16, color: _statutColor(statut)),
        label: Text(_prettyStatut(statut)),
        backgroundColor: const Color(0xFFF7F7F7),
        side: BorderSide.none,
      );

  static Widget _payChip(String label) => Chip(
        avatar: const Icon(Icons.payments_outlined, size: 18),
        label: Text(label),
        backgroundColor: const Color(0xFFF7F7F7),
        side: BorderSide.none,
      );

  static String _prettyStatut(String s) {
    switch (s) {
      case "EN_COURS":
        return "en cours";
      case "TRAITE":
        return "traité";
      case "EN_RETARD":
        return "en retard";
      case "NON_ACCOMPLIES":
        return "non accomplies";
      default:
        return s;
    }
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
