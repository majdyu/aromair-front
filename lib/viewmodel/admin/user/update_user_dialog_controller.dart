import 'package:flutter/material.dart'; // for GlobalKey<FormState>
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/services/user_service.dart';
import 'package:front_erp_aromair/data/repositories/admin/user_repository.dart';
import 'package:front_erp_aromair/data/models/user.dart';
import 'package:front_erp_aromair/data/enums/role.dart';

class UpdateUserDialogController extends GetxController {
  // Expose a FormKey so the Form in the view can use it (validators run from here)
  final formKey = GlobalKey<FormState>();

  // Data access
  final UserRepository repo = UserRepository(UserService(buildDio()));

  // State
  final isSaving = false.obs;
  final error = RxnString();

  int? _userId;
  UserRole? selectedRole;

  void init(UserItem? user) {
    _userId = user?.id;
    selectedRole = user?.role;
  }

  // ---- Validators (used by the view, but logic owned here) ----
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    return null;
  }

  String? validateRole(UserRole? role) {
    if (role == null) return 'Le rôle est obligatoire';
    return null;
  }

  // ---- Public entry from the UI button (runs form validators + submit) ----
  Future<bool> save({
    required String name,
    required String? password,
    required UserRole? role,
  }) async {
    // Trigger the Form's validators
    final ok = formKey.currentState?.validate() ?? false;
    if (!ok) return false;

    // Extra role check (dropdown has no built-in validator in the view)
    final roleErr = validateRole(role);
    if (roleErr != null) {
      ElegantSnackbarService.showError(title: 'Validation', message: roleErr);
      return false;
    }

    return submit(name: name, role: role!, password: password);
  }

  // ---- Actual submit (create/update) ----
  Future<bool> submit({
    required String name,
    required UserRole role,
    String? password,
  }) async {
    try {
      isSaving.value = true;
      error.value = null;

      // Build exact body shape is handled in repository (nom/role/password)
      if (_userId == null) {
        await repo.createUser(
          nom: name.trim(),
          role: role,
          password: password?.trim(),
        );
        ElegantSnackbarService.showSuccess(
          message: 'Utilisateur créé avec succès',
        );
      } else {
        await repo.updateUser(
          id: _userId!,
          nom: name.trim(),
          role: role,
          password: password?.trim(),
        );
        ElegantSnackbarService.showSuccess(
          message: 'Utilisateur mis à jour avec succès',
        );
      }

      return true;
    } catch (e) {
      final msg = "Échec de l'opération: $e";
      error.value = msg;
      ElegantSnackbarService.showError(title: 'Erreur', message: msg);
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
