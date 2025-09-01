import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:front_erp_aromair/data/models/option_item.dart';
import 'package:front_erp_aromair/viewmodel/admin/interventions/add_intervention_controller.dart';

Future<bool?> showAddInterventionDialog(BuildContext context) {
  return Get.dialog<bool>(
    Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: const _AddInterventionForm(),
    ),
    barrierDismissible: false,
    useSafeArea: true,
  );
}

class _AddInterventionForm extends StatelessWidget {
  const _AddInterventionForm();

  @override
  Widget build(BuildContext context) {
    return GetX<AddInterventionController>(
      init: AddInterventionController(),
      builder: (c) {
        String fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
        final maxH = MediaQuery.of(context).size.height * 0.86;

      // contrôleur de recherche du dropdown "Client"
      final clientSearchCtrl = TextEditingController();

        int? safeValue(List<OptionItem> items, int? v) =>
            (v != null && items.any((o) => o.id == v)) ? v : null;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480, maxHeight: maxH),
          child: Material(
            color: const Color(0xFFE29AF2),
            borderRadius: BorderRadius.circular(26),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: c.isLoadingLookups.value
                  ? const SizedBox(
                      height: 280,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Ajouter une intervention",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),

                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                // --- Client (recherchable) ---
                                _rounded(
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton2<int>(
                                      isExpanded: true,
                                      hint: const Text("Client"),
                                      value: safeValue(c.clients, c.selectedClientId.value),
                                      items: c.clients
                                          .map((o) => DropdownMenuItem<int>(
                                                value: o.id,
                                                child: Text(o.label),
                                              ))
                                          .toList(),
                                      onChanged: c.onClientChanged,
                                      buttonStyleData: const ButtonStyleData(
                                        height: 42,
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      dropdownStyleData: const DropdownStyleData(
                                        maxHeight: 320,
                                        offset: Offset(0, 6), // ouvre le menu juste sous le champ
                                      ),

                                      // ======= Recherche intégrée =======
                                      dropdownSearchData: DropdownSearchData(
                                        searchController: clientSearchCtrl,
                                        searchInnerWidgetHeight: 50,
                                        searchInnerWidget: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            controller: clientSearchCtrl,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText: 'Rechercher un client…',
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                              prefixIcon: const Icon(Icons.search),
                                            ),
                                          ),
                                        ),
                                        // Filtrage: on matche sur le texte du child (le label du client)
                                        searchMatchFn: (item, searchValue) {
                                          final label = (item.child as Text).data ?? '';
                                          return label.toLowerCase().contains(searchValue.toLowerCase());
                                        },
                                      ),
                                      // Quand on ferme le menu, on nettoie la barre de recherche
                                      onMenuStateChange: (isOpen) {
                                        if (!isOpen) clientSearchCtrl.clear();
                                      },
                                      // ==================================
                                    ),
                                  ),
),
                                const SizedBox(height: 8),

                                // Technicien
                                _rounded(
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton2<int>(
                                      isExpanded: true,
                                      hint: const Text("Technicien"),
                                      value: safeValue(c.techniciens, c.selectedUserId.value),
                                      items: c.techniciens
                                          .map((o) => DropdownMenuItem(value: o.id, child: Text(o.label)))
                                          .toList(),
                                      onChanged: (v) => c.selectedUserId.value = v,
                                      buttonStyleData: const ButtonStyleData(
                                        height: 42,
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      dropdownStyleData: const DropdownStyleData(
                                        maxHeight: 320,
                                        offset: Offset(0, 6),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Date
                                _rounded(
                                  Row(
                                    children: [
                                      Expanded(child: Text(fmt(c.date.value))),
                                      IconButton(
                                        icon: const Icon(Icons.calendar_month),
                                        onPressed: () => c.pickDate(context),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Remarque
                                _rounded(
                                  TextField(
                                    controller: c.remarqueCtrl,
                                    decoration: const InputDecoration.collapsed(
                                      hintText: "Remarque/Règlement",
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Payement
                                Row(
                                  children: [
                                    Checkbox(
                                      value: c.estPayementObligatoire.value,
                                      onChanged: (v) => c.estPayementObligatoire.value = v ?? false,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const Text("Payement"),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Types (tous les TypeInterv)
                                ...c.types.map((type) {
                                  final enabled = c.enabled[type]!;
                                  final lines = c.linesByType[type]!; // RxList<RxnInt>

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // En-tête du type (sans bouton + ici)
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: enabled.value,
                                            onChanged: (v) => c.toggleType(type, v),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          Text(c.pretty(type)),
                                          const Spacer(),
                                        ],
                                      ),

                                      if (enabled.value) ...[
                                        // Message si pas de diffuseur pour le client choisi
                                        if (c.selectedClientId.value != null && c.diffuseursAll.isEmpty)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8, bottom: 8),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Aucun diffuseur pour ce client",
                                                style: TextStyle(fontSize: 12, color: Colors.black54),
                                              ),
                                            ),
                                          ),

                                        // Lignes dynamiques : dropdown + (+) + (– rouge)
                                        Column(
                                          children: List.generate(lines.length, (i) {
                                            final opts = c.optionsFor(type, i);
                                            final canAddRow = c.canAddLine(type);

                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: _rounded(
                                                      DropdownButtonHideUnderline(
                                                        child: DropdownButton2<int>(
                                                          isExpanded: true,
                                                          hint: const Text("Sélectionner un diffuseur"),
                                                          value: (lines[i].value != null &&
                                                                  opts.any((o) => o.id == lines[i].value))
                                                              ? lines[i].value
                                                              : null,
                                                          items: opts
                                                              .map(
                                                                (o) => DropdownMenuItem(
                                                                  value: o.id,
                                                                  child: Text(o.label),
                                                                ),
                                                              )
                                                              .toList(),
                                                          onChanged: (v) => lines[i].value = v,
                                                          buttonStyleData: const ButtonStyleData(
                                                            height: 40,
                                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                                          ),
                                                          dropdownStyleData: const DropdownStyleData(
                                                            maxHeight: 300,
                                                            offset: Offset(0, 6),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _roundBtn(
                                                    Icons.add,
                                                    onTap: canAddRow ? () => c.addLine(type) : null,
                                                    disabled: !canAddRow,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  _roundBtn(
                                                    Icons.remove,
                                                    onTap: () => c.removeLine(type, i),
                                                    danger: true, // rouge
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        // Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: () => Get.back(result: false),
                              child: const Text("Annuler"),
                            ),
                            FilledButton(
                              onPressed: () async {
                                final ok = await c.submit();
                                if (ok) Get.back(result: true);
                              },
                              child: const Text("Ajouter"),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  static Widget _rounded(Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: child,
      );

  static Widget _roundBtn(
    IconData icon, {
    required VoidCallback? onTap,
    bool disabled = false,
    bool danger = false,
  }) =>
      InkWell(
        customBorder: const CircleBorder(),
        onTap: disabled ? null : onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: disabled
                ? Colors.black26
                : (danger ? Colors.redAccent : const Color(0xFF20C997)),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );
}
