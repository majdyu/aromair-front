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
      init: Get.put(
        EtatClientDiffuseurController(interventionId, clientDiffuseurId),
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
              "État du Diffuseur",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
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
                onPressed: () => c.fetch(),
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Chargement des détails...",
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
                                  size: 48,
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
                                Text(
                                  c.error.value!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: c.fetch,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0A1E40),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Réessayer"),
                                ),
                              ],
                            ),
                          )
                        : data == null
                        ? const Center(
                            child: Text(
                              "Aucune donnée disponible",
                              style: TextStyle(color: Color(0xFF0A1E40)),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header section
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.air,
                                      color: Color(0xFF0A1E40),
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "État du Diffuseur",
                                      style: TextStyle(
                                        fontSize: 22,
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
                                        color: Colors.blue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Actif",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Référence: ${data.cab}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Main content in two columns
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left column - Diffuser info
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          _buildInfoCard(data),
                                          const SizedBox(height: 16),
                                          _buildProgrammesCard(data.programmes),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 24),

                                    // Right column - Intervention info and alerts
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          _buildInterventionInfoCard(data),
                                          const SizedBox(height: 16),
                                          _buildBouteilleCard(data.bouteille),
                                          const SizedBox(height: 16),
                                          _buildAlertesCard(data.alertes),
                                        ],
                                      ),
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

  Widget _buildInfoCard(EtatClientDiffuseur data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF0A1E40),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Informations du diffuseur",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1E40),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _infoRow(
              "Date de mise en marche",
              data.dateMiseEnMarche == null
                  ? "-"
                  : DateFormat('dd/MM/yyyy').format(data.dateMiseEnMarche!),
            ),
            _infoRow(
              "Max minutes/jour",
              data.maxMinutesParJour?.toString() ?? "-",
            ),
            _infoRow(
              "Rythme conso/jour",
              data.rythmeConsomParJour == null
                  ? "-"
                  : "${data.rythmeConsomParJour!} ml",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionInfoCard(EtatClientDiffuseur data) {
    // Helper functions
    String yn(bool? v) => v == null ? "-" : (v ? "Oui" : "Non");
    String quality(bool? v) => v == null ? "-" : (v ? "Bonne" : "Mauvaise");
    String pos(bool? v) => v == null ? "-" : (v ? "Intérieur" : "Extérieur");
    String branchement(bool? v) =>
        v == null ? "-" : (v ? "Branché" : "Débranché");
    String marche(bool? v) => v == null ? "-" : (v ? "En Marche" : "En Arrêt");

    // Get values (priority to infos, otherwise fallback)
    final _qualite = data.infos?.qualiteBonne ?? data.qualiteBonne;
    final _fuite = data.infos?.fuite ?? data.fuite;
    final _marche = data.infos?.enMarche ?? data.enMarche;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.construction,
                  color: Color(0xFF0A1E40),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Informations d'intervention",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1E40),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Status indicators
            Row(
              children: [
                _statusIndicator(
                  "Qualité",
                  quality(_qualite),
                  _qualite == true ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                _statusIndicator(
                  "Fuite",
                  yn(_fuite),
                  _fuite == false ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                _statusIndicator(
                  "État",
                  marche(_marche),
                  _marche == true ? Colors.green : Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Details in two columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        "Position tuyau",
                        pos(data.infos?.tuyeauPosition),
                      ),
                      _infoRow("En place", yn(data.infos?.estEnPlace)),
                      _infoRow(
                        "Autocollant",
                        yn(data.infos?.estAutocolantApplique),
                      ),
                      _infoRow("Dommage", yn(data.infos?.estDommage)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        "Branchement",
                        branchement(data.infos?.branchement),
                      ),
                      _infoRow(
                        "Livraison",
                        yn(data.infos?.estLivraisonEffectue),
                      ),
                      _infoRow(
                        "Programme changé",
                        yn(data.infos?.estProgrammeChange),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Additional info
            if (data.infos?.etatSoftware != null)
              _infoRow("État logiciel", data.infos!.etatSoftware!),
            if (data.infos?.motifArret != null)
              _infoRow("Motif arrêt", data.infos!.motifArret!),
            if (data.infos?.motifDebranchement != null)
              _infoRow("Motif débranchement", data.infos!.motifDebranchement!),
            if (data.infos?.motifInsatisfaction != null)
              _infoRow(
                "Motif insatisfaction",
                data.infos!.motifInsatisfaction!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusIndicator(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgrammesCard(List<ProgrammeEtat> programmes) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Color(0xFF0A1E40), size: 20),
                const SizedBox(width: 8),
                const Text(
                  "Programmes",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1E40),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text("${programmes.length}"),
                  backgroundColor: Colors.blue[50],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            if (programmes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Aucun programme configuré"),
                ),
              )
            else
              ...programmes.map((p) => _programmeTile(p)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _programmeTile(ProgrammeEtat p) {
    String freq() {
      final on = p.tempsEnMarche, off = p.tempsDeRepos, u = p.unite ?? '';
      if (on == null || off == null) return "-";
      final unit = u.toLowerCase().contains('minute') ? 'min' : u.toLowerCase();
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

      return "${_hm(p.heureDebut)} - ${_hm(p.heureFin)}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text("Fréquence: ${freq()}"),
              const Spacer(),
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
                    label: Text(j, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.blue[50],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBouteilleCard(BouteilleEtat? bouteille) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.inventory_2,
                  color: Color(0xFF0A1E40),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Bouteille",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1E40),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            if (bouteille == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Aucune bouteille reliée"),
                ),
              )
            else
              InkWell(
                onTap: bouteille.id != null
                    ? () {
                        Get.toNamed('/bouteilles/${bouteille.id}');
                      }
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _infoRow("Type", bouteille.type ?? "-"),
                      _infoRow("Parfum", bouteille.parfum ?? "-"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _quantityIndicator(
                              "Initiale",
                              bouteille.qteInitiale,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _quantityIndicator(
                              "Prévue",
                              bouteille.qtePrevu,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _quantityIndicator(
                              "Restante",
                              bouteille.qteExistante,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quantityIndicator(String title, int? value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value?.toString() ?? "-",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text("ml", style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildAlertesCard(List<AlerteEtat> alertes) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Color(0xFF0A1E40), size: 20),
                const SizedBox(width: 8),
                const Text(
                  "Alertes",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1E40),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text("${alertes.length}"),
                  backgroundColor: alertes.isEmpty
                      ? Colors.green[50]
                      : Colors.red[50],
                  labelStyle: TextStyle(
                    color: alertes.isEmpty ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            if (alertes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Aucune alerte enregistrée"),
                ),
              )
            else
              ...alertes.map((a) => _alerteTile(a)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _alerteTile(AlerteEtat alerte) {
    Color statusColor = Colors.grey;
    if (alerte.etatResolution.toLowerCase().contains('résolu') ||
        alerte.etatResolution.toLowerCase().contains('resolu')) {
      statusColor = Colors.green;
    } else if (alerte.etatResolution.toLowerCase().contains('en cours')) {
      statusColor = Colors.orange;
    } else if (alerte.etatResolution.toLowerCase().contains('non résolu') ||
        alerte.etatResolution.toLowerCase().contains('non resolu')) {
      statusColor = Colors.red;
    }

    return InkWell(
      onTap: () => Get.toNamed('/alertes/${alerte.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200] ?? Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    alerte.date,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    alerte.etatResolution,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (alerte.probleme != null) Text("Problème: ${alerte.probleme!}"),
            if (alerte.cause != null) Text("Cause: ${alerte.cause!}"),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}
