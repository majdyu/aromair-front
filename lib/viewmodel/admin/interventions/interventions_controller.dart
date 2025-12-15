import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/data/models/intervention_item.dart';
import 'package:front_erp_aromair/data/repositories/admin/interventions_repository.dart';
import 'package:front_erp_aromair/data/services/interventions_service.dart';

class InterventionsController extends GetxController {
  final InterventionsRepository repository = InterventionsRepository(
    InterventionsService(),
  );

  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  // UI state
  final isLoading = false.obs;
  final error = RxnString();
  final items = <InterventionItem>[].obs;

  // Filtres
  final from = DateTime.now().obs;
  final to = DateTime.now().obs;
  final selectedStatut = "ALL".obs;
  final searchCtrl = TextEditingController();

  final statuts = const [
    "ALL",
    "EN_COURS",
    "TRAITE",
    "EN_RETARD",
    "NON_ACCOMPLIES",
  ];

  // Focus (pour éviter l’état "champ cliqué")
  final searchFocus = FocusNode();
  final statutFocus = FocusNode();
  final dummyFocus = FocusNode(skipTraversal: true);

  final selectedRowId = RxnInt();
  void clearSelection() => selectedRowId.value = null;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;
    try {
      final list = await repository.list(
        from: _onlyDate(from.value),
        to: _onlyDate(to.value),
        statut: selectedStatut.value,
        q: searchCtrl.text,
      );
      items.assignAll(list);
    } catch (e) {
      error.value = e.toString();
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Chargement des interventions échoué: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: from.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      from.value = picked;
      fetch();
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: to.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      to.value = picked;
      fetch();
    }
  }

  void onStatutChanged(String? v) {
    if (v == null) return;
    selectedStatut.value = v;
    fetch();

    // Retirer focus du dropdown et le rendre à la recherche
    statutFocus.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (searchFocus.canRequestFocus) {
        searchFocus.requestFocus();
      } else {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
  }

  void onSearch() => fetch();

  void clearFilters() {
    selectedStatut.value = "ALL";
    searchCtrl.clear();
    fetch();
  }

  Future<void> deleteIntervention(int id) async {
    final ok =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text("Confirmation"),
            content: const Text(
              "Supprimer définitivement cette intervention ?",
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text("Annuler"),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text("Supprimer"),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;

    if (!ok) return;

    try {
      await repository.delete(id);
      ElegantSnackbarService.showSuccess(message: 'Intervention supprimée');
      fetch();
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Suppression échouée: $e',
      );
    }
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    searchFocus.dispose();
    statutFocus.dispose();
    dummyFocus.dispose();
    super.onClose();
  }
}
