import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_erp_aromair/data/models/equipe.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:front_erp_aromair/viewmodel/admin/interventions/intervention_detail_controller.dart';
import 'package:front_erp_aromair/view/screens/admin/interventions/work_todo_dialog.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart'; // keep for outer wrapper

class InterventionDetailScreen extends StatelessWidget {
  final int interventionId;
  const InterventionDetailScreen({super.key, required this.interventionId});

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
  String _fmtMoney(num? v) =>
      v == null ? '-' : NumberFormat("#,##0.###", "fr_FR").format(v);

  @override
  Widget build(BuildContext context) {
    final tag = 'inter_$interventionId';

    return GetX<InterventionDetailController>(
      init: Get.put(InterventionDetailController(interventionId), tag: tag),
      tag: tag,
      builder: (c) {
        final d = c.detail.value;

        if (d != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!c.isEditingRemark.value) {
              final incoming = (d.remarque ?? '').trim();
              if (c.remarkCtrl.text != incoming) c.remarkCtrl.text = incoming;
            }
            if (!c.isEditingPay.value) {
              final payStr = d.payement == null ? '' : d.payement!.toString();
              if (c.payCtrl.text != payStr) c.payCtrl.text = payStr;
            }

            // keep basic form hydrated when not editing
            c.hydrateBasicFormIfIdle();
          });
        }

