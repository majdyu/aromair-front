import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ← pour Shortcuts / Actions / Enter
import 'package:get/get.dart';

import '../../viewmodel/controllers/login_controller.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.find<LoginController>();

  // Focus pour naviguer entre les champs
  final _userFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _isInitialCheck = true;

  @override
  void initState() {
    super.initState();
    // petit splash de 500ms (comme avant)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isInitialCheck = false);
    });
  }

  @override
  void dispose() {
    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  // Appelé par Entrée (global) et par onSubmitted du champ password
  void _submit() {
    if (!controller.isLoading.value) controller.login();
  }

  @override
  Widget build(BuildContext context) {
    // Raccourci clavier: Entrée/Numpad Enter → login()
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<Intent>(onInvoke: (intent) {
            _submit();
            return null;
          }),
        },
        child: Focus( // permet de capter les raccourcis
          autofocus: true,
          child: Scaffold(
            backgroundColor: const Color(0xFF6FA8DC),
            body: Center(
              child: _isInitialCheck
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/aromair_logo.png',
                          height: 120,
                          width: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Text('Logo error'),
                        ),
                        const SizedBox(height: 24),
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        const Text('Loading...',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/aromair_logo.png',
                              height: 120,
                              width: 120,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Text('Logo error'),
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

                            // Username
                            CustomTextField(
                              hint: 'User',
                              icon: Icons.person,
                              focusNode: _userFocus,
                              textInputAction: TextInputAction.next,
                              onChanged: (v) => controller.firstname.value = v,
                              onSubmitted: (_) => _passFocus.requestFocus(),
                            ),
                            const SizedBox(height: 16),

                            // Password
                            CustomTextField(
                              hint: 'Password',
                              icon: Icons.lock,
                              obscureText: true,
                              focusNode: _passFocus,
                              textInputAction: TextInputAction.done,
                              onChanged: (v) => controller.password.value = v,
                              onSubmitted: (_) => _submit(), // Entrée → login()
                            ),
                            const SizedBox(height: 24),

                            // Bouton se connecter
                            Obx(() => controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFB45F04),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                    ),
                                    onPressed: _submit,
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
            ),
          ),
        ),
      ),
    );
  }
}
