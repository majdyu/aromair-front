// ignore: file_names
import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/enums/status_commandes.dart';
import 'package:front_erp_aromair/data/models/commande_potentielle.dart';
import 'package:front_erp_aromair/data/repositories/admin/parfum_repository.dart';
import 'package:front_erp_aromair/data/repositories/admin/proposition_commande_repository.dart';
import 'package:front_erp_aromair/data/services/parfum_service.dart';
import 'package:front_erp_aromair/data/services/proposition_commande_service.dart';
import 'package:front_erp_aromair/theme/text_style.dart';
import 'package:front_erp_aromair/view/screens/admin/commande_potentiel/add_commande_potentielle_dialog.dart';
import 'package:front_erp_aromair/view/screens/admin/interventions/add_intervention_dialog.dart';
import 'package:front_erp_aromair/view/widgets/common/snackbar.dart';
import 'package:front_erp_aromair/viewmodel/admin/commande_potentiel/propostion_commande_controller.dart';
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
        parfumRepo: ParfumRepository(ParfumService((buildDio()))),
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
                    const SizedBox(width: 12),
                    _ElegantAddButton(controller: controller),
                  ],
                ),
                const SizedBox(height: 20),
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
                child: const Icon(Icons.circle, color: Colors.white, size: 12),
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

    String getLabel(StatusCommande? status) {
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
                      getLabel(status),
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
                    getLabel(selected),
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
    final controller = Get.find<PropostionCommandeController>();
    final hasPlan = commande.datePlanification != null;
    final isValidated = commande.status == StatusCommande.VALIDE;

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
                  // left status bar
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
                        // client + badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                      if (commande.status ==
                                          StatusCommande.EN_ATTENTE)
                                        IconButton(
                                          onPressed: () {
                                            final c =
                                                Get.find<
                                                  PropostionCommandeController
                                                >();
                                            _showEditCommandeSheet(c, commande);
                                          },
                                          icon: const Icon(
                                            Icons.edit_note_rounded,
                                          ),
                                          color: Colors.grey[700],
                                          tooltip: 'Modifier la proposition',
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
                        _ElegantDetailRow(commande: commande),
                        const SizedBox(height: 16),
                        _ElegantInfoTags(commande: commande),
                        const SizedBox(height: 16),

                        // ==================== BUTTON AREA ====================
                        if (!isValidated)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Obx(() {
                              final isLoading =
                                  controller.validateLoading[commande.id] ??
                                  false;

                              return ElevatedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : hasPlan
                                    ? () async {
                                        final confirm = await controller
                                            .showConfirmDialog();
                                        if (confirm) {
                                          controller.validateCommande(
                                            commande.id,
                                            null,
                                          );
                                        }
                                      }
                                    : () async {
                                        final prefill = PreFillIntervention(
                                          clientId: commande.clientId,
                                          diffuseurId:
                                              commande.clientDiffuseurId,
                                          type: 'LIVRAISON',
                                        );

                                        final result =
                                            await showAddInterventionDialog(
                                              context,
                                              prefill: prefill,
                                            );
                                        if (result?['success'] != true) return;

                                        final interventionDate =
                                            result?['date'] as DateTime?;
                                        final createdId =
                                            result?['interventionId'] as int?;
                                        if (interventionDate == null &&
                                            createdId == null) {
                                          return;
                                        }

                                        final ok = await controller.updateField(
                                          commande.id,
                                          datePlanification: interventionDate,
                                        );

                                        if (!ok) {
                                          ElegantSnackbarService.showError(
                                            title: 'Échec',
                                            message:
                                                'Date non enregistrée sur la commande potentielle.',
                                          );
                                          return;
                                        }

                                        try {
                                          await controller.validateCommande(
                                            commande.id,
                                            createdId,
                                          );
                                        } catch (e) {
                                          ElegantSnackbarService.showError(
                                            title: 'Validation échouée',
                                            message:
                                                'Date enregistrée mais validation impossible: $e',
                                          );
                                        }

                                        controller.fetch();
                                      },
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        hasPlan
                                            ? Icons.verified_rounded
                                            : Icons.event_available_rounded,
                                        size: 18,
                                      ),
                                label: Text(
                                  hasPlan
                                      ? 'Valider la commande'
                                      : 'Planifier une intervention',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasPlan
                                      ? AppColors.success
                                      : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  shadowColor:
                                      (hasPlan
                                              ? AppColors.success
                                              : AppColors.primary)
                                          .withOpacity(0.25),
                                ),
                              );
                            }),
                          ),
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

// === REST OF THE FILE (UNCHANGED) ===

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
          _ElegantDetailItem(
            icon: Icons.scale_outlined,
            label: 'Quantité en ML',
            value: '${commande.quantite ?? 0}',
            color: Colors.teal,
          ),
          _ElegantDetailItem(
            icon: Icons.tune_rounded,
            label: 'Type de tête',
            value: commande.typeTete ?? 'Non spécifié',
            color: Colors.deepPurple,
          ),
          Expanded(child: _EtatBottleSwitch(commande: commande)),
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

