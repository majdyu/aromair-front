import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/data/models/alerte_detail.dart';
import 'package:front_erp_aromair/data/repositories/admin/alertes_repository.dart';
import 'package:front_erp_aromair/data/services/alertes_service.dart';

class AlerteDetailController extends GetxController {
  final int id;
  AlerteDetailController(this.id);

  // ✅ utilise TON Dio configuré (baseUrl + auth + logs)
  late final AlertesRepository repo = AlertesRepository(
    AlertesService(buildDio()),
  );

  // state
  final isLoading = false.obs;
  final isSaving = false.obs;
  final error = RxnString();
  final dto = Rxn<AlerteDetail>();

  final decisionCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;
    try {
      final d = await repo.detail(id);
      dto.value = d;
      decisionCtrl.text = d.decisionPrise ?? '';
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String get buttonLabel =>
      (dto.value?.etatResolution ?? false) ? 'Résolu' : 'Valider';

  ButtonStyle get buttonStyle {
    final resolved = dto.value?.etatResolution ?? false;
    return ElevatedButton.styleFrom(
      backgroundColor: resolved ? Colors.green : Colors.red,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }

  Future<void> onTogglePressed() async {
    if (dto.value == null) return;
    isSaving.value = true;
    try {
      final decision = decisionCtrl.text.trim();
      await repo.toggle(id, decisionPrise: decision.isEmpty ? null : decision);
      await fetch(); // refresh après PATCH
      Get.snackbar('Succès', 'État de résolution basculé.');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du basculement: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Navigation vers la fiche client depuis une alerte
  void goToClient() {
    final current = dto.value;
    if (current == null) return;

    final id = current.clientId;
    if (id != null) {
      Get.toNamed(AppRoutes.detailClient, arguments: {'id': id});
      return;
    }

    final q = (current.client).trim();
    Get.toNamed('/admin-clients', arguments: {'q': q});
  }

  @override
  void onClose() {
    decisionCtrl.dispose();
    super.onClose();
  }
}
