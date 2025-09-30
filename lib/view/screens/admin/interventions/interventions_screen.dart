import 'package:flutter/material.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:front_erp_aromair/viewmodel/admin/interventions/interventions_controller.dart';
import 'package:front_erp_aromair/view/screens/admin/interventions/add_intervention_dialog.dart';

import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/theme/text_style.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';

class InterventionsScreen extends StatelessWidget {
  const InterventionsScreen({super.key});

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InterventionsController>(
      init: InterventionsController(),
      builder: (c) {
        return AromaScaffold(
          title: "Interventions",
          onRefresh: c.fetch,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== Header (INSIDE card) =====
                        Row(
                          children: [
                            const Icon(
                              Icons.construction,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Gestion des Interventions",
                              style: AromaText.h1.copyWith(fontSize: 24),
                            ),
                            const Spacer(),
                            Obx(() {
                              if (c.isLoading.value || c.error.value != null)
                                return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  "${c.items.length} intervention(s)",
                                  style: AromaText.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Filtrez et gérez vos interventions",
                          style: AromaText.bodyMuted,
                        ),
                        const SizedBox(height: 16),

                        // ===== Filters (INSIDE card) =====
                        Obx(
                          () => Row(
                            children: [
                              _labelValue(
                                "Du:",
                                _pillButton(
                                  context: context,
                                  text: _fmt(c.from.value),
                                  onTap: () => c.pickFromDate(context),
                                  icon: Icons.calendar_month,
                                ),
                              ),
                              const SizedBox(width: 16),
                              _labelValue(
                                "Jusqu'à:",
                                _pillButton(
                                  context: context,
                                  text: _fmt(c.to.value),
                                  onTap: () => c.pickToDate(context),
                                  icon: Icons.calendar_month,
                                ),
                              ),
                              const Spacer(),
                              _roundAction(
                                tooltip: "Nouvelle intervention",
                                icon: Icons.add,
                                onTap: () async {
                                  final created =
                                      await showAddInterventionDialog(context);
                                  if (created == true) c.fetch();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ===== Search + statut (INSIDE card) =====
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                focusNode: c.searchFocus,
                                controller: c.searchCtrl,
                                onSubmitted: (_) => c.onSearch(),
                                onTapOutside: (_) =>
                                    FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  hintText:
                                      "Rechercher par client, technicien...",
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 22,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.divider,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.divider,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  border: Border.all(color: AppColors.divider),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            hoverColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                          ),
                                          child: Obx(
                                            () => DropdownButton2<String>(
                                              focusNode: c.statutFocus,
                                              isExpanded: true,
                                              value: c
                                                  .selectedStatut
                                                  .value, // reactive
                                              items: c.statuts.map((s) {
                                                final label = s == "ALL"
                                                    ? "Tout Statut"
                                                    : _prettyStatut(s);
                                                return DropdownMenuItem(
                                                  value: s,
                                                  child: Text(
                                                    label,
                                                    style: AromaText.body,
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (v) {
                                                if (v == null) return;
                                                c.selectedStatut.value =
                                                    v; // update Rx
                                                c.onSearch(); // your logic
                                              },
                                              buttonStyleData:
                                                  const ButtonStyleData(
                                                    padding: EdgeInsets.zero,
                                                    height: 44,
                                                  ),
                                              iconStyleData: const IconStyleData(
                                                icon: Icon(
                                                  Icons.arrow_drop_down_rounded,
                                                ),
                                                iconSize: 24,
                                              ),
                                              dropdownStyleData:
                                                  DropdownStyleData(
                                                    maxHeight: 250,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                0.06,
                                                              ),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            4,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.filter_alt_outlined,
                                      color: Colors.grey.shade600,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ===== Content area (INSIDE the same card) =====
                        Expanded(
                          child: Obx(() {
                            if (c.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (c.error.value != null) {
                              return Center(
                                child: Text(
                                  "Une erreur est survenue.",
                                  style: AromaText.bodyMuted,
                                ),
                              );
                            }
                            if (c.items.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.inbox_outlined,
                                      size: 48,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Aucune intervention pour cette période",
                                      style: AromaText.bodyMuted,
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Normal list area (bordered container)
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: ListView.separated(
                                itemCount: c.items.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: AppColors.divider.withOpacity(0.8),
                                ),
                                itemBuilder: (_, i) {
                                  final it = c.items[i];
                                  return _InterventionListTile(
                                    intervention: it,
                                    onView: () async {
                                      // === BEST PRACTICE: named route + arguments ===
                                      c.selectedRowId.value = it.id;
                                      print(
                                        " Selected ID type: ${c.selectedRowId.value}",
                                      );
                                      final changed = await Get.toNamed(
                                        AppRoutes.interventionDetail,
                                        arguments: c.selectedRowId.value
                                            .toString(),
                                      );
                                      c.clearSelection();
                                      c.selectedRowId.value = null;
                                      if (changed == true) c.fetch();
                                    },
                                    onDelete: () => c.deleteIntervention(it.id),
                                  );
                                },
                              ),
                            );
                          }),
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

  // ---------- small UI helpers (unchanged logic) ----------

  Widget _labelValue(String label, Widget value) {
    return Row(
      children: [
        Text(label, style: AromaText.bodyMuted),
        const SizedBox(width: 8),
        value,
      ],
    );
  }

  Widget _pillButton({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: AromaText.body),
            const SizedBox(width: 8),
            Icon(icon, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _roundAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _InterventionListTile extends StatelessWidget {
  final dynamic intervention; // Assuming Intervention model
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _InterventionListTile({
    required this.intervention,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final it = intervention;
    final fmt = DateFormat('dd/MM/yyyy');
    final dateStr = it.derniereIntervention != null
        ? fmt.format(it.derniereIntervention!)
        : 'N/A';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading status icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _statusColor(it.statutRaw).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(it.statutRaw),
                  color: _statusColor(it.statutRaw),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client + status chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            it.client,
                            style: AromaText.title.copyWith(
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(it.statutRaw),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _prettyStatut(it.statutRaw),
                            style: TextStyle(
                              color: _statusTextColor(it.statutRaw),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Technician
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            it.equipe,
                            style: AromaText.body.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(dateStr, style: AromaText.bodyMuted),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              const SizedBox(width: 12),
              Row(
                children: [
                  IconButton(
                    tooltip: "Voir les détails",
                    icon: const Icon(
                      Icons.visibility_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    onPressed: onView,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  IconButton(
                    tooltip: "Supprimer",
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                      size: 22,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    String n =
        status
            ?.trim()
            .toUpperCase()
            .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
            .replaceAll(RegExp(r'[_\-]+'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim() ??
        '';

    if (n.contains('RETARD')) return Icons.warning_amber;
    if (n.startsWith('TRAIT')) return Icons.check_circle;
    if (n.contains('ANNUL')) return Icons.cancel;
    if (n.contains('EN') && n.contains('COURS')) return Icons.hourglass_empty;
    if (n.contains('NON') &&
        (n.contains('ACCOMPL') ||
            n.contains('EFFECTU') ||
            n.contains('REALIS'))) {
      return Icons.pending;
    }
    return Icons.help_outline;
  }
}

String _prettyStatut(String? s) {
  if (s == null) return '—';
  final n = s
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (n.contains('RETARD')) return 'En retard';
  if (n.startsWith('TRAIT')) return 'Traité';
  if (n.contains('ANNUL')) return 'Annulée';
  if (n.contains('EN') && n.contains('COURS')) return 'En cours';
  if (n.contains('NON') &&
      (n.contains('ACCOMPL') ||
          n.contains('EFFECTU') ||
          n.contains('REALIS'))) {
    return 'Non accomplies';
  }
  return s;
}

Color _statusColor(String? status) {
  if (status == null) return AppColors.divider;
  String n = status
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (n.contains('RETARD')) return AppColors.danger.withOpacity(0.1);
  if (n.startsWith('TRAIT')) return AppColors.success.withOpacity(0.1);
  if (n.contains('ANNUL')) return AppColors.surfaceMuted;
  if (n.contains('EN') && n.contains('COURS'))
    return AppColors.warning.withOpacity(0.1);
  if (n.contains('NON') &&
      (n.contains('ACCOMPL') ||
          n.contains('EFFECTU') ||
          n.contains('REALIS'))) {
    return AppColors.warning.withOpacity(0.1);
  }
  return AppColors.divider;
}

Color _statusTextColor(String? status) {
  if (status == null) return AppColors.textSecondary;
  String n = status
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (n.contains('RETARD')) return AppColors.danger;
  if (n.startsWith('TRAIT')) return AppColors.success;
  if (n.contains('ANNUL')) return AppColors.textPrimary;
  if (n.contains('EN') && n.contains('COURS')) return AppColors.warning;
  if (n.contains('NON') &&
      (n.contains('ACCOMPL') ||
          n.contains('EFFECTU') ||
          n.contains('REALIS'))) {
    return AppColors.warning;
  }
  return AppColors.textSecondary;
}
