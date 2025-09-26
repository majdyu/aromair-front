import 'package:flutter/material.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/viewmodel/admin/alerte_detail_controller.dart';
import 'package:front_erp_aromair/data/models/alerte_recos.dart';

// ✅ Global widgets
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';

// If your AromaScaffold needs an external drawer, uncomment this:
// import '../../widgets/admin_drawer.dart';

class AlerteDetailScreen extends StatelessWidget {
  final int alerteId;
  const AlerteDetailScreen({super.key, required this.alerteId});

  void _showRecosBottomSheet(
    BuildContext context,
    List<String> recos,
    void Function(String? selected) onInsert,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        if (recos.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Aucune recommandation pour ce problème."),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recommandations",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...recos.map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.tips_and_updates_outlined),
                  title: Text(r),
                  trailing: TextButton(
                    onPressed: () {
                      onInsert(r);
                      Navigator.pop(context);
                    },
                    child: const Text("Insérer"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tag = 'al_$alerteId';
    return GetX<AlerteDetailController>(
      init: Get.put(AlerteDetailController(alerteId), tag: tag),
      tag: tag,
      builder: (c) {
        final dto = c.dto.value;

        return AromaScaffold(
          title: "Détails de l'Alerte",
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
                      : dto == null
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
                                    Icons.warning,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Détails de l'Alerte",
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
                                      color: dto.etatResolution
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 12,
                                          color: dto.etatResolution
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          dto.etatResolution
                                              ? "Résolu"
                                              : "Non résolu",
                                          style: TextStyle(
                                            color: dto.etatResolution
                                                ? Colors.green
                                                : Colors.red,
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
                                "Numéro : ${dto.id}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Main content
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left column - Alert details
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _infoCard(
                                          "Informations de l'alerte",
                                          Icons.info_outline,
                                          [
                                            _infoRow("Date", dto.date),
                                            _infoRow(
                                              "Problème",
                                              dto.probleme ?? '-',
                                            ),
                                            _infoRow("Cause", dto.cause ?? '-'),
                                            _infoRow(
                                              "Diffuseur",
                                              _fmtDiffuseur(
                                                dto.diffuseurCab,
                                                dto.diffuseurModele,
                                                dto.diffuseurTypeCarte,
                                              ),
                                            ),
                                            _infoRow("Client", dto.client),
                                            if (dto.emplacement.isNotEmpty)
                                              _infoRow(
                                                "Emplacement",
                                                dto.emplacement,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 24),

                                  // Right column - Actions
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        _actionCard("Actions", Icons.settings, [
                                          ElevatedButton.icon(
                                            onPressed: () => c.goToClient(),
                                            icon: const Icon(
                                              Icons.person_search,
                                              size: 20,
                                            ),
                                            label: const Text(
                                              "Visualiser Client",
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF0A1E40,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ]),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Decision section
                              _infoCard(
                                "Décision prise",
                                Icons.gavel_outlined,
                                [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Décision prise:'),
                                      const SizedBox(width: 8),
                                      Tooltip(
                                        message: 'Voir recommandations',
                                        child: InkWell(
                                          onTap: () {
                                            final recos =
                                                AlerteRecos.forProblem(
                                                  dto.probleme,
                                                );
                                            _showRecosBottomSheet(
                                              context,
                                              recos,
                                              (text) {
                                                if (text != null &&
                                                    text.trim().isNotEmpty) {
                                                  c.decisionCtrl.text = text;
                                                }
                                              },
                                            );
                                          },
                                          child: const Icon(
                                            Icons.info,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: c.decisionCtrl,
                                    minLines: 3,
                                    maxLines: 6,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: c.isSaving.value
                                          ? null
                                          : () async {
                                              await c.onTogglePressed();
                                            },
                                      icon: Icon(
                                        (dto.etatResolution)
                                            ? Icons.sentiment_satisfied_alt
                                            : Icons.sentiment_dissatisfied,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        (dto.etatResolution)
                                            ? 'Marquer comme non résolu'
                                            : 'Marquer comme résolu',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: dto.etatResolution
                                            ? Colors.red
                                            : Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 28,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
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

  static String _fmtDiffuseur(String cab, String modele, String type) {
    final p = <String>[];
    if (cab != '-') p.add(cab);
    if (modele != '-') p.add(modele);
    if (type != '-') p.add(type);
    return p.isEmpty ? '-' : p.join(' • ');
  }

  // ---------- UI Components (now using AromaCard) ----------
  Widget _infoCard(String title, IconData icon, List<Widget> children) {
    return AromaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _actionCard(String title, IconData icon, List<Widget> children) {
    return AromaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(children: children),
        ],
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
            width: 120,
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
