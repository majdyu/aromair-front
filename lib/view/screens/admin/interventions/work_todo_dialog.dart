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
  return Get.dialog<bool>(
    Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: _WorkToDoForm(detail: detail),
    ),
    barrierDismissible: false,
    useSafeArea: true,
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
        final maxH = MediaQuery.of(context).size.height * 0.86;

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
                          "Travail à faire",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                // Client (verrouillé — juste informatif)
                                _rounded(
                                  Opacity(
                                    opacity: 0.75,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<int>(
                                        isExpanded: true,
                                        hint: const Text("Client"),
                                        value: safeValue(
                                          c.clients,
                                          c.selectedClientId.value,
                                        ),
                                        items: c.clients
                                            .map((o) => DropdownMenuItem(
                                                  value: o.id,
                                                  child: Text(o.label),
                                                ))
                                            .toList(),
                                        onChanged: null,
                                        buttonStyleData:
                                            const ButtonStyleData(
                                          height: 42,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                        ),
                                        dropdownStyleData:
                                            const DropdownStyleData(
                                          maxHeight: 320,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Sélectionne les diffuseurs par type d’intervention",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Tous les types (structure/copier-coller du add_intervention_dialog)
                                ...c.types.map((type) {
                                  final enabled = c.enabled[type]!;
                                  final lines = c.linesByType[type]!; // List<RxnInt>

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: enabled.value,
                                            onChanged: (v) =>
                                                c.toggleType(type, v),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                          Text(c.pretty(type)),
                                          const Spacer(),
                                        ],
                                      ),

                                      if (enabled.value) ...[
                                        if (c.selectedClientId.value != null &&
                                            c.diffuseursAll.isEmpty)
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              left: 8,
                                              bottom: 8,
                                            ),
                                            child: Align(
                                              alignment:
                                                  Alignment.centerLeft,
                                              child: Text(
                                                "Aucun diffuseur pour ce client",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                          ),

                                        Column(
                                          children: List.generate(
                                            lines.length,
                                            (i) {
                                              final opts =
                                                  c.optionsFor(type, i);
                                              final canAddRow =
                                                  c.canAddLine(type);

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: _rounded(
                                                        DropdownButtonHideUnderline(
                                                          child:
                                                              DropdownButton2<
                                                                  int>(
                                                            isExpanded:
                                                                true,
                                                            hint: const Text(
                                                              "Sélectionner un diffuseur",
                                                            ),
                                                            value: (lines[i].value !=
                                                                        null &&
                                                                    opts.any((o) =>
                                                                        o.id ==
                                                                        lines[i]
                                                                            .value))
                                                                ? lines[i]
                                                                    .value
                                                                : null,
                                                            items: opts
                                                                .map(
                                                                  (o) =>
                                                                      DropdownMenuItem(
                                                                    value: o
                                                                        .id,
                                                                    child: Text(
                                                                      o.label,
                                                                    ),
                                                                  ),
                                                                )
                                                                .toList(),
                                                            // IMPORTANT :
                                                            // même logique que add_intervention_dialog
                                                            onChanged: (v) =>
                                                                lines[i].value =
                                                                    v,
                                                            buttonStyleData:
                                                                const ButtonStyleData(
                                                              height: 40,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal:
                                                                    10,
                                                              ),
                                                            ),
                                                            dropdownStyleData:
                                                                const DropdownStyleData(
                                                              maxHeight:
                                                                  300,
                                                              offset:
                                                                  Offset(
                                                                0,
                                                                6,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width: 8),
                                                    _roundBtn(
                                                      Icons.add,
                                                      onTap: canAddRow
                                                          ? () => c
                                                              .addLine(
                                                                  type)
                                                          : null,
                                                      disabled:
                                                          !canAddRow,
                                                    ),
                                                    const SizedBox(
                                                        width: 4),
                                                    _roundBtn(
                                                      Icons.remove,
                                                      onTap: () => c
                                                          .removeLine(
                                                              type, i),
                                                      danger: true,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
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
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
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
                              child: const Text("Enregistrer"),
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

  // UI helpers (identiques à ceux utilisés dans add_intervention_dialog)

  static Widget _rounded(Widget child) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
