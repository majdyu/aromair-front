import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/data/models/option_item.dart';
import 'package:front_erp_aromair/data/models/create_intervention_request.dart';
import 'package:front_erp_aromair/data/models/intervention_detail.dart';
import 'package:front_erp_aromair/data/repositories/admin/interventions_repository.dart';
import 'package:front_erp_aromair/data/services/interventions_service.dart';

class EditTafController extends GetxController {
  final InterventionDetail detail;
  EditTafController(this.detail);

  final repo = InterventionsRepository(InterventionsService());

  // état
  final isLoadingLookups = false.obs;
  final error = RxnString();

  // lookups
  final clients = <OptionItem>[].obs; // affichage (client verrouillé)
  final diffuseursAll = <OptionItem>[].obs; // toutes les options du client

  // sélection client (verrouillé mais nécessaire pour charger les CDs)
  final selectedClientId = RxnInt();

  // tous les types supportés (enum complet)
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
    'CHANGEMENT_EMPLACEMENT' => "Changement d’emplacement",
    _ => t,
  };

  /// Etat d’activation par type
  late final Map<String, RxBool> enabled = {
    for (final t in types) t: false.obs,
  };

  late final Map<String, RxList<RxnInt>> linesByType = {
    for (final t in types) t: <RxnInt>[].obs,
  };

  final uiTick = 0.obs;
  void _mark() => uiTick.value++;

  @override
  void onInit() {
    super.onInit();
    selectedClientId.value = detail.clientId;
    _bootstrapFromDetail();
    _loadLookups();
  }

  void _bootstrapFromDetail() {
    for (final t in types) {
      final ids = detail.tafs
          .where((r) => r.type == t)
          .map((r) => r.clientDiffuseurId)
          .whereType<int>()
          .toList();

      if (ids.isNotEmpty) {
        enabled[t]!.value = true;
        final rxList = linesByType[t]!;
        rxList.clear();
        for (final id in ids) {
          final rx = RxnInt()..value = id;
          rxList.add(rx);
        }
      }
    }
    for (final t in types) {
      if (enabled[t]!.value && linesByType[t]!.isEmpty) {
        linesByType[t]!.add(RxnInt());
      }
    }
    _mark();
  }

  // idem mais avec .obs déjà affecté dans onInit()
  Future<void> _loadLookups() async {
    isLoadingLookups.value = true;
    error.value = null;
    try {
      final cs = await repo.clientsMin();
      clients.assignAll(cs);

      if (selectedClientId.value != null) {
        diffuseursAll.assignAll(
          await repo.diffuseursByClientMin(selectedClientId.value!),
        );
      }
    } catch (e) {
      error.value = e.toString();
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Chargement des données: $e',
      );
    } finally {
      isLoadingLookups.value = false;
      _mark();
    }
  }

  // Pas de doublon GLOBAL à travers tous les types
  Set<int> _globalSelectedIds({String? exceptType, int? exceptIndex}) {
    final ids = <int>{};
    for (final t in types) {
      final rows = linesByType[t]!;
      for (var i = 0; i < rows.length; i++) {
        if (t == exceptType && i == exceptIndex) continue;
        final v = rows[i].value;
        if (v != null) ids.add(v);
      }
    }
    return ids;
  }

  List<OptionItem> optionsFor(String type, int index) {
    // lire uiTick pour créer la dépendance de rebuild
    uiTick.value;

    final selected = _globalSelectedIds(exceptType: type, exceptIndex: index);
    final keep = linesByType[type]![index].value;
    return diffuseursAll
        .where((o) => o.id == keep || !selected.contains(o.id))
        .toList();
  }

  int maxLinesForType(String type) => diffuseursAll.length;
  bool canAddLine(String type) =>
      enabled[type]!.value && linesByType[type]!.length < maxLinesForType(type);

  void addLine(String type) {
    if (canAddLine(type)) {
      linesByType[type]!.add(RxnInt());
      _mark();
    }
  }

  void removeLine(String type, int idx) {
    final list = linesByType[type]!;
    if (list.length > 1) {
      list.removeAt(idx);
      _mark();
    }
  }

  void toggleType(String type, bool? v) {
    enabled[type]!.value = v ?? false;
    if (enabled[type]!.value && linesByType[type]!.isEmpty) {
      linesByType[type]!.add(RxnInt());
    }
    _mark();
  }

  void onSelectCd(String type, int index, int? v) {
    linesByType[type]![index].value = v;
    _mark();
  }

  Future<bool> submit() async {
    if (selectedClientId.value == null) {
      ElegantSnackbarService.showError(
        title: 'Client',
        message: 'Client introuvable.',
      );
      return false;
    }
    if (diffuseursAll.isEmpty) {
      ElegantSnackbarService.showError(
        title: 'Client',
        message: 'Aucun diffuseur pour ce client.',
      );
      return false;
    }

    final tafs = <TafCreate>[];
    for (final t in types) {
      if (!enabled[t]!.value) continue;

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
        tafs.add(TafCreate(typeInterventions: t, clientDiffuseur: IdRef(id)));
      }
    }

    try {
      await repo.updateTafs(detail.id, tafs);
      ElegantSnackbarService.showSuccess(
        message: 'Travaux à faire mis à jour avec succès',
      );
      return true;
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Mise à jour échouée: $e',
      );
      return false;
    }
  }
}
