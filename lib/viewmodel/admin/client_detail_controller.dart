import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import 'package:front_erp_aromair/data/models/available_cab.dart';
import 'package:front_erp_aromair/data/models/client_detail.dart';
import 'package:front_erp_aromair/data/services/clientdiffuseur_service.dart';
import 'package:front_erp_aromair/data/repositories/admin/clientdiffuseur_repository.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';

// Pour ouvrir Google Maps (web/mobile)
import 'package:url_launcher/url_launcher_string.dart';

class ClientDetailController extends GetxController {
  final int clientId;
  ClientDetailController(this.clientId);

  // ------- état principal -------
  final isLoading = true.obs;
  final error = RxnString();
  final dto = Rxn<ClientDetail>();
  //----------------------------------------
  final role = ''.obs;
  bool get isSuperAdmin => role.value == 'SUPER_ADMIN';

  // Edition
  final isEditing = false.obs;
  final formKey = GlobalKey<FormState>();

  // ------- pour l’affectation client-diffuseur -------
  final cabsDisponibles = <AvailableCab>[].obs;
  final isLoadingCabs = false.obs;

  // Champs formulaire
  final nomCtrl = TextEditingController();
  final telCtrl = TextEditingController();
  final coordCtrl = TextEditingController();
  final adrCtrl = TextEditingController();
  final frLivCtrl = TextEditingController();
  final frVisCtrl = TextEditingController();

  // Enums (affichés comme chips/menu)
  final nature = RxnString(); // "ENTREPRISE" | "PARTICULIER"
  final type = RxnString(); // "ACHAT" | "CONVENTION" | "MAD"
  final importance = RxnString(); // "ELEVE" | "MOYENNE" | "FAIBLE"
  final algo = RxnString(); // "FREQUENCE_PLAN" | "SUR_COMMANDE"

  // Options statiques (UI)
  static const natureOptions = ["ENTREPRISE", "PARTICULIER"];
  static const typeOptions = ["ACHAT", "CONVENTION", "MAD"];
  static const importanceOptions = ["ELEVE", "MOYENNE", "FAIBLE"];
  static const algoOptions = ["FREQUENCE_PLAN", "SUR_COMMANDE"];

  // ------- couches data -------
  late final Dio _dio;
  late final IClientDiffuseurRepository _clientDiffuseurRepo;

  @override
  void onInit() {
    super.onInit();
    _loadRole();

    // --- DI Dio
    _dio = Get.isRegistered<Dio>()
        ? Get.find<Dio>()
        : Get.put<Dio>(buildDio(), permanent: true);

    // --- DI repo client-diffuseur
    if (!Get.isRegistered<ClientDiffuseurService>()) {
      Get.put<ClientDiffuseurService>(
        ClientDiffuseurService(_dio),
        permanent: true,
      );
    }
    if (!Get.isRegistered<IClientDiffuseurRepository>()) {
      Get.put<IClientDiffuseurRepository>(
        ClientDiffuseurRepository(Get.find<ClientDiffuseurService>()),
        permanent: true,
      );
    }
    _clientDiffuseurRepo = Get.find<IClientDiffuseurRepository>();

    fetch();
  }

