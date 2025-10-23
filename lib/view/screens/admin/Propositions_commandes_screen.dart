// ignore: file_names
import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/enums/status_commandes.dart';
import 'package:front_erp_aromair/data/models/commande_potentielle.dart';
import 'package:front_erp_aromair/data/repositories/admin/proposition_commande_repository.dart';
import 'package:front_erp_aromair/data/services/proposition_commande_service.dart';
import 'package:front_erp_aromair/theme/text_style.dart';
import 'package:front_erp_aromair/viewmodel/admin/propostion_commande_controller.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';
import 'package:front_erp_aromair/theme/colors.dart';

class PropositionsCommandesScreen extends StatelessWidget {
  const PropositionsCommandesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(
      PropostionCommandeController(
        repo: CommandesPotentiellesRepository(
          CommandesPotentiellesService(buildDio()),
        ),
      ),
    );

    return AromaScaffold(
      title: "Propositions de Commandes",
      onRefresh: c.fetch,
      body: Column(
        children: [
          _PremiumHeaderElegant(controller: c),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFf8fafc)],
                ),
              ),
              child: Obx(() {
                if (c.loading.value) {
                  return const _ElegantLoading(isMobile: true);
                }
                if (c.error.value != null) {
                  return _PremiumErrorElegant(
                    error: c.error.value!,
                    onRetry: c.fetch,
                  );
                }
                if (c.items.isEmpty) {
                  return const _PremiumEmptyElegant();
                }
                return _PremiumListElegant(controller: c);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumHeaderElegant extends StatelessWidget {
  final PropostionCommandeController controller;
  const _PremiumHeaderElegant({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.98),
            AppColors.primary.withOpacity(0.92),
            AppColors.primary.withOpacity(0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and subtitle
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.15),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Propositions de Commandes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            final total = controller.items.length;
                            return Text(
                              '$total proposition${total > 1 ? 's' : ''} en cours',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    _ElegantFilter(controller: controller),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats with elegant design
                _ElegantStatsRow(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ElegantStatsRow extends StatelessWidget {
  final PropostionCommandeController controller;
  const _ElegantStatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.items;
      final enAttente = items
          .where((e) => e.status == StatusCommande.EN_ATTENTE)
          .length;
      final prod = items
          .where((e) => e.status == StatusCommande.PRODUIS)
          .length;
      final valides = items
          .where((e) => e.status == StatusCommande.VALIDE)
          .length;

      Widget statCard(String label, int count, Color color) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.circle, color: Colors.white, size: 12),
              ),
              const SizedBox(height: 6),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );

      return Row(
        children: [
          statCard('En Attente', enAttente, AppColors.warning),
          statCard('Production', prod, AppColors.info),
          statCard('Validées', valides, AppColors.success),
        ],
      );
    });
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Elegant Filter
/// ─────────────────────────────────────────────────────────────────────────────
class _ElegantFilter extends StatelessWidget {
  final PropostionCommandeController controller;

  const _ElegantFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    final options = <StatusCommande?>[
      null,
      StatusCommande.EN_ATTENTE,
      StatusCommande.PRODUIS,
      StatusCommande.VALIDE,
    ];

    String _getLabel(StatusCommande? status) {
      if (status == null) return 'Tous les statuts';
      switch (status) {
        case StatusCommande.EN_ATTENTE:
          return 'En attente';
        case StatusCommande.PRODUIS:
          return 'En production';
        case StatusCommande.VALIDE:
          return 'Validées';
        case StatusCommande.INCONNU:
          return 'Inconnu';
      }
    }

    IconData _getIcon(StatusCommande? status) {
      if (status == null) return Icons.filter_list_rounded;
      switch (status) {
        case StatusCommande.EN_ATTENTE:
          return Icons.pending_actions_rounded;
        case StatusCommande.PRODUIS:
          return Icons.build_circle_rounded;
        case StatusCommande.VALIDE:
          return Icons.verified_rounded;
        case StatusCommande.INCONNU:
          return Icons.help_outline_rounded;
      }
    }

    return Obx(() {
      final selected = controller.selectedStatus.value;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: PopupMenuButton<StatusCommande?>(
          onSelected: controller.setStatus,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          itemBuilder: (context) => options.map((status) {
            final isSelected = status == selected;
            return PopupMenuItem(
              value: status,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _getStatusColor(status)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? _getStatusColor(status)
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      _getIcon(status),
                      size: 18,
                      color: _getStatusColor(status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getLabel(status),
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? _getStatusColor(status)
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIcon(selected),
                    size: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getLabel(selected),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 20,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Color _getStatusColor(StatusCommande? status) {
    switch (status) {
      case null:
        return AppColors.primary;
      case StatusCommande.EN_ATTENTE:
        return AppColors.warning;
      case StatusCommande.PRODUIS:
        return AppColors.info;
      case StatusCommande.VALIDE:
        return AppColors.success;
      case StatusCommande.INCONNU:
        return Colors.grey;
    }
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Elegant List
/// ─────────────────────────────────────────────────────────────────────────────
class _PremiumListElegant extends StatelessWidget {
  final PropostionCommandeController controller;

  const _PremiumListElegant({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: controller.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, index) =>
            _ElegantCard(commande: controller.items[index]),
      );
    });
  }
}

class _ElegantCard extends StatelessWidget {
  final CommandePotentielleRow commande;

  const _ElegantCard({required this.commande});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AromaCard(
          padding: const EdgeInsets.all(0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey[50]!],
                ),
              ),
              child: Stack(
                children: [
                  // Status accent with gradient
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _getStatusColor(commande.status),
                            _getStatusColor(commande.status).withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with client info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Client avatar with elegant design
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _getStatusColor(
                                      commande.status,
                                    ).withOpacity(0.15),
                                    _getStatusColor(
                                      commande.status,
                                    ).withOpacity(0.05),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _getStatusColor(
                                    commande.status,
                                  ).withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.business_center_rounded,
                                color: _getStatusColor(commande.status),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Client info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              commande.clientNom ??
                                                  'Client #${commande.clientId}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                                letterSpacing: -0.3,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              commande.diffuseurDesignation ??
                                                  commande.diffuseurCab ??
                                                  'Diffuseur #${commande.clientDiffuseurId}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _ElegantStatusBadge(
                                        status: commande.status,
                                      ),
                                    ],
                                  ),
                                  if (commande.emplacement != null) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          commande.emplacement!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Contact and details in elegant layout
                        _ElegantDetailRow(commande: commande),
                        const SizedBox(height: 16),
                        // Additional info with tags
                        _ElegantInfoTags(commande: commande),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(StatusCommande status) {
    switch (status) {
      case StatusCommande.EN_ATTENTE:
        return AppColors.warning;
      case StatusCommande.PRODUIS:
        return AppColors.info;
      case StatusCommande.VALIDE:
        return AppColors.success;
      case StatusCommande.INCONNU:
        return Colors.grey;
    }
  }
}

class _ElegantStatusBadge extends StatelessWidget {
  final StatusCommande status;

  const _ElegantStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStatusColor(status).withOpacity(0.1),
            _getStatusColor(status).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(status).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor(status).withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _getStatusColor(status),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(StatusCommande status) {
    switch (status) {
      case StatusCommande.EN_ATTENTE:
        return AppColors.warning;
      case StatusCommande.PRODUIS:
        return AppColors.info;
      case StatusCommande.VALIDE:
        return AppColors.success;
      case StatusCommande.INCONNU:
        return Colors.grey;
    }
  }

  String _getStatusText(StatusCommande status) {
    switch (status) {
      case StatusCommande.EN_ATTENTE:
        return 'EN ATTENTE';
      case StatusCommande.PRODUIS:
        return 'PRODUCTION';
      case StatusCommande.VALIDE:
        return 'VALIDÉE';
      case StatusCommande.INCONNU:
        return 'INCONNU';
    }
  }
}

class _ElegantDetailRow extends StatelessWidget {
  final CommandePotentielleRow commande;

  const _ElegantDetailRow({required this.commande});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          _ElegantDetailItem(
            icon: Icons.phone_outlined,
            label: 'Contact',
            value: commande.telephone ?? 'Non renseigné',
            color: Colors.blue,
          ),
          const SizedBox(width: 24),
          _ElegantDetailItem(
            icon: Icons.inventory_2_outlined,
            label: 'État',
            value: commande.bouteilleVide
                ? 'Bouteille vide'
                : 'Bouteille pleine',
            color: commande.bouteilleVide
                ? AppColors.danger
                : AppColors.success,
          ),
          if (commande.date != null) ...[
            const SizedBox(width: 24),
            _ElegantDetailItem(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: _formatDate(commande.date!),
              color: Colors.purple,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _ElegantDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ElegantDetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElegantInfoTags extends StatelessWidget {
  final CommandePotentielleRow commande;

  const _ElegantInfoTags({required this.commande});

  @override
  Widget build(BuildContext context) {
    final tags = <Widget>[];

    if (commande.parfumNom != null && commande.parfumNom!.isNotEmpty) {
      tags.add(
        _ElegantInfoTag(
          icon: Icons.air_outlined,
          text: commande.parfumNom!,
          color: AppColors.primary,
        ),
      );
    }

    if (commande.datePlanification != null) {
      tags.add(
        _ElegantInfoTag(
          icon: Icons.schedule_outlined,
          text: 'Planifié: ${_formatDate(commande.datePlanification!)}',
          color: Colors.orange,
        ),
      );
    }

    return Wrap(spacing: 12, runSpacing: 12, children: tags);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _ElegantInfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _ElegantInfoTag({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Elegant Loaders / Empty / Error
/// ─────────────────────────────────────────────────────────────────────────────

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
            'Chargement des propositions commandes ...',
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

class _PremiumErrorElegant extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _PremiumErrorElegant({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.danger.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.grey[800],
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Réessayer',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumEmptyElegant extends StatelessWidget {
  const _PremiumEmptyElegant();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.9),
                    AppColors.primary.withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Aucune proposition',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.grey[800],
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: Text(
                'Aucune proposition de commande trouvée pour le moment. '
                'Les nouvelles propositions apparaîtront ici automatiquement.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