class _EtatBottleSwitch extends StatelessWidget {
  final CommandePotentielleRow commande;
  const _EtatBottleSwitch({required this.commande});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropostionCommandeController>();
    return Obx(() {
      final currentCommande = controller.items.firstWhere(
        (e) => e.id == commande.id,
        orElse: () => commande,
      );
      final isVide = currentCommande.bouteilleVide;
      final isLoading = controller.toggleLoading[commande.id] ?? false;
      final activeColor = isVide ? AppColors.danger : AppColors.success;
      final inactiveColor = isVide ? AppColors.success : AppColors.danger;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(activeColor),
          const SizedBox(height: 12),
          MouseRegion(
            cursor: isLoading
                ? SystemMouseCursors.wait
                : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: isLoading
                  ? null
                  : () => controller.updateBouteilleEtat(commande.id, !isVide),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: 240,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      activeColor.withOpacity(0.08),
                      activeColor.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: activeColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    _buildBackgroundLabels(activeColor, inactiveColor),
                    _buildThumb(activeColor, isVide, isLoading),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHeader(Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.water_drop_outlined, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'État de la bouteille',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              commande.bouteilleVide ? 'Bouteille vide' : 'Bouteille pleine',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackgroundLabels(Color activeColor, Color inactiveColor) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SwitchLabel(
              text: 'Vide',
              active: commande.bouteilleVide,
              activeColor: activeColor,
              icon: Icons.inventory_2_outlined,
            ),
            _SwitchLabel(
              text: 'Pleine',
              active: !commande.bouteilleVide,
              activeColor: inactiveColor,
              icon: Icons.local_drink_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb(Color activeColor, bool isVide, bool isLoading) {
    return AnimatedAlign(
      alignment: isVide ? Alignment.centerLeft : Alignment.centerRight,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      child: Container(
        width: 112,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: activeColor.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: activeColor.withOpacity(0.2), width: 1),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isVide ? Icons.inventory_2 : Icons.local_drink,
                      size: 16,
                      color: activeColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isVide ? 'Vide' : 'Pleine',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: activeColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SwitchLabel extends StatelessWidget {
  final String text;
  final bool active;
  final Color activeColor;
  final IconData icon;
  const _SwitchLabel({
    required this.text,
    required this.active,
    required this.activeColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: active ? 0.7 : 0.4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: activeColor),
          const SizedBox(width: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              color: activeColor,
              letterSpacing: 0.4,
            ),
            child: Text(text),
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

void _showEditCommandeSheet(
  PropostionCommandeController controller,
  CommandePotentielleRow commande,
) {
  final qtyCtrl = TextEditingController(
    text: (commande.quantite ?? 0).toString(),
  );
  final typeTeteCtrl = TextEditingController(text: commande.typeTete ?? '');
  final selectedParfum = RxnInt(commande.parfumId);

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Obx(() {
        final parfums = controller.parfums;
        final isUpdating = controller.updateLoading[commande.id] ?? false;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Modifier la proposition',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form Fields
            Column(
              children: [
                // Quantité
                _ElegantTextField(
                  controller: qtyCtrl,
                  label: 'Quantité (ml)',
                  icon: Icons.scale_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Type de tête
                _ElegantTextField(
                  controller: typeTeteCtrl,
                  label: 'Type de tête',
                  icon: Icons.tune_rounded,
                  hintText: 'SIMPLE / DOUBLE / ...',
                ),
                const SizedBox(height: 16),

                // Parfum
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<int>(
                      value: selectedParfum.value,
                      decoration: const InputDecoration(
                        labelText: 'Parfum',
                        prefixIcon: Icon(Icons.air_outlined),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text(
                            'Sélectionner un parfum',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ...parfums
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(
                                  p.nom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                      onChanged: (v) => selectedParfum.value = v,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isUpdating
                        ? null
                        : () async {
                            final q = int.tryParse(qtyCtrl.text.trim());
                            final tt = typeTeteCtrl.text.trim();
                            final ok = await controller.updateField(
                              commande.id,
                              quantite: q,
                              typeTete: tt.isEmpty ? null : tt,
                              parfumId: selectedParfum.value,
                            );
                            if (ok) {
                              Get.back();
                              Future.delayed(
                                const Duration(milliseconds: 150),
                                () {
                                  ElegantSnackbarService.showSuccess(
                                    message: 'Proposition mise à jour',
                                  );
                                },
                              );
                            } else {
                              ElegantSnackbarService.showError(
                                message:
                                    'Échec de la mise à jour, vérifiez les champs.',
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Enregistrer',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _ElegantTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hintText;
  final TextInputType? keyboardType;

  const _ElegantTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ElegantAddButton extends StatelessWidget {
  final PropostionCommandeController controller;
  const _ElegantAddButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () async {
          final res = await showAddCommandePotentielleDialog(
            Get.overlayContext ?? context, // 👈 ensures a valid Overlay
          );
          if (res?['success'] == true) {
            await controller.fetch();
            ElegantSnackbarService.showSuccess(message: 'Proposition créée');
          }
        },
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Nouvelle Proposition',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
