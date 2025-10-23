import 'package:flutter/material.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/view/widgets/affecter_clientdiffuseur_dialog.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'package:front_erp_aromair/data/models/client_detail.dart';
import 'package:front_erp_aromair/viewmodel/admin/client_detail_controller.dart';

// Global widgets
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';

class ClientDetailScreen extends StatelessWidget {
  final int clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    final tag = 'client_$clientId';
    return GetX<ClientDetailController>(
      init: Get.put(ClientDetailController(clientId), tag: tag),
      tag: tag,
      builder: (c) {
        final d = c.dto.value;

        return AromaScaffold(
          title: "Détails Client",
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAffecterClientDiffuseurDialog(context, c),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 8,
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Ajouter Diffuseur',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1E40),
                  Color(0xFF1E3A8A),
                  Color(0xFF152A51),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: c.isLoading.value
                    ? _buildLoadingState()
                    : c.error.value != null
                    ? _buildErrorState(c)
                    : d == null
                    ? _buildEmptyState()
                    : _buildContent(context, d, c),
              ),
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------------------------
  // States
  // ----------------------------------------------------------------------------
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Chargement des détails...",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ClientDetailController c) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade400,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Erreur de chargement",
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              c.error.value!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: c.fetch,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text(
                  "Réessayer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_rounded,
                color: Colors.grey.shade400,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Aucune donnée disponible",
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Vérifiez l'ID du client ou contactez le support.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------------
  // Content
  // ----------------------------------------------------------------------------
  Widget _buildContent(
    BuildContext context,
    ClientDetail d,
    ClientDetailController c,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildClientHeader(d, c)),
        SliverToBoxAdapter(child: const SizedBox(height: 32)),
        SliverToBoxAdapter(child: _buildMainContentRow(context, d, c)),
        SliverToBoxAdapter(child: const SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildClientHeader(ClientDetail d, ClientDetailController c) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'client_avatar_${d.id}',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.4), Colors.transparent],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.nom,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        "ID: ${d.id}",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        d.nature ?? 'Client',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildQuickActions(d, c),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ClientDetail d, ClientDetailController c) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: c.openMaps,
            icon: const Icon(Icons.map_outlined, color: Colors.white, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.zero,
            ),
            tooltip: "Localisation",
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: c.isEditing.value ? c.cancelEdit : c.startEdit,
              icon: Icon(
                c.isEditing.value ? Icons.close : Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.zero,
              ),
              tooltip: c.isEditing.value ? "Annuler" : "Modifier",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContentRow(
    BuildContext context,
    ClientDetail d,
    ClientDetailController c,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildDetailsCard(d, c),
              const SizedBox(height: 24),
              _buildDiffuseursSection(context, d.diffuseurs, c),
              const SizedBox(height: 24),
              _buildBouteillesSection(context, d.bouteilles, c), // NEW
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildSatisfactionCard(d),
              const SizedBox(height: 24),
              _buildContactsCard(d.contacts, c), // UPDATED: pass controller
              const SizedBox(height: 24),
              _buildInterventionsCard(d.interventions),
              const SizedBox(height: 24),
              _buildReclamationsCard(d.reclamations),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------------------
  // Details card (unchanged visually)
  // ----------------------------------------------------------------------------
  Widget _buildDetailsCard(ClientDetail d, ClientDetailController c) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.contact_page_rounded,
            title: "Informations Client",
            trailing: _buildEditButton(c),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
            child: _coordsBlock(d, c),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------------
  // Section header helper
  // ----------------------------------------------------------------------------
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildEditButton(ClientDetailController c) {
    return Obx(
      () => c.isEditing.value
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton.icon(
                    onPressed: c.cancelEdit,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text(
                      'Annuler',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: c.save,
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text(
                    'Enregistrer',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            )
          : Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: TextButton.icon(
                onPressed: c.startEdit,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text(
                  'Modifier',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
    );
  }

  // ----------------------------------------------------------------------------
  // Satisfaction card (unchanged)
  // ----------------------------------------------------------------------------
  Widget _buildSatisfactionCard(ClientDetail d) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.sentiment_satisfied_alt_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                "Satisfaction",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _satisfactionGauge(d.satisfaction),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------------
  // CONTACTS (with Add / Edit / Delete) — design preserved
  // ----------------------------------------------------------------------------
  Widget _buildContactsCard(
    List<ContactLite> contacts,
    ClientDetailController c,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.contacts_rounded,
            title: "Contacts",
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${contacts.length}",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Small button; visually aligned with your header
                ElevatedButton.icon(
                  onPressed: () => _onAddContact(Get.context!, c),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          if (contacts.isEmpty)
            _buildEmptySection(
              icon: Icons.perm_contact_calendar_outlined,
              title: "Aucun contact",
              subtitle: "Ajoutez des coordonnées pour ce client.",
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Column(
                children: contacts
                    .map(
                      (cx) => _ContactTile(
                        cx,
                        onEdit: () => _onEditContact(Get.context!, c, cx),
                        onDelete: () =>
                            _confirmDeleteContact(Get.context!, c, cx),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onAddContact(
    BuildContext context,
    ClientDetailController c,
  ) async {
    final res = await showContactFormBottomSheet(context);
    if (res == null) return;
    await c.saveOrUpdateContact(
      id: null,
      nom: res.nom,
      prenom: res.prenom,
      tel: res.tel,
      whatsapp: res.whatsapp,
      email: res.email,
      age: res.age,
      sexe: res.sexe,
      poste: res.poste,
    );
  }

  Future<void> _onEditContact(
    BuildContext context,
    ClientDetailController c,
    ContactLite initial,
  ) async {
    final res = await showContactFormBottomSheet(context, initial: initial);
    if (res == null) return;
    await c.saveOrUpdateContact(
      id: initial.id,
      nom: res.nom,
      prenom: res.prenom,
      tel: res.tel,
      whatsapp: res.whatsapp,
      email: res.email,
      age: res.age,
      sexe: res.sexe,
      poste: res.poste,
    );
  }

  Future<void> _confirmDeleteContact(
    BuildContext context,
    ClientDetailController c,
    ContactLite cx,
  ) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Supprimer ce contact ?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(cx.fullName.isNotEmpty ? cx.fullName : (cx.nom ?? '-')),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true) await c.deleteContact(cx.id);
  }

  // ----------------------------------------------------------------------------
  // Diffuseurs + Bouteilles + Interventions + Réclamations (unchanged visually)
  // ----------------------------------------------------------------------------
  Widget _buildDiffuseursSection(
    BuildContext context,
    List<ClientDiffuseurRow> rows,
    ClientDetailController c,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.devices_rounded,
            title: "Diffuseurs",
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${rows.length} appareil${rows.length != 1 ? 's' : ''}",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (rows.isEmpty)
            _buildEmptySection(
              icon: Icons.device_hub_outlined,
              title: "Aucun diffuseur",
              subtitle: "Ajoutez-en un via le bouton en bas.",
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: _buildDiffuseursTable(context, rows, c),
            ),
        ],
      ),
    );
  }

  Widget _buildBouteillesSection(
    BuildContext context,
    List<BouteilleRow> rows,
    ClientDetailController c,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.local_drink_rounded,
            title: "Bouteilles en stock",
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${rows.length} élément${rows.length != 1 ? 's' : ''}",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (rows.isEmpty)
            _buildEmptySection(
              icon: Icons.local_drink_outlined,
              title: "Aucune bouteille",
              subtitle: "Affectez des bouteilles à ce client.",
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: _buildBouteillesTable(context, rows, c),
            ),
        ],
      ),
    );
  }

  Widget _buildInterventionsCard(List<InterventionRow> rows) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.engineering_rounded,
            title: "Interventions",
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${rows.length}",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (rows.isEmpty)
            _buildEmptySection(
              icon: Icons.engineering_outlined,
              title: "Aucune intervention",
              subtitle: "Suivez les activités ici.",
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: _buildInterventionsList(rows),
            ),
        ],
      ),
    );
  }

