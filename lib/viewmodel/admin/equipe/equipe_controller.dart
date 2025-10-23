import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/equipe.dart';
import 'package:front_erp_aromair/data/repositories/admin/equipe_repository.dart';
import 'package:front_erp_aromair/data/services/equipe_service.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';

class EquipeController extends GetxController {
  late final EquipesRepository _repo = EquipesRepository(
    EquipesService(buildDio()),
  );

  final RxBool _loading = false.obs;
  bool get loading => _loading.value;

  final RxString erreurMessage = ''.obs;

  final RxList<Equipe> _all = <Equipe>[].obs;
  List<Equipe> get all => _all;

  final TextEditingController searchCtrl = TextEditingController();
  final RxString search = ''.obs;

  List<Equipe> get filtered {
    final q = search.value.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all
        .where((d) {
          final m = d.nom.toLowerCase();
          final t = d.chefNom!.toLowerCase();
          final ds = d.description!.toLowerCase();

          return m.contains(q) || t.contains(q) || ds.contains(q);
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
      ElegantSnackbarService.showError(
        message: 'Erreur lors du chargement: $e',
      );
    } finally {
      _loading.value = false;
    }
  }
}
