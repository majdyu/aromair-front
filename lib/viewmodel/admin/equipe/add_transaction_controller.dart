// lib/viewmodel/admin/equipe/add_transaction_controller.dart
import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/services/caisse_service.dart';
import 'package:get/get.dart';

class AddTransactionController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final montantCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  final RxString type = 'ENTREE'.obs;
  final Rx<DateTime> date = DateTime.now().obs;
  final RxBool isSaving = false.obs;

  final int userId;
  late final CaisseService service;

  AddTransactionController(this.userId) {
    service = CaisseService(buildDio());
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final init = date.value;
    final res = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
    );
    if (res != null) {
      // keep only Y-M-D
      date.value = DateTime(res.year, res.month, res.day);
    }
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final raw = montantCtrl.text.trim().replaceAll(',', '.');
    final montant = double.tryParse(raw);
    if (montant == null || montant <= 0) {
      Get.snackbar(
        'Erreur',
        'Montant invalide',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final designation = descriptionCtrl.text.trim().isEmpty
        ? null
        : descriptionCtrl.text.trim();

    isSaving.value = true;
    try {
      final created = await service.addTransaction(
        userId: userId,
        type: type.value,
        montant: montant,
        designation: designation, // backend expects "designation"
        date: date.value, // service will format dd-MM-yyyy
      );

      // ✅ Close the dialog FIRST
      Get.back(result: true);

      // ✅ Show snackbar on the underlying page after a micro delay
      Future.delayed(const Duration(milliseconds: 120), () {
        final solde = created['caisseActuelle'];
        Get.snackbar(
          'Succès',
          solde == null
              ? 'Transaction ajoutée.'
              : 'Transaction ajoutée. Nouveau solde: ${solde.toString()} TND',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      // Keep dialog open and show the backend "details" if available
      final msg = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Erreur',
        msg.isEmpty ? 'Impossible d\'ajouter la transaction' : msg,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    montantCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}
