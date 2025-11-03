import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/enums/status_commandes.dart';
import 'package:front_erp_aromair/data/models/commande_potentielle.dart';
import 'package:front_erp_aromair/data/models/parfum.dart';
import 'package:front_erp_aromair/data/repositories/admin/parfum_repository.dart';
import 'package:front_erp_aromair/data/repositories/admin/proposition_commande_repository.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';

class PropostionCommandeController extends GetxController {
  final CommandesPotentiellesRepository repo;
  final ParfumRepository parfumRepo;

  PropostionCommandeController({required this.repo, required this.parfumRepo});

  // ──────────────────────────────────────────────────────────────
  // State
  // ──────────────────────────────────────────────────────────────
  final items = <CommandePotentielleRow>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final selectedStatus = Rxn<StatusCommande>();
  final toggleLoading = <int, bool>{}.obs;
  final validateLoading = <int, bool>{}.obs;
  final updateLoading = <int, bool>{}.obs; // For partial updates

  final parfums = <Parfum>[].obs;
  final parfumLoading = false.obs;
  final parfumError = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetch();
    fetchParfums();
  }

  // ──────────────────────────────────────────────────────────────
  // Fetch data
  // ──────────────────────────────────────────────────────────────
  Future<void> fetch() async {
    loading.value = true;
    error.value = null;
    try {
      final data = await repo.fetch(status: selectedStatus.value);
      items.assignAll(data);
    } catch (e) {
      error.value = e.toString();
      ElegantSnackbarService.showError(message: e.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchParfums() async {
    parfumLoading.value = true;
    parfumError.value = null;
    try {
      final data = await parfumRepo.fetch();
      parfums.assignAll(data);
    } catch (e) {
      parfumError.value = e.toString();
      ElegantSnackbarService.showError(message: 'Erreur parfums: $e');
    } finally {
      parfumLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Toggle bottle state
  // ──────────────────────────────────────────────────────────────
  Future<void> updateBouteilleEtat(int commandeId, bool wantVide) async {
    final current = items.firstWhereOrNull((e) => e.id == commandeId);
    if (current == null || current.bouteilleVide == wantVide) return;

    toggleLoading[commandeId] = true;
    try {
      await repo.toggleEtatBouteille(commandeId);
      await fetch();
    } catch (e) {
      ElegantSnackbarService.showError(message: 'État bouteille: $e');
    } finally {
      toggleLoading.remove(commandeId);
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Validate order
  // ──────────────────────────────────────────────────────────────
  Future<bool> showConfirmDialog() async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Confirmer la validation',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: const Text(
              'Êtes-vous sûr de vouloir valider cette commande ? '
              'Cette action est irréversible.',
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.back(result: true),
                child: const Text(
                  'Confirmer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;
  }

  Future<void> validateCommande(int commandeId, int? interventionid) async {
    final confirmed = await showConfirmDialog();
    if (!confirmed) return;

    validateLoading[commandeId] = true;
    try {
      await repo.validateCommande(commandeId, interventionid);
      await fetch();
      ElegantSnackbarService.showSuccess(
        message: 'Commande validée avec succès',
      );
    } catch (e) {
      ElegantSnackbarService.showError(message: e.toString());
    } finally {
      validateLoading.remove(commandeId);
    }
  }

  Future<bool> updateField(
    int commandeId, {
    int? parfumId,
    int? quantite,
    int? nbrBouteilles,
    String? typeTete,
    DateTime? datePlanification,
  }) async {
    final item = items.firstWhereOrNull((e) => e.id == commandeId);
    if (item == null) return false;

    final oldItem = item.copyWith();
    final newItem = item.copyWith(
      parfumId: parfumId ?? item.parfumId,
      nbrBouteilles: nbrBouteilles ?? item.nbrBouteilles,
      quantite: quantite ?? item.quantite,
      typeTete: typeTete ?? item.typeTete,
      datePlanification: datePlanification ?? item.datePlanification,
    );

    final index = items.indexOf(item);
    items[index] = newItem;
    updateLoading[commandeId] = true;

    try {
      final updated = await repo.updatePartiellement(
        commandeId,
        parfumId: parfumId,
        quantite: quantite,
        nbrBouteilles: nbrBouteilles,
        typeTete: typeTete,
        datePlanification: datePlanification,
      );
      items[index] = updated;
      return true; // ✅ on laisse le UI décider
    } catch (e) {
      items[index] = oldItem; // rollback
      return false; // ❌ le UI montrera l'erreur
    } finally {
      updateLoading.remove(commandeId);
    }
  }

  // ──────────────────────────────────────────────────────────────
  // UI Helpers: Edit dialogs
  // ──────────────────────────────────────────────────────────────
  void showEditQuantiteDialog(int commandeId, int current) {
    final controller = TextEditingController(text: current.toString());
    Get.dialog(
      AlertDialog(
        title: const Text('Quantité'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Entrez la quantité'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                updateField(commandeId, quantite: val);
                Get.back();
              } else {
                ElegantSnackbarService.showError(message: 'Quantité invalide');
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showEditParfumDialog(int commandeId, int currentParfumId) {
    final selected = parfums.firstWhereOrNull((p) => p.id == currentParfumId);
    Get.dialog(
      AlertDialog(
        title: const Text('Choisir un parfum'),
        content: Obx(() {
          if (parfumLoading.value) return const CircularProgressIndicator();
          if (parfums.isEmpty) return const Text('Aucun parfum');
          return DropdownButton<int>(
            isExpanded: true,
            value: selected?.id,
            items: parfums
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nom)))
                .toList(),
            onChanged: (id) {
              if (id != null) {
                updateField(commandeId, parfumId: id);
                Get.back();
              }
            },
          );
        }),
      ),
    );
  }

  void showEditDateDialog(int commandeId, DateTime current) {
    Get.dialog(
      AlertDialog(
        title: const Text('Date de planification'),
        content: ElevatedButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: current,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              final time = await showTimePicker(
                context: Get.context!,
                initialTime: TimeOfDay.fromDateTime(current),
              );
              if (time != null) {
                final finalDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
                updateField(commandeId, datePlanification: finalDate);
                Get.back();
              }
            }
          },
          child: Text(current.toString().substring(0, 16).replaceAll('T', ' ')),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
        ],
      ),
    );
  }

  void setStatus(StatusCommande? s) {
    selectedStatus.value = s;
    fetch();
  }
}
