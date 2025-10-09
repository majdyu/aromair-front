import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:get/get.dart';
import '../../data/models/authentication_request.dart';
import '../../data/repositories/auth_repository.dart';
import '../../utils/storage_helper.dart';
import '../../utils/jwt_helper.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthRepository repository;
  LoginController(this.repository);

  var isLoading = false.obs;
  var firstname = ''.obs;
  var password = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> login() async {
    print("[LoginController] Login started for user: ${firstname.value}");
    try {
      isLoading.value = true;
      final response = await repository.authenticate(
        AuthenticationRequest(
          firstname: firstname.value,
          password: password.value,
        ),
      );
      print("[LoginController] Received token: ${response.token}");
      final payload = JwtHelper.decode(response.token);
      print("[LoginController] Decoded JWT payload: $payload");
      await StorageHelper.saveUser(
        payload['id'],
        payload['role'],
        response.token,
      );
      print(
        "[LoginController] Saved to SharedPreferences: id=${payload['id']}, role=${payload['role']}",
      );
      _navigateByRole(payload['role']);
    } catch (e) {
      print("[LoginController] Login error: $e");
      ElegantSnackbarService.showError(
        title: "Erreur",
        message: "Échec de connexion",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkLoginStatus() async {
    print("[LoginController] Checking if user is already logged in...");
    final user = await StorageHelper.getUser();
    if (user != null && user['token'] != null) {
      print("[LoginController] Found saved user: $user");
      final payload = JwtHelper.decode(user['token']);
      final expiration = payload['exp'] as int?;
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (expiration != null && currentTime >= expiration) {
        print(
          "[LoginController] Token expired: exp=$expiration, current=$currentTime",
        );
        logout();
      } else {
        _navigateByRole(user['role']);
      }
    } else {
      print("[LoginController] No saved user or token found.");
    }
  }

  void _navigateByRole(String role) {
    switch (role) {
      case 'ADMIN':
      case 'SUPER_ADMIN':
        Get.offAllNamed(AppRoutes.adminOverview);
        break;
      case 'TECHNICIEN':
        Get.offAllNamed(AppRoutes.techHome);
        break;
      case 'PRODUCTION':
        Get.offAllNamed(AppRoutes.prodHome);
        break;
      case 'CLIENT':
        Get.offAllNamed(AppRoutes.clientHome);
        break;
      default:
        print("[LoginController] Unknown role: $role");
        ElegantSnackbarService.showError(
          title: "Erreur",
          message: "Rôle inconnu: $role",
        );
        Get.offAllNamed(AppRoutes.login);
    }
  }

  void logout() {
    print("[LoginController] Logging out...");
    StorageHelper.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
