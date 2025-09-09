import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/data/models/intervention_detail.dart';
import 'package:front_erp_aromair/data/repositories/admin/interventions_repository.dart';
import 'package:front_erp_aromair/data/services/interventions_service.dart';

class InterventionDetailController extends GetxController {
  final InterventionsRepository repo =
      InterventionsRepository(InterventionsService());
  final int interventionId;
  InterventionDetailController(this.interventionId);

  final isLoading = false.obs;
  final error = RxnString();
  final detail = Rxn<InterventionDetail>();

  // --- Remarque inline ---
  final remarkCtrl = TextEditingController();
  final isEditingRemark = false.obs;
  final isSavingRemark  = false.obs;

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

      // Toujours réaligner le champ sur la valeur DB (jamais "-")
      // sauf si on est en train d’éditer (sécurité supplémentaire côté écran déjà faite)
      if (!isEditingRemark.value) {
        remarkCtrl.text = (d.remarque ?? '').trim();
      }

      // On sort du mode édition si on y était (ex. après patch)
      isEditingRemark.value = false;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void startEditRemark() => isEditingRemark.value = true;

  Future<void> submitRemark() async {
    isSavingRemark.value = true;
    try {
      final text = remarkCtrl.text.trim();
      // IMPORTANT : envoyer null si vide (et pas "-")
      await repo.updateMeta(interventionId, remarque: text.isEmpty ? null : text);
      await fetch(); // se réaligne avec la DB (et met fin au mode édition)
      Get.snackbar('Succès', 'Remarque enregistrée.');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de mise à jour: $e');
    } finally {
      isSavingRemark.value = false;
    }
  }

  @override
  void onClose() {
    remarkCtrl.dispose();
    super.onClose();
  }
}
