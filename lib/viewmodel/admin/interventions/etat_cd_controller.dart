import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/data/models/etat_client_diffuseur.dart';
import 'package:front_erp_aromair/data/repositories/admin/interventions_repository.dart';
import 'package:front_erp_aromair/data/services/interventions_service.dart';

class EtatClientDiffuseurController extends GetxController {
  final int interventionId;
  final int clientDiffuseurId;

  EtatClientDiffuseurController(this.interventionId, this.clientDiffuseurId);

  final repo = InterventionsRepository(InterventionsService());

  // state
  final isLoading = false.obs;
  final error = RxnString();
  final dto = Rxn<EtatClientDiffuseur>(); // instance immuable

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;
    try {
      final data = await repo.etatClientDiffuseur(
        interventionId,
        clientDiffuseurId,
      );
      dto.value = data;
    } catch (e) {
      error.value = e.toString();
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Chargement de l’état échoué: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------- Toggles (optimistic update immuable + rollback) ----------

  Future<void> toggleQualite(bool? v) async {
    final current = dto.value;
    if (current == null) return;

    final next = current.copyWith(qualiteBonne: v ?? false);
    dto.value = next;
    try {
      await repo.patchIcd(
        interventionId,
        clientDiffuseurId,
        qualiteBonne: v ?? false,
      );
    } catch (e) {
      dto.value = current;
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Mise à jour "Qualité" échouée: $e',
      );
    }
  }

  Future<void> toggleFuite(bool? v) async {
    final current = dto.value;
    if (current == null) return;

    final next = current.copyWith(fuite: v ?? false);
    dto.value = next;
    try {
      await repo.patchIcd(interventionId, clientDiffuseurId, fuite: v ?? false);
      ElegantSnackbarService.showSuccess(
        title: 'Succès',
        message: 'Mise à jour réussie',
      );
    } catch (e) {
      dto.value = current;
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Mise à jour "Fuite" échouée: $e',
      );
    }
  }

  Future<void> toggleMarche(bool? v) async {
    final current = dto.value;
    if (current == null) return;

    final next = current.copyWith(enMarche: v ?? false);
    dto.value = next;
    try {
      await repo.patchIcd(
        interventionId,
        clientDiffuseurId,
        enMarche: v ?? false,
      );
    } catch (e) {
      dto.value = current; // rollback
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Mise à jour "En marche" échouée: $e',
      );
    }
  }
}
