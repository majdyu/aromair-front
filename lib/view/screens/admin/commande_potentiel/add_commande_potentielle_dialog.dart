import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_erp_aromair/viewmodel/admin/commande_potentiel/add_commande_potentielle_controller.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:front_erp_aromair/data/models/option_item.dart';

Future<Map<String, dynamic>?> showAddCommandePotentielleDialog(
  BuildContext context,
) async {
  return await Get.bottomSheet<Map<String, dynamic>>(
    DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, __) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const _AddCommandePotForm(),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _AddCommandePotForm extends StatelessWidget {
  const _AddCommandePotForm();

  @override
  Widget build(BuildContext context) {
    return GetX<AddCommandePotentielleController>(
      init: AddCommandePotentielleController(),
      builder: (c) {
        final clientSearchCtrl = TextEditingController();
        final diffuseurSearchCtrl = TextEditingController();
        final parfumSearchCtrl = TextEditingController();

        int? safe(List<OptionItem> items, int? v) =>
            (v != null && items.any((o) => o.id == v)) ? v : null;

        return Column(
          children: [
            // handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "Nouvelle proposition de commande",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: c.isLoadingLookups.value
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _title("Client"),
                          const SizedBox(height: 8),
                          _dropdown(
                            hint: "Sélectionner un client",
                            value: safe(c.clients, c.selectedClientId.value),
                            items: c.clients,
                            onChanged: c.onClientChanged,
                            searchController: clientSearchCtrl,
                          ),
                          const SizedBox(height: 16),

                          _title("Diffuseur"),
                          const SizedBox(height: 8),
                          _dropdown(
                            hint: c.selectedClientId.value == null
                                ? "Choisissez d’abord un client"
                                : (c.diffuseurs.isEmpty
                                      ? "Aucun diffuseur pour ce client"
                                      : "Sélectionner un diffuseur"),
                            value: safe(
                              c.diffuseurs,
                              c.selectedDiffuseurId.value,
                            ),
                            items: c.diffuseurs,
                            onChanged: c.selectedClientId.value == null
                                ? null
                                : (v) => c.selectedDiffuseurId.value = v,
                            searchController: diffuseurSearchCtrl,
                          ),
                          const SizedBox(height: 16),

                          _title("Parfum (optionnel)"),
                          const SizedBox(height: 8),
                          _dropdown(
                            hint: "Laisser vide pour conserver le précédent",
                            value: safe(c.parfums, c.selectedParfumId.value),
                            items: c.parfums,
                            onChanged: (v) => c.selectedParfumId.value = v,
                            searchController: parfumSearchCtrl,
                          ),
                          const SizedBox(height: 16),

                          _title("Quantité (ml, optionnel)"),
                          const SizedBox(height: 8),
                          _textField(
                            controller: c.quantiteCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            hint: "Laisser vide pour conserver la précédente",
                            prefix: Icons.scale_rounded,
                            errorTextRx: c.qtyError, // inline error
                          ),
                          const SizedBox(height: 16),

                          _title("Nombre de bouteilles (requis)"),
                          const SizedBox(height: 8),
                          _textField(
                            controller: c.nbrBouteillesCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            hint: "Doit être ≥ 1 (défaut: 1)",
                            prefix: Icons.local_drink_outlined,
                            errorTextRx: c.nbError, // inline error
                          ),
                          const SizedBox(height: 16),

                          _title("Type de tête (optionnel)"),
                          const SizedBox(height: 8),
                          _textField(
                            controller: c.typeTeteCtrl,
                            hint: "SIMPLE / DOUBLE …",
                            prefix: Icons.tune_rounded,
                          ),
                          const SizedBox(height: 12),

                          // Force checkbox
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: c.forceCreation.value,
                                  onChanged: (v) =>
                                      c.forceCreation.value = v ?? false,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Forcer la création",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Colors.orange.shade800,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Si coché, la commande sera créée même si le système "
                                    "en a déjà généré une pour ce diffuseur. "
                                    "Sinon, aucune commande ne sera créée s’il en existe déjà.",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),
                          Obx(
                            () => c.error.value == null
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      c.error.value!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
            ),

            // actions
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: const Border(
                  top: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Annuler"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: c.isSubmitting.value
                          ? null
                          : () async {
                              // Prevent submit if inline errors exist
                              if (c.qtyError.value != null ||
                                  c.nbError.value != null) {
                                ElegantSnackbarService.showError(
                                  title: 'Formulaire',
                                  message:
                                      'Corrige les erreurs surlignées avant de continuer.',
                                );
                                return;
                              }
                              final ok = await c.submit();
                              if (ok) {
                                ElegantSnackbarService.showSuccess(
                                  message: "Proposition créée",
                                );
                                Get.back(
                                  result: {
                                    'success': true,
                                    'createdId': c.createdId.value,
                                  },
                                  closeOverlays: true,
                                );
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Obx(
                        () => c.isSubmitting.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Créer",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _title(String t) => Text(
    t,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
  );

  Widget _dropdown({
    required String hint,
    required int? value,
    required List<OptionItem> items,
    required Function(int?)? onChanged,
    TextEditingController? searchController,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<int>(
          isExpanded: true,
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(hint, style: TextStyle(color: Colors.grey[600])),
          ),
          items: items
              .map(
                (o) => DropdownMenuItem<int>(
                  value: o.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(o.label),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          buttonStyleData: const ButtonStyleData(
            height: 48,
            padding: EdgeInsets.zero,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 320,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          ),
          dropdownSearchData: searchController != null
              ? DropdownSearchData(
                  searchController: searchController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Rechercher…',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    final label = (item.child as Padding).child as Text;
                    return (label.data ?? '').toLowerCase().contains(
                      searchValue.toLowerCase(),
                    );
                  },
                )
              : null,
          onMenuStateChange: (open) {
            if (!open && searchController != null) searchController.clear();
          },
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.arrow_drop_down),
            iconEnabledColor: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    IconData? prefix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    RxnString? errorTextRx, // <- show inline error (if provided)
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              prefixIcon: prefix == null
                  ? null
                  : Icon(prefix, color: Colors.grey[600]),
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        if (errorTextRx != null)
          Obx(
            () => errorTextRx.value == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 6, left: 6),
                    child: Text(
                      errorTextRx.value!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}
