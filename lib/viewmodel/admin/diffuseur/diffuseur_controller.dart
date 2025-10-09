import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/diffuseur.dart';
import 'package:front_erp_aromair/data/repositories/admin/diffuseur_repository.dart';
import 'package:front_erp_aromair/data/services/diffuseur_service.dart';

class DiffuseurController extends GetxController {
  late final DiffuseurRepository _repo = DiffuseurRepository(
    DiffuseurService(buildDio()),
  );

  final RxBool _loading = false.obs;
  bool get loading => _loading.value;

  final RxString erreurMessage = ''.obs;

  final RxList<Diffuseur> _all = <Diffuseur>[].obs;
  List<Diffuseur> get all => _all;

  final TextEditingController searchCtrl = TextEditingController();
  final RxString search = ''.obs;

  List<Diffuseur> get filtered {
    final q = search.value.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all
        .where((d) {
          final m = d.modele.toLowerCase();
          final t = d.typCarte.toLowerCase();
          final ds = d.designation.toLowerCase();
          final c = d.consommation.toString().toLowerCase();
          return m.contains(q) ||
              t.contains(q) ||
              ds.contains(q) ||
              c.contains(q);
        })
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    searchCtrl.addListener(() => search.value = searchCtrl.text);
    fetch();
  }

  Future<void> fetch() async {
    _loading.value = true;
    try {
      final data = await _repo.list();
      _all.assignAll(data);
      erreurMessage.value = '';
    } catch (e) {
      erreurMessage.value = 'Erreur: $e';
      // Optional: surface a toast if you want
      ElegantSnackbarService.showError(
        message: 'Erreur lors du chargement: $e',
      );
      rethrow;
    } finally {
      _loading.value = false;
    }
  }

  Future<void> deleteDiffuseur(int id) async {
    try {
      await _repo.delete(id);
      // remove locally
      _all.removeWhere((d) => d.id == id);
      ElegantSnackbarService.showSuccess(
        message: 'Diffuseur supprimé avec succès',
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = (data is Map) ? data['code'] as String? : null;
      final serverMsg = (data is Map) ? data['error']?.toString() : null;

      if (e.response?.statusCode == 404 || code == 'NOT_FOUND') {
        ElegantSnackbarService.showError(
          title: 'Introuvable',
          message: 'Diffuseur (id $id) introuvable.',
        );
      } else if (e.response?.statusCode == 409 || code == 'DIFFUSEUR_LINKED') {
        ElegantSnackbarService.showError(
          title: 'Conflit',
          message:
              serverMsg ??
              'Suppression impossible : le diffuseur est relié à des clients diffuseurs.',
        );
      } else {
        ElegantSnackbarService.showError(
          message: serverMsg ?? 'Erreur lors de la suppression',
        );
      }
    } catch (e) {
      ElegantSnackbarService.showError(message: '$e');
    }
  }

  // allow other controllers to push freshly created items
  void prepend(Diffuseur d) => _all.insert(0, d);

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}
