import 'package:flutter/widgets.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/data/models/client.dart';
import 'package:front_erp_aromair/data/repositories/admin/client_repository.dart';

class ClientController extends GetxController {
  final ClientRepository _repo;
  ClientController(this._repo);

  // ------------------------
  // State
  // ------------------------
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  final TextEditingController searchCtrl = TextEditingController();
  final RxString activeFilter = 'ALL'.obs; // 'ALL' | 'ACTIVE' | 'INACTIVE'
  String? type; // 'ACHAT' | 'CONVENTION' | 'MAD' | null

  /// Source list from backend
  final RxList<ClientRow> items = <ClientRow>[].obs;

  /// Derived list used by the UI
  List<ClientRow> get filteredItems => _applyFilters();

  // ------------------------
  // Search debouncing
  // ------------------------
  final RxString _searchQuery = ''.obs;
  Worker? _searchDebouncer;

  @override
  void onInit() {
    super.onInit();

    // Setup search debouncing
    _searchDebouncer = debounce<String>(
      _searchQuery,
      (query) => _fetchWithFilters(),
      time: const Duration(milliseconds: 500),
    );

    // Listen to search controller changes
    searchCtrl.addListener(() {
      _searchQuery.value = searchCtrl.text.trim();
    });

    fetch();
  }

  final RxSet<int> _toggling = <int>{}.obs;

  bool isToggling(int id) => _toggling.contains(id);

  Future<void> onToggleActive(ClientRow client) async {
    if (_toggling.contains(client.id)) return;

    _toggling.add(client.id);
    update();

    try {
      final newActive = await _repo.toggleActive(client.id);

      final idx = items.indexWhere((e) => e.id == client.id);
      if (idx != -1) {
        items[idx] = items[idx].copyWith(estActive: newActive);
      }

      update();
    } catch (e) {
      error.value = e.toString();
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Impossible de changer le statut du client.',
      );
    } finally {
      _toggling.remove(client.id);
      update();
    }
  }

  // ------------------------
  // Fetch with filters (USES WEB SERVICE)
  // ------------------------
  Future<void> _fetchWithFilters() async {
    try {
      isLoading.value = true;
      error.value = null;

      // Convert type filter to backend format
      String? backendType;
      if (type != null) {
        switch (type!.toUpperCase()) {
          case 'ACHAT':
            backendType = 'ACHAT';
            break;
          case 'CONVENTION':
            backendType = 'CONVENTION';
            break;
          case 'MAD':
            backendType = 'MAD';
            break;
        }
      }

      // Call web service with search query and type
      final data = await _repo.getClients(
        q: _searchQuery.value.isEmpty ? null : _searchQuery.value,
        type: backendType,
      );

      items.assignAll(data);
    } catch (e) {
      final msg = e.toString();
      error.value = msg;
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Chargement des clients échoué: $msg',
      );
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ------------------------
  // Local filters only (for active status)
  // ------------------------
  List<ClientRow> _applyFilters() {
    return items.where((c) {
      // Filter by active status only (search and type are handled by web service)
      final okActive = switch (activeFilter.value) {
        'ACTIVE' => c.estActive == true,
        'INACTIVE' => c.estActive == false,
        _ => true, // ALL
      };

      return okActive;
    }).toList();
  }

  // Example: called by AromaScaffold.onRefresh
  Future<void> fetch() async {
    // Reset search and fetch all
    searchCtrl.clear();
    _searchQuery.value = '';
    await _fetchWithFilters();
  }

  // UI helpers
  void setActiveFilter(String v) {
    activeFilter.value = v;
    update();
  }

  void setType(String? v) {
    type = v;
    _fetchWithFilters();
  }

  @override
  void onClose() {
    _searchDebouncer?.dispose();
    searchCtrl.dispose();
    super.onClose();
  }
}
