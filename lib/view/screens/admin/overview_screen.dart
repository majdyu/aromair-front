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
            backgroundColor: const Color(0xFF75A6D1),
            elevation: 0,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            centerTitle: true,
            title: const Text("Aperçu"),
          ),
          body: Container(
            color: const Color(0xFF75A6D1),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: _body(c),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(OverviewController c) {
    if (c.isLoading.value) {
      return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()));
    }
    if (c.error.value != null) {
      return SizedBox(
        height: 260,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text("Erreur: ${c.error.value}", textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton(onPressed: c.fetch, child: const Text("Réessayer")),
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

    return Column(
      children: [
        // Ligne 2 jauges (cercle graphique)
        Row(
          children: [
            Expanded(
              child: _GaugeTile(
                percent: sav,
                title: "Rendement\nSAV",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GaugeTile(
                percent: sat,
                title: "Satisfaction\nClients",
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Grille 3 x 2
        LayoutBuilder(builder: (context, cons) {
          final twoCols = cons.maxWidth < 700;
          return GridView.count(
            crossAxisCount: twoCols ? 2 : 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatBox(value: nbDiff, label: "Nombre de\nDiffuseurs"),
              _StatBox(value: nbTech, label: "Nombre de\nTechniciens"),
              _StatBox(value: nbInterv, label: "Nombre d' \nInterventions d'aujourd'hui"),
              _StatBox(value: nbAchat, label: "Clients\nStock Achat"),
              _StatBox(value: nbConv, label: "Clients\nConventionné"),
              _StatBox(value: nbMad, label: "Clients\nMis à disposition"),
            ],
          );
        }),
      ],
    );
  }

  int _safe(List<int> l, int i) => (i < 0 || i >= l.length) ? 0 : l[i];
}

/// des cercles graphiques comme sur la maquette.
/// Voici une jauge simple en CustomPaint (anneau gris + anneau de progression).
class _GaugeTile extends StatelessWidget {
  final int percent; // 0..100
  final String title;
  const _GaugeTile({required this.percent, required this.title});

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0, 100).toDouble();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CustomPaint(
              painter: _RingPainter(value: p / 100),
              child: Center(
                child: Text(
                  "${p.toInt()}%",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value; // 0..1
  _RingPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 6.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) / 2) - stroke;

    final bg = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = Colors.black87 // couleur principale du ring
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // anneau de fond
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi, false, bg);
    // progression
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * value, false, fg);

    // petit liseré externe (look proche de la maquette)
    final thin = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius + stroke / 2 + 1, thin);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value;
}

class _StatBox extends StatelessWidget {
  final int value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$value", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}
