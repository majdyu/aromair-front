import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/user.dart';
import 'package:front_erp_aromair/view/screens/admin/user/update_user_dialog.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/viewmodel/admin/user/user_controller.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';
import 'package:front_erp_aromair/theme/text_style.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/data/enums/role.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());

    return AromaScaffold(
      title: "Utilisateurs",
      onRefresh: controller.fetch,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isMobile = screenWidth < 600;
          final isTablet = screenWidth >= 600 && screenWidth < 1200;
          final isDesktop = screenWidth >= 1200;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 1200,
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                child: AromaCard(
                  padding: EdgeInsets.all(isMobile ? 16 : 32),
                  child: Column(
                    children: [
                      // Responsive Header with Obx for users count
                      Obx(
                        () => _ResponsiveHeader(
                          usersCount: controller.users.length,
                          isMobile: isMobile,
                          isTablet: isTablet,
                        ),
                      ),

                      SizedBox(height: isMobile ? 20 : 32),

                      // Search & Filter Bar
                      _ResponsiveSearchFilterBar(isMobile: isMobile),

                      SizedBox(height: isMobile ? 16 : 32),

                      // Users Content with Obx for loading, error, and users
                      Expanded(
                        child: Obx(() {
                          if (controller.loading.value) {
                            return _ElegantLoading(isMobile: isMobile);
                          } else if (controller.error.isNotEmpty) {
                            return _ElegantError(
                              error: controller.error.value,
                              isMobile: isMobile,
                            );
                          } else if (controller.users.isEmpty) {
                            return _ElegantEmpty(isMobile: isMobile);
                          } else {
                            return _ResponsiveUsersGrid(
                              users: controller.users,
                              isMobile: isMobile,
                              isTablet: isTablet,
                              isDesktop: isDesktop,
                            );
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showUpdateUserDialog(context, user: null);
          if (created == true) {
            await controller.fetch();
          }
        },

        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
      ),
    );
  }
}

class _ResponsiveHeader extends StatelessWidget {
  final int usersCount;
  final bool isMobile;
  final bool isTablet;

  const _ResponsiveHeader({
    required this.usersCount,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Équipe Utilisateurs',
                  style: AromaText.title.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$usersCount',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              'Gestion des accès système',
              style: AromaText.bodyMuted.copyWith(fontSize: 13),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: isTablet ? 24 : 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 16),
                Text(
                  'Équipe Utilisateurs',
                  style: AromaText.title.copyWith(
                    fontSize: isTablet ? 20 : 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: isTablet ? 16 : 20),
              child: Text(
                'Gestion des accès et permissions système',
                style: AromaText.bodyMuted.copyWith(
                  fontSize: isTablet ? 14 : 15,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        // Stats Card
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 24,
            vertical: isTablet ? 12 : 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.05),
                AppColors.primary.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$usersCount',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Membres',
                style: AromaText.bodyMuted.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 13 : 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResponsiveSearchFilterBar extends StatelessWidget {
  final bool isMobile;

  const _ResponsiveSearchFilterBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 44 : 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: isMobile ? 18 : 22,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: isMobile ? 8 : 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Rechercher par nom, rôle...",
                        hintStyle: AromaText.bodyMuted.copyWith(
                          fontSize: isMobile ? 14 : 15,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isMobile) ...[
            Container(
              width: 1,
              height: 28,
              color: AppColors.divider.withOpacity(0.3),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  print('Filter button tapped');
                },
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 22,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Filtrer',
                        style: AromaText.bodyMuted.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ElegantLoading extends StatelessWidget {
  final bool isMobile;

  const _ElegantLoading({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMobile ? 48 : 64,
            height: isMobile ? 48 : 64,
            padding: EdgeInsets.all(isMobile ? 14 : 18),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            'Chargement de l\'équipe',
            style: AromaText.body.copyWith(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElegantError extends StatelessWidget {
  final String error;
  final bool isMobile;

  const _ElegantError({required this.error, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24 : 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: isMobile ? 28 : 36,
                color: Colors.red,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            Text(
              'Impossible de charger les utilisateurs',
              style: AromaText.body.copyWith(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              error,
              style: AromaText.bodyMuted.copyWith(fontSize: isMobile ? 12 : 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ElegantEmpty extends StatelessWidget {
  final bool isMobile;

  const _ElegantEmpty({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24 : 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          border: Border.all(color: AppColors.divider.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_alt_outlined,
                size: isMobile ? 40 : 56,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            SizedBox(height: isMobile ? 16 : 28),
            Text(
              'Aucun utilisateur',
              style: AromaText.title.copyWith(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 16),
            Text(
              'Commencez par inviter des membres\nà rejoindre votre équipe',
              style: AromaText.bodyMuted.copyWith(
                fontSize: isMobile ? 13 : 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveUsersGrid extends StatelessWidget {
  final List<UserItem> users;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const _ResponsiveUsersGrid({
    required this.users,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _MobileUserCard(user: user);
        },
      );
    }

    final crossAxisCount = isTablet ? 3 : 4;
    final childAspectRatio = isTablet ? 1.3 : 1.1;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isTablet ? 16 : 20,
        mainAxisSpacing: isTablet ? 16 : 20,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserProfileCard(user: user, isTablet: isTablet);
      },
    );
  }
}

class _MobileUserCard extends StatelessWidget {
  final UserItem user;

  const _MobileUserCard({required this.user});

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
        return 'Admin';
      case UserRole.technicien:
        return 'Technicien';
      case UserRole.production:
        return 'Production';
      case UserRole.unknown:
        return 'Inconnu';
    }
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Icons.verified_user_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.technicien:
        return Icons.engineering_rounded;
      case UserRole.production:
        return Icons.factory_rounded;
      case UserRole.unknown:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(user.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('User ${user.nom} tapped');
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          roleColor.withOpacity(0.15),
                          roleColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: roleColor.withOpacity(0.2)),
                    ),
                    child: Icon(
                      _roleIcon(user.role),
                      size: 18,
                      color: roleColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.nom.isNotEmpty ? user.nom : 'Nom non renseigné',
                          style: AromaText.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _roleLabel(user.role),
                          style: AromaText.caption.copyWith(
                            color: roleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  final UserItem user;
  final bool isTablet;

  const _UserProfileCard({required this.user, required this.isTablet});

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

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Icons.verified_user_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.technicien:
        return Icons.engineering_rounded;
      case UserRole.production:
        return Icons.factory_rounded;
      case UserRole.unknown:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(user.role);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final update = await showUpdateUserDialog(context, user: user);
          if (update == true) {
            final usersController = Get.find<UserController>();
            await usersController.fetch();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Row(
                  children: [
                    Container(
                      width: isTablet ? 40 : 48,
                      height: isTablet ? 40 : 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            roleColor.withOpacity(0.15),
                            roleColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isTablet ? 10 : 12),
                        border: Border.all(color: roleColor.withOpacity(0.2)),
                      ),
                      child: Icon(
                        _roleIcon(user.role),
                        size: isTablet ? 18 : 22,
                        color: roleColor,
                      ),
                    ),
                    SizedBox(width: isTablet ? 10 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nom.isNotEmpty
                                ? user.nom
                                : 'Nom non renseigné',
                            style: AromaText.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: isTablet ? 14 : 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _roleLabel(user.role),
                            style: AromaText.caption.copyWith(
                              color: roleColor,
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 11 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Status Bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [roleColor, roleColor.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(color: Colors.transparent),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 12),
                // Action Hint
                Row(
                  children: [
                    Text(
                      'Update Profile',
                      style: AromaText.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: isTablet ? 11 : 12,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.edit_note_outlined,
                      size: isTablet ? 12 : 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
