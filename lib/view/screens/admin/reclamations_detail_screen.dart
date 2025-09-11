import 'package:flutter/material.dart';
import 'package:front_erp_aromair/viewmodel/admin/reclamation_detail_controller.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';
import 'package:front_erp_aromair/data/models/reclamation_detail.dart';

class ReclamationDetailScreen extends StatelessWidget {
  final int reclamationId;
  const ReclamationDetailScreen({super.key, required this.reclamationId});

  @override
  Widget build(BuildContext context) {
    final tag = 'recl_$reclamationId';
    return GetX<ReclamationDetailController>(
      init: Get.put(ReclamationDetailController(reclamationId), tag: tag),
      tag: tag,
      builder: (c) {
        final d = c.dto.value;

        return Scaffold(
          drawer: const AdminDrawer(),
          appBar: AppBar(
            backgroundColor: const Color(0xFF75A6D1),
            centerTitle: true,
            title: const Text("Consulter Réclamation"),
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
                constraints: const BoxConstraints(maxWidth: 900),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                        _kv("Date", d.dateLabel),
                                        _kv("Problème", d.probleme ?? "-"),
                                        Row(
                                          children: [
                                            Expanded(child: _kv("Dernier Technicien", d.dernierTechnicien ?? "-")),
                                            const SizedBox(width: 12),
                                            Expanded(child: _kv("Client", d.client ?? "-")),
                                            const SizedBox(width: 12),
                                            FilledButton.tonal(
                                              onPressed: c.goToClient,
                                              child: const Text("Visualiser Client"),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Chip(
                                            label: Text("Statut: ${d.statut.apiValue}"),
                                            backgroundColor: const Color(0xFFEDEAF6),
                                          ),
                                        ),

                                        const SizedBox(height: 20),
                                        const Text("Étapes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Text("Appel téléphonique:"),
                                            const SizedBox(width: 8),
                                            Tooltip(
                                              message: c.infoAppelTel,
                                              preferBelow: false,
                                              child: const Icon(Icons.info, color: Color(0xFF3E7DA6)),
                                            ),
                                            const SizedBox(width: 12),
                                            Checkbox(
                                              value: d.etapes,
                                              onChanged: (v) => c.toggleEtapes(v ?? false),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text("Visite contrôle:"),
                                            const SizedBox(width: 8),
                                            FilledButton(
                                              onPressed: c.canPlanifier ? () => c.planifierIntervention(context) : null,
                                              style: FilledButton.styleFrom(
                                                backgroundColor: c.canPlanifier ? const Color(0xFF6B7280) : Colors.black26,
                                              ),
                                              child: const Text("Planifier une intervention"),
                                            ),
                                            const SizedBox(width: 10),
                                            Tooltip(
                                              message: c.infoVisiteCtrl,
                                              child: const Icon(Icons.info, color: Color(0xFF3E7DA6)),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            OutlinedButton(
                                              onPressed: c.markFausse,
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF9C3A3A),
                                                side: const BorderSide(color: Color(0xFF9C3A3A)),
                                              ),
                                              child: const Text("Fausse Réclamation"),
                                            ),
                                            const SizedBox(width: 12),
                                            FilledButton(
                                              onPressed: c.markTraite,
                                              style: FilledButton.styleFrom(
                                                backgroundColor: const Color(0xFFDFF5E1),
                                                foregroundColor: const Color(0xFF1B6B3A),
                                              ),
                                              child: const Text("Traité"),
                                            ),
                                          ],
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

  static Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$k: ", style: const TextStyle(fontWeight: FontWeight.w700)),
            Expanded(child: Text(v)),
          ],
        ),
      );
}
