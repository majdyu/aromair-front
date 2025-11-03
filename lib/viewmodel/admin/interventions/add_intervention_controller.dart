// lib/viewmodel/admin/interventions/add_intervention_controller.dart
import 'package:front_erp_aromair/view/screens/admin/interventions/add_intervention_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/option_item.dart';
import 'package:front_erp_aromair/data/models/create_intervention_request.dart';
import 'package:front_erp_aromair/data/repositories/admin/interventions_repository.dart';
import 'package:front_erp_aromair/data/repositories/admin/equipe_repository.dart';
import 'package:front_erp_aromair/data/services/interventions_service.dart';
import 'package:front_erp_aromair/data/services/equipe_service.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';

class AddInterventionController extends GetxController {
  final repo = InterventionsRepository(InterventionsService());
  final repoEquipe = EquipesRepository(EquipesService(buildDio()));

  final PreFillIntervention? prefill;

  AddInterventionController({this.prefill});

  final isLoadingLookups = false.obs;
  final error = RxnString();

  final clients = <OptionItem>[].obs;
  final equipes = <OptionItem>[].obs;
  final diffuseursAll = <OptionItem>[].obs;

  final selectedClientId = RxnInt();
  final selectedUserId = RxnInt();
  final date = DateTime.now().obs;
  final remarqueCtrl = TextEditingController();
  final estPayementObligatoire = false.obs;
  final createdInterventionId = RxnInt();
  final types = const [
    'CONTROLE',
    'DEMO',
    'LIVRAISON',
    'RECLAMATION',
    'REPARATION',
    'INSTALLATION',
    'CHANGEMENT_EMPLACEMENT',
  ];

  String pretty(String t) => switch (t) {
    'CONTROLE' => 'Contrôle',
    'DEMO' => 'Démo',
    'LIVRAISON' => 'Livraison',
    'RECLAMATION' => 'Réclamation',
    'REPARATION' => 'Réparation',
    'INSTALLATION' => 'Installation',
    'CHANGEMENT_EMPLACEMENT' => 'Changement d’emplacement',
    _ => t,
  };

  late final Map<String, RxBool> enabled = {
    for (final t in types) t: false.obs,
  };

  late final RxMap<String, RxList<RxnInt>> linesByType =
      <String, RxList<RxnInt>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    for (final t in types) {
      linesByType[t] = <RxnInt>[].obs;
    }

    if (prefill == null) {
      enabled['CONTROLE']!.value = true;
      linesByType['CONTROLE']!.add(RxnInt());
    }