  // ------------------------------------------------------------
  // API client : fetch + patch (controller auto-suffisant)
  // ------------------------------------------------------------
  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;
    try {
      final res = await _dio.get('/clients/$clientId/detail');
      final data = ClientDetail.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
      dto.value = data;

      // Pré-remplir le form
      nomCtrl.text = data.nom;
      telCtrl.text = data.telephone;
      coordCtrl.text = data.coordonateur;
      adrCtrl.text = data.adresse;
      frLivCtrl.text = (data.frequenceLivraisonParJour ?? 0).toString();
      frVisCtrl.text = (data.frequenceVisiteParJour ?? 0).toString();

      nature.value = data.nature;
      type.value = data.type;
      importance.value = data.importance;
      algo.value = data.algoPlan;
    } on DioException catch (e) {
      error.value = 'HTTP ${e.response?.statusCode ?? '-'}: ${e.message}';
      ElegantSnackbarService.showError(title: 'Erreur', message: error.value!);
    } catch (e) {
      error.value = e.toString();
      ElegantSnackbarService.showError(title: 'Erreur', message: error.value!);
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit() => isEditing.value = true;

  void cancelEdit() {
    isEditing.value = false;
    final d = dto.value;
    if (d == null) return;
    nomCtrl.text = d.nom;
    telCtrl.text = d.telephone;
    coordCtrl.text = d.coordonateur;
    adrCtrl.text = d.adresse;
    frLivCtrl.text = (d.frequenceLivraisonParJour ?? 0).toString();
    frVisCtrl.text = (d.frequenceVisiteParJour ?? 0).toString();
    nature.value = d.nature;
    type.value = d.type;
    importance.value = d.importance;
    algo.value = d.algoPlan;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    final body = <String, dynamic>{
      'nom': nomCtrl.text.trim(),
      'telephone': telCtrl.text.trim(),
      'coordonateur': coordCtrl.text.trim(),
      'adresse': adrCtrl.text.trim(),
      'frequenceLivraisonParJour': int.tryParse(frLivCtrl.text.trim()),
      'frequenceVisiteParJour': int.tryParse(frVisCtrl.text.trim()),
      'nature': nature.value,
      'type': type.value,
      'importance': importance.value,
      'algoPlan': algo.value,
    }..removeWhere((k, v) => v == null);

    try {
      await _dio.patch('/clients/$clientId', data: body);
      isEditing.value = false;
      await fetch();
      ElegantSnackbarService.showSuccess(message: 'Client mis à jour');
    } on DioException catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'HTTP ${e.response?.statusCode ?? '-'}: ${e.message}',
      );
    } catch (e) {
      ElegantSnackbarService.showError(title: 'Erreur', message: e.toString());
    }
  }

  // ------------------------------------------------------------
  // Actions utilitaires
  // ------------------------------------------------------------
  void openMaps() {
    final url = dto.value?.adresse.trim() ?? '';
    if (url.isEmpty) return;
    launchUrlString(url, mode: LaunchMode.externalApplication);
  }

  void goToClientDiffuseur(int clientDiffuseurId) {
    Get.toNamed(
      AppRoutes.clientDiffuseurDetail,
      arguments: {'id': clientDiffuseurId},
    );
  }

  // ------------------------------------------------------------
  // *** AFFECTATION CLIENT ⇄ CLIENT-DIFFUSEUR (INIT) ***
  // ------------------------------------------------------------
  Future<void> loadCabsDisponibles({String? q}) async {
    try {
      isLoadingCabs.value = true;
      final list = await _clientDiffuseurRepo.getCabsDisponibles(q: q);
      cabsDisponibles.assignAll(list);
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Chargement CAB disponibles: $e',
      );
    } finally {
      isLoadingCabs.value = false;
    }
  }

  Future<void> affecterClientDiffuseurInit({
    required String cab,
    required Map<String, dynamic>
    req, // { emplacement, maxMinParJour?, programmes[] }
  }) async {
    await _clientDiffuseurRepo.affecterInit(
      clientId: clientId,
      cab: cab,
      body: req,
    );
    await fetch(); // refresh liste des diffuseurs
  }

  Future<void> _loadRole() async {
    final u = await StorageHelper.getUser();
    role.value = (u?['role'] as String?) ?? '';
  }

  // --- retrait d’un client diffuseur ---
  Future<void> retirerClientDiffuseur({required String cab}) async {
    await _clientDiffuseurRepo.retirerClient(cab);
    await fetch();
    ElegantSnackbarService.showSuccess(message: 'Diffuseur retiré du client');
  }

  @override
  void onClose() {
    nomCtrl.dispose();
    telCtrl.dispose();
    coordCtrl.dispose();
    adrCtrl.dispose();
    frLivCtrl.dispose();
    frVisCtrl.dispose();
    super.onClose();
  }
}
