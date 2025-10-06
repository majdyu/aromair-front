import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/repositories/admin/reclamation_repository.dart';
import 'package:front_erp_aromair/view/screens/admin/reclamation/add_reclamation_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:front_erp_aromair/data/enums/statut_reclamation.dart';
import 'package:front_erp_aromair/data/models/reclamtion.dart';
import 'package:front_erp_aromair/data/services/reclamation_service.dart';

import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/theme/text_style.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';

import 'package:front_erp_aromair/viewmodel/admin/reclamation/reclamation_controller.dart';

class ReclamationsScreen extends StatelessWidget {
  const ReclamationsScreen({super.key});

  Future<void> _pickRange(BuildContext context, ReclamationController c) async {
    final initial = DateTime.now();
    final firstDate = DateTime(initial.year - 3, 1, 1);
    final lastDate = DateTime(initial.year + 1, 12, 31);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: (c.du.value != null || c.jusqua.value != null)
          ? DateTimeRange(
              start: c.du.value ?? c.jusqua.value!,
              end: c.jusqua.value ?? c.du.value!,
            )
          : null,
      helpText: 'Sélectionner une période',
    );

    if (picked != null) {
      c.setDateRange(picked.start, picked.end);
    }
  }

  Future<void> _showAddReclamationDialog(
    BuildContext context,
    ReclamationController c,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AddReclamationDialog(
        onSuccess: () async {
          await c.fetch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReclamationController>(
      init: ReclamationController(
        ReclamationRepository(ReclamationService(buildDio())),
      ),
      builder: (c) {
        return AromaScaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddReclamationDialog(context, c),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.add, size: 24),
          ),
          title: "Réclamations",
          onRefresh: c.fetch,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== Header =====
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.assignment,
                                size: 24,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Liste des réclamations',
                              style: AromaText.title.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),

                            // Date range selector
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: TextButton.icon(
                                onPressed: () => _pickRange(context, c),
                                icon: const Icon(Icons.date_range, size: 18),
                                label: Text(
                                  c.dateRangeLabel,
                                  style: AromaText.body,
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (c.du.value != null || c.jusqua.value != null)
                              TextButton(
                                onPressed: c.clearDateRange,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Effacer'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ===== Filters row (INSIDE card) =====
                        Row(
                          children: [
                            // Search field
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: c.searchCtrl,
                                  onTapOutside: (_) =>
                                      FocusScope.of(context).unfocus(),
                                  decoration: InputDecoration(
                                    hintText:
                                        "Rechercher (client, problème, technicien...)",
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 22,
                                      color: AppColors.textSecondary,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.divider,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    suffixIcon: (c.searchCtrl.text.isNotEmpty)
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 20,
                                            ),
                                            onPressed: c.clearSearch,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Stats (count)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary.withOpacity(0.1),
                                    AppColors.primary.withOpacity(0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Obx(
                                () => Text(
                                  'Total: ${c.rowsFiltered.length}',
                                  style: AromaText.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ===== Content area (INSIDE the same card) =====
                        Expanded(
                          child: Obx(() {
                            if (c.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              );
                            }
                            if (c.error.value != null) {
                              return Center(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        size: 42,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        c.error.value!,
                                        style: AromaText.body.copyWith(
                                          color: Colors.red,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            final list = c.rowsFiltered;
                            if (list.isEmpty) {
                              return Center(
                                child: Container(
                                  padding: const EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.divider,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 64,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Aucune réclamation pour ces filtres',
                                        style: AromaText.body.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Essayez de modifier vos critères de recherche',
                                        style: AromaText.caption,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _showAddReclamationDialog(
                                              context,
                                              c,
                                            ),
                                        icon: const Icon(Icons.add),
                                        label: const Text(
                                          'Ajouter une réclamation',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Enhanced list area
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.divider.withOpacity(0.5),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ListView.separated(
                                  itemCount: list.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    color: AppColors.divider.withOpacity(0.6),
                                  ),
                                  itemBuilder: (_, i) {
                                    final r = list[i];
                                    return _ReclamationListTile(
                                      row: r,
                                      onTap: () {
                                        // TODO: navigate to detail if route exists
                                        // Get.toNamed(AppRoutes.detailReclamation, arguments: {'id': r.id});
                                      },
                                    );
                                  },
                                ),
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
}

// ... Keep the existing _ReclamationListTile and _MetaItem classes unchanged ...

class _ReclamationListTile extends StatelessWidget {
  final ReclamationRow row;
  final VoidCallback? onTap;
  const _ReclamationListTile({required this.row, this.onTap});

  Color _statutColor(StatutReclamation s) {
    switch (s) {
      case StatutReclamation.EN_COURS:
        return Colors.orange;
      case StatutReclamation.TRAITE:
        return Colors.green;
      case StatutReclamation.FAUSSE_RECLAMATION:
        return Colors.grey;
      case StatutReclamation.DEPASSE_48H:
        return Colors.red;
      case StatutReclamation.unknown:
        return AppColors.textSecondary;
    }
  }

  String _statutLabel(StatutReclamation s) {
    switch (s) {
      case StatutReclamation.EN_COURS:
        return 'EN COURS';
      case StatutReclamation.TRAITE:
        return 'TRAITÉ';
      case StatutReclamation.FAUSSE_RECLAMATION:
        return 'FAUSSE';
      case StatutReclamation.DEPASSE_48H:
        return 'DÉPASSÉ 48H';
      case StatutReclamation.unknown:
        return 'INCONNU';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = row.date != null
        ? DateFormat('dd/MM/yyyy').format(row.date!)
        : 'N/A';
    final statutColor = _statutColor(row.statutReclamation);
    final techs = row.techniciens.isEmpty ? '-' : row.techniciens.join(', ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.assignment_outlined,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),

                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title line: Client + statut chip
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.clientNom ?? '(Client inconnu)',
                                  style: AromaText.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Référence: ${row.id}',
                                  style: AromaText.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statutColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statutColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _statutLabel(row.statutReclamation),
                              style: AromaText.h1.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: statutColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Problem line
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.report_problem_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                row.probleme,
                                style: AromaText.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Meta: date • équipe • techniciens
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _MetaItem(icon: Icons.event, text: dateStr),
                          if ((row.derniereEquipeNom ?? '').isNotEmpty)
                            _MetaItem(
                              icon: Icons.group,
                              text: row.derniereEquipeNom!,
                            ),
                          _MetaItem(icon: Icons.engineering, text: techs),
                          if ((row.decisionPrise ?? '').isNotEmpty)
                            _MetaItem(
                              icon: Icons.rule,
                              text: row.decisionPrise!,
                            ),
                          _MetaItem(
                            icon: Icons.check_circle_outline,
                            text: row.etapes == true
                                ? 'Étapes OK'
                                : 'Étapes en cours',
                            color: row.etapes == true
                                ? Colors.green
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MetaItem({
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: AromaText.caption.copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
