import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _userFocus = FocusNode();
  final _passFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!controller.isLoading.value) controller.login();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<Intent>(
            onInvoke: (intent) {
              _submit();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A1E40), // Dark navy
                    Color(0xFF152A51), // Medium navy
                    Color(0xFF1E3A8A), // Royal blue
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isLandscape ? 900 : 650,
                    maxHeight: isLandscape ? 550 : 700,
                  ),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: isLandscape
                      ? _buildLandscapeLayout()
                      : _buildPortraitLayout(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Left side - Premium Branding
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A1E40), Color(0xFF152A51)],
              ),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium logo container with subtle shadow - LARGER SIZE
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade900.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/aromair_logo.png',
                      height: 180, // Increased from 140 to 180
                      width: 180, // Increased from 140 to 180
                      fit: BoxFit.contain,
                      color: Colors.white,
                      errorBuilder: (_, __, ___) => Container(
                        width: 180, // Increased from 140 to 180
                        height: 180, // Increased from 140 to 180
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1E40),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.air,
                          size: 100, // Increased from 80 to 100
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'AROMAIR SYSTEM',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(
                  color: Colors.white30,
                  thickness: 1,
                  indent: 40,
                  endIndent: 40,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Premium Air Quality Management',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right side - Elegant Login Form
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: _buildLoginForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // Top section - Premium Branding
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A1E40), Color(0xFF152A51)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Premium logo container - LARGER SIZE
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade900.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/aromair_logo.png',
                    height: 180, // Increased from 150 to 180
                    width: 180, // Increased from 150 to 180
                    fit: BoxFit.contain,
                    color: Colors.white,
                    errorBuilder: (_, __, ___) => Container(
                      width: 180, // Increased from 150 to 180
                      height: 180, // Increased from 150 to 180
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1E40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.air,
                        size: 100, // Increased from 60 to 100
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'AROMAIR SYSTEM',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Premium Air Quality Management',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        // Bottom section - Elegant Login Form
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: _buildLoginForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1E40),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please enter your credentials to continue',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Username field
            const Text(
              'USERNAME',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              hint: 'Enter your username',
              icon: Icons.person_outline,
              focusNode: _userFocus,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
              onChanged: (v) => controller.firstname.value = v,
              onSubmitted: (_) => _passFocus.requestFocus(),
            ),
            const SizedBox(height: 24),

            // Password field
            const Text(
              'PASSWORD',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              hint: 'Enter your password',
              icon: Icons.lock_outline,
              obscureText: true,
              focusNode: _passFocus,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              onChanged: (v) => controller.password.value = v,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),

            // Remember me & Forgot password
            Row(
              children: [
                // Elegant checkbox
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0A1E40),
                      width: 1.5,
                    ),
                  ),
                  child: Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.transparent),
                    child: Checkbox(
                      value: false,
                      onChanged: (value) {},
                      activeColor: const Color(0xFF0A1E40),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Remember me',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0A1E40),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Login button with elegant design
            Obx(
              () => controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0A1E40),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A1E40),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF0A1E40).withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _submit,
                        child: const Text(
                          'SIGN IN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
