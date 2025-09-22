import 'package:flutter/material.dart';
import 'percent_gauge.dart';

class GaugeTile extends StatelessWidget {
  final int percent; // 0..100
  final String title;
  final String subtitle;

  const GaugeTile({
    super.key,
    required this.percent,
    required this.title,
    required this.subtitle,
  });

  Color _gaugeColor(double p) {
    if (p >= 80) return const Color(0xFF4CAF50); // green
    if (p >= 60) return const Color(0xFFFF9800); // orange
    return const Color(0xFFF44336); // red
  }

  String _perfLabel(double p) {
    if (p >= 80) return "Excellent";
    if (p >= 60) return "Bon";
    if (p >= 40) return "Moyen";
    return "À améliorer";
  }

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0, 100).toDouble();
    final color = _gaugeColor(p);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
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
              color: Color(0xFF0A1E40), // brand navy
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 20),

          // Donut gauge
          PercentGauge(
            percent: p,
            color: color,
            center: Column(
              mainAxisSize: MainAxisSize.min,
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
                  _perfLabel(p),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Linear bar under the gauge
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: p / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
