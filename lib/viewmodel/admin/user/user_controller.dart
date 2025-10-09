import 'package:front_erp_aromair/data/repositories/admin/user_repository.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/user.dart';
import 'package:front_erp_aromair/data/services/user_service.dart';

class UserController extends GetxController {
  late final UserRepository _repo = UserRepository(UserService(buildDio()));

  final RxBool loading = false.obs;
  final RxString error = ''.obs;
  final RxList<UserItem> users = <UserItem>[].obs;

  Future<void> fetch() async {
    loading.value = true;
    error.value = '';
    try {
      final data = await _repo.list();
      users.assignAll(data);
    } catch (e) {
      final msg = e.toString();
      error.value = msg;
      ElegantSnackbarService.showError(
        title: 'Erreur',
        message: 'Chargement des utilisateurs échoué: $msg',
      );
    } finally {
      loading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
