import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/alert.dart';
import 'package:front_erp_aromair/data/repositories/admin/alertes_repository.dart';
import 'package:front_erp_aromair/data/services/alertes_service.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum AlerteStatutFilter { all, resolved, unresolved }

class AlertesController extends GetxController {
  late final AlertesRepository _repo = AlertesRepository(
    AlertesService(buildDio()),
  );
  // state
  final RxBool _loading = false.obs;
  bool get loading => _loading.value;

  final RxList<IncidentItem> _all = <IncidentItem>[].obs;

  final TextEditingController searchCtrl = TextEditingController();
  final Rx<AlerteStatutFilter> statutFilter = AlerteStatutFilter.all.obs;
  final Rxn<DateTimeRange> dateRange = Rxn<DateTimeRange>();
  final _fmt = DateFormat('dd/MM/yyyy');

  List<IncidentItem> get items {
    final q = searchCtrl.text.trim().toLowerCase();
    final f = statutFilter.value;
    final r = dateRange.value;

    return _all
        .where((a) {
          final txt = [
            a.clientNom,
            a.diffuseurDesignation,
            a.probleme,
            a.cause,
          ].whereType<String>().join(' ').toLowerCase();

          if (q.isNotEmpty && !txt.contains(q)) return false;

          if (f == AlerteStatutFilter.resolved && a.etatResolution != true)
            return false;
          if (f == AlerteStatutFilter.unresolved && a.etatResolution == true)
            return false;

          if (r != null) {
            final d = a.date;
            final start = DateTime(r.start.year, r.start.month, r.start.day);
            final end = DateTime(
              r.end.year,
              r.end.month,
              r.end.day,
              23,
              59,
              59,
            );
            if (d.isBefore(start) || d.isAfter(end)) return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  Future<void> fetch() async {
    _loading.value = true;
    update();
    try {
      final list = await _repo.list();
      _all.assignAll(list);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      _loading.value = false;
      update();
    }
  }

  void clearFilters() {
    searchCtrl.clear();
    statutFilter.value = AlerteStatutFilter.all;
    dateRange.value = null;
    update();
  }

  Future<void> pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final initial =
        dateRange.value ??
        DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial,
      helpText: 'Sélectionner une plage de dates',
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      dateRange.value = picked;
      update();
    }
  }

  String fmtDate(DateTime d) => _fmt.format(d);

  Future<void> toggleResolution(IncidentItem a) async {
    String? note;
    if (a.etatResolution != true) {
      final ctrl = TextEditingController();
      final ok = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Marquer comme résolue'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Décision prise (optionnel)',
              hintText: 'Ex: Réglage intensité / Changement bouteille…',
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Valider'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      note = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
    }

    try {
      _loading.value = true;
      update();
      await _repo.toggle(a.id, decisionPrise: note);
      await fetch();
      Get.snackbar(
        'Succès',
        'État mis à jour',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      _loading.value = false;
      update();
    }
  }

  void openDetail(IncidentItem a) {
    Get.toNamed(AppRoutes.alerteDetail, arguments: {'alerteId': a.id});
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}
