import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/client.dart';
import 'package:front_erp_aromair/data/repositories/admin/client_repository.dart';
import 'package:front_erp_aromair/data/repositories/admin/reclamation_repository.dart';
import 'package:front_erp_aromair/data/services/client_service.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/data/models/reclamtion.dart';
import 'package:front_erp_aromair/data/services/reclamation_service.dart';
import 'package:front_erp_aromair/data/models/create_reclamation_request.dart';

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
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Chargement des réclamations échoué: $e',
      );
    } finally {
      isLoading.value = false;
      update();
    }
  }

  final RxList<ClientRow> clientOptions = <ClientRow>[].obs;
  final RxBool isLoadingClients = false.obs;

  Future<void> loadClientsForPicker({String query = ''}) async {
    isLoadingClients.value = true;
    try {
      final repo = ClientRepository(ClientService());
      final results = await repo
          .getClients(); // adapter si signature différente
      clientOptions.assignAll(results);
    } catch (e) {
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Chargement des clients impossible: $e',
      );
    } finally {
      isLoadingClients.value = false;
    }
  }

  // Créer une réclamation
  Future<bool> createReclamation(String probleme, int clientId) async {
    if (probleme.trim().isEmpty || clientId == 0) {
      ElegantSnackbarService.showError(
        title: 'Champs manquants',
        message: 'Sélectionnez un client et décrivez le problème.',
      );
      return false;
    }

    try {
      final body = CreateReclamationRequest(
        clientId: clientId,
        probleme: probleme.trim(),
      );
      await _repo.create(body);
      ElegantSnackbarService.showSuccess(
        message: 'Réclamation créée avec succès',
      );
      // Facultatif: refresh la liste
      await fetch();
      return true;
    } catch (e) {
      error.value = e.toString();
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Création échouée: $e',
      );
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