        return AromaScaffold(
          title: "Détails de l'Intervention $interventionId",
          body: AromaCard(
            // only the outermost wrapper uses AromaCard
            child: Padding(
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
                            color: Colors.red.shade400,
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
                  : d == null
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
                                Icons.construction,
                                color: AppColors.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Détails de l'Intervention",
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
                                  color: _statusColor(
                                    d.statut,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 12,
                                      color: _statusColor(d.statut),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _prettyStatut(d.statut),
                                      style: TextStyle(
                                        color: _statusColor(d.statut),
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
                            "Numéro : ${d.id}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Main content - two columns layout
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column - Basic info
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ==================== INFORMATIONS DE BASE (view/edit) ====================
                                    _infoCard(
                                      "Informations de base",
                                      Icons.info_outline,
                                      [
                                        Obx(
                                          () => c.isEditingBasicInfo.value
                                              ? _basicInfoForm(c) // EDIT
                                              : _basicInfoView(d), // VIEW
                                        ),
                                      ],
                                      trailing: Obx(() {
                                        if (c.isEditingBasicInfo.value) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                tooltip: "Annuler",
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                ),
                                                onPressed:
                                                    c.isSavingBasicInfo.value
                                                    ? null
                                                    : c.cancelEditBasicInfo,
                                              ),
                                              IconButton(
                                                tooltip: "Enregistrer",
                                                icon: c.isSavingBasicInfo.value
                                                    ? const SizedBox(
                                                        width: 18,
                                                        height: 18,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      )
                                                    : const Icon(
                                                        Icons.check,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                onPressed:
                                                    c.isSavingBasicInfo.value
                                                    ? null
                                                    : c.submitBasicInfo,
                                              ),
                                            ],
                                          );
                                        } else {
                                          return IconButton(
                                            tooltip:
                                                "Modifier les informations de base",
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                            onPressed: c.startEditBasicInfo,
                                          );
                                        }
                                      }),
                                    ),
                                    const SizedBox(height: 16),
                                    _remarqueWidget(c),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 24),

                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _actionCard("Actions", Icons.settings, [
                                      ElevatedButton.icon(
                                        onPressed: c.detail.value == null
                                            ? null
                                            : () async {
                                                final ok =
                                                    await showWorkToDoDialog(
                                                      context,
                                                      c.detail.value!,
                                                    );
                                                if (ok == true) {
                                                  await c.fetch();
                                                }
                                              },
                                        icon: const Icon(
                                          Icons.list_alt,
                                          size: 20,
                                        ),
                                        label: const Text("Travail à faire"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0A1E40,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.photo_library_outlined,
                                          size: 20,
                                        ),
                                        label: const Text("Médias (bientôt)"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF0A1E40,
                                          ),
                                          side: const BorderSide(
                                            color: AppColors.primary,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.picture_as_pdf,
                                          size: 20,
                                        ),
                                        label: Text(
                                          d.titreFicheMaintenance ??
                                              "Fiche maintenance",
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF0A1E40,
                                          ),
                                          side: const BorderSide(
                                            color: AppColors.primary,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: 16),
                                    _paymentWidget(c),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Diffuseurs section
                          _sectionTitle("Diffuseurs"),
                          const SizedBox(height: 12),
                          _dataTableCard(
                            columns: const [
                              DataColumn(label: _TableHeader("CAB")),
                              DataColumn(label: _TableHeader("Modèle")),
                              DataColumn(label: _TableHeader("Type carte")),
                              DataColumn(label: _TableHeader("Emplacement")),
                            ],
                            rows: d.diffuseurs.map((r) {
                              return DataRow(
                                onSelectChanged: (_) {
                                  Get.toNamed(
                                    AppRoutes.interventionClientDiffuseur,
                                    arguments: {
                                      'interventionId': d.id,
                                      'clientDiffuseurId': r.id,
                                    },
                                  );
                                },
                                cells: [
                                  DataCell(Text(r.cab)),
                                  DataCell(Text(r.modeleDiffuseur)),
                                  DataCell(Text(r.typeDiffuseur)),
                                  DataCell(Text(r.emplacement)),
                                ],
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),

                          // Alertes section
                          _sectionTitle("Alertes"),
                          const SizedBox(height: 12),
                          d.alertes.isEmpty
                              ? _emptyStateCard(
                                  Icons.notifications_none,
                                  "Aucune alerte enregistrée",
                                )
                              : _dataTableCard(
                                  columns: const [
                                    DataColumn(label: _TableHeader("Date")),
                                    DataColumn(label: _TableHeader("Problème")),
                                    DataColumn(label: _TableHeader("Cause")),
                                    DataColumn(
                                      label: _TableHeader("État résolution"),
                                    ),
                                  ],
                                  rows: d.alertes.map((a) {
                                    return DataRow(
                                      onSelectChanged: (_) {
                                        print("Alerte ID: ${a.id}");
                                        Get.toNamed(
                                          AppRoutes.alerteDetail,
                                          arguments: {'alerteId': a.id},
                                        );
                                      },
                                      cells: [
                                        DataCell(Text(a.date)),
                                        DataCell(Text(a.probleme ?? '-')),
                                        DataCell(Text(a.cause ?? '-')),
                                        DataCell(Text(a.etatResolution)),
                                      ],
                                    );
                                  }).toList(),
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

  Widget _infoRowWidget(String label, Widget child) {
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
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _techniciensChips(List<String> names) {
    if (names.isEmpty)
      return Text('-', style: TextStyle(color: Colors.grey.shade700));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: names.map((n) {
        final initials = _initials(n);
        return Chip(
          label: Text(
            n,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          avatar: CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.primary.withOpacity(0.16),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          backgroundColor: AppColors.primary.withOpacity(0.08),
          side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    var out = '';
    for (final p in parts) {
      out += p[0].toUpperCase();
      if (out.length >= 2) break;
    }
    return out.isEmpty ? '?' : out;
  }

  // ---------- Remarque (édition inline) ----------
  Widget _remarqueWidget(InterventionDetailController c) {
    String _serverValue() => (c.detail.value?.remarque ?? '').trim();

    void _cancelEdit() {
      c.remarkCtrl.text = _serverValue();
      c.isEditingRemark.value = false;
    }

    return _infoCard("Remarque / Règlement", Icons.note_outlined, [
      Obx(
        () => c.isEditingRemark.value
            ? Focus(
                onKey: (node, event) {
                  if (event.logicalKey.keyLabel == 'Escape') {
                    _cancelEdit();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: c.remarkCtrl,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 5,
                  onSubmitted: (_) => c.submitRemark(),
                  decoration: InputDecoration(
                    hintText: 'Saisir puis Entrée pour enregistrer',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Annuler (Échap)',
                          icon: const Icon(Icons.close),
                          onPressed: c.isSavingRemark.value
                              ? null
                              : _cancelEdit,
                        ),
                        c.isSavingRemark.value
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : IconButton(
                                tooltip: 'Enregistrer (Entrée)',
                                icon: const Icon(Icons.check),
                                onPressed: c.submitRemark,
                              ),
                      ],
                    ),
                  ),
                ),
              )
            : InkWell(
                onTap: c.startEditRemark,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (() {
                            final t = c.remarkCtrl.text.trim();
                            return t.isEmpty
                                ? 'Cliquez pour ajouter une remarque...'
                                : t;
                          })(),
                          style: const TextStyle(height: 1.3),
                        ),
                      ),
                      const Icon(Icons.edit_outlined, size: 18),
                    ],
                  ),
                ),
              ),
      ),
    ]);
  }

  // ---------- Paiement (édition inline) ----------
  Widget _paymentWidget(InterventionDetailController c) {
    String _serverValue() {
      final v = c.detail.value?.payement;
      return v == null ? '' : v.toString();
    }

    void _cancelEdit() {
      c.payCtrl.text = _serverValue();
      c.isEditingPay.value = false;
    }

    return _infoCard("Montant à payer (TND)", Icons.payments_outlined, [
      Obx(
        () => c.isEditingPay.value
            ? Focus(
                onKey: (node, event) {
                  if (event.logicalKey.keyLabel == 'Escape') {
                    _cancelEdit();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: c.payCtrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                  ],
                  onSubmitted: (_) => c.submitPay(),
                  decoration: InputDecoration(
                    hintText: '0.000',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Annuler (Échap)',
                          icon: const Icon(Icons.close),
                          onPressed: c.isSavingPay.value ? null : _cancelEdit,
                        ),
                        c.isSavingPay.value
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : IconButton(
                                tooltip: 'Enregistrer (Entrée)',
                                icon: const Icon(Icons.check),
                                onPressed: c.submitPay,
                              ),
                      ],
                    ),
                  ),
                ),
              )
            : InkWell(
                onTap: c.startEditPay,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _fmtMoney(c.detail.value?.payement),
                          style: const TextStyle(
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.edit_outlined, size: 18),
                    ],
                  ),
                ),
              ),
      ),
    ]);
  }

  // ---------- UI Components ----------
  Widget _infoCard(
    String title,
    IconData icon,
    List<Widget> children, {
    Widget? trailing,
  }) {
    return Card(
      // back to regular Card
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
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
                const Spacer(),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _actionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      // back to regular Card
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
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

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _dataTableCard({
    required List<DataColumn> columns,
    required List<DataRow> rows,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: const BoxConstraints(minWidth: 800),
            child: DataTable(
              showCheckboxColumn: false,
              columnSpacing: 24,
              headingRowHeight: 48,
              dataRowMinHeight: 48,
              headingRowColor: MaterialStateProperty.all(
                AppColors.primary.withOpacity(0.8),
              ),
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyStateCard(IconData icon, String message) {
    return Card(
      // back to regular Card
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _statusColor(String s) {
    switch (s) {
      case "TRAITE":
        return const Color(0xFF2EB85C); // Green
      case "EN_RETARD":
        return const Color(0xFFDC3545); // Red
      case "NON_ACCOMPLIES":
        return const Color(0xFFFF7F50); // Orange
      case "EN_COURS":
      default:
        return const Color(0xFFFFC107); // Amber
    }
  }

  static String _prettyStatut(String s) {
    switch (s) {
      case "EN_COURS":
        return "En cours";
      case "TRAITE":
        return "Traité";
      case "EN_RETARD":
        return "En retard";
      case "NON_ACCOMPLIES":
        return "Non accomplies";
      default:
        return s;
    }
  }

  // ===================== HELPERS ADDED FOR BASIC INFO FORM =====================

  // READ-ONLY VIEW (unchanged content, grouped)
  Widget _basicInfoView(dynamic d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow("Date", _fmtDate(d.date)),
        _infoRow(
          "Dernière intervention",
          d.derniereIntervention != null
              ? _fmtDate(d.derniereIntervention!)
              : "-",
        ),
        _infoRow("Equipe Nom", d.equipeNom),
        _infoRowWidget("Techniciens", _techniciensChips(d.techniciens)),
        _infoRow("Client", d.clientNom),
        _infoRow(
          "Paiement obligatoire",
          d.estPayementObligatoire ? "Oui" : "Non",
        ),
        _infoRow("Montant", "${_fmtMoney(d.payement)} TND"),
      ],
    );
  }

  // EDIT FORM (inline) — Client read-only, Équipe dropdown, Techniciens locked
  Widget _basicInfoForm(InterventionDetailController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledField(
          "Date",
          TextField(
            controller: c.dateBasicCtrl,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'jj/MM/aaaa',
              suffixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onTap: () async {
              DateTime init = DateTime.now();
              try {
                init = DateFormat(
                  'dd/MM/yyyy',
                ).parseStrict(c.dateBasicCtrl.text);
              } catch (_) {}
              final picked = await showDatePicker(
                context: Get.context!,
                initialDate: init,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                c.dateBasicCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
              }
            },
          ),
        ),

        const SizedBox(height: 12),

        // ----- ÉQUIPE: dropdown from service -----
        _labeledField(
          "Equipe",
          Obx(() {
            final items = c.equipes;
            if (items.isEmpty) {
              return InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                child: Row(
                  children: const [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text("Chargement des équipes..."),
                  ],
                ),
              );
            }

            return DropdownButtonFormField<Equipe>(
              value: c.selectedEquipe.value,
              items: items
                  .map(
                    (e) =>
                        DropdownMenuItem<Equipe>(value: e, child: Text(e.nom)),
                  )
                  .toList(),
              onChanged: (e) => c.onEquipeSelected(e),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              hint: const Text("Sélectionner une équipe"),
            );
          }),
        ),

        const SizedBox(height: 12),

        // ----- TECHNICIENS: locked (chips from selected équipe or existing) -----
        _labeledField(
          "Techniciens",
          Obx(() {
            final techs =
                c.selectedEquipe.value?.techniciens ??
                ((c.techniciensBasicCtrl.text.isNotEmpty)
                    ? c.techniciensBasicCtrl.text
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList()
                    : (c.detail.value?.techniciens ?? const <String>[]));
            return _techniciensChips(techs);
          }),
        ),

        const SizedBox(height: 12),

        // ----- CLIENT: read-only -----
        _labeledField(
          "Client",
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              c.detail.value?.clientNom ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),

        const SizedBox(height: 12),

        _labeledField(
          "Paiement obligatoire",
          Obx(
            () => Switch(
              value: c.payObligatoire.value,
              onChanged: (v) => c.payObligatoire.value = v,
            ),
          ),
        ),

        const SizedBox(height: 8),
        Text(
          "NB : Le montant reste éditable dans le bloc \"Montant à payer (TND)\".",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Reuse your two-column row layout for editable widgets
  Widget _labeledField(String label, Widget field) {
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
          Expanded(child: field),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
