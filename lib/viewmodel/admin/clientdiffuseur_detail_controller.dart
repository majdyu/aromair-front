import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/affecter_client_diffuseur_request.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:front_erp_aromair/data/models/clientdiffuseur_detail.dart';
import 'package:front_erp_aromair/data/services/clientdiffuseur_service.dart';
import 'package:front_erp_aromair/data/repositories/admin/clientdiffuseur_repository.dart';

class ClientDiffuseurDetailController extends GetxController {
  final int clientDiffuseurId;
  ClientDiffuseurDetailController(this.clientDiffuseurId);

  final isLoading = true.obs;
  final error = RxnString();
  final dto = Rxn<ClientDiffuseurDetail>();

  late final IClientDiffuseurRepository _repo;

  @override
  void onInit() {
    super.onInit();
    final dio = Get.isRegistered<Dio>() ? Get.find<Dio>() : Get.put<Dio>(buildDio(), permanent: true);
    if (!Get.isRegistered<ClientDiffuseurService>()) {
      Get.put<ClientDiffuseurService>(ClientDiffuseurService(dio), permanent: true);
    }
    if (!Get.isRegistered<IClientDiffuseurRepository>()) {
      Get.put<IClientDiffuseurRepository>(
        ClientDiffuseurRepository(Get.find<ClientDiffuseurService>()),
        permanent: true,
      );
    }
    _repo = Get.find<IClientDiffuseurRepository>();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;
    try {
      dto.value = await _repo.getDetail(clientDiffuseurId);
    } on DioException catch (e) {
      error.value = 'HTTP ${e.response?.statusCode ?? '-'}: ${e.message}';
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
