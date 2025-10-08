import 'package:flutter/material.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/viewmodel/admin/user/update_user_dialog_controller.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:front_erp_aromair/data/models/user.dart';
import 'package:front_erp_aromair/data/enums/role.dart';

Future<bool?> showUpdateUserDialog(BuildContext context, {UserItem? user}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(child: _UpdateUserForm(user: user)),
          ],
        ),
      ),
    ),
  );
}

class _UpdateUserForm extends StatefulWidget {
  final UserItem? user;

  const _UpdateUserForm({this.user});

  @override
  State<_UpdateUserForm> createState() => _UpdateUserFormState();
}

class _UpdateUserFormState extends State<_UpdateUserForm> {
  final UpdateUserDialogController c = Get.put(
    UpdateUserDialogController(),
    tag: 'update_user_dialog',
  );

  final _nomController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole? _selectedRole;

  bool _obscurePwd = true; // password toggle

  @override
  void initState() {
    super.initState();
    c.init(widget.user);

    if (widget.user != null) {
      _nomController.text = widget.user!.nom;
      _selectedRole = widget.user!.role;
      c.selectedRole = _selectedRole;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return const Color(0xFF8B5FBF);
      case UserRole.admin:
        return const Color(0xFFE74C3C);
      case UserRole.technicien:
        return const Color(0xFF3498DB);
      case UserRole.production:
        return const Color(0xFFF39C12);
      case UserRole.unknown:
        return AppColors.textSecondary;
    }
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.technicien:
        return 'Technicien';
      case UserRole.production:
        return 'Production';
      case UserRole.unknown:
        return 'Inconnu';
    }
  }

  // Validators: required only on CREATE (user == null)
  String? _validateNameCreate(String? v) {
    if (widget.user == null) {
      return c.validateName(v);
    }
    return null; // update: optional
  }

  String? _validatePasswordCreate(String? v) {
    if (widget.user == null) {
      if (v == null || v.trim().isEmpty)
        return 'Le mot de passe est obligatoire';
      if (v.trim().length < 6) return 'Au moins 6 caractères';
    }
    return null; // update: optional
  }

  String? _validateRoleCreate(UserRole? role) {
    if (widget.user == null) {
      if (role == null) return 'Le rôle est obligatoire';
    }
    return null; // update: optional
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.user == null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              isCreate ? "Nouvel Utilisateur" : "Modifier l'utilisateur",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Form(
                key: c.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Name field
                    _buildSectionTitle("Nom complet"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nomController,
                      hintText: "Saisissez le nom complet",
                      validator: _validateNameCreate,
                    ),

                    const SizedBox(height: 16),

                    // Password field (with show/hide)
                    _buildSectionTitle(
                      isCreate ? "Mot de passe" : "Nouveau Mot de passe",
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: isCreate
                          ? "Saisissez le mot de passe"
                          : "Saisissez le nouveau mot de passe",
                      validator: _validatePasswordCreate,
                      obscureText: _obscurePwd,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscurePwd = !_obscurePwd),
                        icon: Icon(
                          _obscurePwd ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Role field (required only on create)
                    _buildSectionTitle("Rôle"),
                    const SizedBox(height: 8),
                    FormField<UserRole>(
                      validator: (val) => _validateRoleCreate(val),
                      builder: (ffState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRoleDropdown(
                              value: _selectedRole,
                              onChanged: (UserRole? value) {
                                setState(() => _selectedRole = value);
                                ffState.didChange(value); // sync validator
                                c.selectedRole = value;
                              },
                            ),
                            if (ffState.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  ffState.errorText!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: const Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Annuler"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      // Avoid overwriting with empty values on UPDATE
                      final safeName =
                          (widget.user != null &&
                              _nomController.text.trim().isEmpty)
                          ? widget.user!.nom
                          : _nomController.text.trim();

                      final safeRole = widget.user == null
                          ? _selectedRole
                          : (_selectedRole ?? widget.user!.role);

                      final safePassword =
                          _passwordController.text.trim().isEmpty
                          ? null
                          : _passwordController.text.trim();

                      final success = await c.save(
                        name: safeName,
                        password: safePassword,
                        role: safeRole,
                      );
                      if (success && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCreate ? "Créer" : "Modifier",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          hintText: hintText,
          errorStyle: const TextStyle(fontSize: 12),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown({
    required UserRole? value,
    required void Function(UserRole?) onChanged,
  }) {
    final roles = UserRole.values
        .where((role) => role != UserRole.unknown)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<UserRole>(
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Sélectionner un rôle",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          value: value,
          items: roles.map((role) {
            final color = _roleColor(role);
            return DropdownMenuItem<UserRole>(
              value: role,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _roleLabel(role),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          buttonStyleData: const ButtonStyleData(
            height: 48,
            padding: EdgeInsets.only(left: 12, right: 8),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 320,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.arrow_drop_down),
            iconEnabledColor: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
