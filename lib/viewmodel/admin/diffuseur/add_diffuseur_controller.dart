import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/repositories/admin/diffuseur_repository.dart';
import 'package:front_erp_aromair/data/services/diffuseur_service.dart';
import 'package:front_erp_aromair/viewmodel/admin/diffuseur/diffuseur_controller.dart';

class AddDiffuseurController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // fields
  final modeleCtrl = TextEditingController();
  final typCarteCtrl = TextEditingController();
  final designationCtrl = TextEditingController();
  final consommationCtrl = TextEditingController();

  final isSubmitting = false.obs;

  late final DiffuseurRepository _repo = DiffuseurRepository(
    DiffuseurService(buildDio()),
  );

  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    final conso = double.parse(
      consommationCtrl.text.trim().replaceAll(',', '.'),
    );

    isSubmitting.value = true;
    try {
      final created = await _repo.create(
        modele: modeleCtrl.text.trim(),
        typCarte: typCarteCtrl.text.trim(),
        designation: designationCtrl.text.trim(),
        consommation: conso,
      );

      // Immediately reflect in the list if screen controller exists
      if (Get.isRegistered<DiffuseurController>()) {
        Get.find<DiffuseurController>().prepend(created);
      }

      ElegantSnackbarService.showSuccess(message: 'Diffuseur créé');
      return true;
    } catch (e) {
      ElegantSnackbarService.showError(message: '$e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    modeleCtrl.dispose();
    typCarteCtrl.dispose();
    designationCtrl.dispose();
    consommationCtrl.dispose();
    super.onClose();
  }
}
