// lib/view/screens/admin/equipe/add_transaction_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';
import 'package:front_erp_aromair/viewmodel/admin/equipe/add_transaction_controller.dart';

class AddTransactionDialog extends StatelessWidget {
  final int userId;
  const AddTransactionDialog({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AddTransactionController(userId));

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SingleChildScrollView(
        child: AromaCard(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Elegant Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.02),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.attach_money_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOUVELLE TRANSACTION',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ajouter une transaction',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(result: false),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: c.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Transaction Type Cards
                      _TransactionTypeSelector(controller: c),
                      const SizedBox(height: 24),

                      // Amount Field
                      TextFormField(
                        controller: c.montantCtrl,
                        decoration: _buildInputDecoration(
                          'Montant (TND)',
                          Icons.currency_exchange_rounded,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Montant obligatoire';
                          }
                          final x = double.tryParse(v.replaceAll(',', '.'));
                          if (x == null || x <= 0) return 'Montant invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Date Picker
                      _DatePicker(controller: c),
                      const SizedBox(height: 20),

                      // Description Field
                      TextFormField(
                        controller: c.descriptionCtrl,
                        decoration: _buildInputDecoration(
                          'Description (optionnelle)',
                          Icons.description_rounded,
                        ),
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      _ActionButtons(controller: c),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _TransactionTypeSelector extends StatelessWidget {
  final AddTransactionController controller;

  const _TransactionTypeSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TYPE DE TRANSACTION',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _TransactionTypeCard(
                  type: 'ENTREE',
                  label: 'Entrée',
                  icon: Icons.arrow_circle_down_rounded,
                  color: AppColors.success,
                  isSelected: controller.type.value == 'ENTREE',
                  onTap: () => controller.type.value = 'ENTREE',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TransactionTypeCard(
                  type: 'DEPENSE',
                  label: 'Dépense',
                  icon: Icons.arrow_circle_up_rounded,
                  color: AppColors.danger,
                  isSelected: controller.type.value == 'DEPENSE',
                  onTap: () => controller.type.value = 'DEPENSE',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionTypeCard extends StatelessWidget {
  final String type;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransactionTypeCard({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? color : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(Icons.check_circle_rounded, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final AddTransactionController controller;

  const _DatePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final dateStr = DateFormat(
            'dd/MM/yyyy',
          ).format(controller.date.value);
          return InkWell(
            onTap: () => controller.pickDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date sélectionnée',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Icons.edit_calendar_rounded,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final AddTransactionController controller;

  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () => Get.back(result: false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: const Text(
                'ANNULER',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () => controller.submit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'ENREGISTRER',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      );
    });
  }
}
