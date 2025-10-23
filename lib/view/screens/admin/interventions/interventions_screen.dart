import 'package:flutter/material.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:front_erp_aromair/viewmodel/admin/interventions/interventions_controller.dart';
import 'package:front_erp_aromair/view/screens/admin/interventions/add_intervention_dialog.dart';

import 'package:front_erp_aromair/theme/colors.dart';
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
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8FAFF), Color(0xFFF0F4FF), Colors.white],
              ),
            ),
            child: Column(
              children: [
                // ===== ELEGANT HEADER =====
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Title with elegant icon
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, Color(0xFF667EEA)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.construction_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Interventions",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                "Gestion des interventions techniques",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Stats with elegant design
                          Obx(() {
                            if (c.isLoading.value || c.error.value != null)
                              return const SizedBox.shrink();
                            return Row(
                              children: [
                                _elegantStat(
                                  value: c.items.length.toString(),
                                  label: "Total",
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 16),
                                _elegantStat(
                                  value: c.items
                                      .where((i) => i.statutRaw == "TRAITE")
                                      .length
                                      .toString(),
                                  label: "Traitées",
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 16),
                                _elegantStat(
                                  value: c.items
                                      .where((i) => i.statutRaw == "EN_COURS")
                                      .length
                                      .toString(),
                                  label: "En cours",
                                  color: AppColors.warning,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ===== CREATIVE FILTER BAR =====
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Obx(
                                () => Row(
                                  children: [
                                    _elegantDateChip(
                                      text: _fmt(c.from.value),
                                      onTap: () => c.pickFromDate(context),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Container(
                                        width: 24,
                                        height: 2,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    _elegantDateChip(
                                      text: _fmt(c.to.value),
                                      onTap: () => c.pickToDate(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Status filter
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: Obx(
                                    () => DropdownButton2<String>(
                                      value: c.selectedStatut.value,
                                      items: c.statuts.map((s) {
                                        final label = s == "ALL"
                                            ? "Tous les statuts"
                                            : _prettyStatut(s);
                                        return DropdownMenuItem(
                                          value: s,
                                          child: Text(
                                            label,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (v) {
                                        if (v == null) return;
                                        c.selectedStatut.value = v;
                                        c.onSearch();
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        height: 48,
                                      ),
                                      iconStyleData: const IconStyleData(
                                        icon: Icon(Icons.expand_more_rounded),
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: c.searchCtrl,
                                  onChanged: (_) => c.onSearch(),
                                  decoration: InputDecoration(
                                    hintText: "Rechercher une intervention...",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: Colors.grey.shade500,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Elegant add button
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    Color(0xFF667EEA),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  final created =
                                      await showAddInterventionDialog(context);
                                  if (created == true) c.fetch();
                                },
                                icon: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== ELEGANT INTERVENTION LIST =====
                Expanded(
                  child: Obx(() {
                    if (c.isLoading.value) return _buildElegantLoading();
                    if (c.error.value != null) return _buildElegantError();
                    if (c.items.isEmpty) return _buildElegantEmpty();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      child: ListView.builder(
                        itemCount: c.items.length,
                        itemBuilder: (context, index) {
                          final intervention = c.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ElegantInterventionCard(
                              intervention: intervention,
                              onView: () async {
                                c.selectedRowId.value = intervention.id;
                                final changed = await Get.toNamed(
                                  AppRoutes.interventionDetail,
                                  arguments: c.selectedRowId.value.toString(),
                                );
                                c.clearSelection();
                                c.selectedRowId.value = null;
                                if (changed == true) c.fetch();
                              },
                              onDelete: () =>
                                  c.deleteIntervention(intervention.id),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _elegantStat({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
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
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _elegantDateChip({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.calendar_month_rounded,
              size: 16,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElegantLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Chargement des interventions",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Erreur de chargement",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Veuillez réessayer ultérieurement",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Aucune intervention",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Commencez par créer votre première intervention",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _ElegantInterventionCard extends StatelessWidget {
  final dynamic intervention;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _ElegantInterventionCard({
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Stack(
          children: [
            // Elegant status accent
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _statusColor(it.statutRaw),
                      _statusColor(it.statutRaw).withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Status icon with elegant background
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          _statusColor(it.statutRaw).withOpacity(0.2),
                          _statusColor(it.statutRaw).withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(it.statutRaw),
                      color: _statusColor(it.statutRaw),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Main content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client name
                        Text(
                          it.client,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Details row
                        Row(
                          children: [
                            // Team
                            Row(
                              children: [
                                Icon(
                                  Icons.groups_rounded,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  it.equipe,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),

                            // Date
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status and actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(it.statutRaw).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _statusColor(it.statutRaw).withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          _prettyStatut(it.statutRaw),
                          style: TextStyle(
                            color: _statusColor(it.statutRaw),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Elegant action buttons
                      Row(
                        children: [
                          _elegantActionButton(
                            icon: Icons.visibility_rounded,
                            color: AppColors.primary,
                            onTap: onView,
                            tooltip: "Voir les détails",
                          ),
                          const SizedBox(width: 8),
                          _elegantActionButton(
                            icon: Icons.delete_rounded,
                            color: AppColors.danger,
                            onTap: onDelete,
                            tooltip: "Supprimer",
                          ),
                        ],
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

  Widget _elegantActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, size: 20, color: color),
          padding: EdgeInsets.zero,
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

    if (n.contains('RETARD')) return Icons.warning_amber_rounded;
    if (n.startsWith('TRAIT')) return Icons.check_circle_rounded;
    if (n.contains('ANNUL')) return Icons.cancel_rounded;
    if (n.contains('EN') && n.contains('COURS'))
      return Icons.hourglass_top_rounded;
    if (n.contains('NON') &&
        (n.contains('ACCOMPL') ||
            n.contains('EFFECTU') ||
            n.contains('REALIS'))) {
      return Icons.pending_rounded;
    }
    return Icons.help_outline_rounded;
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
  if (status == null) return Colors.grey;
  String n = status
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (n.contains('RETARD')) return AppColors.danger;
  if (n.startsWith('TRAIT')) return AppColors.success;
  if (n.contains('ANNUL')) return Colors.grey;
  if (n.contains('EN') && n.contains('COURS')) return AppColors.warning;
  if (n.contains('NON') &&
      (n.contains('ACCOMPL') ||
          n.contains('EFFECTU') ||
          n.contains('REALIS'))) {
    return AppColors.warning;
  }
  return Colors.grey;
}
