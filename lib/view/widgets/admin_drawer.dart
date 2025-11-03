import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/utils/storage_helper.dart';
import 'package:front_erp_aromair/utils/jwt_helper.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topSafe = MediaQuery.of(context).padding.top;
    final w = size.width;
    final h = size.height;

    final bool isTablet = w >= 600 && w < 1024;
    final bool isMobile = w < 600;

    // Drawer width as a percentage of screen width (with clamps)
    final double drawerWidth = _clamp(
      isMobile ? w * 0.88 : (isTablet ? w * 0.30 : w * 0.22),
      260,
      360,
    );

    // === Percent-based sizing ===
    final double pad = _clamp(drawerWidth * 0.07, 16, 28); // header padding
    final double gapNameRole = _clamp(
      h * 0.006,
      3,
      8,
    ); // gap between name & role
    final double gapAvatar = _clamp(
      h * 0.012,
      6,
      14,
    ); // gap between avatar & name
    final double avatarPad = _clamp(
      drawerWidth * 0.045,
      12,
      18,
    ); // inner pad of avatar circle

    final double headerIcon = _clamp(
      drawerWidth * 0.11,
      32,
      44,
    ); // big avatar icon size
    final double itemIcon = _clamp(
      drawerWidth * 0.07,
      20,
      26,
    ); // menu icon size
    final double itemVPad = _clamp(h * 0.016, 10, 18); // menu vertical padding
    final double itemText = _clamp(
      drawerWidth * 0.045,
      14,
      16,
    ); // menu text size
    final double titleSize = _clamp(
      drawerWidth * 0.065,
      18,
      24,
    ); // name font size
    final double roleSize = _clamp(
      drawerWidth * 0.040,
      12,
      15,
    ); // role font size
    final double footerBtnVPad = _clamp(
      h * 0.018,
      12,
      18,
    ); // footer button padding

    // Header minimum height as a percentage of screen height (so it can grow if needed)
    final double headerMinHeight =
        (isMobile ? h * 0.22 : h * 0.20) + topSafe + 2; // +2px safety
    final double headerTarget = (isMobile
        ? h * 0.24
        : (isTablet ? h * 0.22 : h * 0.22));
    final double headerHeightMin = math.max(headerTarget, headerMinHeight);

    return Drawer(
      width: drawerWidth,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1E40), Color(0xFF152A51), Color(0xFF1E3A8A)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(
              minHeight: headerHeightMin,
              pad: pad,
              avatarPad: avatarPad,
              headerIcon: headerIcon,
              titleSize: titleSize,
              roleSize: roleSize,
              gapAvatar: gapAvatar,
              gapNameRole: gapNameRole,
            ),
            Expanded(child: _buildMenuItems(itemIcon, itemVPad, itemText)),
            _buildFooter(footerBtnVPad),
          ],
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _buildHeader({
    required double minHeight,
    required double pad,
    required double avatarPad,
    required double headerIcon,
    required double titleSize,
    required double roleSize,
    required double gapAvatar,
    required double gapNameRole,
  }) {
    return Container(
      // let content define the final height, we only enforce a min
      constraints: BoxConstraints(minHeight: minHeight),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF0A1E40)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // shrink to fit; minHeight handles the rest
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(avatarPad),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  size: headerIcon,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: gapAvatar),

              // NAME (from storage, fallback to JWT "sub")
              FutureBuilder<Map<String, dynamic>?>(
                future: StorageHelper.getUser(),
                builder: (context, snap) {
                  final u = snap.data;
                  String displayName = (u?['name'] ?? '').toString().trim();
                  if (displayName.isEmpty) {
                    final token = (u?['token'] ?? '').toString();
                    if (token.isNotEmpty) {
                      final sub = JwtHelper.sub(token) ?? '';
                      if (sub.isNotEmpty) {
                        displayName = sub;
                        Future.microtask(() => StorageHelper.saveUserName(sub));
                      }
                    }
                  }
                  displayName = displayName.isEmpty
                      ? 'Utilisateur'
                      : displayName;
                  return Text(
                    displayName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  );
                },
              ),

              SizedBox(height: gapNameRole),

              // ROLE (from storage, fallback to JWT "role")
              FutureBuilder<Map<String, dynamic>?>(
                future: StorageHelper.getUser(),
                builder: (context, snap) {
                  final u = snap.data;
                  String role = (u?['role'] ?? '').toString();
                  if (role.isEmpty) {
                    final token = (u?['token'] ?? '').toString();
                    if (token.isNotEmpty) role = JwtHelper.role(token) ?? '';
                  }
                  final label = _labelRole(role);
                  return Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: roleSize,
                      height: 1.25,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.2,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Menu ----------------
  Widget _buildMenuItems(double iconSize, double vPad, double textSize) {
    final items = [
      {
        'icon': Icons.dashboard,
        'title': 'Aperçu',
        'route': AppRoutes.adminOverview,
      },
      {
        'icon': Icons.handyman,
        'title': 'Interventions',
        'route': AppRoutes.adminInterventions,
      },
      {
        'icon': Icons.people,
        'title': 'Clients',
        'route': AppRoutes.adminClients,
      },
      {
        'icon': Icons.devices,
        'title': 'Diffuseurs',
        'route': AppRoutes.adminDiffuseurs,
      },
      {
        'icon': Icons.warning_amber,
        'title': 'Alertes',
        'route': AppRoutes.adminAlertes,
      },
      {
        'icon': Icons.report_problem,
        'title': 'Réclamations',
        'route': AppRoutes.adminReclamations,
      },
      {
        'icon': Icons.bar_chart,
        'title': 'Rapports',
        'route': AppRoutes.adminRapports,
      },
      {
        'icon': Icons.supervised_user_circle,
        'title': 'Utilisateurs',
        'route': AppRoutes.adminUtilisateurs,
      },
      {
        'icon': Icons.group_work,
        'title': 'Équipes',
        'route': AppRoutes.adminEquipes,
      },
      {
        'icon': Icons.wysiwyg_rounded,
        'title': 'Propositions Commandes',
        'route': AppRoutes.adminPropositionsCommandes,
      },
      {
        'icon': Icons.message,
        'title': 'Messages Broadcast',
        'route': AppRoutes.adminMessagesBroadcast,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = Get.currentRoute == item['route'];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _navigateTo(item['route'] as String),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: vPad),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: iconSize,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: textSize,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- Footer ----------------
  Widget _buildFooter(double buttonVPad) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Colors.white24, height: 1, thickness: 1),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0A1E40),
                padding: EdgeInsets.symmetric(
                  vertical: buttonVPad,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 20),
              label: const Text(
                "Déconnexion",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Helpers ----------------
  void _navigateTo(String route) {
    Get.back();
    if (Get.currentRoute != route) {
      Get.offNamed(route);
    }
  }

  void _logout() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1E40).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  color: Color(0xFF0A1E40),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Déconnexion",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A1E40),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Êtes-vous sûr de vouloir vous déconnecter ?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Color(0xFF0A1E40)),
                      ),
                      child: const Text(
                        "Annuler",
                        style: TextStyle(
                          color: Color(0xFF0A1E40),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.back();
                        StorageHelper.clear();
                        Get.offAllNamed(AppRoutes.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1E40),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Déconnecter",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _clamp(double v, double min, double max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  String _labelRole(String? role) {
    switch ((role ?? '').toUpperCase()) {
      case 'SUPER_ADMIN':
        return 'Super Admin';
      case 'ADMIN':
        return 'Admin';
      case 'TECHNICIEN':
        return 'Technicien';
      case 'PRODUCTION':
        return 'Production';
      default:
        return (role == null || role.isEmpty) ? '—' : role;
    }
  }
}
