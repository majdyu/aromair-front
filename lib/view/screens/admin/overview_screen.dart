import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/viewmodel/admin/overview_controller.dart';
import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<OverviewController>(
      init: OverviewController(),
      builder: (c) {
        return Scaffold(
          drawer: const AdminDrawer(),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A1E40),
            elevation: 0,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            centerTitle: true,
            title: const Text(
              "Tableau de Bord",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: _body(context, c),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, OverviewController c) {
    if (c.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2.0,
        ),
      );
    }

    if (c.error.value != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 48),
            const SizedBox(height: 20),
            Text(
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
              style: TextStyle(color: Colors.white70, fontSize: 14),
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
      );
    }

    final sav = _safe(c.data, OverviewController.iRendementSav);
    final sat = _safe(c.data, OverviewController.iSatisfaction);
    final nbDiff = _safe(c.data, OverviewController.iNbDiffuseurs);
    final nbTech = _safe(c.data, OverviewController.iNbTechniciens);
    final nbInterv = _safe(c.data, OverviewController.iNbIntervJour);
    final nbAchat = _safe(c.data, OverviewController.iClientsAchat);
    final nbConv = _safe(c.data, OverviewController.iClientsConvention);
    final nbMad = _safe(c.data, OverviewController.iClientsMAD);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
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
          Text(
            "Statistiques et indicateurs de performance",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 32),

          // Gauges Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return isWide
                  ? Row(
                      children: [
                        Expanded(
                          child: _GaugeTile(
                            percent: sav,
                            title: "Rendement SAV",
                            subtitle: "Efficacité du service après-vente",
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _GaugeTile(
                            percent: sat,
                            title: "Satisfaction Clients",
                            subtitle: "Niveau de satisfaction global",
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _GaugeTile(
                          percent: sav,
                          title: "Rendement SAV",
                          subtitle: "Efficacité du service après-vente",
                        ),
                        const SizedBox(height: 20),
                        _GaugeTile(
                          percent: sat,
                          title: "Satisfaction Clients",
                          subtitle: "Niveau de satisfaction global",
                        ),
                      ],
                    );
            },
          ),
          const SizedBox(height: 32),

          // Stats Grid
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
              _StatBox(
                value: nbDiff,
                label: "Diffuseurs",
                icon: Icons.air,
                description: "Nombre total de diffuseurs",
                color: const Color(0xFF4FC3F7),
              ),
              _StatBox(
                value: nbTech,
                label: "Techniciens",
                icon: Icons.engineering,
                description: "Effectif technique",
                color: const Color(0xFF9575CD),
              ),
              _StatBox(
                value: nbInterv,
                label: "Interventions",
                icon: Icons.assignment,
                description: "Aujourd'hui",
                color: const Color(0xFF4DB6AC),
              ),
              _StatBox(
                value: nbAchat,
                label: "Clients Achat",
                icon: Icons.shopping_cart,
                description: "Stock achat",
                color: const Color(0xFFFFB74D),
              ),
              _StatBox(
                value: nbConv,
                label: "Clients Convention",
                icon: Icons.handshake,
                description: "Conventionnés",
                color: const Color(0xFFAED581),
              ),
              _StatBox(
                value: nbMad,
                label: "Clients MAD",
                icon: Icons.business_center,
                description: "Mis à disposition",
                color: const Color(0xFFF06292),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _safe(List<int> l, int i) => (i < 0 || i >= l.length) ? 0 : l[i];
}

class _GaugeTile extends StatelessWidget {
  final int percent;
  final String title;
  final String subtitle;

  const _GaugeTile({
    required this.percent,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0, 100).toDouble();
    final color = _getGaugeColor(p);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0A1E40),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(160, 160),
                  painter: _RingPainter(value: p / 100, color: color),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${p.toInt()}%",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPerformanceText(p),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: p / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Color _getGaugeColor(double percent) {
    if (percent >= 80) return const Color(0xFF4CAF50); // Green
    if (percent >= 60) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  String _getPerformanceText(double percent) {
    if (percent >= 80) return "Excellent";
    if (percent >= 60) return "Bon";
    if (percent >= 40) return "Moyen";
    return "À améliorer";
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;

  _RingPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - stroke;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Foreground circle (progress)
    final fgPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.7)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Draw background circle
    canvas.drawCircle(center, radius, bgPaint);

    // Draw progress arc
    final sweepAngle = 2 * math.pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );

    // Draw center circle with subtle gradient
    final centerGradient = RadialGradient(
      colors: [Colors.white, Colors.grey.shade100],
    );
    final centerPaint = Paint()
      ..shader = centerGradient.createShader(
        Rect.fromCircle(center: center, radius: radius - stroke),
      );
    canvas.drawCircle(center, radius - stroke, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color;
}

class _StatBox extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final String description;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const Spacer(),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0A1E40),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A1E40),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
