import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/option_item.dart';
import 'package:front_erp_aromair/data/models/create_intervention_request.dart';
import 'package:front_erp_aromair/data/repositories/admin/interventions_repository.dart';
import 'package:front_erp_aromair/data/services/interventions_service.dart';

class AddInterventionController extends GetxController {
  final repo = InterventionsRepository(InterventionsService());

  // état chargement / erreur
  final isLoadingLookups = false.obs;
  final error = RxnString();

  // lookups
  final clients = <OptionItem>[].obs;
  final techniciens = <OptionItem>[].obs;
  final diffuseursAll = <OptionItem>[].obs; // dépend du client

  // sélections
  final selectedClientId = RxnInt();
  final selectedUserId = RxnInt();
  final date = DateTime.now().obs;
  final remarqueCtrl = TextEditingController();
  final estPayementObligatoire = false.obs;

  // types gérés
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

  // état par type
  late final Map<String, RxBool> enabled = {
    for (final t in types) t: (t == 'CONTROLE').obs,
  }; // CONTROLE coché par défaut

  // RxMap de RxList => chaque add/remove déclenche un rebuild
  late final RxMap<String, RxList<RxnInt>> linesByType =
      <String, RxList<RxnInt>>{}.obs;

  void _ensureOneLineIfEnabled(String type) {
    final list = linesByType[type]!;
    if (enabled[type]!.value && list.isEmpty) {
      list.add(RxnInt());
    }
  }

  int maxLinesForType(String type) => diffuseursAll.length;

  /// IDs de diffuseurs déjà utilisés dans *tous* les types activés.
  /// (On peut exclure la ligne courante pour afficher sa propre valeur.)
  Set<int> _selectedIdsGlobal({String? exceptType, int? exceptIndex}) {
    final used = <int>{};
    for (final t in types) {
      if (!(enabled[t]?.value ?? false)) continue;
      final list = linesByType[t]!;
      for (int i = 0; i < list.length; i++) {
        if (t == exceptType && i == exceptIndex) continue;
        final v = list[i].value;
        if (v != null) used.add(v);
      }
    }
    return used;
  }

  /// reste global disponible (tous types confondus)
  int _remainingSlotsGlobal() {
    final used = _selectedIdsGlobal();
    final total = diffuseursAll.length;
    final rem = total - used.length;
    return rem < 0 ? 0 : rem;
  }

  bool canAddLine(String type) {
    if (!(enabled[type]?.value ?? false)) return false;
    if (_remainingSlotsGlobal() <= 0) return false;
    return linesByType[type]!.length < diffuseursAll.length;
  }

  void addLine(String type) {
    final list = linesByType[type]!;
    if (canAddLine(type)) list.add(RxnInt()); // RxList => rebuild
  }

  void removeLine(String type, int idx) {
    final list = linesByType[type]!;
    if (list.length > 1) list.removeAt(idx); // RxList => rebuild
  }

  @override
  void onInit() {
    super.onInit();
    for (final t in types) {
      linesByType[t] = <RxnInt>[].obs; // crée une RxList pour chaque type
      _ensureOneLineIfEnabled(t);
    }
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    isLoadingLookups.value = true;
    error.value = null;
    try {
      final c = await repo.clientsMin();
      final u = await repo.techniciensMin();
      clients.assignAll(c);
      techniciens.assignAll(u);

      // sécurité: value -> null si absente des items
      if (selectedClientId.value != null &&
          !clients.any((o) => o.id == selectedClientId.value)) {
        selectedClientId.value = null;
      }
      if (selectedUserId.value != null &&
          !techniciens.any((o) => o.id == selectedUserId.value)) {
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
          final max = maxLinesForType(t);
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

  // options autorisées pour une ligne d’un type (sans doublon dans le même type)
  List<OptionItem> optionsFor(String type, int index) {
    final keep = linesByType[type]![index].value;
    final usedEverywhere = _selectedIdsGlobal(
      exceptType: type,
      exceptIndex: index,
    );
    return diffuseursAll
        .where((o) => o.id == keep || !usedEverywhere.contains(o.id))
        .toList();
  }

  void toggleType(String type, bool? v) {
    final newVal = v ?? false;
    enabled[type]!.value = newVal;
    if (newVal) {
      _ensureOneLineIfEnabled(type);
    } else {
      for (final r in linesByType[type]!) {
        r.value = null; // libère ces IDs pour les autres types
      }
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
      user: IdRef(selectedUserId.value!),
      tafList: tafs,
    );

    try {
      await repo.create(body);
      ElegantSnackbarService.showSuccess(
        message: 'Intervention créée avec succès',
      );
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
