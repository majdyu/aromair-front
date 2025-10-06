import 'package:flutter/material.dart';
import 'package:front_erp_aromair/viewmodel/admin/reclamation/add_reclamation_controller.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/theme/text_style.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';

class AddReclamationDialog extends StatelessWidget {
  final VoidCallback? onSuccess;

  const AddReclamationDialog({super.key, this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GetX<AddReclamationController>(
        init: AddReclamationController()..bootstrap(),
        builder: (c) {
          final isLoading = c.isSubmitting.value || c.isBootstrapping.value;

          return AromaCard(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.assignment_add,
                          size: 28,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Nouvelle Réclamation',
                          style: AromaText.title.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Remplissez les informations pour créer une nouvelle réclamation',
                    style: AromaText.bodyMuted.copyWith(fontSize: 14),
                  ),

                  const SizedBox(height: 32),

                  // CLIENT FIELD
                  _ClientField(),
                  const SizedBox(height: 20),

                  // PROBLEME FIELD
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description du problème *',
                        style: AromaText.body.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: TextFormField(
                          controller: c.problemeCtrl,
                          maxLines: 4,
                          style: AromaText.body,
                          decoration: const InputDecoration(
                            hintText:
                                'Décrivez le problème rencontré par le client...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ACTIONS
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.divider.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            foregroundColor: AppColors.textSecondary,
                          ),
                          child: const Text('Annuler'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final ok = await c.submit();
                                  if (ok) {
                                    onSuccess?.call();
                                    if (context.mounted)
                                      Navigator.of(context).pop();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          icon: c.isSubmitting.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.add, size: 18),
                          label: Text(
                            c.isSubmitting.value
                                ? 'Création...'
                                : 'Créer la réclamation',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClientField extends StatelessWidget {
  void _showClientSelectionDialog(
    BuildContext context,
    AddReclamationController c,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: AromaCard(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 24,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sélectionner un client',
                      style: AromaText.title.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un client...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      // Add search functionality if needed
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Clients list
                Expanded(
                  child: c.clientOptions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.business_outlined,
                                size: 48,
                                color: AppColors.textSecondary.withOpacity(0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun client disponible',
                                style: AromaText.bodyMuted,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: c.clientOptions.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: AppColors.divider.withOpacity(0.3),
                          ),
                          itemBuilder: (context, index) {
                            final client = c.clientOptions[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  c.selectedClientId.value = client.id;
                                  Navigator.of(context).pop();
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: c.selectedClientId.value == client.id
                                        ? AppColors.primary.withOpacity(0.05)
                                        : Colors.transparent,
                                    border:
                                        c.selectedClientId.value == client.id
                                        ? Border.all(
                                            color: AppColors.primary
                                                .withOpacity(0.3),
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          size: 20,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          client.label,
                                          style: AromaText.body.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      if (c.selectedClientId.value == client.id)
                                        Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetX<AddReclamationController>(
      builder: (c) {
        final selectedClient = c.clientOptions.firstWhere(
          (client) => client.id == c.selectedClientId.value,
          orElse: () => OptionItem(id: 0, label: ''),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client *',
              style: AromaText.body.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            if (c.isBootstrapping.value)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Chargement des clients...',
                      style: AromaText.bodyMuted,
                    ),
                  ],
                ),
              )
            else if (c.clientOptions.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 24,
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aucun client disponible',
                            style: AromaText.body.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ajoutez des clients avant de créer une réclamation',
                            style: AromaText.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showClientSelectionDialog(context, c),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedClient.label.isEmpty
                                    ? 'Sélectionner un client'
                                    : selectedClient.label,
                                style: AromaText.body.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: selectedClient.label.isEmpty
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (selectedClient.label.isNotEmpty)
                                const SizedBox(height: 2),
                              if (selectedClient.label.isNotEmpty)
                                Text(
                                  'Client sélectionné',
                                  style: AromaText.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
