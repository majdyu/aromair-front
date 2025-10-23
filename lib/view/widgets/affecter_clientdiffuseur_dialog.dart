import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/viewmodel/admin/client_detail_controller.dart';
import 'package:front_erp_aromair/data/models/available_cab.dart';
import 'package:front_erp_aromair/theme/colors.dart';

// --------- Payloads ---------
class ProgrammePayload {
  int tempsEnMarche;
  int tempsDeRepos;
  String unite; // MINUTE / SECONDE
  String heureDebut; // HH:mm:ss
  String heureFin; // HH:mm:ss
  Set<String> jours; // MONDAY..SUNDAY

  ProgrammePayload({
    this.tempsEnMarche = 1,
    this.tempsDeRepos = 5,
    this.unite = 'MINUTE',
    this.heureDebut = '08:00:00',
    this.heureFin = '17:00:00',
    Set<String>? jours,
  }) : jours =
           jours ?? {'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'};

  Map<String, dynamic> toJson() => {
    'frequence': {
      'tempsEnMarche': tempsEnMarche,
      'tempsDeRepos': tempsDeRepos,
      'unite': unite,
    },
    'plageHoraire': {'heureDebut': heureDebut, 'heureFin': heureFin},
    'joursActifs': jours.toList(),
  };
}

class AffecterClientDiffuseurRequest {
  final String emplacement;
  final int? maxMinParJour;
  final List<ProgrammePayload> programmes;

  AffecterClientDiffuseurRequest({
    required this.emplacement,
    required this.programmes,
    this.maxMinParJour,
  });

  Map<String, dynamic> toJson() => {
    'emplacement': emplacement,
    if (maxMinParJour != null) 'maxMinParJour': maxMinParJour,
    'programmes': programmes.map((p) => p.toJson()).toList(),
  };
}

