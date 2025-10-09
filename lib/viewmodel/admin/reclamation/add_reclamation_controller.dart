import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/create_reclamation_request.dart';
import 'package:front_erp_aromair/data/repositories/admin/interventions_repository.dart';
import 'package:front_erp_aromair/data/services/interventions_service.dart';
import 'package:front_erp_aromair/data/services/reclamation_service.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/data/repositories/admin/reclamation_repository.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';

class OptionItem {
  final int id;
  final String label;
  const OptionItem({required this.id, required this.label});
}

class AddReclamationController extends GetxController {
  // UI state
  final isBootstrapping = false.obs;
  final isSubmitting = false.obs;

  // Form
  final RxInt? _selectedClientIdRx = RxInt(0);
  RxInt get selectedClientId => _selectedClientIdRx!;
  final TextEditingController problemeCtrl = TextEditingController();

  // Data
  final clientOptions = <OptionItem>[].obs;

  // Repo
  late final ReclamationRepository _repo;
  late final InterventionsRepository intRepo;

  AddReclamationController({
    ReclamationRepository? repo,
    InterventionsRepository? interRepo,
  }) {
    intRepo = interRepo ?? InterventionsRepository(InterventionsService());
    _repo = repo ?? ReclamationRepository(ReclamationService(buildDio()));
  }

  Future<void> bootstrap() async {
    isBootstrapping.value = true;
    try {
      final list = await intRepo.clientsMin();
      clientOptions.assignAll(
        list.map((e) => OptionItem(id: e.id, label: e.label)),
      );
      if (clientOptions.isNotEmpty) {
        selectedClientId.value = clientOptions.first.id;
      }
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Impossible de charger la liste des clients',
      );
    } finally {
      isBootstrapping.value = false;
    }
  }

  Future<bool> submit() async {
    final clientId = selectedClientId.value;
    final probleme = problemeCtrl.text.trim();

    if (clientId == 0 || probleme.isEmpty) {
      ElegantSnackbarService.showError(
        title: 'Champs manquants',
        message: 'Sélectionnez un client et décrivez le problème.',
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      final body = CreateReclamationRequest(
        clientId: clientId,
        probleme: probleme,
      );
      await _repo.create(body);
      ElegantSnackbarService.showSuccess(
        message: 'Réclamation créée avec succès',
      );
      return true;
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Création échouée',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    problemeCtrl.dispose();
    super.onClose();
  }
}
