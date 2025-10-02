import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/alert.dart';
import 'package:front_erp_aromair/viewmodel/admin/alert_controller.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';

import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/theme/text_style.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';

class AlertesScreen extends StatelessWidget {
  const AlertesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AlertesController>(
      init: AlertesController(),
      builder: (c) {
        return AromaScaffold(
          title: "Alertes",
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
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notification_important_outlined,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Gestion des Alertes",
                              style: AromaText.h1.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Obx(() {
                              if (c.loading) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.1),
                                      AppColors.primary.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  "${c.items.length} alerte(s)",
                                  style: AromaText.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Surveillance et gestion des incidents en temps réel",
                          style: AromaText.bodyMuted.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 24),

                        // ===== Filters =====
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.divider.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Search field
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: c.searchCtrl,
                                    onTapOutside: (_) =>
                                        FocusScope.of(context).unfocus(),
                                    onChanged: (_) => c.update(),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Rechercher (client, diffuseur, problème, cause)',
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                        size: 20,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 16,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Status filter
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<AlerteStatutFilter>(
                                      isExpanded: true,
                                      value: c.statutFilter.value,
                                      hint: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          "Statut",
                                          style: AromaText.body.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: AlerteStatutFilter.all,
                                          child: Text('Toutes les alertes'),
                                        ),
                                        DropdownMenuItem(
                                          value: AlerteStatutFilter.unresolved,
                                          child: Text('Alertes ouvertes'),
                                        ),
                                        DropdownMenuItem(
                                          value: AlerteStatutFilter.resolved,
                                          child: Text('Alertes résolues'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) {
                                          c.statutFilter.value = v;
                                          c.update();
                                        }
                                      },
                                      buttonStyleData: ButtonStyleData(
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ===== Content area =====
                        Expanded(
                          child: Obx(() {
                            if (c.loading) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Chargement des alertes...",
                                      style: AromaText.bodyMuted,
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (c.items.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_off_rounded,
                                      size: 64,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Aucune alerte trouvée",
                                      style: AromaText.h2.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Ajustez vos critères de recherche ou actualisez",
                                      style: AromaText.bodyMuted,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: c.items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) => _AlerteCard(
                                alert: c.items[i],
                                onOpen: c.openDetail,
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

class _AlerteCard extends StatelessWidget {
  final IncidentItem alert;
  final void Function(IncidentItem) onOpen;

  const _AlerteCard({required this.alert, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final resolved = alert.etatResolution == true;
    final fmt = DateFormat('dd/MM/yyyy • HH:mm');
    final dateStr = alert.date != null ? fmt.format(alert.date!) : 'N/A';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onOpen(alert),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: _getBorderColor(resolved), width: 1.2),
          ),
          child: Stack(
            children: [
              // Background accent
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: _getStatusColor(resolved),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status indicator
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(resolved).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getStatusColor(resolved).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getStatusIcon(resolved),
                        color: _getStatusColor(resolved),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Main content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alert.probleme ?? 'Incident signalé',
                                      style: AromaText.title.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (alert.cause != null &&
                                        alert.cause!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          alert.cause!,
                                          style: AromaText.caption.copyWith(
                                            color: AppColors.textSecondary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    resolved,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      resolved,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  resolved ? "Résolue" : "En cours",
                                  style: AromaText.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(resolved),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Info grid
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                _InfoItem(
                                  icon: Icons.business_rounded,
                                  label: "Client",
                                  value: alert.clientNom ?? 'Non spécifié',
                                ),
                                const SizedBox(width: 20),
                                _InfoItem(
                                  icon: Icons.device_hub_rounded,
                                  label: "Diffuseur",
                                  value:
                                      alert.diffuseurDesignation ??
                                      'Non spécifié',
                                ),
                                const SizedBox(width: 20),
                                _InfoItem(
                                  icon: Icons.schedule_rounded,
                                  label: "Date",
                                  value: dateStr,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Actions row - Only details button now
                          Row(
                            children: [
                              const Spacer(),

                              // Details action
                              GestureDetector(
                                onTap: () => onOpen(alert),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Voir détails",
                                        style: AromaText.caption.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ],
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
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(bool resolved) {
    return resolved ? AppColors.success : AppColors.warning;
  }

  Color _getBorderColor(bool resolved) {
    return resolved
        ? AppColors.success.withOpacity(0.2)
        : AppColors.warning.withOpacity(0.2);
  }

  IconData _getStatusIcon(bool resolved) {
    return resolved ? Icons.check_circle_rounded : Icons.warning_amber_rounded;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
      case 'high':
        return AppColors.danger;
      case 'moyenne':
      case 'medium':
        return AppColors.warning;
      case 'basse':
      case 'low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
      case 'high':
        return 'Haute priorité';
      case 'moyenne':
      case 'medium':
        return 'Priorité moyenne';
      case 'basse':
      case 'low':
        return 'Basse priorité';
      default:
        return priority;
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AromaText.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AromaText.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
