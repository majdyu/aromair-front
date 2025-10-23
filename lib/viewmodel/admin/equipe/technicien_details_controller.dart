import 'package:flutter/material.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import 'package:front_erp_aromair/data/models/technicien.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';

import 'package:front_erp_aromair/data/repositories/admin/equipe_repository.dart';
import 'package:front_erp_aromair/data/services/equipe_service.dart';

import 'package:front_erp_aromair/data/models/caisse_sav_detail.dart';
import 'package:front_erp_aromair/data/models/recette_clients_detail.dart';
import 'package:front_erp_aromair/data/services/caisse_service.dart';
import 'package:front_erp_aromair/data/services/recette_service.dart';

class TechnicienConsultationController extends GetxController {
  // ====== Repos / Services ======
  late final Dio _dio = buildDio();
  late final EquipesRepository _repo = EquipesRepository(EquipesService(_dio));
  late final CaisseService _caisseService = CaisseService(_dio);
  late final RecetteService _recetteService = RecetteService(_dio);

  // ====== Primary data (technicien résumé) ======
  final data = Rx<TechnicienConsultation?>(null);
  final isLoading = false.obs;

  // ====== Detail (expanded) states ======
  final recetteExpanded = false.obs;
  final caisseExpanded = false.obs;

  final loadingRecette = false.obs;
  final loadingCaisse = false.obs;

  final recetteDetail = Rxn<RecetteClientsDetail>();
  final caisseDetail = Rxn<CaisseSavDetail>();

  CancelToken? _cancelRecette;
  CancelToken? _cancelCaisse;

  // ====== Routing & period ======
  int? _technicienId;
  DateTime _du = _firstDayOfThisMonth();
  DateTime _jusqua = DateTime.now();

  String get periodeLabel => '${_fmtDate(_du)}  →  ${_fmtDate(_jusqua)}';
  DateTime get periodStart => _du;
  DateTime get periodEnd => _jusqua;

  @override
  void onInit() {
    super.onInit();
    _loadFromArgsAndFetch();
  }

  void _loadFromArgsAndFetch() async {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['technicienId'] != null) {
      _technicienId = (args['technicienId'] as num).toInt();
      await fetch();
    } else {
      Get.snackbar('Erreur', 'Identifiant du technicien manquant.');
    }
  }

  Future<void> fetch() async {
    final id = _technicienId;
    if (id == null) return;
    try {
      isLoading.value = true;
      update();
      final res = await _repo.consulterTechnicien(id, du: _du, jusqua: _jusqua);
      data.value = res;
    } catch (e) {
      Get.snackbar('Erreur', '$e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> refreshFromServer() async {
    await fetch();
    // If expanded, refresh the panels too
    if (recetteExpanded.value) await _fetchRecette();
    if (caisseExpanded.value) await _fetchCaisse();
  }

  // ====== Period picking (date range) ======
  Future<void> pickPeriode(BuildContext context) async {
    final initial = DateTimeRange(start: _du, end: _jusqua);
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: initial,
      firstDate: DateTime(now.year - 5, 1, 1),
      lastDate: now,
      helpText: 'Sélectionnez la période',
      saveText: 'Appliquer',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (range != null) {
      _du = DateTime(range.start.year, range.start.month, range.start.day);
      _jusqua = DateTime(range.end.year, range.end.month, range.end.day);
      await fetch();
      // Also refresh expanded panels with new period
      if (recetteExpanded.value) await _fetchRecette();
      if (caisseExpanded.value) await _fetchCaisse();
    }
  }

  // ====== Expand handlers ======
  Future<void> toggleRecetteExpanded() async {
    recetteExpanded.toggle();
    if (recetteExpanded.value) {
      await _fetchRecette();
    }
  }

  Future<void> toggleCaisseExpanded() async {
    caisseExpanded.toggle();
    if (caisseExpanded.value) {
      await _fetchCaisse();
    }
  }

  // ====== Loads for details (by date range) ======
  Future<void> _fetchRecette() async {
    final id = _technicienId;
    if (id == null) return;
    _cancelRecette?.cancel('new request');
    _cancelRecette = CancelToken();

    loadingRecette.value = true;
    try {
      final d = await _recetteService.getDetail(
        userId: id,
        du: _du,
        jusqua: _jusqua,
        cancelToken: _cancelRecette,
      );
      recetteDetail.value = d;
    } catch (e) {
      Get.snackbar('Erreur', 'Chargement recette: $e');
    } finally {
      loadingRecette.value = false;
    }
  }

  Future<void> _fetchCaisse() async {
    final id = _technicienId;
    if (id == null) return;
    _cancelCaisse?.cancel('new request');
    _cancelCaisse = CancelToken();

    loadingCaisse.value = true;
    try {
      final d = await _caisseService.getDetail(
        userId: id,
        du: _du,
        jusqua: _jusqua,
        cancelToken: _cancelCaisse,
      );
      caisseDetail.value = d;
    } catch (e) {
      Get.snackbar('Erreur', 'Chargement caisse: $e');
    } finally {
      loadingCaisse.value = false;
    }
  }

  // ===== Helpers =====
  static DateTime _firstDayOfThisMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static String _two(int v) => v < 10 ? '0$v' : '$v';
  static String _fmtDate(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';

  String get duIso => _fmtDate(_du); // e.g. 2025-09-10
  String get jusquaIso => _fmtDate(_jusqua);
  void openRecetteDetails() {
    final id = _technicienId;
    if (id == null) return;
    Get.toNamed(
      AppRoutes.recetteTechnicien,
      arguments: {'technicienId': id, 'du': duIso, 'jusqua': jusquaIso},
    );
  }

  void openCaisseDetails() {
    final id = _technicienId;
    if (id == null) return;
    Get.toNamed(
      AppRoutes.caisseTechnicien,
      arguments: {'technicienId': id, 'du': duIso, 'jusqua': jusquaIso},
    );
  }
}
