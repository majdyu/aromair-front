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
      await repo.updateMeta(interventionId, remarque: text.isEmpty ? null : text);
      await fetch();
      Get.snackbar('Succès', 'Remarque enregistrée.');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de mise à jour: $e');
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
      Get.snackbar("Montant invalide", "Saisis un nombre (ex: 12.500)");
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
    } catch (e) {
      Get.snackbar("Erreur", "Mise à jour du paiement échouée: $e");
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
}