// --------- submit ----------
Future<void> _submit({
  required ClientDetailController c,
  required String cab,
  required String emplacement,
  int? maxMinParJour,
  required List<ProgrammePayload> programmes,
}) async {
  final req = AffecterClientDiffuseurRequest(
    emplacement: emplacement.trim(),
    programmes: programmes,
    maxMinParJour: maxMinParJour,
  );
  try {
    await c.affecterClientDiffuseurInit(cab: cab.trim(), req: req.toJson());
    Get.back(result: true);
    Get.snackbar(
      'Succès',
      'Diffuseur affecté avec succès.',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Affectation échouée: $e',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

// --------- UI ----------
Future<bool?> showAffecterClientDiffuseurDialog(
  BuildContext context,
  ClientDetailController c,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AffecterClientDiffuseurBottomSheet(controller: c),
  );
}

class _AffecterClientDiffuseurBottomSheet extends StatefulWidget {
  final ClientDetailController controller;
  const _AffecterClientDiffuseurBottomSheet({required this.controller});

  @override
  State<_AffecterClientDiffuseurBottomSheet> createState() =>
      _AffecterClientDiffuseurBottomSheetState();
}

class _AffecterClientDiffuseurBottomSheetState
    extends State<_AffecterClientDiffuseurBottomSheet> {
  final emplCtrl = TextEditingController();
  final maxCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ⚠️ pas de saisie libre du CAB : on force une sélection
  AvailableCab? _selectedCab;

  bool withProgramme = true;
  final programmes = <ProgrammePayload>[ProgrammePayload()];

  bool get isMAD =>
      (widget.controller.dto.value?.type ?? '').toUpperCase() == 'MAD';

  @override
  void initState() {
    super.initState();
    // première charge des CAB disponibles si la liste est vide
    if (widget.controller.cabsDisponibles.isEmpty &&
        !widget.controller.isLoadingCabs.value) {
      widget.controller.loadCabsDisponibles();
    }
  }

  @override
  void dispose() {
    emplCtrl.dispose();
    maxCtrl.dispose();
    super.dispose();
  }

  Future<void> pickTime(TextEditingController target) async {
    final now = TimeOfDay.now();
    final res = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (res != null) {
      final hh = res.hour.toString().padLeft(2, '0');
      final mm = res.minute.toString().padLeft(2, '0');
      target.text = '$hh:$mm:00';
    }
  }

  InputDecoration _dec(String hint, {IconData? icon}) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.tertiary.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.tertiary.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    prefixIcon: icon != null ? Icon(icon, color: AppColors.tertiary) : null,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    filled: true,
    fillColor: Colors.white,
  );

  Widget _field(Widget child) => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );

  // -------- Sélecteur CAB (sélection forcée) --------
  Future<void> _openCabPicker() async {
    final ctrl = widget.controller;

    // Charge au moins une fois côté serveur si vide
    if (ctrl.cabsDisponibles.isEmpty && !ctrl.isLoadingCabs.value) {
      await ctrl.loadCabsDisponibles();
    }

    final picked = await showModalBottomSheet<AvailableCab>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        // Liste filtrable, maintenue par le StatefulBuilder
        List<AvailableCab> options = List.of(ctrl.cabsDisponibles);
        final search = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            void applyFilter(String q) {
              final v = q.trim().toLowerCase();
              setModalState(() {
                options = ctrl.cabsDisponibles.where((o) {
                  final a = o.cab.toLowerCase();
                  final b = o.designation.toLowerCase();
                  return a.contains(v) || b.contains(v);
                }).toList();
              });
            }

            Future<void> refreshServer() async {
              await ctrl.loadCabsDisponibles(
                q: search.text.trim().isEmpty ? null : search.text.trim(),
              );
              setModalState(() {
                // Après refresh serveur, on repart de la source
                options = List.of(ctrl.cabsDisponibles);
              });
            }

            final loading = ctrl.isLoadingCabs.value;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Padding(
                padding: MediaQuery.of(ctx).viewInsets,
                child: SizedBox(
                  height: 480,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const Text(
                          'Sélectionner un CAB',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Barre de recherche (filtre local) + refresh serveur
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: search,
                                onChanged:
                                    applyFilter, // filtre local instantané
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: AppColors.tertiary,
                                  ),
                                  hintText: 'Rechercher (CAB ou désignation)…',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: AppColors.tertiary.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Rafraîchir depuis le serveur',
                              onPressed: loading ? null : refreshServer,
                              icon: loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.refresh,
                                      color: AppColors.primary,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Liste filtrée
                      Expanded(
                        child: options.isEmpty
                            ? Center(
                                child: Text(
                                  'Aucun CAB disponible',
                                  style: TextStyle(
                                    color: AppColors.tertiary.withOpacity(0.6),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: options.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: AppColors.tertiary.withOpacity(0.3),
                                ),
                                itemBuilder: (_, i) {
                                  final o = options[i];
                                  return ListTile(
                                    title: Text(
                                      o.cab,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    subtitle: o.designation.isEmpty
                                        ? null
                                        : Text(
                                            o.designation,
                                            style: TextStyle(
                                              color: AppColors.tertiary,
                                            ),
                                          ),
                                    onTap: () => Navigator.of(ctx).pop(o),
                                  );
                                },
                              ),
                      ),

                      // Actions feuille
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Fermer'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedCab = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Text(
                  'Affecter un Diffuseur',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),

                        // --- CAB (sélection obligatoire, pas de saisie libre)
                        _field(
                          GestureDetector(
                            onTap: _openCabPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.tertiary.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade50,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    color: AppColors.tertiary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedCab == null
                                          ? 'Sélectionner un CAB…'
                                          : (_selectedCab!.designation.isEmpty
                                                ? _selectedCab!.cab
                                                : '${_selectedCab!.cab} — ${_selectedCab!.designation}'),
                                      style: TextStyle(
                                        color: _selectedCab == null
                                            ? AppColors.tertiary.withOpacity(
                                                0.6,
                                              )
                                            : Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.tertiary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Emplacement
                        _field(
                          TextFormField(
                            controller: emplCtrl,
                            decoration: _dec(
                              'Emplacement',
                              icon: Icons.place_outlined,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Emplacement requis'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Max minutes / jour (MAD)
                        if (isMAD)
                          _field(
                            TextFormField(
                              controller: maxCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _dec(
                                'Max minutes / jour (MAD)',
                                icon: Icons.watch_later_outlined,
                              ),
                              validator: (v) {
                                if (!isMAD) return null;
                                if (v == null || v.trim().isEmpty) {
                                  return 'Obligatoire pour client MAD';
                                }
                                final x = int.tryParse(v);
                                if (x == null || x < 0 || x > 1440)
                                  return '0..1440';
                                return null;
                              },
                            ),
                          ),

                        const SizedBox(height: 20),

                        // --- Programmes init
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: withProgramme,
                                onChanged: (v) =>
                                    setState(() => withProgramme = v ?? false),
                                visualDensity: VisualDensity.compact,
                                activeColor: AppColors.primary,
                                checkColor: Colors.white,
                              ),
                              Expanded(
                                child: Text(
                                  'Définir un programme initial',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              if (withProgramme)
                                IconButton(
                                  tooltip: 'Ajouter un programme',
                                  onPressed: () => setState(
                                    () => programmes.add(ProgrammePayload()),
                                  ),
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        if (withProgramme) ...[
                          const SizedBox(height: 16),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                children: List.generate(programmes.length, (i) {
                                  final p = programmes[i];
                                  final debutCtrl = TextEditingController(
                                    text: p.heureDebut,
                                  );
                                  final finCtrl = TextEditingController(
                                    text: p.heureFin,
                                  );

                                  Widget chipDay(String d, String label) {
                                    final selected = p.jours.contains(d);
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 6,
                                        bottom: 6,
                                      ),
                                      child: FilterChip(
                                        selected: selected,
                                        label: Text(label),
                                        onSelected: (v) {
                                          setState(() {
                                            if (v) {
                                              p.jours.add(d);
                                            } else {
                                              p.jours.remove(d);
                                            }
                                          });
                                        },
                                        selectedColor: AppColors.primary
                                            .withOpacity(0.1),
                                        checkmarkColor: AppColors.primary,
                                        backgroundColor: Colors.grey.shade100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          side: selected
                                              ? BorderSide(
                                                  color: AppColors.primary
                                                      .withOpacity(0.3),
                                                )
                                              : BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                        ),
                                      ),
                                    );
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.tertiary.withOpacity(
                                          0.2,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(
                                            0.05,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _field(
                                                TextFormField(
                                                  initialValue: p.tempsEnMarche
                                                      .toString(),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: _dec(
                                                    'Tps marche',
                                                  ),
                                                  onChanged: (v) =>
                                                      p.tempsEnMarche =
                                                          int.tryParse(v) ?? 1,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _field(
                                                TextFormField(
                                                  initialValue: p.tempsDeRepos
                                                      .toString(),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: _dec('Tps repos'),
                                                  onChanged: (v) =>
                                                      p.tempsDeRepos =
                                                          int.tryParse(v) ?? 5,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _field(
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: AppColors.tertiary
                                                          .withOpacity(0.3),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child:
                                                      DropdownButtonFormField<
                                                        String
                                                      >(
                                                        value: p.unite,
                                                        items: const [
                                                          DropdownMenuItem(
                                                            value: 'MINUTE',
                                                            child: Text(
                                                              'MINUTE',
                                                            ),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: 'SECONDE',
                                                            child: Text(
                                                              'SECONDE',
                                                            ),
                                                          ),
                                                        ],
                                                        onChanged: (v) =>
                                                            setState(
                                                              () => p.unite =
                                                                  v ?? 'MINUTE',
                                                            ),
                                                        decoration:
                                                            const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                            ),
                                                        icon: Icon(
                                                          Icons.arrow_drop_down,
                                                          color: AppColors
                                                              .tertiary,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (programmes.length > 1)
                                              IconButton(
                                                tooltip: 'Retirer',
                                                onPressed: () => setState(
                                                  () => programmes.removeAt(i),
                                                ),
                                                icon: Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red.shade600,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _field(
                                                TextFormField(
                                                  controller: debutCtrl,
                                                  readOnly: true,
                                                  onTap: () async {
                                                    await pickTime(debutCtrl);
                                                    p.heureDebut =
                                                        debutCtrl.text;
                                                  },
                                                  decoration: _dec(
                                                    'Heure début',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _field(
                                                TextFormField(
                                                  controller: finCtrl,
                                                  readOnly: true,
                                                  onTap: () async {
                                                    await pickTime(finCtrl);
                                                    p.heureFin = finCtrl.text;
                                                  },
                                                  decoration: _dec('Heure fin'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Wrap(
                                            children: [
                                              chipDay('MONDAY', 'MON'),
                                              chipDay('TUESDAY', 'TUE'),
                                              chipDay('WEDNESDAY', 'WED'),
                                              chipDay('THURSDAY', 'THU'),
                                              chipDay('FRIDAY', 'FRI'),
                                              chipDay('SATURDAY', 'SAT'),
                                              chipDay('SUNDAY', 'SUN'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(result: false),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: AppColors.tertiary.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'Annuler',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.tertiary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // validations
                                  if (_selectedCab == null) {
                                    Get.snackbar(
                                      'Champ requis',
                                      'Veuillez sélectionner un CAB.',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    return;
                                  }
                                  if (!formKey.currentState!.validate()) return;

                                  final emp = emplCtrl.text;
                                  final max = isMAD
                                      ? int.tryParse(maxCtrl.text)
                                      : null;
                                  final progs = withProgramme
                                      ? programmes
                                      : <ProgrammePayload>[];

                                  _submit(
                                    c: widget.controller,
                                    cab: _selectedCab!.cab,
                                    emplacement: emp,
                                    maxMinParJour: max,
                                    programmes: progs,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  shadowColor: AppColors.primary.withOpacity(
                                    0.3,
                                  ),
                                ),
                                child: const Text(
                                  'Valider',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
