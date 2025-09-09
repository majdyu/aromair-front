import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:front_erp_aromair/data/models/client_detail.dart';
import 'package:front_erp_aromair/data/services/client_service.dart';
import 'package:front_erp_aromair/data/repositories/admin/client_repository.dart';
import 'package:front_erp_aromair/utils/url_opener.dart';

class ClientDetailController extends GetxController {
  final int clientId;
  ClientDetailController(this.clientId);

  // state
  final isLoading = true.obs;
  final error = RxnString();
  final dto = Rxn<ClientDetail>();

  // edit state
  final isEditing = false.obs;
  final formKey = GlobalKey<FormState>();

  // enums (en String pour rester simple)
  static const natureOptions = ['ENTREPRISE', 'PARTICULIER'];
  static const typeOptions = ['ACHAT', 'CONVENTION', 'MAD'];
  static const importanceOptions = ['ELEVE', 'MOYENNE', 'FAIBLE'];
  static const algoOptions = ['FREQUENCE_PLAN', 'SUR_COMMANDE'];

  final nature = RxnString();
  final type = RxnString();
  final importance = RxnString();
  final algo = RxnString();

  // text controllers
  final nomCtrl = TextEditingController();
  final telCtrl = TextEditingController();
  final adrCtrl = TextEditingController();
  final frLivCtrl = TextEditingController();
  final frVisCtrl = TextEditingController();
  final coordCtrl = TextEditingController();

  late IClientRepository _repo;

  @override
  void onInit() {
    super.onInit();

    if (!Get.isRegistered<IClientRepository>()) {
      final dio = Get.isRegistered<Dio>() ? Get.find<Dio>() : Get.put<Dio>(buildDio(), permanent: true);
      if (!Get.isRegistered<ClientService>()) {
        Get.put<ClientService>(ClientService(dio), permanent: true);
      }
      Get.put<IClientRepository>(ClientRepository(Get.find<ClientService>()), permanent: true);
    }
    _repo = Get.find<IClientRepository>();
    fetch();
  }

  @override
  void onClose() {
    nomCtrl.dispose(); telCtrl.dispose(); adrCtrl.dispose();
    frLivCtrl.dispose(); frVisCtrl.dispose(); coordCtrl.dispose();
    super.onClose();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;
    try {
      final data = await _repo.getClientDetail(clientId);
      dto.value = data;
      _fillFormFromDto(data);
    } on DioException catch (e) {
      error.value = 'HTTP ${e.response?.statusCode ?? '-'}: ${e.message}';
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _fillFormFromDto(ClientDetail d) {
    nature.value = d.nature;
    type.value = d.type;
    importance.value = d.importance;
    algo.value = d.algoPlan;

    nomCtrl.text = d.nom;
    telCtrl.text = d.telephone;
    adrCtrl.text = d.adresse;
    frLivCtrl.text = (d.frequenceLivraisonParJour ?? 0).toString();
    frVisCtrl.text = (d.frequenceVisiteParJour ?? 0).toString();
    coordCtrl.text = d.coordonateur;
  }

  void startEdit() => isEditing.value = true;
  void cancelEdit() {
    final d = dto.value;
    if (d != null) _fillFormFromDto(d);
    isEditing.value = false;
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

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
    };

    // retire les null (pour un vrai PATCH partiel)
    body.removeWhere((k, v) => v == null);

    isLoading.value = true;
    try {
      await _repo.updateClient(clientId, body);
      await fetch();          // refresh
      isEditing.value = false;
      Get.snackbar('Client', 'Enregistré avec succès');
    } on DioException catch (e) {
      error.value = 'HTTP ${e.response?.statusCode ?? '-'}: ${e.message}';
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // --- Google Maps (ouvre URL ou construit une recherche)
  Future<void> openMaps() async {
    final raw = (dto.value?.adresse ?? '').trim();
    if (raw.isEmpty || raw == '-') return;

    final isUrl = raw.startsWith('http://') || raw.startsWith('https://');
    final url = isUrl
        ? raw
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(raw)}';

    try {
      await openExternalUrl(url);
    } catch (_) {
      Get.snackbar('Google Maps', "Impossible d'ouvrir le lien.");
    }
  }
}
