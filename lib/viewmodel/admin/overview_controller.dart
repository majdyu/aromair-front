import 'package:get/get.dart';
import 'package:front_erp_aromair/data/repositories/admin/overview_repository.dart';
import 'package:front_erp_aromair/data/services/overview_service.dart';

class OverviewController extends GetxController {
  final OverviewRepository repository = OverviewRepository(OverviewService());

  var isLoading = false.obs;
  var error = RxnString();
  var data = <int>[].obs; // 8 entiers

  // indices lisibles
  static const iRendementSav = 0;
  static const iSatisfaction = 1;
  static const iNbDiffuseurs = 2;
  static const iNbTechniciens = 3;
  static const iNbIntervJour = 4;
  static const iClientsAchat = 5;
  static const iClientsConvention = 6;
  static const iClientsMAD = 7;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    print("[OverviewController] fetch()");
    isLoading.value = true;
    error.value = null;
    try {
      final res = await repository.getOverview();
      data.assignAll(res);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
