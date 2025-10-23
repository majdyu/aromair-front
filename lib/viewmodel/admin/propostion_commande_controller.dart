import 'package:front_erp_aromair/data/enums/status_commandes.dart';
import 'package:front_erp_aromair/data/models/commande_potentielle.dart';
import 'package:front_erp_aromair/data/repositories/admin/proposition_commande_repository.dart';
import 'package:get/get.dart';

class PropostionCommandeController extends GetxController {
  final CommandesPotentiellesRepository repo;

  PropostionCommandeController({required this.repo});

  // State
  final items = <CommandePotentielleRow>[].obs;
  final loading = false.obs;
  final error = RxnString();

  // Optional status filter (null -> no filter)
  final selectedStatus = Rxn<StatusCommande>();

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    loading.value = true;
    error.value = null;
    try {
      final data = await repo.fetch(status: selectedStatus.value);
      items.assignAll(data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void setStatus(StatusCommande? s) {
    selectedStatus.value = s;
    fetch();
  }
}
