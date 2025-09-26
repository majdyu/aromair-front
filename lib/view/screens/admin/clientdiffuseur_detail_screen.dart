import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/etat_client_diffuseur.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:front_erp_aromair/viewmodel/admin/clientdiffuseur_detail_controller.dart';

// ✅ Global widgets
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';

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

        return AromaScaffold(
          title: "Détails du Client Diffuseur",
          onRefresh: c.fetch,
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: AromaCard(
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
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Chargement des données...",
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
                              const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 52,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                child: Text(
                                  c.error.value!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: c.fetch,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
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
                                  color: AppColors.primary,
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
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Détails du Diffuseur",
                                    style: TextStyle(
                                      fontSize: 24,
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
                                      color: const Color(
                                        0xFF0A1E40,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      "Ref: ${data.cab}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
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
                                      _infoRow("Type de carte", data.typeCarte),
                                      const Divider(height: 20),
                                      _infoRow("Emplacement", data.emplacement),
                                      const Divider(height: 20),
                                      _infoRow(
                                        "Date de mise en marche",
                                        data.dateMiseEnMarche == null
                                            ? "-"
                                            : DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(data.dateMiseEnMarche!),
                                      ),
                                      const Divider(height: 20),
                                      _infoRow(
                                        "Max minutes / jour",
                                        data.maxMinutesParJour?.toString() ??
                                            "-",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Programmes
                              _sectionTitle("Programmes"),
                              const SizedBox(height: 16),
                              _dataCard(
                                child: data.programmes.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          "Aucun programme configuré.",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    : Column(
                                        children: data.programmes
                                            .map(_programmeRow)
                                            .toList(),
                                      ),
                              ),
                              const SizedBox(height: 24),

                              // Bouteille
                              _sectionTitle("Bouteille"),
                              const SizedBox(height: 16),
                              _dataCard(
                                child: data.bouteille == null
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          "Aucune bouteille reliée.",
                                          style: TextStyle(color: Colors.grey),
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
                                                  final id = data.bouteille?.id;
                                                  if (id != null) {
                                                    // (Optionally convert to args-based route if you have one)
                                                    Get.toNamed(
                                                      '/bouteilles/$id',
                                                    );
                                                  } else {
                                                    Get.snackbar(
                                                      "Indisponible",
                                                      "Cette bouteille n'a pas d'identifiant.",
                                                      backgroundColor:
                                                          Colors.red,
                                                      colorText: Colors.white,
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF0A1E40,
                                                  ),
                                                  foregroundColor: Colors.white,
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

                              // Alertes
                              _sectionTitle("Alertes"),
                              const SizedBox(height: 16),
                              _dataCard(
                                child: data.alertes.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          "Aucune alerte enregistrée.",
                                          style: TextStyle(color: Colors.grey),
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
                                                  if (data.alertes.last != a)
                                                    const Divider(height: 20),
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
        );
      },
    );
  }

  // ---- helpers (unchanged visually) ----
  static Widget _infoRow(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(width: 2),
      Expanded(
        flex: 2,
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
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
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        t,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: AppColors.primary,
        ),
      ),
    ],
  );

  // ✅ Use AromaCard for data sections
  static Widget _dataCard({required Widget child}) => AromaCard(
    padding: EdgeInsets.zero, // content manages its own padding
    child: child,
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
            children: const [
              Icon(Icons.schedule, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
            ],
          ),
          Row(
            children: [
              Text(
                "Fréquence: ${freq()}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
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
                    label: Text(j),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppColors.primary),
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
      // ✅ args-based navigation for alert detail
      onTap: () =>
          Get.toNamed(AppRoutes.alerteDetail, arguments: {'alerteId': a.id}),
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
                      color: AppColors.primary,
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
    final lower = etat.toLowerCase();
    if (lower.contains('résolu') ||
        lower.contains('resolu') ||
        lower.contains('traité')) {
      return Colors.green;
    } else if (lower.contains('en cours')) {
      return Colors.orange;
    } else if (lower.contains('critique') || lower.contains('urgence')) {
      return Colors.red;
    }
    return Colors.grey;
  }
}

// (kept for satisfaction gauge)
/*class _DonutPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _DonutPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final prog = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    final start = -math.pi / 2;
    final sweep = (2 * math.pi) * progress;
    canvas.drawArc(rect, start, sweep, false, prog);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
*/
