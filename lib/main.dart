import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'viewmodel/controllers/login_controller.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/auth_service.dart';

// FCM
import 'core/notification/fcm_service.dart'; // your path

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-UI init: NO navigation here
  await FcmService.I.preUiInit();

  runApp(const MainApp());

  // Post-UI init: navigation is safe here
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await FcmService.I.postUiInit();
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aromair',
      navigatorKey: Get.key, // important
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
      initialBinding: BindingsBuilder(() {
        Get.put(
          LoginController(AuthRepository(AuthService())),
          permanent: true,
        );
      }),
      unknownRoute: GetPage(
        name: '/404',
        page: () => const Scaffold(body: Center(child: Text('PAGE INCONNUE'))),
      ),
    );
  }
}
