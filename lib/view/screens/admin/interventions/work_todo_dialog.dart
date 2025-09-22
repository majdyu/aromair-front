import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:front_erp_aromair/data/models/intervention_detail.dart';
import 'package:front_erp_aromair/data/models/option_item.dart';
import 'package:front_erp_aromair/viewmodel/admin/interventions/edit_taf_controller.dart';

Future<bool?> showWorkToDoDialog(
  BuildContext context,
  InterventionDetail detail,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
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
            Expanded(child: _WorkToDoForm(detail: detail)),
          ],
        ),
      ),
    ),
  );
}

class _WorkToDoForm extends StatelessWidget {
  final InterventionDetail detail;
  const _WorkToDoForm({required this.detail});

  @override
  Widget build(BuildContext context) {
    return GetX<EditTafController>(
      init: EditTafController(detail),
      builder: (c) {
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
                        "Travail à faire",
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

                            // Client field (read-only)
                            _buildSectionTitle("Client"),
                            const SizedBox(height: 8),
                            _buildReadOnlyClientField(c),
                            const SizedBox(height: 16),

                            // Instruction text
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0A1E40,
                                ).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF0A1E40,
                                  ).withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: const Color(0xFF0A1E40),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Sélectionnez les diffuseurs par type d'intervention",
                                      style: TextStyle(
                                        color: const Color(0xFF0A1E40),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Intervention types
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
                              onPressed: () => Navigator.pop(context, false),
                              style: OutlinedButton.styleFrom(
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
                                final ok = await c.submit();
                                if (ok && context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0A1E40),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Enregistrer",
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  Widget _buildReadOnlyClientField(EditTafController c) {
    int? safeValue(List<OptionItem> items, int? v) =>
        (v != null && items.any((o) => o.id == v)) ? v : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<int>(
          isExpanded: true,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text("Client", style: TextStyle(color: Colors.grey)),
          ),
          value: safeValue(c.clients, c.selectedClientId.value),
          items: c.clients
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
          onChanged: null, // Read-only
          buttonStyleData: const ButtonStyleData(
            height: 48,
            padding: EdgeInsets.zero,
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.lock, size: 18),
            iconEnabledColor: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildInterventionType(
    BuildContext context,
    EditTafController c,
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
          // Type header
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
                  // Message if no diffusers
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
                    // Dynamic lines
                    ...List.generate(lines.length, (i) {
                      final opts = c.optionsFor(type, i);
                      final canAddRow = c.canAddLine(type);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildDiffuseurDropdown(
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
                              color: const Color(0xFF0A1E40),
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

                    // Add line button
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
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
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

  Widget _buildDiffuseurDropdown({
    required String hint,
    required int? value,
    required List<OptionItem> items,
    required Function(int?)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.arrow_drop_down),
            iconEnabledColor: Colors.grey[600],
          ),
        ),
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
