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
            backgroundColor: const Color(0xFF0A1E40),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Détails de la Réclamation",
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
                  Color(0xFF0A1E40),
                  Color(0xFF152A51),
                  Color(0xFF1E3A8A),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: c.isLoading.value
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Chargement des détails...",
                          style: TextStyle(color: Colors.white),
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
                          color: Colors.red.shade100,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Erreur de chargement",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          c.error.value!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade300),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: c.fetch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0A1E40),
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
                : d == null
                ? const Center(
                    child: Text(
                      "Aucune donnée disponible",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : _ReclamationDetailView(d: d, controller: c),
          ),
        );
      },
    );
  }
}

class _ReclamationDetailView extends StatelessWidget {
  final ReclamationDetail d;
  final ReclamationDetailController controller;

  const _ReclamationDetailView({required this.d, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1E40).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.report_problem,
                          color: Color(0xFF0A1E40),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Réclamation #${d.id}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A1E40),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              d.dateLabel,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            d.statut.apiValue,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getStatusColor(d.statut.apiValue),
                          ),
                        ),
                        child: Text(
                          d.statut.apiValue,
                          style: TextStyle(
                            color: _getStatusColor(d.statut.apiValue),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    "Problème",
                    d.probleme ?? "-",
                    Icons.description,
                  ),
                  _buildDetailItem("Client", d.client ?? "-", Icons.person),
                  _buildDetailItem(
                    "Dernier Technicien",
                    d.dernierTechnicien ?? "-",
                    Icons.engineering,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Steps Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ÉTAPES DE TRAITEMENT",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1E40),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Appel téléphonique step
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: d.etapes
                              ? const Color(0xFF1B6B3A)
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone,
                          color: d.etapes ? Colors.white : Colors.grey.shade600,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Appel téléphonique",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Tooltip(
                        message: controller.infoAppelTel,
                        preferBelow: false,
                        child: const Icon(Icons.info, color: Color(0xFF3E7DA6)),
                      ),
                      const SizedBox(width: 12),
                      Checkbox(
                        value: d.etapes,
                        onChanged: (v) => controller.toggleEtapes(v ?? false),
                        activeColor: const Color(0xFF0A1E40),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Container(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 16),

                  // Visite contrôle step
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: controller.canPlanifier
                              ? const Color(0xFF0A1E40)
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.engineering,
                          color: controller.canPlanifier
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Visite contrôle",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      FilledButton(
                        onPressed: controller.canPlanifier
                            ? () => controller.planifierIntervention(context)
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: controller.canPlanifier
                              ? const Color(0xFF0A1E40)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text("Planifier"),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: controller.infoVisiteCtrl,
                        child: const Icon(Icons.info, color: Color(0xFF3E7DA6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Actions Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ACTIONS",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1E40),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.markFausse,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF9C3A3A),
                            side: const BorderSide(color: Color(0xFF9C3A3A)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel, size: 20),
                              SizedBox(width: 8),
                              Text("Fausse Réclamation"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: controller.markTraite,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1B6B3A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 20),
                              SizedBox(width: 8),
                              Text("Marquer Traité"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  FilledButton(
                    onPressed: controller.goToClient,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0A1E40),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 20),
                        SizedBox(width: 8),
                        Text("Visualiser Client"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0A1E40)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1E40),
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'traité':
        return const Color(0xFF1B6B3A);
      case 'en cours':
        return const Color(0xFF3E7DA6);
      case 'fausse réclamation':
        return const Color(0xFF9C3A3A);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