  Widget _buildReclamationsCard(List<ReclamationRow> rows) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.report_problem_rounded,
            title: "Réclamations",
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${rows.length}",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (rows.isEmpty)
            _buildEmptySection(
              icon: Icons.report_problem_outlined,
              title: "Aucune réclamation",
              subtitle: "Gérez les signalements ici.",
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: _buildReclamationsList(rows),
            ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------------
  // Empty section
  // ----------------------------------------------------------------------------
  Widget _buildEmptySection({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------------
  // Diffuseurs table (unchanged)
  // ----------------------------------------------------------------------------
  Widget _buildDiffuseursTable(
    BuildContext context,
    List<ClientDiffuseurRow> rows,
    ClientDetailController c,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: false,
          headingRowHeight: 60,
          dataRowHeight: 60,
          horizontalMargin: 0,
          headingRowColor: MaterialStateProperty.all(
            AppColors.primary.withOpacity(0.05),
          ),
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade200),
            verticalInside: BorderSide(color: Colors.grey.shade200),
          ),
          columns: [
            _DataColumnHeader("CAB"),
            _DataColumnHeader("Modèle"),
            _DataColumnHeader("Type Carte"),
            _DataColumnHeader("Emplacement"),
            if (c.isSuperAdmin) _DataColumnHeader("Actions"),
          ],
          rows: rows.map((r) => _buildDiffuseurRow(r, c)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDiffuseurRow(ClientDiffuseurRow r, ClientDetailController c) {
    Future<void> _confirmRetirer(String cab) async {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Confirmer la suppression",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text("Retirer le diffuseur $cab de ce client ?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Retirer"),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await c.retirerClientDiffuseur(cab: cab);
      }
    }

    void navigateToDiffuseurDetail() {
      Get.toNamed(AppRoutes.clientDiffuseurDetail, arguments: {'id': r.id});
    }

    return DataRow(
      onSelectChanged: (_) => navigateToDiffuseurDetail(),
      color: MaterialStateProperty.all(Colors.white),
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              r.cab,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              r.modele,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              r.typeCarte,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              r.emplacement,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        if (c.isSuperAdmin)
          DataCell(
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _confirmRetirer(r.cab),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade600,
                        size: 18,
                      ),
                      tooltip: "Retirer",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ----------------------------------------------------------------------------
  // Bouteilles table (unchanged)
  // ----------------------------------------------------------------------------
  Widget _buildBouteillesTable(
    BuildContext context,
    List<BouteilleRow> rows,
    ClientDetailController c,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: false,
          headingRowHeight: 60,
          dataRowHeight: 60,
          horizontalMargin: 0,
          headingRowColor: MaterialStateProperty.all(
            AppColors.primary.withOpacity(0.05),
          ),
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade200),
            verticalInside: BorderSide(color: Colors.grey.shade200),
          ),
          columns: [
            _DataColumnHeader("CAB"),
            _DataColumnHeader("Type"),
            _DataColumnHeader("Parfum"),
            _DataColumnHeader("Date Prod."),
            _DataColumnHeader("Qté initiale"),
            if (c.isSuperAdmin) _DataColumnHeader("Actions"),
          ],
          rows: rows.map((r) => _buildBouteilleRow(r, c)).toList(),
        ),
      ),
    );
  }

  DataRow _buildBouteilleRow(BouteilleRow r, ClientDetailController c) {
    String fmt(String? s) => (s == null || s.trim().isEmpty) ? '-' : s;

    Future<void> _confirmDetach(String cab) async {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Confirmer l'action",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text("Retirer la bouteille $cab de ce client ?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Retirer"),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        // TODO: implémenter dans le controller si nécessaire
        // await c.retirerBouteille(cab: cab);
      }
    }

    void _navigateToBouteilleDetail() {
      // TODO: si vous avez un écran de détail
      // Get.toNamed(AppRoutes.bouteilleDetail, arguments: {'id': r.id});
    }

    return DataRow(
      onSelectChanged: (_) => _navigateToBouteilleDetail(),
      color: MaterialStateProperty.all(Colors.white),
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              r.cab,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              fmt(r.type),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              fmt(r.parfum),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              fmt(r.dateProd), // backend "dd/MM/yyyy"
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              (r.qteInitiale ?? 0).toString(),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
        if (c.isSuperAdmin)
          DataCell(
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _confirmDetach(r.cab),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade600,
                        size: 18,
                      ),
                      tooltip: "Retirer",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ----------------------------------------------------------------------------
  // Interventions & Réclamations list (unchanged)
  // ----------------------------------------------------------------------------
  Widget _buildInterventionsList(List<InterventionRow> rows) {
    return Column(
      children: rows.take(5).map((intervention) {
        void _navigateToInterventionDetail() {
          Get.toNamed(
            AppRoutes.interventionDetail,
            arguments: intervention.id.toString(),
          );
        }

        return GestureDetector(
          onTap: _navigateToInterventionDetail,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getInterventionColor(intervention.statut),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getInterventionColor(
                          intervention.statut,
                        ).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intervention.date ?? "-",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intervention.equipe ?? "-",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getInterventionColor(
                      intervention.statut,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getInterventionColor(
                        intervention.statut,
                      ).withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    intervention.statut ?? "-",
                    style: TextStyle(
                      color: _getInterventionColor(intervention.statut),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReclamationsList(List<ReclamationRow> rows) {
    return Column(
      children: rows.take(5).map((reclamation) {
        void _navigateToReclamationDetail() {
          Get.toNamed(
            AppRoutes.reclamationDetail,
            arguments: {'id': reclamation.id},
          );
        }

        return GestureDetector(
          onTap: _navigateToReclamationDetail,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getReclamationColor(reclamation.statut),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getReclamationColor(
                          reclamation.statut,
                        ).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reclamation.date ?? "-",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reclamation.probleme ?? "-",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ----------------------------------------------------------------------------
  // Colors helpers
  // ----------------------------------------------------------------------------
  Color _getInterventionColor(String? statut) {
    switch (statut?.toLowerCase()) {
      case "terminé":
      case "terminée":
        return Colors.green.shade500;
      case "en cours":
        return Colors.orange.shade500;
      case "planifié":
        return Colors.blue.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  Color _getReclamationColor(String? statut) {
    switch (statut?.toLowerCase()) {
      case "résolu":
        return Colors.green.shade500;
      case "en cours":
        return Colors.orange.shade500;
      case "nouveau":
        return Colors.red.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  // ----------------------------------------------------------------------------
  // Coordinates block (unchanged visually)
  // ----------------------------------------------------------------------------
  Widget _coordsBlock(ClientDetail d, ClientDetailController c) {
    Widget chip(String text, {Color? color}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.only(right: 12, bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color?.withOpacity(0.15) ?? AppColors.primary.withOpacity(0.15),
            color?.withOpacity(0.05) ?? AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color?.withOpacity(0.3) ?? AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color ?? AppColors.primary,
          fontSize: 13,
        ),
      ),
    );

    Widget kv(String key, String value, {bool isUrl = false}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$key:",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    value.isEmpty ? '-' : value,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                if (isUrl)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      onPressed: c.openMaps,
                      icon: const Icon(
                        Icons.open_in_new,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    InputDecoration deco(String label, {IconData? prefixIcon}) =>
        InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey.shade500)
              : null,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        );

    Widget numberField(
      TextEditingController ctrl,
      String label, {
      IconData? icon,
    }) => TextFormField(
      controller: ctrl,
      decoration: deco(label, prefixIcon: icon),
      keyboardType: TextInputType.number,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        if (int.tryParse(v.trim()) == null) return 'Nombre invalide';
        return null;
      },
    );

    Widget dropdown(
      String label,
      List<String> items,
      RxnString value, {
      IconData? icon,
    }) => Obx(
      () => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonFormField<String>(
          value: value.value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => value.value = v,
          decoration: deco(
            label,
            prefixIcon: icon,
          ).copyWith(border: InputBorder.none),
          style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
        ),
      ),
    );

    final rawAdr = d.adresse.trim();

    return Obx(() {
      if (!c.isEditing.value) {
        // LECTURE
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: [
                if (d.nature != null)
                  chip(
                    d.nature! == "ENTREPRISE" ? "Entreprise" : "Particulier",
                    color: d.nature == "ENTREPRISE"
                        ? Colors.blue.shade600
                        : Colors.green.shade600,
                  ),
                if (d.type != null) chip("Type: ${d.type}"),
                if (d.importance != null) chip("Importance: ${d.importance}"),
                if (d.algoPlan != null) chip("Algo: ${d.algoPlan}"),
              ],
            ),
            const SizedBox(height: 28),
            kv("Nom du Client", d.nom),
            kv("Téléphone", d.telephone),
            kv("Coordonateur", d.coordonateur),
            kv("Adresse", rawAdr, isUrl: rawAdr.isNotEmpty),
            kv(
              "Fréq. Livraison (jours)",
              (d.frequenceLivraisonParJour ?? 0).toString(),
            ),
            kv(
              "Fréq. Visite (jours)",
              (d.frequenceVisiteParJour ?? 0).toString(),
            ),
          ],
        );
      }

      // EDITION
      return Form(
        key: c.formKey,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: dropdown(
                    "Nature",
                    ClientDetailController.natureOptions,
                    c.nature,
                    icon: Icons.business,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: dropdown(
                    "Type",
                    ClientDetailController.typeOptions,
                    c.type,
                    icon: Icons.category,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: dropdown(
                    "Importance",
                    ClientDetailController.importanceOptions,
                    c.importance,
                    icon: Icons.star,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: dropdown(
                    "Algo Planification",
                    ClientDetailController.algoOptions,
                    c.algo,
                    icon: Icons.timeline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: c.nomCtrl,
              decoration: deco("Nom du Client", prefixIcon: Icons.person),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: c.telCtrl,
                    decoration: deco("Téléphone", prefixIcon: Icons.phone),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: c.coordCtrl,
                    decoration: deco(
                      "Coordonateur",
                      prefixIcon: Icons.support_agent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: c.adrCtrl,
              decoration: deco(
                "Adresse (URL ou texte)",
                prefixIcon: Icons.location_on,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: numberField(
                    c.frLivCtrl,
                    "Fréq. Livraison (jours)",
                    icon: Icons.local_shipping,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: numberField(
                    c.frVisCtrl,
                    "Fréq. Visite (jours)",
                    icon: Icons.visibility,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ----------------------------------------------------------------------------
  // Gauge
  // ----------------------------------------------------------------------------
  Widget _satisfactionGauge(int? value) {
    final int pct = (value ?? 0).clamp(0, 100);
    final double v = pct / 100.0;

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: v),
        duration: const Duration(milliseconds: 1800),
        curve: Curves.elasticOut,
        builder: (context, anim, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.grey.shade100, Colors.white],
                      ),
                      border: Border.all(color: Colors.grey.shade200, width: 6),
                    ),
                  ),
                  CustomPaint(
                    size: const Size(140, 140),
                    painter: _DonutPainter(
                      progress: anim,
                      color: AppColors.primary,
                      trackColor: Colors.transparent,
                      strokeWidth: 14,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$pct%",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        Text(
                          "sur 100",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Niveau de Satisfaction",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  DataColumn _DataColumnHeader(String label) {
    return DataColumn(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _DonutPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}

// ============================================================================
// Bottom-sheet form used for Add/Edit Contact (keeps your design)
// ============================================================================
Future<_ContactFormResult?> showContactFormBottomSheet(
  BuildContext context, {
  ContactLite? initial,
}) {
  final nom = TextEditingController(text: initial?.nom ?? '');
  final prenom = TextEditingController(text: initial?.prenom ?? '');
  final tel = TextEditingController(text: initial?.tel ?? '');
  final whatsapp = TextEditingController(text: initial?.whatsapp ?? '');
  final email = TextEditingController(text: initial?.email ?? '');
  final age = TextEditingController(text: initial?.age?.toString() ?? '');
  final poste = TextEditingController(text: initial?.poste ?? '');
  String? sexe = (initial?.sexe ?? '').isNotEmpty ? initial!.sexe : null;

  final formKey = GlobalKey<FormState>();

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: Colors.grey.shade500),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    filled: true,
    fillColor: Colors.grey.shade50,
  );

  return showModalBottomSheet<_ContactFormResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Text(
                  initial == null ? 'Nouveau contact' : 'Modifier contact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: nom,
                        decoration: _deco('Nom', Icons.badge_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nom requis'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: prenom,
                        decoration: _deco('Prénom', Icons.person_outline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: tel,
                        decoration: _deco('Téléphone', Icons.phone),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: whatsapp,
                        decoration: _deco('WhatsApp', Icons.telegram),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: email,
                  decoration: _deco('Email', Icons.mail_outline),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: sexe,
                        items: const [
                          DropdownMenuItem(
                            value: 'HOMME',
                            child: Text('Homme'),
                          ),
                          DropdownMenuItem(
                            value: 'FEMME',
                            child: Text('Femme'),
                          ),
                        ],
                        onChanged: (v) => sexe = v,
                        decoration: _deco(
                          'Sexe',
                          Icons.wc,
                        ).copyWith(prefixIcon: null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: age,
                        decoration: _deco('Âge', Icons.cake_outlined),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) return null;
                          return int.tryParse(v!.trim()) == null
                              ? 'Nombre invalide'
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: poste,
                  decoration: _deco('Poste', Icons.work_outline),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(ctx, null),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Annuler'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          Navigator.pop(
                            ctx,
                            _ContactFormResult(
                              id: initial?.id,
                              nom: nom.text.trim(),
                              prenom: prenom.text.trim(),
                              tel: tel.text.trim(),
                              whatsapp: whatsapp.text.trim(),
                              email: email.text.trim(),
                              age: (age.text.trim().isEmpty)
                                  ? null
                                  : int.parse(age.text.trim()),
                              sexe: sexe,
                              poste: poste.text.trim(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save, size: 16),
                        label: const Text('Enregistrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
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
    },
  );
}

class _ContactFormResult {
  final int? id;
  final String nom, prenom;
  final String? tel, whatsapp, email, sexe, poste;
  final int? age;

  _ContactFormResult({
    this.id,
    required this.nom,
    required this.prenom,
    this.tel,
    this.whatsapp,
    this.email,
    this.sexe,
    this.poste,
    this.age,
  });
}

// ============================================================================
// CONTACT TILE — same design, adds a tiny 3-dots menu for Edit/Delete
// ============================================================================
class _ContactTile extends StatefulWidget {
  final ContactLite c;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _ContactTile(this.c, {this.onEdit, this.onDelete});

  @override
  State<_ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<_ContactTile> {
  bool _expanded = false;

  ContactLite get c => widget.c;

  bool get hasTel => (c.tel ?? '').trim().isNotEmpty;
  bool get hasMail => (c.email ?? '').trim().isNotEmpty;

  String get _name {
    final name = (c.fullName.isNotEmpty ? c.fullName : (c.nom ?? '-')).trim();
    return name.isEmpty ? '-' : name;
  }

  Widget _chip(String text, {Color? color}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    margin: const EdgeInsets.only(left: 10),
    decoration: BoxDecoration(
      color: (color ?? AppColors.primary).withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: (color ?? AppColors.primary).withOpacity(0.25)),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color ?? AppColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    ),
  );

  Widget _infoRow(
    IconData icon,
    String label,
    String? value, {
    VoidCallback? onTap,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $v',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _call() {
    if (!hasTel) return;
    Get.snackbar('Appeler', c.tel!, snackPosition: SnackPosition.BOTTOM);
  }

  void _email() {
    if (!hasMail) return;
    Get.snackbar('Courriel', c.email!, snackPosition: SnackPosition.BOTTOM);
  }

  void _whatsapp() {
    if (!hasTel) return;
    Get.snackbar('WhatsApp', c.tel!, snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_expanded ? 0.07 : 0.04),
              blurRadius: _expanded ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ======= COLLAPSED OVERVIEW =======
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            _name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.grey.shade900,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if ((c.poste ?? '').trim().isNotEmpty)
                          _chip(c.poste!.trim(), color: Colors.indigo.shade700),
                      ],
                    ),
                    if (_expanded) ...[
                      const SizedBox(height: 12),
                      Divider(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 8),

                      if ((c.sexe ?? '').trim().isNotEmpty)
                        _infoRow(Icons.person_outline, 'Sexe', c.sexe),
                      if (c.age != null)
                        _infoRow(Icons.cake_outlined, 'Âge', '${c.age}'),
                      _infoRow(
                        Icons.phone,
                        'Téléphone',
                        c.tel,
                        onTap: hasTel ? _call : null,
                      ),
                      _infoRow(
                        Icons.mail,
                        'Email',
                        c.email,
                        onTap: hasMail ? _email : null,
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          if (hasTel)
                            _quickBtn(Icons.call_rounded, 'Appeler', _call),
                          if (hasTel) const SizedBox(width: 8),
                          if (hasTel)
                            _quickBtn(Icons.telegram, 'WhatsApp', _whatsapp),
                          if (hasMail) const SizedBox(width: 8),
                          if (hasMail)
                            _quickBtn(Icons.email_rounded, 'Email', _email),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Right-side: menu + chevron (subtle; design preserved)
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: 'Actions',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (v) {
                if (v == 'edit' && widget.onEdit != null) widget.onEdit!();
                if (v == 'delete' && widget.onDelete != null)
                  widget.onDelete!();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.edit, size: 18),
                    title: Text('Modifier'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                    title: Text('Supprimer'),
                  ),
                ),
              ],
              child: Icon(
                Icons.more_vert,
                size: 20,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              size: 20,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.12)),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}
