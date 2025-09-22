import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/viewmodel/admin/overview_controller.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/kpi/gauge_tile.dart';
import 'package:front_erp_aromair/view/widgets/kpi/stat_box.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  int _safe(List<int> l, int i) => (i < 0 || i >= l.length) ? 0 : l[i];

  @override
  Widget build(BuildContext context) {
    return GetX<OverviewController>(
      init: OverviewController(),
      builder: (c) {
        // Loading
        if (c.isLoading.value) {
          return AromaScaffold(
            title: "Tableau de Bord",
            onRefresh: c.fetch,
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
          );
        }

        // Error
        if (c.error.value != null) {
          return AromaScaffold(
            title: "Tableau de Bord",
            onRefresh: c.fetch,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white70,
                    size: 48,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Erreur de chargement des données",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    c.error.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: c.fetch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0A1E40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            ),
          );
        }

        // Data
        final sav = _safe(c.data, OverviewController.iRendementSav);
        final sat = _safe(c.data, OverviewController.iSatisfaction);
        final nbDiff = _safe(c.data, OverviewController.iNbDiffuseurs);
        final nbTech = _safe(c.data, OverviewController.iNbTechniciens);
        final nbInterv = _safe(c.data, OverviewController.iNbIntervJour);
        final nbAchat = _safe(c.data, OverviewController.iClientsAchat);
        final nbConv = _safe(c.data, OverviewController.iClientsConvention);
        final nbMad = _safe(c.data, OverviewController.iClientsMAD);

        return AromaScaffold(
          title: "Tableau de Bord",
          onRefresh: c.fetch, // refresh action in AppBar
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Aperçu Global",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const Text(
                        "Statistiques et indicateurs de performance",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Gauges Row (responsive)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 900;
                          final tiles = [
                            GaugeTile(
                              percent: sav,
                              title: "Rendement SAV",
                              subtitle: "Efficacité du service après-vente",
                            ),
                            GaugeTile(
                              percent: sat,
                              title: "Satisfaction Clients",
                              subtitle: "Niveau de satisfaction global",
                            ),
                          ];
                          return isWide
                              ? Row(
                                  children: [
                                    Expanded(child: tiles[0]),
                                    const SizedBox(width: 20),
                                    Expanded(child: tiles[1]),
                                  ],
                                )
                              : Column(
                                  children: [
                                    tiles[0],
                                    const SizedBox(height: 20),
                                    tiles[1],
                                  ],
                                );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Stats Grid (responsive)
                      GridView.count(
                        crossAxisCount: MediaQuery.of(context).size.width > 1200
                            ? 3
                            : MediaQuery.of(context).size.width > 700
                            ? 2
                            : 1,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 1.5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [],
                      ),

                      // Fill grid items
                      GridView.count(
                        crossAxisCount: MediaQuery.of(context).size.width > 1200
                            ? 3
                            : MediaQuery.of(context).size.width > 700
                            ? 2
                            : 1,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 1.5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatBox(
                            value: nbDiff,
                            label: "Diffuseurs",
                            icon: Icons.air,
                            description: "Nombre total de diffuseurs",
                            color: Color(0xFF4FC3F7),
                          ),
                          StatBox(
                            value: nbTech,
                            label: "Techniciens",
                            icon: Icons.engineering,
                            description: "Effectif technique",
                            color: Color(0xFF9575CD),
                          ),
                          StatBox(
                            value: nbInterv,
                            label: "Interventions",
                            icon: Icons.assignment,
                            description: "Aujourd'hui",
                            color: Color(0xFF4DB6AC),
                          ),
                          StatBox(
                            value: nbAchat,
                            label: "Clients Achat",
                            icon: Icons.shopping_cart,
                            description: "Stock achat",
                            color: Color(0xFFFFB74D),
                          ),
                          StatBox(
                            value: nbConv,
                            label: "Clients Convention",
                            icon: Icons.handshake,
                            description: "Conventionnés",
                            color: Color(0xFFAED581),
                          ),
                          StatBox(
                            value: nbMad,
                            label: "Clients MAD",
                            icon: Icons.business_center,
                            description: "Mis à disposition",
                            color: Color(0xFFF06292),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
