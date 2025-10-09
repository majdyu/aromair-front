import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/viewmodel/admin/diffuseur/add_diffuseur_controller.dart';

Future<bool?> showAddDiffuseurDialog(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, __) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Column(
          children: [
            // Drag handle
            _DragHandle(),
            Expanded(child: _AddDiffuseurForm()),
          ],
        ),
      ),
    ),
  );
  // IMPORTANT: don't manually Get.delete here; GetBuilder will auto-dispose.
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _AddDiffuseurForm extends StatelessWidget {
  const _AddDiffuseurForm();

  @override
  Widget build(BuildContext context) {
    // Non-reactive wrapper; safe to init controller here.
    return GetBuilder<AddDiffuseurController>(
      init: AddDiffuseurController(),
      builder: (c) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Nouveau Diffuseur",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1),

              // Form content (non-reactive)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16, top: 16),
                  child: Form(
                    key: c.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("Modèle"),
                        const SizedBox(height: 8),
                        _textField(
                          controller: c.modeleCtrl,
                          hintText: "Saisissez le modèle",
                          validator: _required,
                        ),
                        const SizedBox(height: 16),

                        _sectionTitle("Type carte"),
                        const SizedBox(height: 8),
                        _textField(
                          controller: c.typCarteCtrl,
                          hintText: "Saisissez le type de carte",
                          validator: _required,
                        ),
                        const SizedBox(height: 16),

                        _sectionTitle("Désignation"),
                        const SizedBox(height: 8),
                        _textField(
                          controller: c.designationCtrl,
                          hintText: "Saisissez la désignation",
                          validator: _required,
                        ),
                        const SizedBox(height: 16),

                        _sectionTitle("Consommation (W)"),
                        const SizedBox(height: 8),
                        _textField(
                          controller: c.consommationCtrl,
                          hintText: "Ex: 0.1",
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validateConso,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Actions (only this part is reactive)
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
                      child: Obx(() {
                        // Read the Rx from the SAME controller instance we already built.
                        final isSubmitting = c.isSubmitting.value;
                        return FilledButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final ok = await c.submit();
                                  if (ok && context.mounted) {
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
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Créer",
                                  style: TextStyle(color: Colors.white),
                                ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          hintText: hintText,
          errorStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

String? _required(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;

String? _validateConso(String? v) {
  if (v == null || v.trim().isEmpty) return 'Champ obligatoire';
  final parsed = double.tryParse(v.replaceAll(',', '.'));
  if (parsed == null) return 'Valeur numérique invalide';
  return null;
}
