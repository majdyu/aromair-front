import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/screens/admin/alerte_detail_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/alertes_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/bouteille_detail_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/client_detail_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/clientdiffuseur_detail_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/clients_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/diffuseurs_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/interventions/etat_clientdiffuseur_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/interventions/intervention_detail_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/interventions/interventions_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/rapports_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/reclamations_detail_screen.dart';
import 'package:front_erp_aromair/view/screens/admin/utilisateurs_screen.dart';
import 'package:get/get.dart';
import '../view/screens/login_screen.dart';
import '../view/screens/technicien/tech_dashboard.dart';
import '../view/screens/admin/overview_screen.dart';
import '../viewmodel/controllers/login_controller.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/auth_service.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: BindingsBuilder(() {
        Get.put(LoginController(AuthRepository(AuthService())));
      }),
    ),
    // Admin routes
    GetPage(name: AppRoutes.adminOverview, page: () => const OverviewScreen()),

    GetPage(
      name: AppRoutes.adminInterventions,
      page: () => InterventionsScreen(),
    ),

    GetPage(
      name: '/interventions',
      page: () {
        final id = int.tryParse(Get.arguments);
        print("Intervention ID from arguments: ${id is int}");
        if (id == null) {
          return const Scaffold(
            body: Center(child: Text('Intervention ID invalide')),
          );
        }
        return InterventionDetailScreen(interventionId: id);
      },
    ),
    GetPage(
      name: AppRoutes.interventionClientDiffuseur,
      page: () {
        final args = (Get.arguments ?? const {}) as Map;
        final interId = args['interventionId'] as int?;
        final cdId = args['clientDiffuseurId'] as int?;

        // (Optional) guard against nulls
        assert(
          interId != null && cdId != null,
          'interventionId and clientDiffuseurId must be provided in arguments',
        );

        return EtatClientDiffuseurScreen(
          interventionId: interId!,
          clientDiffuseurId: cdId!,
        );
      },
    ),

    GetPage(
      name: AppRoutes.alerteDetail,
      page: () {
        final args = (Get.arguments ?? const {}) as Map;
        final alerteId = args['alerteId'] as int?;
        assert(alerteId != null, 'alerteId must be provided in arguments');

        return AlerteDetailScreen(alerteId: alerteId!);
      },
    ),
    GetPage(
      name: AppRoutes.bouteilleDetail,
      page: () {
        final args = (Get.arguments ?? const {}) as Map;
        final bouteilleId = args['bouteilleId'] as int?;
        assert(
          bouteilleId != null,
          'bouteilleId must be provided in arguments',
        );
        return BouteilleDetailScreen(bouteilleId: bouteilleId!);
      },
    ),

    GetPage(
      name: AppRoutes.detailClient,
      page: () {
        final args = (Get.arguments ?? const {}) as Map;
        final idClient = args['id'] as int?;
        assert(idClient != null, 'Client ID must be provided in arguments');
        return ClientDetailScreen(clientId: idClient!);
      },
    ),

    GetPage(
      name: '/client-diffuseurs/:id',
      page: () => ClientDiffuseurDetailScreen(
        clientDiffuseurId: int.parse(Get.parameters['id']!),
      ),
    ),
    GetPage(name: AppRoutes.adminClients, page: () => const ClientsScreen()),
    GetPage(
      name: AppRoutes.adminDiffuseurs,
      page: () => const DiffuseursScreen(),
    ),
    GetPage(name: AppRoutes.adminAlertes, page: () => const AlertesScreen()),

    // Détail réclamation : /reclamations/:id
    GetPage(
      name: AppRoutes.reclamationDetail, // '/reclamations/:id'
      page: () {
        final idStr = Get.parameters['id'];
        final id = int.tryParse(idStr ?? '');
        if (id == null) {
          return const Scaffold(
            body: Center(child: Text('Réclamation ID invalide')),
          );
        }
        return ReclamationDetailScreen(reclamationId: id); // <— pas de const
      },
    ),

    GetPage(
      name: AppRoutes.adminUtilisateurs,
      page: () => const UtilisateursScreen(),
    ),
    GetPage(name: AppRoutes.adminRapports, page: () => const RapportsScreen()),
    // Technicien routes
    GetPage(name: AppRoutes.techHome, page: () => const TechDashboard()),
    // Add your home pages for each role...
  ];
}
