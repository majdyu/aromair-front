import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:front_erp_aromair/viewmodel/admin/overview_controller.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  int _safe(List<int> l, int i) => (i < 0 || i >= l.length) ? 0 : l[i];

  @override
  Widget build(BuildContext context) {
    return GetX<OverviewController>(
      init: OverviewController(),
      builder: (c) {
        if (c.isLoading.value) {
          return _buildLoadingState();
        }

        if (c.error.value != null) {
          return _buildErrorState(c);
        }

        // Data Processing - ONLY using actual available data
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
          onRefresh: c.fetch,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F1B2D),
                  Color(0xFF1A2B3E),
                  Color(0xFF2D3B4E),
                ],
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // Performance Gauges - Using actual SAV and Satisfaction data
                    _buildPerformanceGauges(sav, sat),
                    const SizedBox(height: 32),

                    // Main Charts Grid - Using ONLY actual data
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.of(context).size.width > 1200
                          ? 2
                          : 1,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.6,
                      children: [
                        // Client Distribution - Using actual client type data
                        _buildClientsDistributionChart(nbAchat, nbConv, nbMad),
                        // Operations Overview - Using actual operations data
                        _buildOperationsChart(nbInterv, nbDiff, nbTech),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Metrics Summary - Using actual count data
                    _buildMetricsSummary(
                      nbDiff,
                      nbTech,
                      nbInterv,
                      nbAchat,
                      nbConv,
                      nbMad,
                      context,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return AromaScaffold(
      title: "Tableau de Bord",
      onRefresh: () {},
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1B2D), Color(0xFF1A2B3E)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(OverviewController c) {
    return AromaScaffold(
      title: "Tableau de Bord",
      onRefresh: c.fetch,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1B2D), Color(0xFF1A2B3E)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              Text(
                c.error.value!,
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: c.fetch,
                child: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tableau de Bord Analytics",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Analyses basées sur vos données actuelles",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGauges(int sav, int sat) {
    return Row(
      children: [
        Expanded(
          child: _buildGaugeChart(
            sav,
            "Rendement SAV",
            "Efficacité du service",
            const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildGaugeChart(
            sat,
            "Satisfaction Client",
            "Niveau de satisfaction",
            const Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }

  Widget _buildGaugeChart(
    int value,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: value / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                // Value text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$value%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _getPerformanceLabel(value),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPerformanceLabel(int value) {
    if (value >= 80) return 'Excellent';
    if (value >= 60) return 'Bon';
    return 'À améliorer';
  }

  Widget _buildClientsDistributionChart(int achat, int convention, int mad) {
    final total = achat + convention + mad;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_alt_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                "Répartition des Clients",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Basé sur ${total} clients au total",
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: total > 0
                ? PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: achat.toDouble(),
                          color: const Color(0xFFFFB74D),
                          title:
                              '${((achat / total) * 100).toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: convention.toDouble(),
                          color: const Color(0xFFAED581),
                          title:
                              '${((convention / total) * 100).toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: mad.toDouble(),
                          color: const Color(0xFFF06292),
                          title: '${((mad / total) * 100).toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  )
                : const Center(
                    child: Text(
                      "Aucune donnée client disponible",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem("Achat ($achat)", const Color(0xFFFFB74D)),
              _buildLegendItem(
                "Convention ($convention)",
                const Color(0xFFAED581),
              ),
              _buildLegendItem("MAD ($mad)", const Color(0xFFF06292)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsChart(
    int interventions,
    int diffuseurs,
    int techniciens,
  ) {
    final maxValue = [
      interventions,
      diffuseurs,
      techniciens,
    ].reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                "Aperçu des Opérations",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Comparaison des principales métriques",
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final titles = [
                          'Interventions',
                          'Diffuseurs',
                          'Techniciens',
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            titles[value.toInt()],
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: interventions.toDouble(),
                        color: const Color(0xFF4DB6AC),
                        width: 24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: diffuseurs.toDouble(),
                        color: const Color(0xFF4FC3F7),
                        width: 24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: techniciens.toDouble(),
                        color: const Color(0xFF9575CD),
                        width: 24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSummary(
    int nbDiff,
    int nbTech,
    int nbInterv,
    int nbAchat,
    int nbConv,
    int nbMad,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.summarize_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                "Résumé des Métriques",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _buildMetricCard(
                "Diffuseurs",
                nbDiff,
                Icons.air_rounded,
                const Color(0xFF4FC3F7),
              ),
              _buildMetricCard(
                "Techniciens",
                nbTech,
                Icons.engineering_rounded,
                const Color(0xFF9575CD),
              ),
              _buildMetricCard(
                "Interventions",
                nbInterv,
                Icons.assignment_rounded,
                const Color(0xFF4DB6AC),
              ),
              _buildMetricCard(
                "Clients Achat",
                nbAchat,
                Icons.shopping_cart_rounded,
                const Color(0xFFFFB74D),
              ),
              _buildMetricCard(
                "Clients Convention",
                nbConv,
                Icons.handshake_rounded,
                const Color(0xFFAED581),
              ),
              _buildMetricCard(
                "Clients MAD",
                nbMad,
                Icons.business_center_rounded,
                const Color(0xFFF06292),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
