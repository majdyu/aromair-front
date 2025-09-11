import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/client_detail.dart';
import 'package:front_erp_aromair/data/services/clientdiffuseur_service.dart';
import 'package:front_erp_aromair/data/repositories/admin/clientdiffuseur_repository.dart';

// Pour ouvrir Google Maps (web/mobile)
import 'package:url_launcher/url_launcher_string.dart';

class ClientDetailController extends GetxController {
  final int clientId;
  ClientDetailController(this.clientId);

  // ------- état principal -------
  final isLoading = true.obs;
  final error = RxnString();
  final dto = Rxn<ClientDetail>();

  // Edition (déjà utilisée par ton UI)
  final isEditing = false.obs;
  final formKey = GlobalKey<FormState>();

  // Champs formulaire
  final nomCtrl = TextEditingController();
  final telCtrl = TextEditingController();
  final coordCtrl = TextEditingController();
  final adrCtrl = TextEditingController();
  final frLivCtrl = TextEditingController();
  final frVisCtrl = TextEditingController();

  // Enums (affichés comme chips/menu)
  final nature = RxnString();     // "ENTREPRISE" | "PARTICULIER"
  final type = RxnString();       // "ACHAT" | "CONVENTION" | "MAD"
  final importance = RxnString(); // "ELEVE" | "MOYENNE" | "FAIBLE"
  final algo = RxnString();       // "FREQUENCE_PLAN" | "SUR_COMMANDE"

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

    // --- DI Dio
    _dio = Get.isRegistered<Dio>() ? Get.find<Dio>() : Get.put<Dio>(buildDio(), permanent: true);

    // --- DI repo client-diffuseur
    if (!Get.isRegistered<ClientDiffuseurService>()) {
      Get.put<ClientDiffuseurService>(ClientDiffuseurService(_dio), permanent: true);
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
      final data = ClientDetail.fromJson(Map<String, dynamic>.from(res.data as Map));
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
    } catch (e) {
      error.value = e.toString();
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
      Get.snackbar('Succès', 'Client mis à jour', snackPosition: SnackPosition.BOTTOM);
    } on DioException catch (e) {
      Get.snackbar('Erreur', 'HTTP ${e.response?.statusCode ?? '-'}: ${e.message}',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
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
    Get.toNamed('/client-diffuseurs/$clientDiffuseurId');
  }

  // ------------------------------------------------------------
  // *** AFFECTATION CLIENT ⇄ CLIENT-DIFFUSEUR (INIT) ***
  // ------------------------------------------------------------
  Future<void> affecterClientDiffuseurInit({
    required String cab,
    required Map<String, dynamic> req, // { emplacement, maxMinParJour?, programmes[] }
  }) async {
    await _clientDiffuseurRepo.affecterInit(
      clientId: clientId,
      cab: cab,
      body: req,
    );
    await fetch(); // refresh liste des diffuseurs
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
