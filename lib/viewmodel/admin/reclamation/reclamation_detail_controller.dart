import 'package:front_erp_aromair/data/enums/statut_reclamation.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:front_erp_aromair/data/models/reclamation_detail.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart'; // buildDio()
import 'package:front_erp_aromair/view/screens/admin/interventions/add_intervention_dialog.dart';

import 'package:front_erp_aromair/data/services/reclamation_service.dart';
import 'package:front_erp_aromair/data/repositories/admin/reclamation_repository.dart';

class ReclamationDetailController extends GetxController {
  final int reclamationId;
  ReclamationDetailController(this.reclamationId);

  final isLoading = true.obs;
  final isPatching = false.obs;
  final error = RxnString();
  final dto = Rxn<ReclamationDetail>();

  late final Dio _dio;
  late final ReclamationService _service;
  late final ReclamationRepository _repo;

  bool get canPlanifier => dto.value?.canPlanifier ?? false;
  String get titleDate => dto.value?.dateLabel ?? '-';

  @override
  void onInit() {
    super.onInit();

    _dio = Get.isRegistered<Dio>()
        ? Get.find<Dio>()
        : Get.put<Dio>(buildDio(), permanent: true);

    if (!Get.isRegistered<ReclamationService>()) {
      Get.put<ReclamationService>(ReclamationService(_dio), permanent: true);
    }
    _service = Get.find<ReclamationService>();

    if (!Get.isRegistered<ReclamationRepository>()) {
      Get.put<ReclamationRepository>(
        ReclamationRepository(_service),
        permanent: true,
      );
    }
    _repo = Get.find<ReclamationRepository>();

    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;
    try {
      dto.value = await _repo.getDetail(reclamationId);
    } on DioException catch (e) {
      error.value = 'HTTP ${e.response?.statusCode ?? '-'}: ${e.message}';
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // --- Actions

  Future<void> toggleEtapes(bool value) async {
    final current = dto.value;
    if (current == null) return;

    isPatching.value = true;
    try {
      await _repo.patchEtapes(reclamationId, value);
      dto.value = current.copyWith(etapes: value);
      if (value) {
        Get.snackbar(
          "Étape validée",
          "Vous pouvez maintenant planifier une intervention.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de mettre à jour l'étape: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPatching.value = false;
    }
  }

  Future<void> markTraite() => _setStatut(StatutReclamation.TRAITE);
  Future<void> markFausse() => _setStatut(StatutReclamation.FAUSSE_RECLAMATION);

  Future<void> _setStatut(StatutReclamation statut) async {
    final current = dto.value;
    if (current == null) return;

    isPatching.value = true;
    try {
      await _repo.patchStatut(reclamationId, statut);
      dto.value = current.copyWith(statut: statut);
      Get.snackbar(
        "Succès",
        "Statut mis à jour: ${statut.name}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de changer le statut: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPatching.value = false;
    }
  }

  void goToClient() {
    final id = dto.value?.clientId;
    if (id == null) return;
    Get.toNamed(AppRoutes.detailClient, arguments: {'id': id});
  }

  Future<void> planifierIntervention(BuildContext context) async {
    final cur = dto.value;
    if (cur == null) return;

    if (!cur.canPlanifier) {
      Get.snackbar(
        "Indisponible",
        "Validez d'abord l'appel téléphonique.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final bool? ok = await showAddInterventionDialog(context);
    if (ok == true) {
      Get.snackbar(
        "Succès",
        "Intervention ajoutée.",
        snackPosition: SnackPosition.BOTTOM,
      );
      // await fetch();
    }
  }

  String get infoAppelTel =>
      "Étape recommandée :\n"
      "1) Appeler le client pour qualifier le problème.\n"
      "2) Vérifier diffuseur (marche/fuite) et perception.\n"
      "3) Si nécessaire, planifier une visite de contrôle.";

  String get infoVisiteCtrl =>
      "Visite de contrôle :\n"
      "• Planifier une intervention si l'appel n'a pas résolu le souci.\n"
      "• Prévoir pièces/bouteilles nécessaires.\n"
      "• Documenter l'état et les actions au terrain.";
}
