import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/viewmodel/admin/client_detail_controller.dart';
import 'package:front_erp_aromair/data/models/available_cab.dart';

// --------- Payloads ---------
class ProgrammePayload {
  int tempsEnMarche;
  int tempsDeRepos;
  String unite;      // MINUTE / SECONDE
  String heureDebut; // HH:mm:ss
  String heureFin;   // HH:mm:ss
  Set<String> jours; // MONDAY..SUNDAY

  ProgrammePayload({
    this.tempsEnMarche = 1,
    this.tempsDeRepos = 5,
    this.unite = 'MINUTE',
    this.heureDebut = '08:00:00',
    this.heureFin = '17:00:00',
    Set<String>? jours,
  }) : jours = jours ?? {'MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY'};

  Map<String, dynamic> toJson() => {
        'frequence': {
          'tempsEnMarche': tempsEnMarche,
          'tempsDeRepos': tempsDeRepos,
          'unite': unite,
        },
        'plageHoraire': {
          'heureDebut': heureDebut,
          'heureFin': heureFin,
        },
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
    Get.snackbar('Succès', 'Diffuseur affecté avec succès.',
        snackPosition: SnackPosition.BOTTOM);
  } catch (e) {
    Get.snackbar('Erreur', 'Affectation échouée: $e',
        snackPosition: SnackPosition.BOTTOM);
  }
}

// --------- UI ----------
Future<bool?> showAffecterClientDiffuseurDialog(
  BuildContext context,
  ClientDetailController c,
) {
  return Get.dialog<bool>(
    Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: _AffecterClientDiffuseurForm(controller: c),
    ),
    barrierDismissible: false,
    useSafeArea: true,
  );
}

class _AffecterClientDiffuseurForm extends StatefulWidget {
  final ClientDetailController controller;
  const _AffecterClientDiffuseurForm({required this.controller});

  @override
  State<_AffecterClientDiffuseurForm> createState() =>
      _AffecterClientDiffuseurFormState();
}

