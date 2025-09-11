import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/screens/admin/interventions/intervention_detail_screen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';
import 'package:front_erp_aromair/viewmodel/admin/interventions/interventions_controller.dart';
import 'package:front_erp_aromair/view/screens/admin/interventions/add_intervention_dialog.dart';

class InterventionsScreen extends StatelessWidget {
  const InterventionsScreen({super.key});

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    return GetX<InterventionsController>(
      init: InterventionsController(),
      builder: (c) {
        return Scaffold(
          drawer: const AdminDrawer(),
          appBar: AppBar(
            backgroundColor: const Color(0xFF75A6D1),
            elevation: 0,
            centerTitle: true,
            title: const Text("Interventions"),
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ),
          body: Container(
            color: const Color(0xFF75A6D1),
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filtres (dates + bouton +)
                        Row(
                          children: [
                            _labelValue(
                              "Du:",
                              _pillButton(
                                context: context,
                                text: _fmt(c.from.value),
                                onTap: () => c.pickFromDate(context),
                                icon: Icons.calendar_month,
                              ),
                            ),
                            const SizedBox(width: 16),
                            _labelValue(
                              "Jusqu'à:",
                              _pillButton(
                                context: context,
                                text: _fmt(c.to.value),
                                onTap: () => c.pickToDate(context),
                                icon: Icons.calendar_month,
                              ),
                            ),
                            const Spacer(),
                            _roundAction(
                              tooltip: "Nouvelle intervention",
                              icon: Icons.add,
                              onTap: () async {
                                final created = await showAddInterventionDialog(context);
                                if (created == true) c.fetch();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Recherche + filtre statut
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                focusNode: c.searchFocus,
                                controller: c.searchCtrl,
                                onSubmitted: (_) => c.onSearch(),
                                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  hintText: "Rechercher",
                                  prefixIcon: const Icon(Icons.search),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(24),
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
                                            focusNode: c.statutFocus,
                                            isExpanded: true,
                                            value: c.selectedStatut.value,
                                            items: c.statuts.map((s) {
                                              final label = s == "ALL"
                                                  ? "Tout Statut"
                                                  : _prettyStatut(s);
                                              return DropdownMenuItem(
                                                value: s,
                                                child: Text(label),
                                              );
                                            }).toList(),
                                            onChanged: (v) {
                                              c.onStatutChanged(v);
                                              FocusManager.instance.primaryFocus?.unfocus();
                                            },
                                            buttonStyleData: const ButtonStyleData(
                                              height: 44,
                                              padding: EdgeInsets.zero,
                                            ),
                                            dropdownStyleData: DropdownStyleData(
                                              maxHeight: 280,
                                              offset: const Offset(0, 8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              elevation: 6,
                                            ),
                                            menuItemStyleData:
                                                const MenuItemStyleData(height: 44),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.filter_alt_outlined),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: c.onSearch,
                              child: const Text("Filtrer"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tableau
                        if (c.isLoading.value)
                          const Expanded(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (c.error.value != null)
                          Expanded(
                            child: Center(child: Text("Erreur: ${c.error.value}")),
                          )
                        else
                          Expanded(
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: LayoutBuilder(
                                builder: (context, cons) {
                                  return SingleChildScrollView(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(minWidth: cons.maxWidth),
                                        child: DataTable(
                                                headingRowColor: MaterialStateProperty.all(const Color(0xFF5DB7A1)),
                                                showCheckboxColumn: false,
                                                columns: const [
                                                  DataColumn(label: _HeaderCell("Client")),
                                                  DataColumn(label: _HeaderCell("Technicien")),
                                                  DataColumn(label: _HeaderCell("Derniere Intervention")),
                                                  DataColumn(label: _HeaderCell("Statut")),
                                                  DataColumn(label: _HeaderCell("Supprimer")),
                                                ],
                                                rows: c.items.map((it) {
                                                  return DataRow(
                                                    // ✅ Couleur par ligne selon statut
                                                    color: MaterialStateProperty.resolveWith<Color?>((states) {
                                                      if (states.contains(MaterialState.selected)) return Colors.black12;
                                                      return _rowBgForStatut(it.statutRaw);
                                                    }),
                                                    onSelectChanged: (_) async {
                                                      c.selectedRowId.value = it.id;
                                                      await Get.toNamed('/interventions/${it.id}')?.then((_) => c.clearSelection());
                                                      c.selectedRowId.value = null;
                                                    },
                                                    cells: [
                                                      DataCell(Text(it.client)),
                                                      DataCell(Text(it.technicien)),
                                                      DataCell(Text(it.derniereIntervention != null ? _fmt(it.derniereIntervention!) : '')),
                                                      DataCell(Text(_prettyStatut(it.statutRaw))),
                                                      DataCell(
                                                        IconButton(
                                                          tooltip: "Supprimer",
                                                          icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                                          onPressed: () => c.deleteIntervention(it.id),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
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

  Widget _labelValue(String label, Widget child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          child
        ],
      );

  Widget _pillButton({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text(text), const SizedBox(width: 8), Icon(icon, size: 20)],
        ),
      ),
    );
  }

  Widget _roundAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1CA8D4),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

String _prettyStatut(String? s) {
  if (s == null) return '—';

  // Normalisation : MAJUSCULES, accents -> E, remplace _ et - par espace, compresse espaces
  final n = s.trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (n.contains('RETARD')) return 'En retard';
  if (n.startsWith('TRAIT')) return 'Traité';
  if (n.contains('ANNUL')) return 'Annulée';
  if (n.contains('EN') && n.contains('COURS')) return 'En cours';
  // "non accomplies" / "non effectuée" / "non réalisée"…
  if (n.contains('NON') && (n.contains('ACCOMPL') || n.contains('EFFECTU') || n.contains('REALIS'))) {
    return 'Non accomplies';
  }

  // fallback : affichage brut si cas non prévu
  return s;
}


Color? _rowBgForStatut(String? raw) {
  if (raw == null) return null;

  // Normalisation : MAJUSCULES, accents -> E, remplace tirets/underscores par espaces, squeeze des espaces
  String n = raw
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // Détections "souples"
  final isRetard = n.contains('RETARD'); // "EN RETARD" etc.
  final isTraite = n.startsWith('TRAIT'); // "TRAITE", "TRAITEE"
  final isNonAccomplies = n.contains('NON') &&
      (n.contains('ACCOMPL') || n.contains('EFFECTU') || n.contains('REALIS'));

  if (isRetard)        return const Color.fromARGB(255, 255, 198, 207); // rouge très clair
  if (isNonAccomplies) return const Color.fromARGB(255, 255, 233, 199); // orange très clair
  if (isTraite)        return const Color(0xFFE8F5E9); // vert très clair
  return null; // aucun surlignage pour les autres
}


