import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/data/models/alerte_detail.dart';
import 'package:front_erp_aromair/data/repositories/admin/alertes_repository.dart';
import 'package:front_erp_aromair/data/services/alertes_service.dart';

class AlerteDetailController extends GetxController {
  final int id;
  AlerteDetailController(this.id);

  // ✅ utilise TON Dio configuré (baseUrl + auth + logs)
  late final AlertesRepository repo =
      AlertesRepository(AlertesService(buildDio()));

  // state
  final isLoading = false.obs;
  final isSaving  = false.obs;
  final error     = RxnString();
  final dto       = Rxn<AlerteDetail>();

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

  /// Navigation vers le client (adapter si tu ajoutes un `clientId` dans le DTO)
  void goToClient() {
    final current = dto.value;
    if (current == null) return;

    // Si tu as ajouté un clientId côté backend/DTO
    if (current.clientId != null) {
      Get.toNamed('/clients/${current.clientId}');
      return;
    }

    // Sinon fallback: ouvre la liste des clients avec un filtre temporaire via arguments (pas global)
    Get.toNamed('/admin-clients', arguments: {'q': current.client});
  }

  @override
  void onClose() {
    decisionCtrl.dispose();
    super.onClose();
  }
}
