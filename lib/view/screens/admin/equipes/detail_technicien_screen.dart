import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/technicien.dart';
import 'package:front_erp_aromair/viewmodel/admin/equipe/technicien_details_controller.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';
import 'package:front_erp_aromair/theme/colors.dart';

class TechnicienConsultationScreen extends StatelessWidget {
  const TechnicienConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TechnicienConsultationController());

    return GetBuilder<TechnicienConsultationController>(
      builder: (_) {
        final t = c.data.value;

        return AromaScaffold(
          title: t?.nom.toUpperCase() ?? 'Technicien',
          onRefresh: c.refreshFromServer,
          body: t == null
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 768;
                    final isTablet = constraints.maxWidth < 1024;

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        children: [
                          _buildProfileHeader(context, t, c, isMobile),
                          SizedBox(height: isMobile ? 20 : 24),
                          _buildKpiCards(t, isMobile, isTablet),
                          SizedBox(height: isMobile ? 20 : 24),
                          if (!isMobile) _buildChartsRow(t, isMobile),
                          if (isMobile) _buildMobileCharts(t),
                          SizedBox(height: isMobile ? 20 : 24),
                          _buildPerformanceInsights(t, isMobile),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    TechnicienConsultation t,
    TechnicienConsultationController c,
    bool isMobile,
  ) {
    return AromaCard(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      child: Row(
        children: [
          // Avatar with Performance Ring
          Stack(
            children: [
              Container(
                width: isMobile ? 80 : 100,
                height: isMobile ? 80 : 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.engineering_rounded,
                  color: Colors.white,
                  size: isMobile ? 36 : 42,
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _colorForRendement(t.rondementTAF),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    '${t.rondementTAF}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: isMobile ? 16 : 24),

          // Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.nom.toUpperCase(),
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Depuis ${t.dateAjout}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.handyman_rounded,
                            size: 14,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${t.nbrInterventionsDiffuseurs} interventions',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Period Selector
          _buildPeriodSelector(c, context),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(
    TechnicienConsultationController c,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Période',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => c.pickPeriode(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    c.periodeLabel,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCards(
    TechnicienConsultation t,
    bool isMobile,
    bool isTablet,
  ) {
    final kpis = [
      _KpiData(
        title: 'Performance TAF',
        value: '${t.rondementTAF}%',
        subtitle: 'Rendement actuel',
        color: _colorForRendement(t.rondementTAF),
        icon: Icons.trending_up_rounded,
        trend: _calculateTrend(t.rondementTAF),
      ),
      _KpiData(
        title: 'Interventions',
        value: '${t.nbrInterventionsDiffuseurs}',
        subtitle: 'Total réalisées',
        color: const Color(0xFF10B981),
        icon: Icons.handyman_rounded,
        trend: 'up',
      ),
      _KpiData(
        title: 'Recette',
        value: _fmtMoney(t.recetteActuelle),
        subtitle: 'Cumul généré',
        color: const Color(0xFF3B82F6),
        icon: Icons.attach_money_rounded,
        trend: 'up',
      ),
      _KpiData(
        title: 'Caisse',
        value: _fmtMoney(t.caisseActuelle),
        subtitle: 'Solde actuel',
        color: const Color(0xFFF59E0B),
        icon: Icons.account_balance_wallet_rounded,
        trend: 'stable',
      ),
    ];

    if (isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: kpis.length,
        itemBuilder: (context, index) => _KpiCard(kpi: kpis[index]),
      );
    }

    return Row(
      children: kpis.map((kpi) => Expanded(child: _KpiCard(kpi: kpi))).toList(),
    );
  }

  Widget _buildChartsRow(TechnicienConsultation t, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildPerformanceGauge(t)),
        SizedBox(width: isMobile ? 16 : 24),
        Expanded(flex: 1, child: _buildFinancialBreakdown(t)),
      ],
    );
  }

  Widget _buildMobileCharts(TechnicienConsultation t) {
    return Column(
      children: [
        _buildPerformanceGauge(t),
        const SizedBox(height: 16),
        _buildFinancialBreakdown(t),
      ],
    );
  }

  Widget _buildPerformanceGauge(TechnicienConsultation t) {
    return AromaCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Jauge de Performance",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular Gauge
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Progress circle
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            _colorForRendement(t.rondementTAF),
                            _colorForRendement(t.rondementTAF).withOpacity(0.3),
                          ],
                          stops: [t.rondementTAF / 100, t.rondementTAF / 100],
                        ),
                      ),
                    ),
                    // Inner circle
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${t.rondementTAF}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: _colorForRendement(t.rondementTAF),
                              ),
                            ),
                            Text(
                              _getPerformanceLabel(t.rondementTAF),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildPerformanceLegend(t.rondementTAF),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceLegend(int rendement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendDot('Faible', const Color(0xFFEF4444), rendement < 60),
        const SizedBox(width: 16),
        _buildLegendDot(
          'Moyen',
          const Color(0xFFF59E0B),
          rendement >= 60 && rendement < 80,
        ),
        const SizedBox(width: 16),
        _buildLegendDot('Excellent', const Color(0xFF10B981), rendement >= 80),
      ],
    );
  }

  Widget _buildLegendDot(String label, Color color, bool isActive) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialBreakdown(TechnicienConsultation t) {
    final totalValue = t.recetteActuelle + t.caisseActuelle;
    final recettePercentage = totalValue > 0
        ? (t.recetteActuelle / totalValue * 100)
        : 0;
    final caissePercentage = totalValue > 0
        ? (t.caisseActuelle / totalValue * 100)
        : 0;

    return AromaCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Répartition Financière",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              // Recette Bar
              _buildFinancialBar(
                'Recette Générée',
                _fmtMoney(t.recetteActuelle),
                recettePercentage.toDouble(),
                const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 12),
              // Caisse Bar
              _buildFinancialBar(
                'Caisse Actuelle',
                _fmtMoney(t.caisseActuelle),
                caissePercentage.toDouble(),
                const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _fmtMoney(totalValue),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialBar(
    String label,
    String value,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width: percentage * 2, // keep original sizing assumption
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceInsights(TechnicienConsultation t, bool isMobile) {
    return AromaCard(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Indicateurs Clés",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              childAspectRatio: isMobile ? 1.8 : 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildMetricCard(
                  'Efficacité Opérationnelle',
                  '${t.rondementTAF}%',
                  'Basé sur le rendement TAF',
                  _colorForRendement(t.rondementTAF),
                  Icons.workspace_premium_rounded,
                );
              } else {
                final avgRevenuePerIntervention =
                    t.nbrInterventionsDiffuseurs > 0
                    ? t.recetteActuelle / t.nbrInterventionsDiffuseurs
                    : 0;
                return _buildMetricCard(
                  'Revenue par Intervention',
                  _fmtMoney(avgRevenuePerIntervention.toDouble()),
                  'Moyenne par diffuseur',
                  const Color(0xFF10B981),
                  Icons.attach_money_rounded,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'KPI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Helper methods ----

  static Color _colorForRendement(int p) {
    if (p >= 80) return const Color(0xFF10B981);
    if (p >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  static String _fmtMoney(double v) {
    return '${v.toStringAsFixed(3)} TND';
  }

  static String _calculateTrend(int rendement) {
    if (rendement >= 80) return 'up';
    if (rendement >= 60) return 'stable';
    return 'down';
  }

  static String _getPerformanceLabel(int rendement) {
    if (rendement >= 80) return 'Excellent';
    if (rendement >= 60) return 'Bon';
    return 'À améliorer';
  }
}

class _KpiData {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String trend;

  _KpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.trend,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiData kpi;

  const _KpiCard({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TechnicienConsultationController>();
    final isRecette = kpi.title == 'Recette';
    final isCaisse = kpi.title == 'Caisse';

    return GestureDetector(
      onTap: () {
        if (isRecette) ctrl.openRecetteDetails();
        if (isCaisse) ctrl.openCaisseDetails();
      },
      onLongPress: () {
        if (isRecette) ctrl.toggleRecetteExpanded();
        if (isCaisse) ctrl.toggleCaisseExpanded();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: kpi.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(kpi.icon, color: kpi.color, size: 16),
                ),
                const Spacer(),
                Icon(
                  kpi.trend == 'up'
                      ? Icons.trending_up_rounded
                      : kpi.trend == 'down'
                      ? Icons.trending_down_rounded
                      : Icons.trending_flat_rounded,
                  color: kpi.trend == 'up'
                      ? const Color(0xFF10B981)
                      : kpi.trend == 'down'
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFF59E0B),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              kpi.value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              kpi.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              kpi.subtitle,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),

            // === Added: inline expansion area (preserves your design) ===
            if (isRecette)
              Obx(
                () => AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  crossFadeState: ctrl.recetteExpanded.value
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _RecettePreview(),
                  ),
                ),
              ),
            if (isCaisse)
              Obx(
                () => AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  crossFadeState: ctrl.caisseExpanded.value
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _CaissePreview(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ====== Small preview widgets (keeps card clean) ======

class _RecettePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<TechnicienConsultationController>();
    return Obx(() {
      if (c.loadingRecette.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: LinearProgressIndicator(minHeight: 4),
        );
      }
      final d = c.recetteDetail.value;
      if (d == null) return const Text('—');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _miniRow('Actuelle', '${d.actuelle.toStringAsFixed(3)} TND'),
          _miniRow('Supposée', '${d.recetteSuppose.toStringAsFixed(3)} TND'),
          _miniRow('Cultivée', '${d.recetteCultive.toStringAsFixed(3)} TND'),
          _miniRow('Reçue', '${d.recetteRecu.toStringAsFixed(3)} TND'),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              c.periodeLabel,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    });
  }

  Widget _miniRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(fontSize: 11)),
        Text(
          v,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _CaissePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<TechnicienConsultationController>();
    return Obx(() {
      if (c.loadingCaisse.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: LinearProgressIndicator(minHeight: 4),
        );
      }
      final d = c.caisseDetail.value;
      if (d == null) return const Text('—');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _miniRow('Solde actuel', '${d.actuelle.toStringAsFixed(3)} TND'),
          _miniRow('Entrées', '${d.totalEntree.toStringAsFixed(3)} TND'),
          _miniRow('Dépenses', '${d.totalDepense.toStringAsFixed(3)} TND'),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              c.periodeLabel,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    });
  }

  Widget _miniRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(fontSize: 11)),
        Text(
          v,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
