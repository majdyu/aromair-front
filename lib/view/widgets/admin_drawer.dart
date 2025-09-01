import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/storage_helper.dart';
import '../../../routes/app_routes.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1A2F5), Color(0xFFD196F0)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMenuItems()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6FA8DC), Color(0xFF5A9BD4)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.admin_panel_settings, size: 35, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                "Administrateur",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Panel d'administration",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    final items = [
      {'icon': Icons.dashboard, 'title': 'Aperçu', 'route': AppRoutes.adminOverview},
      {'icon': Icons.handyman, 'title': 'Interventions', 'route': AppRoutes.adminInterventions},
      {'icon': Icons.people, 'title': 'Clients', 'route': AppRoutes.adminClients},
      {'icon': Icons.devices, 'title': 'Diffuseurs', 'route': AppRoutes.adminDiffuseurs},
      {'icon': Icons.warning_amber, 'title': 'Alertes', 'route': AppRoutes.adminAlertes},
      {'icon': Icons.report_problem, 'title': 'Réclamations', 'route': AppRoutes.adminReclamations},
      {'icon': Icons.bar_chart, 'title': 'Rapports', 'route': AppRoutes.adminRapports},
      {'icon': Icons.supervised_user_circle, 'title': 'Utilisateurs', 'route': AppRoutes.adminUtilisateurs},
      
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = Get.currentRoute == item['route'];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _navigateTo(item['route'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : null,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected) Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7), size: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 20),
              label: const Text(
                "Déconnexion",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(String route) {
    Get.back();
    if (Get.currentRoute != route) {
      Get.offNamed(route);
    }
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Déconnexion"),
        content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              Get.back();
              StorageHelper.clear();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text("Déconnecter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}