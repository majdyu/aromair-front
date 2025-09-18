import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/etat_client_diffuseur.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';
import 'package:front_erp_aromair/viewmodel/admin/clientdiffuseur_detail_controller.dart';

class ClientDiffuseurDetailScreen extends StatelessWidget {
  final int clientDiffuseurId;
  const ClientDiffuseurDetailScreen({
    super.key,
    required this.clientDiffuseurId,
  });

  @override
  Widget build(BuildContext context) {
    final tag = 'cdd_$clientDiffuseurId';
    return GetX<ClientDiffuseurDetailController>(
      init: Get.put(
        ClientDiffuseurDetailController(clientDiffuseurId),
        tag: tag,
      ),
      tag: tag,
      builder: (c) {
        final data = c.dto.value;

        return Scaffold(
          drawer: const AdminDrawer(),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A1E40),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Détails du Client Diffuseur",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: c.fetch,
                tooltip: "Actualiser",
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1E40), // Dark navy
                  Color(0xFF152A51), // Medium navy
                  Color(0xFF1E3A8A), // Royal blue
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 12,
                    shadowColor: Colors.black.withOpacity(0.4),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: c.isLoading.value
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF0A1E40),
                                    ),
                                    strokeWidth: 3,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Chargement des données...",
                                    style: TextStyle(color: Color(0xFF0A1E40)),
                                  ),
                                ],
                              ),
                            )
                          : c.error.value != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade400,
                                    size: 52,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Erreur de chargement",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF0A1E40),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                    child: Text(
                                      c.error.value!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: c.fetch,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A1E40),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Text("Réessayer"),
                                  ),
                                ],
                              ),
                            )
                          : data == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.devices_other,
                                    color: Colors.grey,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Aucune donnée disponible",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF0A1E40),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.devices_other,
                                        color: Color(0xFF0A1E40),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Détails du Diffuseur",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0A1E40),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF0A1E40,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Text(
                                          "Ref: ${data.cab}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF0A1E40),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Informations détaillées du diffuseur client",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Informations générales
                                  _sectionTitle("Informations Générales"),
                                  const SizedBox(height: 16),
                                  _dataCard(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          _infoRow("Modèle", data.modele),
                                          const Divider(height: 20),
                                          _infoRow(
                                            "Type de carte",
                                            data.typeCarte,
                                          ),
                                          const Divider(height: 20),
                                          _infoRow(
                                            "Emplacement",
                                            data.emplacement,
                                          ),
                                          const Divider(height: 20),
                                          _infoRow(
                                            "Date de mise en marche",
                                            data.dateMiseEnMarche == null
                                                ? "-"
                                                : DateFormat(
                                                    'dd/MM/yyyy',
                                                  ).format(
                                                    data.dateMiseEnMarche!,
                                                  ),
                                          ),
                                          const Divider(height: 20),
                                          _infoRow(
                                            "Max minutes / jour",
                                            data.maxMinutesParJour
                                                    ?.toString() ??
                                                "-",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // ---------- Programmes ----------
                                  _sectionTitle("Programmes"),
                                  const SizedBox(height: 16),
                                  _dataCard(
                                    child: data.programmes.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Text(
                                              "Aucun programme configuré.",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : Column(
                                            children: data.programmes
                                                .map(_programmeRow)
                                                .toList(),
                                          ),
                                  ),
                                  const SizedBox(height: 24),

                                  // ---------- Bouteille ----------
                                  _sectionTitle("Bouteille"),
                                  const SizedBox(height: 16),
                                  _dataCard(
                                    child: data.bouteille == null
                                        ? const Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Text(
                                              "Aucune bouteille reliée.",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _infoRow(
                                                  "Type",
                                                  data.bouteille!.type ?? "-",
                                                ),
                                                const Divider(height: 20),
                                                _infoRow(
                                                  "Quantité initiale",
                                                  data.bouteille!.qteInitiale
                                                          ?.toString() ??
                                                      "-",
                                                ),
                                                const Divider(height: 20),
                                                _infoRow(
                                                  "Quantité prévue",
                                                  data.bouteille!.qtePrevu
                                                          ?.toString() ??
                                                      "-",
                                                ),
                                                const Divider(height: 20),
                                                _infoRow(
                                                  "Quantité restante",
                                                  data.bouteille!.qteExistante
                                                          ?.toString() ??
                                                      "-",
                                                ),
                                                const Divider(height: 20),
                                                _infoRow(
                                                  "Parfum",
                                                  data.bouteille!.parfum ?? "-",
                                                ),
                                                const SizedBox(height: 16),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      final id =
                                                          data.bouteille?.id;
                                                      if (id != null) {
                                                        Get.toNamed(
                                                          '/bouteilles/$id',
                                                        );
                                                      } else {
                                                        Get.snackbar(
                                                          "Indisponible",
                                                          "Cette bouteille n'a pas d'identifiant.",
                                                          backgroundColor:
                                                              Colors.red,
                                                          colorText:
                                                              Colors.white,
                                                        );
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF0A1E40,
                                                          ),
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      "Voir les détails de la bouteille",
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 24),

                                  // ---------- Alertes ----------
                                  _sectionTitle("Alertes"),
                                  const SizedBox(height: 16),
                                  _dataCard(
                                    child: data.alertes.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Text(
                                              "Aucune alerte enregistrée.",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              children: [
                                                ...data.alertes.map(
                                                  (a) => Column(
                                                    children: [
                                                      _alertRow(a),
                                                      if (data.alertes.last !=
                                                          a)
                                                        const Divider(
                                                          height: 20,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
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
          ),
        );
      },
    );
  }

  // ---- helpers réutilisés (identiques à ton autre écran)
  static Widget _infoRow(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 2,
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A1E40),
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
      ),
    ],
  );

  static Widget _sectionTitle(String t) => Row(
    children: [
      Container(
        width: 4,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFF0A1E40),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        t,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Color(0xFF0A1E40),
        ),
      ),
    ],
  );

  static Widget _dataCard({required Widget child}) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    ),
  );

  static Widget _programmeRow(ProgrammeEtat p) {
    String freq() {
      final on = p.tempsEnMarche, off = p.tempsDeRepos, u = p.unite ?? '';
      if (on == null || off == null) return "-";
      final unit = u.toLowerCase().contains('minute')
          ? 'minute'
          : u.toLowerCase();
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 18, color: Color(0xFF0A1E40)),
              const SizedBox(width: 8),
              Text(
                "Fréquence: ${freq()}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Color(0xFF0A1E40)),
              const SizedBox(width: 8),
              Text("Plage: ${plage()}"),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: p.joursActifs
                .map(
                  (j) => Chip(
                    label: Text(j),
                    backgroundColor: const Color(0xFF0A1E40).withOpacity(0.1),
                    labelStyle: const TextStyle(color: Color(0xFF0A1E40)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  static Widget _alertRow(AlerteEtat a) {
    return InkWell(
      onTap: () => Get.toNamed('/alertes/${a.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber,
              color: _getAlertColor(a.etatResolution),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.date,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A1E40),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.probleme ?? '-',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getAlertColor(
                            a.etatResolution,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          a.etatResolution,
                          style: TextStyle(
                            color: _getAlertColor(a.etatResolution),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _getAlertColor(String etat) {
    if (etat.contains('résolu') || etat.contains('traité')) {
      return Colors.green;
    } else if (etat.contains('en cours')) {
      return Colors.orange;
    } else if (etat.contains('critique') || etat.contains('urgence')) {
      return Colors.red;
    }
    return Colors.grey;
  }
}