    _loadLookups().then((_) {
      if (prefill != null) _applyPrefill();
    });
  }

  Future<void> _loadLookups() async {
    isLoadingLookups.value = true;
    error.value = null;
    try {
      final c = await repo.clientsMin();
      final u = await repoEquipe.list();
      clients.assignAll(c);
      equipes.assignAll(u.map((e) => OptionItem(id: e.id, label: e.nom)));

      if (selectedClientId.value != null &&
          !clients.any((o) => o.id == selectedClientId.value)) {
        selectedClientId.value = null;
      }
      if (selectedUserId.value != null &&
          !equipes.any((o) => o.id == selectedUserId.value)) {
        selectedUserId.value = null;
      }
    } catch (e) {
      error.value = e.toString();
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Chargement des listes: $e',
      );
    } finally {
      isLoadingLookups.value = false;
    }
  }

  Future<void> _applyPrefill() async {
    final p = prefill!;
    selectedClientId.value = p.clientId;

    try {
      diffuseursAll.assignAll(await repo.diffuseursByClientMin(p.clientId));
    } catch (_) {}

    final type = p.type;
    enabled[type]!.value = true;
    final list = linesByType[type]!;
    list.clear();
    list.add(RxnInt(p.diffuseurId));
  }

  Future<void> onClientChanged(int? id) async {
    selectedClientId.value = id;
    diffuseursAll.clear();

    for (final t in types) {
      for (final r in linesByType[t]!) {
        r.value = null;
      }
    }

    if (id != null) {
      try {
        diffuseursAll.assignAll(await repo.diffuseursByClientMin(id));
        for (final t in types) {
          final list = linesByType[t]!;
          final max = diffuseursAll.length;
          if (list.length > max) list.removeRange(max, list.length);
          if ((enabled[t]?.value ?? false) && list.isEmpty) list.add(RxnInt());
        }
      } catch (e) {
        ElegantSnackbarService.showError(
          title: 'Erreur',
          message: 'Chargement diffuseurs: $e',
        );
      }
    }
  }

  List<OptionItem> optionsFor(String type, int index) {
    final keep = linesByType[type]![index].value;
    final usedEverywhere = <int>{};
    for (final t in types) {
      if (!(enabled[t]?.value ?? false)) continue;
      final list = linesByType[t]!;
      for (int i = 0; i < list.length; i++) {
        if (t == type && i == index) continue;
        final v = list[i].value;
        if (v != null) usedEverywhere.add(v);
      }
    }
    return diffuseursAll
        .where((o) => o.id == keep || !usedEverywhere.contains(o.id))
        .toList();
  }

  bool canAddLine(String type) {
    if (!(enabled[type]?.value ?? false)) return false;
    if (diffuseursAll.length <= usedEverywhereCount()) return false;
    return linesByType[type]!.length < diffuseursAll.length;
  }

  int usedEverywhereCount() {
    final used = <int>{};
    for (final t in types) {
      if (!(enabled[t]?.value ?? false)) continue;
      for (final r in linesByType[t]!) {
        if (r.value != null) used.add(r.value!);
      }
    }
    return used.length;
  }

  void addLine(String type) {
    if (canAddLine(type)) linesByType[type]!.add(RxnInt());
  }

  void removeLine(String type, int idx) {
    final list = linesByType[type]!;
    if (list.length > 1) list.removeAt(idx);
  }

  void toggleType(String type, bool? v) {
    final newVal = v ?? false;
    enabled[type]!.value = newVal;
    if (!newVal) {
      for (final r in linesByType[type]!) r.value = null;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: date.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    date.value = DateTime(d.year, d.month, d.day, t?.hour ?? 9, t?.minute ?? 0);
  }

  Future<bool> submit() async {
    if (selectedClientId.value == null || selectedUserId.value == null) {
      ElegantSnackbarService.showError(
        title: 'Champs manquants',
        message: 'Client et Technicien sont obligatoires',
      );
      return false;
    }

    if (diffuseursAll.isEmpty) {
      ElegantSnackbarService.showError(
        title: 'Client',
        message: 'Aucun ClientDiffuseur pour ce client.',
      );
      return false;
    }

    final tafs = <TafCreate>[];
    final usedGlobal = <int>{};

    for (final t in types) {
      if (!(enabled[t]?.value ?? false)) continue;
      final rows = linesByType[t]!;
      final ids = rows.map((r) => r.value).whereType<int>().toList();
      if (ids.isEmpty) {
        ElegantSnackbarService.showError(
          title: pretty(t),
          message: 'Sélectionne au moins un diffuseur.',
        );
        return false;
      }
      for (final id in ids) {
        if (usedGlobal.contains(id)) {
          ElegantSnackbarService.showError(
            title: 'Conflit',
            message:
                'Le diffuseur $id est déjà sélectionné dans un autre type.',
          );
          return false;
        }
        usedGlobal.add(id);
        tafs.add(TafCreate(typeInterventions: t, clientDiffuseur: IdRef(id)));
      }
    }

    final body = CreateInterventionRequest(
      date: date.value,
      estPayementObligatoire: estPayementObligatoire.value,
      remarque: remarqueCtrl.text.isEmpty ? null : remarqueCtrl.text,
      client: IdRef(selectedClientId.value!),
      equipe: IdRef(selectedUserId.value!),
      tafList: tafs,
    );

    try {
      final created = await repo.create(body);
      print("Intervention créée avec ID: ${created.id}");
      createdInterventionId.value = created.id;

      return true;
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Création échouée: $e',
      );
      return false;
    }
  }

  @override
  void onClose() {
    remarqueCtrl.dispose();
    super.onClose();
  }
}
