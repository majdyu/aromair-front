import 'package:get/get.dart';
import 'package:front_erp_aromair/data/models/intervention_detail.dart';
import 'package:front_erp_aromair/data/repositories/admin/interventions_repository.dart';
import 'package:front_erp_aromair/data/services/interventions_service.dart';

class InterventionDetailController extends GetxController {
  final InterventionsRepository repo = InterventionsRepository(InterventionsService());
  final int interventionId;
  InterventionDetailController(this.interventionId);

  final isLoading = false.obs;
  final error = RxnString();
  final detail = Rxn<InterventionDetail>();

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true; error.value = null;
    try { detail.value = await repo.detail(interventionId); }
    catch (e) { error.value = e.toString(); }
    finally { isLoading.value = false; }
  }
}
