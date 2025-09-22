import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/empty_state_card.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
        return AromaScaffold(
          title: "Interventions",
          onRefresh: c.fetch, // refresh action in AppBar
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 12,
                  shadowColor: Colors.black.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            const Icon(
                              Icons.construction,
                              color: Color(0xFF0A1E40),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Gestion des Interventions",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0A1E40),
                              ),
                            ),
                            const Spacer(),
                            if (!c.isLoading.value && c.error.value == null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0A1E40,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  "${c.items.length} intervention(s)",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0A1E40),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Filtrez et gérez vos interventions",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),

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
                                final created = await showAddInterventionDialog(
                                  context,
                                );
                                if (created == true) c.fetch();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Recherche + filtre statut
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                focusNode: c.searchFocus,
                                controller: c.searchCtrl,
                                onSubmitted: (_) => c.onSearch(),
                                onTapOutside: (_) =>
                                    FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  hintText:
                                      "Rechercher par client, technicien...",
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
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0A1E40),
                                      width: 1.5,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
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
                                            focusNode: c.statutFocus,
                                            isExpanded: true,
                                            value: c.selectedStatut.value,
                                            items: c.statuts.map((s) {
                                              final label = s == "ALL"
                                                  ? "Tout Statut"
                                                  : _prettyStatut(s);
                                              return DropdownMenuItem(
                                                value: s,
                                                child: Text(
                                                  label,
                                                  style: TextStyle(
                                                    color: s == "ALL"
                                                        ? Colors.grey.shade600
                                                        : const Color(
                                                            0xFF0A1E40,
                                                          ),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (v) {
                                              c.onStatutChanged(v);
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            buttonStyleData:
                                                const ButtonStyleData(
                                                  height: 46,
                                                  padding: EdgeInsets.zero,
                                                ),
                                            dropdownStyleData:
                                                DropdownStyleData(
                                                  maxHeight: 280,
                                                  offset: const Offset(0, 8),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.15),
                                                        blurRadius: 16,
                                                        offset: const Offset(
                                                          0,
                                                          6,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  elevation: 8,
                                                ),
                                            menuItemStyleData:
                                                const MenuItemStyleData(
                                                  height: 46,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
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
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: c.onSearch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A1E40),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                shadowColor: Colors.black.withOpacity(0.2),
                              ),
                              icon: const Icon(Icons.filter_list, size: 20),
                              label: const Text("Appliquer"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Liste des interventions
                        if (c.isLoading.value)
                          const Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF0A1E40),
                                    ),
                                    strokeWidth: 3,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Chargement des interventions...",
                                    style: TextStyle(color: Color(0xFF0A1E40)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (c.error.value != null)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade400,
                                    size: 52,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Erreur de chargement",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF0A1E40),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                    child: Text(
                                      c.error.value!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: c.fetch,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A1E40),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Text("Réessayer"),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (c.items.isEmpty)
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: EmptyStateCard(
                                  embedded: true,
                                  icon: Icons.assignment_outlined,
                                  message:
                                      "Aucune intervention trouvée\n"
                                      "Essayez de modifier vos filtres ou créez une nouvelle intervention",
                                  actionText: "Créer une intervention",
                                  onAction: () async {
                                    final created =
                                        await showAddInterventionDialog(
                                          context,
                                        );
                                    if (created == true) c.fetch();
                                  },
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListView.separated(
                                  itemCount: c.items.length,
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.grey.shade300,
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                                  itemBuilder: (context, index) {
                                    final it = c.items[index];
                                    return _InterventionListTile(
                                      intervention: it,
                                      onView: () async {
                                        c.selectedRowId.value = it.id;
                                        await Get.toNamed(
                                          '/interventions/${it.id}',
                                        )?.then((_) => c.clearSelection());
                                        c.selectedRowId.value = null;
                                      },
                                      onDelete: () =>
                                          c.deleteIntervention(it.id),
                                    );
                                  },
                                ),
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
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0A1E40),
        ),
      ),
      const SizedBox(width: 8),
      child,
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF0A1E40).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF0A1E40)),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18, color: const Color(0xFF0A1E40)),
          ],
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
      child: Material(
        color: const Color(0xFF0A1E40),
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _InterventionListTile extends StatelessWidget {
  final dynamic intervention; // Assuming Intervention model
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _InterventionListTile({
    required this.intervention,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final it = intervention;
    final fmt = DateFormat('dd/MM/yyyy');
    final dateStr = it.derniereIntervention != null
        ? fmt.format(it.derniereIntervention!)
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
                  color: _statusColor(it.statutRaw).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(it.statutRaw),
                  color: _statusColor(it.statutRaw),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client + status chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            it.client,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0A1E40),
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
                            color: _statusColor(it.statutRaw),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _prettyStatut(it.statutRaw),
                            style: TextStyle(
                              color: _statusTextColor(it.statutRaw),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Technician
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            it.technicien,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              const SizedBox(width: 12),
              Row(
                children: [
                  IconButton(
                    tooltip: "Voir les détails",
                    icon: const Icon(
                      Icons.visibility_outlined,
                      color: Color(0xFF0A1E40),
                      size: 22,
                    ),
                    onPressed: onView,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  IconButton(
                    tooltip: "Supprimer",
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade500,
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

  IconData _getStatusIcon(String? status) {
    String n =
        status
            ?.trim()
            .toUpperCase()
            .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
            .replaceAll(RegExp(r'[_\-]+'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim() ??
        '';

    if (n.contains('RETARD')) return Icons.warning_amber;
    if (n.startsWith('TRAIT')) return Icons.check_circle;
    if (n.contains('ANNUL')) return Icons.cancel;
    if (n.contains('EN') && n.contains('COURS')) return Icons.hourglass_empty;
    if (n.contains('NON') &&
        (n.contains('ACCOMPL') ||
            n.contains('EFFECTU') ||
            n.contains('REALIS'))) {
      return Icons.pending;
    }
    return Icons.help_outline;
  }
}

String _prettyStatut(String? s) {
  if (s == null) return '—';
  final n = s
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (n.contains('RETARD')) return 'En retard';
  if (n.startsWith('TRAIT')) return 'Traité';
  if (n.contains('ANNUL')) return 'Annulée';
  if (n.contains('EN') && n.contains('COURS')) return 'En cours';
  if (n.contains('NON') &&
      (n.contains('ACCOMPL') ||
          n.contains('EFFECTU') ||
          n.contains('REALIS'))) {
    return 'Non accomplies';
  }
  return s;
}

Color _statusColor(String? status) {
  if (status == null) return Colors.grey.shade200;
  String n = status
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (n.contains('RETARD')) return const Color(0xFFFFCDD2);
  if (n.startsWith('TRAIT')) return const Color(0xFFC8E6C9);
  if (n.contains('ANNUL')) return const Color(0xFFF5F5F5);
  if (n.contains('EN') && n.contains('COURS')) return const Color(0xFFFFECB3);
  if (n.contains('NON') &&
      (n.contains('ACCOMPL') ||
          n.contains('EFFECTU') ||
          n.contains('REALIS'))) {
    return const Color(0xFFFFE0B2);
  }
  return Colors.grey.shade200;
}

Color _statusTextColor(String? status) {
  if (status == null) return Colors.grey.shade700;
  String n = status
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (n.contains('RETARD')) return const Color(0xFFC62828);
  if (n.startsWith('TRAIT')) return const Color(0xFF2E7D32);
  if (n.contains('ANNUL')) return const Color(0xFF424242);
  if (n.contains('EN') && n.contains('COURS')) return const Color(0xFFF57C00);
  if (n.contains('NON') &&
      (n.contains('ACCOMPL') ||
          n.contains('EFFECTU') ||
          n.contains('REALIS'))) {
    return const Color(0xFFEF6C00);
  }
  return Colors.grey.shade700;
}
