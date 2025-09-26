import 'package:flutter/material.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:front_erp_aromair/viewmodel/admin/interventions/etat_cd_controller.dart';
import 'package:front_erp_aromair/data/models/etat_client_diffuseur.dart';

import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';

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

        return AromaScaffold(
          // ⬅️ Uses your global Scaffold (keeps gradient + app bar styling)
          title: "État du Diffuseur",
          onRefresh: c.fetch,
          // If your AromaScaffold does not include the drawer internally, uncomment:
          // drawer: const AdminDrawer(),
          body: Padding(
            // keep same spacing as before
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: AromaCard(
                  // ⬅️ Outer container card (replaces Card+Padding)
                  padding: const EdgeInsets.all(24),
                  child: c.isLoading.value
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Chargement des détails...",
                                style: TextStyle(color: AppColors.primary),
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
                                color: Colors.redAccent,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Erreur de chargement",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.primary,
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
                                  backgroundColor: AppColors.primary,
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
                            style: TextStyle(color: AppColors.primary),
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
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "État du Diffuseur",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
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
                                        const Icon(
                                          Icons.circle,
                                          size: 12,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
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
                                  // Left column
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

                                  // Right column
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
        );
      },
    );
  }

  // ===============================
  // Cards now use AromaCard
  // ===============================

  Widget _buildInfoCard(EtatClientDiffuseur data) {
    return AromaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                "Informations du diffuseur",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
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
    );
  }

  Widget _buildInterventionInfoCard(EtatClientDiffuseur data) {
    String yn(bool? v) => v == null ? "-" : (v ? "Oui" : "Non");
    String quality(bool? v) => v == null ? "-" : (v ? "Bonne" : "Mauvaise");
    String pos(bool? v) => v == null ? "-" : (v ? "Intérieur" : "Extérieur");
    String branchement(bool? v) =>
        v == null ? "-" : (v ? "Branché" : "Débranché");
    String marche(bool? v) => v == null ? "-" : (v ? "En Marche" : "En Arrêt");

    final _qualite = data.infos?.qualiteBonne ?? data.qualiteBonne;
    final _fuite = data.infos?.fuite ?? data.fuite;
    final _marche = data.infos?.enMarche ?? data.enMarche;

    return AromaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.construction, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                "Informations d'intervention",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
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

          // Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Position tuyau", pos(data.infos?.tuyeauPosition)),
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
                    _infoRow("Livraison", yn(data.infos?.estLivraisonEffectue)),
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

          if (data.infos?.etatSoftware != null)
            _infoRow("État logiciel", data.infos!.etatSoftware!),
          if (data.infos?.motifArret != null)
            _infoRow("Motif arrêt", data.infos!.motifArret!),
          if (data.infos?.motifDebranchement != null)
            _infoRow("Motif débranchement", data.infos!.motifDebranchement!),
          if (data.infos?.motifInsatisfaction != null)
            _infoRow("Motif insatisfaction", data.infos!.motifInsatisfaction!),
        ],
      ),
    );
  }

  Widget _buildProgrammesCard(List<ProgrammeEtat> programmes) {
    return AromaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Programmes",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text("${programmes.length}"),
                backgroundColor: Colors.blue[50],
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Spacer(),
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
    );
  }

  Widget _buildBouteilleCard(BouteilleEtat? bouteille) {
    return AromaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.inventory_2, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                "Bouteille",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
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
                      Get.toNamed(
                        AppRoutes.bouteilleDetail,
                        arguments: {'bouteilleId': bouteille.id},
                      );
                      //Get.toNamed('/bouteilles/${bouteille.id}');
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
    );
  }

  Widget _buildAlertesCard(List<AlerteEtat> alertes) {
    return AromaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Alertes",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
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
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Spacer(),
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
    );
  }

  Widget _alerteTile(AlerteEtat alerte) {
    Color statusColor = Colors.grey;
    final st = alerte.etatResolution.toLowerCase();
    if (st.contains('résolu') || st.contains('resolu')) {
      statusColor = Colors.green;
    } else if (st.contains('en cours')) {
      statusColor = Colors.orange;
    } else if (st.contains('non résolu') || st.contains('non resolu')) {
      statusColor = Colors.red;
    }

    return InkWell(
      // ✅ pass via arguments (no id in URL)
      onTap: () {
        Get.toNamed(AppRoutes.alerteDetail, arguments: {'alerteId': alerte.id});
      },
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

  // ===== helpers unchanged =====

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
