import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/client.dart';
import 'package:front_erp_aromair/data/repositories/admin/client_repository.dart';
import 'package:front_erp_aromair/data/services/client_service.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:front_erp_aromair/viewmodel/admin/client_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/theme/text_style.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      init: ClientController(ClientRepository(ClientService())),
      builder: (c) {
        return AromaScaffold(
          title: "Clients",
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
                        Row(
                          children: [
                            const Icon(
                              Icons.business,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Gestion des Clients",
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
                                  "${c.filteredItems.length} client(s)",
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
                          "Filtrez et gérez vos clients",
                          style: AromaText.bodyMuted,
                        ),
                        const SizedBox(height: 16),

                        // ===== Filters (INSIDE card) =====
                        Row(
                          children: [
                            // Search field
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: c.searchCtrl,
                                onTapOutside: (_) =>
                                    FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  hintText: "Rechercher par nom de client...",
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

                            // Type filter
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
                                          child: DropdownButton2<String>(
                                            isExpanded: true,
                                            value: c.type?.toUpperCase(),
                                            hint: Text(
                                              "Type client",
                                              style: AromaText.body.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'ACHAT',
                                                child: Text('ACHAT'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'CONVENTION',
                                                child: Text('CONVENTION'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'MAD',
                                                child: Text('MAD'),
                                              ),
                                            ],
                                            onChanged: (v) {
                                              c.setType(v);
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
                                                            .withOpacity(0.06),
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
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.category_outlined,
                                      color: Colors.grey.shade600,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Status filter
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
                                          child: DropdownButton2<String>(
                                            isExpanded: true,
                                            value: c.activeFilter.value,
                                            hint: Text(
                                              "Statut",
                                              style: AromaText.body.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'ALL',
                                                child: Text('Tous'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'ACTIVE',
                                                child: Text('Actif'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'INACTIVE',
                                                child: Text('Suspendu'),
                                              ),
                                            ],
                                            onChanged: (v) {
                                              if (v != null) {
                                                c.setActiveFilter(v);
                                              }
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
                                                            .withOpacity(0.06),
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

                            final list = c.filteredItems;

                            if (list.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.business_outlined,
                                      size: 48,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Aucun client trouvé",
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
                                itemCount: list.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: AppColors.divider.withOpacity(0.8),
                                ),
                                // inside ListView.separated itemBuilder in ClientsScreen:
                                itemBuilder: (_, i) {
                                  final client = list[i];
                                  return _ClientListTile(
                                    client: client,
                                    onView: () => Get.toNamed(
                                      AppRoutes.detailClient,
                                      arguments: {'id': client.id},
                                    ),
                                    onToggleStatus: (_) => c.onToggleActive(
                                      client,
                                    ), // backend handles the toggle
                                    onDelete: () =>
                                        print("Delete client: ${client.nom}"),
                                    isBusy: c.isToggling(client.id), // <-- NEW
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
}

class _ClientListTile extends StatelessWidget {
  final ClientRow client;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleStatus;
  final bool isBusy; // <-- NEW

  const _ClientListTile({
    required this.client,
    required this.onView,
    required this.onDelete,
    required this.onToggleStatus,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final dateStr = client.derniereIntervention != null
        ? fmt.format(client.derniereIntervention!)
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
                  color: _statusColor(client.estActive).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(client.estActive),
                  color: _statusColor(client.estActive),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client name + status chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            client.nom,
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
                            color: _statusColor(client.estActive),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            client.estActive ? "Actif" : "Suspendu",
                            style: TextStyle(
                              color: _statusTextColor(client.estActive),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Client type
                    Row(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _typeLabel(client.type),
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

                    // Last intervention date
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
                  // Status toggle switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: client.estActive,
                          onChanged: isBusy ? null : onToggleStatus,
                          activeColor: AppColors.success,
                          activeTrackColor: AppColors.success.withOpacity(0.4),
                          inactiveThumbColor: AppColors.danger,
                          inactiveTrackColor: AppColors.danger.withOpacity(0.4),
                        ),
                        const SizedBox(height: 4),
                        if (isBusy)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Text(
                            client.estActive ? "Actif" : "Suspendu",
                            style: AromaText.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: client.estActive
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // View details button
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

                  // Delete button
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

  IconData _getStatusIcon(bool isActive) {
    return isActive ? Icons.check_circle : Icons.pause_circle;
  }

  Color _statusColor(bool isActive) {
    return isActive ? AppColors.success : AppColors.danger;
  }

  Color _statusTextColor(bool isActive) {
    return Colors.white;
  }

  String _typeLabel(TypeClient type) {
    switch (type) {
      case TypeClient.achat:
        return 'ACHAT';
      case TypeClient.convention:
        return 'CONVENTION';
      case TypeClient.mad:
        return 'MAD';
      case TypeClient.unknown:
        return 'INCONNU';
    }
  }
}
