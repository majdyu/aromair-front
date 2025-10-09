import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/equipe.dart';
import 'package:front_erp_aromair/data/repositories/admin/equipe_repository.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/data/models/intervention_detail.dart';
import 'package:front_erp_aromair/data/repositories/admin/interventions_repository.dart';
import 'package:front_erp_aromair/data/services/interventions_service.dart';
import 'package:intl/intl.dart';

class InterventionDetailController extends GetxController {
  final InterventionsRepository repo = InterventionsRepository(
    InterventionsService(),
  );
  final int interventionId;
  InterventionDetailController(this.interventionId);

  final isLoading = false.obs;
  final error = RxnString();
  final detail = Rxn<InterventionDetail>();

  // --- Remarque inline ---
  final remarkCtrl = TextEditingController();
  final isEditingRemark = false.obs;
  final isSavingRemark = false.obs;

  // --- Paiement inline ---
  final payCtrl = TextEditingController();
  final isEditingPay = false.obs;
  final isSavingPay = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;
    try {
      final d = await repo.detail(interventionId);
      detail.value = d;

      // réaligner les champs UI si pas en édition
      if (!isEditingRemark.value) {
        remarkCtrl.text = (d.remarque ?? '').trim();
      }
      if (!isEditingPay.value) {
        payCtrl.text = d.payement == null ? '' : d.payement!.toString();
      }

      isEditingRemark.value = false;
      isEditingPay.value = false;
    } catch (e) {
      error.value = e.toString();
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Chargement des détails échoué: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- Remarque ---
  void startEditRemark() => isEditingRemark.value = true;

  Future<void> submitRemark() async {
    isSavingRemark.value = true;
    try {
      final text = remarkCtrl.text.trim();
      await repo.updateMeta(
        interventionId,
        remarque: text.isEmpty ? null : text,
      );
      await fetch();
      ElegantSnackbarService.showSuccess(message: 'Remarque enregistrée.');
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Échec de mise à jour: $e',
      );
    } finally {
      isSavingRemark.value = false;
    }
  }

  // --- Paiement ---
  void startEditPay() => isEditingPay.value = true;

  Future<void> submitPay() async {
    final raw = payCtrl.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);
    if (value == null) {
      ElegantSnackbarService.showError(
        title: 'Montant invalide',
        message: 'Saisis un nombre (ex: 12.500)',
      );
      return;
    }

    isSavingPay.value = true;
    try {
      await repo.updateMeta(interventionId, payement: value);
      // update optimiste local
      final d = detail.value;
      if (d != null) {
        detail.value = d.copyWith(payement: value);
      }
      isEditingPay.value = false;
      ElegantSnackbarService.showSuccess(message: 'Paiement mis à jour.');
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Mise à jour du paiement échouée: $e',
      );
    } finally {
      isSavingPay.value = false;
    }
  }

  @override
  void onClose() {
    remarkCtrl.dispose();
    payCtrl.dispose(); // ✅ important
    super.onClose();
  }

  // ======================= BASIC INFO INLINE EDIT =======================
  final equipes = <Equipe>[].obs;
  final selectedEquipe = Rxn<Equipe>();
  final _equipesRepo = EquipesRepository();

  // State
  final isEditingBasicInfo = false.obs;
  final isSavingBasicInfo = false.obs;

  // Form controllers
  final dateBasicCtrl = TextEditingController(); // dd/MM/yyyy
  final equipeBasicCtrl =
      TextEditingController(); // string (filled from selectedEquipe)
  final techniciensBasicCtrl =
      TextEditingController(); // always set from selectedEquipe
  final clientBasicCtrl =
      TextEditingController(); // read-only (filled from detail)
  final payObligatoire = false.obs;

  // Hydrate form from current detail (no API call here)
  void _hydrateBasicForm() {
    final d = detail.value;
    if (d == null) return;
    try {
      dateBasicCtrl.text = DateFormat('dd/MM/yyyy').format(d.date);
    } catch (_) {
      dateBasicCtrl.text = '';
    }
    equipeBasicCtrl.text = d.equipeNom;
    techniciensBasicCtrl.text = (d.techniciens).join(', ');
    clientBasicCtrl.text = d.clientNom;
    payObligatoire.value = d.estPayementObligatoire;
  }

  void hydrateBasicFormIfIdle() {
    if (!isEditingBasicInfo.value) _hydrateBasicForm();
  }

  // Load équipes from backend and preselect current if names match
  Future<void> loadEquipes() async {
    try {
      final list = await _equipesRepo.fetchEquipes();
      equipes.assignAll(list);

      // try to preselect by name
      final currentName = detail.value?.equipeNom.toLowerCase().trim();
      if (currentName != null && currentName.isNotEmpty) {
        Equipe? match;
        for (final e in list) {
          if (e.nom.toLowerCase().trim() == currentName) {
            match = e;
            break;
          }
        }
        selectedEquipe.value = match;
        if (match != null) {
          equipeBasicCtrl.text = match.nom;
          techniciensBasicCtrl.text = match.techniciens.join(', ');
        }
      }
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Info',
        message: 'Impossible de charger les équipes : $e',
      );
    }
  }

  void onEquipeSelected(Equipe? e) {
    selectedEquipe.value = e;
    if (e != null) {
      equipeBasicCtrl.text = e.nom;
      techniciensBasicCtrl.text = e.techniciens.join(', ');
    } else {
      equipeBasicCtrl.clear();
      techniciensBasicCtrl.clear();
    }
  }

  void startEditBasicInfo() {
    _hydrateBasicForm();
    isEditingBasicInfo.value = true;
    loadEquipes();
  }

  void cancelEditBasicInfo() {
    _hydrateBasicForm();
    isEditingBasicInfo.value = false;
  }

  Future<void> submitBasicInfo() async {
    if (detail.value == null) return;
    try {
      isSavingBasicInfo.value = true;

      DateTime? newDate;
      try {
        newDate = DateFormat(
          'dd/MM/yyyy',
        ).parseStrict(dateBasicCtrl.text.trim());
      } catch (_) {
        ElegantSnackbarService.showError(
          title: 'Champ invalide',
          message: 'La date est invalide (format: jj/MM/aaaa)',
        );
        return;
      }

      await repo.updateMeta(
        detail.value!.id,
        date: DateTime(newDate.year, newDate.month, newDate.day),
        estPayementObligatoire: payObligatoire.value,
        equipeId: selectedEquipe.value?.id,
      );
      await fetch();
      _hydrateBasicForm(); // keep form in sync
      isEditingBasicInfo.value = false;
      ElegantSnackbarService.showSuccess(message: 'Informations mises à jour.');
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Impossible de mettre à jour: $e',
      );
    } finally {
      isSavingBasicInfo.value = false;
    }
  }
}
