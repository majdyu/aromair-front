import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodel/controllers/login_controller.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.find<LoginController>();
  bool isInitialCheck = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          isInitialCheck = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6FA8DC),
      body: Center(
        child: isInitialCheck
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/aromair_logo.png',
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Text('Logo error'),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/aromair_logo.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Text('Logo error'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      hint: 'User',
                      icon: Icons.person,
                      onChanged: (v) => controller.firstname.value = v,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hint: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                      onChanged: (v) => controller.password.value = v,
                    ),
                    const SizedBox(height: 24),
                    Obx(() => controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB45F04),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: controller.login,
                            child: const Text(
                              'se connecter',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}