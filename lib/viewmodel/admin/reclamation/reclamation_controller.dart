import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/client.dart';
import 'package:front_erp_aromair/data/repositories/admin/client_repository.dart';
import 'package:front_erp_aromair/data/repositories/admin/reclamation_repository.dart';
import 'package:front_erp_aromair/data/services/client_service.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/data/models/reclamtion.dart';
import 'package:front_erp_aromair/data/services/reclamation_service.dart';

class ReclamationController extends GetxController {
  final IReclamationRepository _repo;

  ReclamationController([IReclamationRepository? repo])
    : _repo = repo ?? ReclamationRepository(ReclamationService(buildDio()));

  // Remote rows (raw data)
  final RxList<ReclamationRow> _rows = <ReclamationRow>[].obs;

  // Public, filtered view
  List<ReclamationRow> get rowsFiltered => _applyTextFilter(_rows);

  // Loading / error
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  // Filters
  final du = Rxn<DateTime>();
  final jusqua = Rxn<DateTime>();

  // Text search
  final TextEditingController searchCtrl = TextEditingController();
  final RxString _search = ''.obs;
  Timer? _debounce;
  Duration debounceDuration = const Duration(milliseconds: 350);

  // Networking
  final CancelToken _cancelToken = CancelToken();

  @override
  void onInit() {
    super.onInit();
    // Bind search controller changes with debounce
    searchCtrl.addListener(() {
      final v = searchCtrl.text.trim();
      _onSearchChanged(v);
    });
    fetch(); // initial fetch (no date filter)
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, () {
      _search.value = v.toLowerCase();
      // No new network call – local filtering only
      update(); // for GetBuilder rebuilds
    });
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;
    try {
      final list = await _repo.fetchByDate(
        du: du.value,
        jusqua: jusqua.value,
        cancelToken: _cancelToken,
      );
      _rows.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  final RxList<ClientRow> clientOptions = <ClientRow>[].obs;
  final RxBool isLoadingClients = false.obs;

  Future<void> loadClientsForPicker({String query = ''}) async {
    final repo = ClientRepository(ClientService());
    // Adjust this line to your repo signature:
    final results = await repo.getClients();
    clientOptions.assignAll(results);
  }

  // Add this method for creating reclamation
  Future<bool> createReclamation(String probleme, int clientId) async {
    try {
      // await _repo.createReclamation(probleme, clientId);
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  void setDateRange(DateTime? from, DateTime? to) {
    du.value = from;
    jusqua.value = to;
    fetch();
  }

  void clearDateRange() {
    du.value = null;
    jusqua.value = null;
    fetch();
  }

  void clearSearch() {
    searchCtrl.clear();
    _search.value = '';
    update();
  }

  bool _matchesText(ReclamationRow r, String q) {
    if (q.isEmpty) return true;
    final cible = StringBuffer()
      ..write(r.clientNom ?? '')
      ..write(' ')
      ..write(r.probleme)
      ..write(' ')
      ..write(r.decisionPrise ?? ' ')
      ..write(' ')
      ..write(r.derniereEquipeNom ?? ' ')
      ..write(' ')
      ..writeAll(r.techniciens, ' ');
    return cible.toString().toLowerCase().contains(q);
  }

  List<ReclamationRow> _applyTextFilter(List<ReclamationRow> input) {
    final q = _search.value;
    if (q.isEmpty) return input;
    return input.where((r) => _matchesText(r, q)).toList(growable: false);
  }

  String get dateRangeLabel {
    final d = du.value, j = jusqua.value;
    if (d == null && j == null) return 'Toute période';
    if (d != null && j == null) return 'Depuis ${_fmt(d)}';
    if (d == null && j != null) return 'Jusqu\'au ${_fmt(j)}';
    return '${_fmt(d!)} → ${_fmt(j!)}';
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  void onClose() {
    _debounce?.cancel();
    searchCtrl.dispose();
    _cancelToken.cancel('controller disposed');
    super.onClose();
  }
}
