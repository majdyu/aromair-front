// lib/viewmodel/admin/messaging_broadcast_controller.dart
import 'package:front_erp_aromair/data/repositories/admin/messaging_broadcast_repository.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/data/models/whatsapp_broadcast_request.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';

class MessagingBroadcastController extends GetxController {
  final MessagingBroadcastRepository repo;
  MessagingBroadcastController({required this.repo});

  // les 3 listes venant du backend
  final types = const ['ACHAT', 'CONVENTION', 'MAD'];
  final natures = const ['ENTREPRISE', 'PARTICULIER'];
  final importances = const ['ELEVE', 'MOYENNE', 'FAIBLE'];

  // selections
  final selectedTypes = <String>{}.obs;
  final selectedNatures = <String>{}.obs;
  final selectedImportances = <String>{}.obs;

  final message = ''.obs;
  final sending = false.obs;
  final lastResult = Rxn<String>(); // pour afficher "0/0"

  void toggleType(String v) {
    if (selectedTypes.contains(v)) {
      selectedTypes.remove(v);
    } else {
      selectedTypes.add(v);
    }
  }

  void toggleNature(String v) {
    if (selectedNatures.contains(v)) {
      selectedNatures.remove(v);
    } else {
      selectedNatures.add(v);
    }
  }

  void toggleImportance(String v) {
    if (selectedImportances.contains(v)) {
      selectedImportances.remove(v);
    } else {
      selectedImportances.add(v);
    }
  }

  // 👇 nouvelle méthode
  void resetForm() {
    selectedTypes.clear();
    selectedNatures.clear();
    selectedImportances.clear();
    message.value = '';
  }

  Future<void> send() async {
    if (message.value.trim().isEmpty) {
      ElegantSnackbarService.showError(message: 'Le message est obligatoire.');
      return;
    }

    sending.value = true;
    try {
      final req = WhatsappBroadcastRequest(
        types: selectedTypes.isEmpty ? null : selectedTypes.toList(),
        natures: selectedNatures.isEmpty ? null : selectedNatures.toList(),
        importances: selectedImportances.isEmpty
            ? null
            : selectedImportances.toList(),
        message: message.value.trim(),
      );

      final res = await repo.sendTemplateFirst(req);

      // on garde le résultat pour l'afficher
      lastResult.value =
          'Ciblés: ${res.totalTargets}, envoyés: ${res.sent}, échoués: ${res.failed}';

      // 👇 reset du formulaire après succès
      resetForm();

      ElegantSnackbarService.showSuccess(
        message:
            'Broadcast envoyé. Ciblés: ${res.totalTargets}, envoyés: ${res.sent}',
      );
    } catch (e) {
      ElegantSnackbarService.showError(message: 'Envoi échoué: $e');
    } finally {
      sending.value = false;
    }
  }
}
