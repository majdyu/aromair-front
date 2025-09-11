import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'viewmodel/controllers/login_controller.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register controller globally - onInit will be called automatically
  Get.put(LoginController(AuthRepository(AuthService())));

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aromair',
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
      unknownRoute: GetPage(
        name: '/404',
        page: () => const Scaffold(body: Center(child: Text('PAGE INCONNUE'))),
      ),

    );
  }
}