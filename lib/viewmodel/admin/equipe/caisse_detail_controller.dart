import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/services/caisse_service.dart';
import 'package:front_erp_aromair/data/models/caisse_sav_detail.dart';

class CaisseDetailController extends GetxController {
  late final Dio _dio = buildDio();
  late final CaisseService _service = CaisseService(_dio);

  final detail = Rxn<CaisseSavDetail>();
  final isLoading = false.obs;

  int? technicienId;
  DateTime du = DateTime.now().subtract(const Duration(days: 30));
  DateTime jusqua = DateTime.now();

  String get periodeLabel => '${_fmtDate(du)}  →  ${_fmtDate(jusqua)}';

  CancelToken? _cancel;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;

    technicienId = (args?['technicienId'] as num?)?.toInt();
    final duStr = args?['du'] as String?;
    final jsStr = args?['jusqua'] as String?;
    if (duStr != null) du = DateTime.parse(duStr);
    if (jsStr != null) jusqua = DateTime.parse(jsStr);

    fetch();
  }

  Future<void> fetch() async {
    final id = technicienId;
    if (id == null) {
      Get.snackbar('Erreur', 'technicienId manquant');
      return;
    }
    _cancel?.cancel('new request');
    _cancel = CancelToken();
    isLoading.value = true;
    try {
      final d = await _service.getDetail(
        userId: id,
        du: du,
        jusqua: jusqua,
        cancelToken: _cancel,
      );
      detail.value = d;
    } catch (e) {
      Get.snackbar('Erreur', 'Chargement caisse: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickPeriode(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: du, end: jusqua),
      firstDate: DateTime(DateTime.now().year - 5, 1, 1),
      lastDate: DateTime.now(),
      helpText: 'Sélectionnez la période',
      saveText: 'Appliquer',
    );
    if (range != null) {
      du = DateTime(range.start.year, range.start.month, range.start.day);
      jusqua = DateTime(range.end.year, range.end.month, range.end.day);
      await fetch();
    }
  }

  Future<void> refreshFromServer() => fetch();

  static String _two(int v) => v < 10 ? '0$v' : '$v';
  static String _fmtDate(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';
}
