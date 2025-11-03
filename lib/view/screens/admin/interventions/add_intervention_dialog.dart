// lib/view/screens/admin/interventions/add_intervention_dialog.dart
import 'package:flutter/material.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:front_erp_aromair/data/models/option_item.dart';
import 'package:front_erp_aromair/viewmodel/admin/interventions/add_intervention_controller.dart';

/// Model for pre-filling the form (from Commande)
class PreFillIntervention {
  final int clientId;
  final int diffuseurId;
  final String type;

  PreFillIntervention({
    required this.clientId,
    required this.diffuseurId,
    this.type = 'LIVRAISON',
  });
}

/// Opens the dialog – returns {success: true, date: DateTime} on success
Future<Map<String, dynamic>?> showAddInterventionDialog(
  BuildContext context, {
  PreFillIntervention? prefill,
}) async {
  return await Get.bottomSheet<Map<String, dynamic>>(
    DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(child: _AddInterventionForm(prefill: prefill)),
          ],
        ),
      ),
    ),
    // mêmes options que showModalBottomSheet
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _AddInterventionForm extends StatelessWidget {
  final PreFillIntervention? prefill;
  const _AddInterventionForm({this.prefill});

  @override
  Widget build(BuildContext context) {
    return GetX<AddInterventionController>(
      init: AddInterventionController(prefill: prefill),
      builder: (c) {
        String fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
        final clientSearchCtrl = TextEditingController();

        int? safeValue(List<OptionItem> items, int? v) =>
            (v != null && items.any((o) => o.id == v)) ? v : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: c.isLoadingLookups.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Nouvelle Intervention",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Divider(height: 1),

                    // Form content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Client field
                            _buildSectionTitle("Client"),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              hint: "Sélectionner un client",
                              value: safeValue(
                                c.clients,
                                c.selectedClientId.value,
                              ),
                              items: c.clients,
                              onChanged: c.onClientChanged,
                              searchController: clientSearchCtrl,
                            ),
                            const SizedBox(height: 16),

                            // Technician field
                            _buildSectionTitle("Equipe"),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              hint: "Sélectionner un technicien",
                              value: safeValue(
                                c.equipes,
                                c.selectedUserId.value,
                              ),
                              items: c.equipes,
                              onChanged: (v) => c.selectedUserId.value = v,
                            ),
                            const SizedBox(height: 16),

                            // Date field
                            _buildSectionTitle("Date d'intervention"),
                            const SizedBox(height: 8),
                            _buildDateField(context, c, fmt),
                            const SizedBox(height: 16),

                            // Remarks field
                            _buildSectionTitle("Remarques"),
                            const SizedBox(height: 8),
                            _buildRemarksField(c),
                            const SizedBox(height: 16),

                            // Payment checkbox
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: c.estPayementObligatoire.value,
                                    onChanged: (v) =>
                                        c.estPayementObligatoire.value =
                                            v ?? false,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Paiement obligatoire",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Intervention types
                            _buildSectionTitle("Types d'intervention"),
                            const SizedBox(height: 8),
                            ...c.types.map(
                              (type) =>
                                  _buildInterventionType(context, c, type),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Actions
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                              onPressed: () async {
                                print("Submitting new intervention...");
                                final ok = await c.submit();
                                if (ok) {
                                  Get.back(
                                    result: {
                                      'success': true,
                                      'date': c.date.value,
                                      'interventionId':
                                          c.createdInterventionId.value,
                                    },
                                  );
                                }
                                print("Submission done.$ok");
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Ajouter",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // === ALL YOUR ORIGINAL WIDGETS BELOW (unchanged) ===
  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
  );

  Widget _buildDropdown({
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
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(hint, style: TextStyle(color: Colors.grey[600])),
          ),
          value: value,
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
                        hintText: 'Rechercher...',
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
                    return label.data!.toLowerCase().contains(
                      searchValue.toLowerCase(),
                    );
                  },
                )
              : null,
          onMenuStateChange: (isOpen) {
            if (!isOpen && searchController != null) searchController.clear();
          },
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.arrow_drop_down),
            iconEnabledColor: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    AddInterventionController c,
    String Function(DateTime) fmt,
  ) {
    return GestureDetector(
      onTap: () => c.pickDate(context),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Expanded(child: Text(fmt(c.date.value))),
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksField(AddInterventionController c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: c.remarqueCtrl,
        maxLines: 3,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(16),
          border: InputBorder.none,
          hintText: "Saisissez vos remarques ici...",
        ),
      ),
    );
  }

  Widget _buildInterventionType(
    BuildContext context,
    AddInterventionController c,
    String type,
  ) {
    final enabled = c.enabled[type]!;
    final lines = c.linesByType[type]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: enabled.value,
                    onChanged: (v) => c.toggleType(type, v),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  c.pretty(type),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (enabled.value) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (c.selectedClientId.value != null &&
                      c.diffuseursAll.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Aucun diffuseur disponible pour ce client",
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (c.selectedClientId.value != null &&
                      c.diffuseursAll.isNotEmpty) ...[
                    ...List.generate(lines.length, (i) {
                      final opts = c.optionsFor(type, i);
                      final canAddRow = c.canAddLine(type);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                hint: "Sélectionner un diffuseur",
                                value:
                                    (lines[i].value != null &&
                                        opts.any((o) => o.id == lines[i].value))
                                    ? lines[i].value
                                    : null,
                                items: opts,
                                onChanged: (v) => lines[i].value = v,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildIconButton(
                              icon: Icons.add,
                              onPressed: canAddRow
                                  ? () => c.addLine(type)
                                  : null,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            _buildIconButton(
                              icon: Icons.remove,
                              onPressed: () => c.removeLine(type, i),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      );
                    }),
                    if (c.canAddLine(type))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => c.addLine(type),
                          icon: Icon(
                            Icons.add,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Text(
                            "Ajouter un diffuseur",
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: onPressed != null ? color.withOpacity(0.1) : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 18,
          color: onPressed != null ? color : Colors.grey,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
