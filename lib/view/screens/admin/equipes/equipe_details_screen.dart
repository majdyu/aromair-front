import 'package:flutter/material.dart';
import 'package:front_erp_aromair/viewmodel/admin/equipe/equipe_details_controller.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/data/models/equipe.dart';

class EquipeDetailsScreen extends StatelessWidget {
  const EquipeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(EquipeDetailsController());

    return GetBuilder<EquipeDetailsController>(
      builder: (_) {
        final e = c.equipe.value;

        return AromaScaffold(
          title: e?.nom ?? "Équipe",
          onRefresh: () async {
            final id = c.equipe.value?.id;
            if (id != null) await c.fetch(id);
          },
          body: e == null
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 768;

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        children: [
                          // Hero Header
                          _buildHeroHeader(context, c, e, isMobile),
                          SizedBox(height: isMobile ? 20 : 24),

                          // Stats Cards Row
                          if (!isMobile) _buildStatsRow(e),
                          if (isMobile) _buildStatsColumn(e),
                          SizedBox(height: isMobile ? 20 : 24),

                          // Main Content
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column - Team Info
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildPerformanceCard(e, isMobile),
                                    SizedBox(height: isMobile ? 16 : 20),
                                    _buildTeamLeadCard(context, c, e, isMobile),
                                  ],
                                ),
                              ),

                              if (!isMobile) const SizedBox(width: 20),

                              // Right Column - Members
                              Expanded(
                                flex: 3,
                                child: _buildMembersCard(
                                  context,
                                  c,
                                  e,
                                  isMobile,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildHeroHeader(
    BuildContext context,
    EquipeDetailsController c,
    Equipe e,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          // Team Icon
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.group_work_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          SizedBox(width: isMobile ? 16 : 24),

          // Team Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.nom,
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                if (e.description?.isNotEmpty == true)
                  Text(
                    e.description!,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Actions (Edit)
          Row(
            children: [
              _HeroBadge(text: 'Numéro : #${e.id}'),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Éditer l’équipe',
                child: InkWell(
                  onTap: () => c.openEditEquipeDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Equipe e) {
    final members = e.membres;
    final rp = (e.respectPlanification ?? 0).clamp(0, 100);

    return Row(
      children: [
        // Members Count
        Expanded(
          child: _StatCard(
            icon: Icons.people_alt_rounded,
            value: members.length.toString(),
            label: 'Membres',
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 16),

        // Performance
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up_rounded,
            value: '$rp%',
            label: 'Performance',
            color: _getRespectColor(rp),
          ),
        ),
        const SizedBox(width: 16),

        // Team Lead Status
        Expanded(
          child: _StatCard(
            icon: Icons.verified_user_rounded,
            value: e.chefNom != null ? 'Assigné' : 'En attente',
            label: 'Chef d\'équipe',
            color: e.chefNom != null
                ? const Color(0xFFF59E0B)
                : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsColumn(Equipe e) {
    final members = e.membres;
    final rp = (e.respectPlanification ?? 0).clamp(0, 100);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people_alt_rounded,
                value: members.length.toString(),
                label: 'Membres',
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up_rounded,
                value: '$rp%',
                label: 'Performance',
                color: _getRespectColor(rp),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          icon: Icons.verified_user_rounded,
          value: e.chefNom != null ? 'Assigné' : 'En attente',
          label: 'Chef d\'équipe',
          color: e.chefNom != null
              ? const Color(0xFFF59E0B)
              : const Color(0xFF6B7280),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(Equipe e, bool isMobile) {
    final rp = (e.respectPlanification ?? 0).clamp(0, 100);
    final color = _getRespectColor(rp);

    return AromaCard(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.trending_up_rounded, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Performance",
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Performance Score
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: isMobile ? 120 : 140,
                  height: isMobile ? 120 : 140,
                  child: CircularProgressIndicator(
                    value: rp / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$rp%',
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 32,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      'Score',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Performance Label
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getPerformanceLabel(rp),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLeadCard(
    BuildContext context,
    EquipeDetailsController c,
    Equipe e,
    bool isMobile,
  ) {
    return AromaCard(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Chef d'équipe",
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (e.membres.isNotEmpty)
                TextButton.icon(
                  onPressed: () => c.pickChefFlow(context),
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text("Changer"),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (e.chefNom != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.chefNom!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Responsable d'équipe",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person_off_rounded,
                    size: 32,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Aucun chef assigné",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersCard(
    BuildContext context,
    EquipeDetailsController c,
    Equipe e,
    bool isMobile,
  ) {
    final members = e.membres;

    return AromaCard(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people_alt_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Membres de l'équipe",
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${members.length}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => c.addMembersFlow(context),
                icon: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  "Ajouter",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (members.isEmpty)
            _buildEmptyMembersState()
          else
            _buildMembersGrid(context, c, e, members, isMobile),
        ],
      ),
    );
  }

  Widget _buildMembersGrid(
    BuildContext context,
    EquipeDetailsController c,
    Equipe e,
    List<dynamic> members,
    bool isMobile,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 3 : 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: members.length,
      itemBuilder: (_, index) {
        final m = members[index];
        final isChef = (e.chefNom != null) && (m.nom == e.chefNom);
        return Stack(
          children: [
            // Clickable member card
            InkWell(
              onTap: () => c.consultTechnicien(context, m.id),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar section
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: AppColors.primary.withOpacity(0.6),
                        ),
                      ),
                    ),

                    // Name section
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          m.nom,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Three dots menu positioned inside the card
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  itemBuilder: (context) => [
                    if (!isChef)
                      PopupMenuItem(
                        value: 'chef',
                        height: 48,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.verified_user_rounded,
                                  size: 18,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Définir comme chef',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    PopupMenuItem(
                      value: 'remove',
                      height: 48,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person_remove_alt_1_rounded,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Retirer du groupe',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onSelected: (v) => c.memberMenuAction(context, v, m.id),
                ),
              ),
            ),

            // Chef badge
            if (isChef)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      const Text(
                        'Chef',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyMembersState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            "Aucun membre",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Ajoutez des membres pour commencer",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _getPerformanceLabel(int percentage) {
    if (percentage >= 90) return 'Excellente';
    if (percentage >= 80) return 'Très bonne';
    if (percentage >= 70) return 'Bonne';
    if (percentage >= 60) return 'Satisfaisante';
    return 'À améliorer';
  }
}

class _HeroBadge extends StatelessWidget {
  final String text;
  const _HeroBadge({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _getRespectColor(int percentage) {
  if (percentage >= 80) return const Color(0xFF10B981);
  if (percentage >= 60) return const Color(0xFFF59E0B);
  return const Color(0xFFEF4444);
}