class _AffecterClientDiffuseurFormState
    extends State<_AffecterClientDiffuseurForm> {
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
    final res = await showTimePicker(context: context, initialTime: now);
    if (res != null) {
      final hh = res.hour.toString().padLeft(2, '0');
      final mm = res.minute.toString().padLeft(2, '0');
      target.text = '$hh:$mm:00';
    }
  }

  InputDecoration _dec(String hint, {IconData? icon}) => InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        prefixIcon: icon != null ? Icon(icon) : null,
      );

  Widget _rounded(Widget child) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

            return Padding(
              padding: MediaQuery.of(ctx).viewInsets,
              child: SizedBox(
                height: 480,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 42, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sélectionner un CAB',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),

                    // Barre de recherche (filtre local) + refresh serveur
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: search,
                              onChanged: applyFilter, // filtre local instantané
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: 'Rechercher (CAB ou désignation)…',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Rafraîchir depuis le serveur',
                            onPressed: loading ? null : refreshServer,
                            icon: loading
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Liste filtrée
                    Expanded(
                      child: options.isEmpty
                          ? const Center(child: Text('Aucun CAB disponible'))
                          : ListView.separated(
                              itemCount: options.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final o = options[i];
                                return ListTile(
                                  title: Text(
                                    o.cab,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: o.designation.isEmpty
                                      ? null
                                      : Text(o.designation),
                                  onTap: () => Navigator.of(ctx).pop(o),
                                );
                              },
                            ),
                    ),

                    // Actions feuille
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Material(
        color: const Color(0xFFE7A5F1),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Affecter un Diffuseur',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                // --- CAB (sélection obligatoire, pas de saisie libre)
                _rounded(
                  InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: _openCabPicker,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.badge_outlined, color: Colors.black54),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedCab == null
                                  ? 'Sélectionner un CAB…'
                                  : (_selectedCab!.designation.isEmpty
                                      ? _selectedCab!.cab
                                      : '${_selectedCab!.cab} — ${_selectedCab!.designation}'),
                              style: TextStyle(
                                color: _selectedCab == null ? Colors.black45 : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // --- Emplacement
                _rounded(TextFormField(
                  controller: emplCtrl,
                  decoration: _dec('Emplacement', icon: Icons.place_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Emplacement requis'
                      : null,
                )),
                const SizedBox(height: 10),

                // --- Max minutes / jour (MAD)
                if (isMAD)
                  _rounded(TextFormField(
                    controller: maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _dec('Max minutes / jour (MAD)',
                        icon: Icons.watch_later_outlined),
                    validator: (v) {
                      if (!isMAD) return null;
                      if (v == null || v.trim().isEmpty) {
                        return 'Obligatoire pour client MAD';
                      }
                      final x = int.tryParse(v);
                      if (x == null || x < 0 || x > 1440) return '0..1440';
                      return null;
                    },
                  )),

                const SizedBox(height: 12),

                // --- Programmes init
                Row(
                  children: [
                    Checkbox(
                      value: withProgramme,
                      onChanged: (v) =>
                          setState(() => withProgramme = v ?? false),
                      visualDensity: VisualDensity.compact,
                    ),
                    const Text('Définir un programme initial'),
                    const Spacer(),
                    if (withProgramme)
                      IconButton(
                        tooltip: 'Ajouter un programme',
                        onPressed: () =>
                            setState(() => programmes.add(ProgrammePayload())),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                  ],
                ),

                if (withProgramme) ...[
                  const SizedBox(height: 6),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(programmes.length, (i) {
                          final p = programmes[i];
                          final debutCtrl =
                              TextEditingController(text: p.heureDebut);
                          final finCtrl =
                              TextEditingController(text: p.heureFin);

                          Widget chipDay(String d, String label) {
                            final selected = p.jours.contains(d);
                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: 6, bottom: 6),
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
                              ),
                            );
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.85),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _rounded(TextFormField(
                                        initialValue:
                                            p.tempsEnMarche.toString(),
                                        keyboardType: TextInputType.number,
                                        decoration: _dec('Tps marche'),
                                        onChanged: (v) => p.tempsEnMarche =
                                            int.tryParse(v) ?? 1,
                                      )),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _rounded(TextFormField(
                                        initialValue:
                                            p.tempsDeRepos.toString(),
                                        keyboardType: TextInputType.number,
                                        decoration: _dec('Tps repos'),
                                        onChanged: (v) => p.tempsDeRepos =
                                            int.tryParse(v) ?? 5,
                                      )),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _rounded(
                                        DropdownButtonFormField<String>(
                                          value: p.unite,
                                          items: const [
                                            DropdownMenuItem(
                                                value: 'MINUTE',
                                                child: Text('MINUTE')),
                                            DropdownMenuItem(
                                                value: 'SECONDE',
                                                child: Text('SECONDE')),
                                          ],
                                          onChanged: (v) =>
                                              setState(() => p.unite =
                                                  v ?? 'MINUTE'),
                                          decoration: const InputDecoration(
                                              border: InputBorder.none),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (programmes.length > 1)
                                      IconButton(
                                        tooltip: 'Retirer',
                                        onPressed: () =>
                                            setState(() => programmes
                                                .removeAt(i)),
                                        icon: const Icon(Icons.remove_circle,
                                            color: Colors.redAccent),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _rounded(TextFormField(
                                        controller: debutCtrl,
                                        readOnly: true,
                                        onTap: () async {
                                          await pickTime(debutCtrl);
                                          p.heureDebut = debutCtrl.text;
                                        },
                                        decoration: _dec('Heure début'),
                                      )),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _rounded(TextFormField(
                                        controller: finCtrl,
                                        readOnly: true,
                                        onTap: () async {
                                          await pickTime(finCtrl);
                                          p.heureFin = finCtrl.text;
                                        },
                                        decoration: _dec('Heure fin'),
                                      )),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
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

                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                      ),
                      child: const Text('Annuler'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        // validations
                        if (_selectedCab == null) {
                          Get.snackbar('Champ requis', 'Veuillez sélectionner un CAB.',
                              snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        if (!formKey.currentState!.validate()) return;

                        final emp = emplCtrl.text;
                        final max = isMAD ? int.tryParse(maxCtrl.text) : null;
                        final progs = withProgramme ? programmes : <ProgrammePayload>[];

                        _submit(
                          c: widget.controller,
                          cab: _selectedCab!.cab,
                          emplacement: emp,
                          maxMinParJour: max,
                          programmes: progs,
                        );
                      },
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                      ),
                      child: const Text('Valider'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
