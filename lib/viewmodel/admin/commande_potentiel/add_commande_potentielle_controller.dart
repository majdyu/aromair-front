import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:front_erp_aromair/data/models/option_item.dart';

import 'package:front_erp_aromair/data/repositories/admin/interventions_repository.dart';
import 'package:front_erp_aromair/data/repositories/admin/proposition_commande_repository.dart';
import 'package:front_erp_aromair/data/repositories/admin/parfum_repository.dart';

import 'package:front_erp_aromair/data/services/interventions_service.dart';
import 'package:front_erp_aromair/data/services/proposition_commande_service.dart';
import 'package:front_erp_aromair/data/services/parfum_service.dart';

class AddCommandePotentielleController extends GetxController {
  // Lookups
  final clients = <OptionItem>[].obs;
  final diffuseurs = <OptionItem>[].obs;
  final parfums = <OptionItem>[].obs;

  // Selections
  final selectedClientId = RxnInt();
  final selectedDiffuseurId = RxnInt(); // clientDiffuseurId
  final selectedParfumId = RxnInt(); // OPTIONAL (can stay null)

  // Form fields
  final quantiteCtrl = TextEditingController(); // OPTIONAL
  final typeTeteCtrl = TextEditingController(); // OPTIONAL
  final nbrBouteillesCtrl = TextEditingController(); // REQUIRED (default 1)

  // Inline errors (reactive)
  final qtyError = RxnString(); // null => no error
  final nbError = RxnString(); // null => no error

  // UI state
  final forceCreation = false.obs;
  final isLoadingLookups = false.obs;
  final isSubmitting = false.obs;
  final error = RxnString();
  final createdId = RxnInt();

  // repos
  final _interRepo = InterventionsRepository(InterventionsService());
  final _cmdRepo = CommandesPotentiellesRepository(
    CommandesPotentiellesService(buildDio()),
  );
  final _parfumRepo = ParfumRepository(ParfumService(buildDio()));

  @override
  void onInit() {
    super.onInit();

    // Defaults
    nbrBouteillesCtrl.text = '1'; // default required value

    // Live validation
    quantiteCtrl.addListener(() {
      final txt = quantiteCtrl.text.trim();
      if (txt.isEmpty) {
        // optional -> no error when empty
        qtyError.value = null;
      } else {
        final q = int.tryParse(txt);
        if (q == null || q <= 0) {
          qtyError.value = 'Quantité invalide (entier > 0)';
        } else {
          qtyError.value = null;
        }
      }
    });

    nbrBouteillesCtrl.addListener(() {
      final txt = nbrBouteillesCtrl.text.trim();
      final nb = int.tryParse(txt);
      if (nb == null || nb < 1) {
        nbError.value = 'Nombre de bouteilles requis (≥ 1)';
      } else {
        nbError.value = null;
      }
    });

    _loadLookups();
  }

  @override
  void onClose() {
    quantiteCtrl.dispose();
    typeTeteCtrl.dispose();
    nbrBouteillesCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadLookups() async {
    isLoadingLookups.value = true;
    error.value = null;
    try {
      clients.assignAll(await _interRepo.clientsMin());
      parfums.assignAll(
        (await _parfumRepo.fetch())
            .map((p) => OptionItem(id: p.id, label: p.nom))
            .toList(),
      );
    } catch (e) {
      error.value = 'Chargement des listes: $e';
      ElegantSnackbarService.showError(title: 'Erreur', message: error.value!);
    } finally {
      isLoadingLookups.value = false;
    }
  }

  Future<void> onClientChanged(int? id) async {
    selectedClientId.value = id;
    selectedDiffuseurId.value = null;
    diffuseurs.clear();

    if (id == null) return;

    try {
      diffuseurs.assignAll(await _interRepo.diffuseursByClientMin(id));
      if (diffuseurs.isEmpty) {
        ElegantSnackbarService.showError(
          title: 'Client',
          message: 'Aucun diffuseur pour ce client.',
        );
      }
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Chargement diffuseurs: $e',
      );
    }
  }

  bool _hasBlockingErrors() {
    // Evaluate live errors
    // quantity optional -> only block when a non-empty invalid value
    if (qtyError.value != null) return true;

    // nbBouteilles required
    if (nbError.value != null) return true;

    return false;
  }

  Future<bool> submit() async {
    // Minimal required choices
    final clientId = selectedClientId.value;
    final cdId = selectedDiffuseurId.value; // clientDiffuseurId

    if (clientId == null) {
      ElegantSnackbarService.showError(
        title: 'Champs manquants',
        message: 'Client obligatoire.',
      );
      return false;
    }
    if (cdId == null) {
      ElegantSnackbarService.showError(
        title: 'Champs manquants',
        message: 'Diffuseur obligatoire.',
      );
      return false;
    }

    // Re-check inline constraints (blocks submit)
    if (_hasBlockingErrors()) {
      ElegantSnackbarService.showError(
        title: 'Formulaire',
        message: 'Corrige les erreurs surlignées.',
      );
      return false;
    }

    // Read parsed values
    final q = quantiteCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(quantiteCtrl.text.trim());

    final nbText = nbrBouteillesCtrl.text.trim();
    final nb =
        int.tryParse(nbText) ??
        1; // default 1 already guarded by inline validation

    final typeTete = typeTeteCtrl.text.trim().isEmpty
        ? null
        : typeTeteCtrl.text.trim();

    final parfId = selectedParfumId.value; // optional (nullable)

    isSubmitting.value = true;
    try {
      final created = await _cmdRepo.createManuelle(
        clientDiffuseurId: cdId,
        quantiteMl: q,
        parfumId: parfId,
        force: forceCreation.value,
        nbrBouteilles: nb,
        typeTete: typeTete,
      );

      createdId.value = created.id;
      return true;
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Création échouée: $e',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
