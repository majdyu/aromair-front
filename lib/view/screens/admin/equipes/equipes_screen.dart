import 'package:flutter/material.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:front_erp_aromair/viewmodel/admin/equipe/equipe_controller.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/data/models/equipe.dart';

class EquipesScreen extends StatelessWidget {
  const EquipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(EquipeController());

    return AromaScaffold(
      title: "Équipes",
      onRefresh: c.fetch,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: ouvrir un dialog/écran de création d'équipe
        },
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          return Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: AromaCard(
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(isMobile),
                  SizedBox(height: isMobile ? 24 : 32),

                  // Search and Actions
                  _buildSearchAndActions(c, isMobile),
                  SizedBox(height: 24),

                  // Main Content
                  Expanded(child: _buildContent(c, isMobile)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gestion des Équipes",
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Organisez et gérez l'ensemble de vos équipes efficacement",
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndActions(EquipeController c, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: c.searchCtrl,
              decoration: InputDecoration(
                hintText: "Rechercher une équipe...",
                prefixIcon: Container(
                  margin: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                suffixIcon: Obx(() {
                  final hasText = c.search.value.isNotEmpty;
                  return hasText
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => c.searchCtrl.clear(),
                        )
                      : SizedBox.shrink();
                }),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6366F1).withOpacity(0.4),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: c.fetch,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(EquipeController c, bool isMobile) {
    return GetX<EquipeController>(
      builder: (_) {
        if (c.loading) return _LoadingState();
        if (c.erreurMessage.isNotEmpty)
          return _ErrorState(message: c.erreurMessage.value);

        final items = c.filtered;
        if (items.isEmpty)
          return _EmptyState(hasSearch: c.search.value.isNotEmpty);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  Text(
                    "Liste des Équipes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${items.length} équipes",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Scroll Cards
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 8),
                itemCount: items.length,
                itemBuilder: (_, index) => Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: _HorizontalTeamCard(e: items[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HorizontalTeamCard extends StatelessWidget {
  final Equipe e;
  const _HorizontalTeamCard({required this.e});

  void _onCardTap() {
    Get.toNamed(AppRoutes.equipeDetails, arguments: {'equipeId': e.id});
  }

  @override
  Widget build(BuildContext context) {
    final rp = (e.respectPlanification ?? 0).clamp(0, 100);
    final members = e.membres;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _onCardTap,
        child: Container(
          height: 140, // Fixed height for horizontal cards
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 25,
                offset: Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Row(
            children: [
              // Left Side - Team Identity
              Container(
                width: 160,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.group_work_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      e.nom,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Right Side - Team Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 16,
                                  color: _getRespectColor(rp),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Performance",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRespectColor(
                                      rp,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$rp%',
                                    style: TextStyle(
                                      color: _getRespectColor(rp),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  Container(
                                    width: (rp / 100) * 100,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _getRespectColor(rp),
                                          _getRespectColor(rp).withOpacity(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Vertical Divider
                      Container(
                        width: 1,
                        height: 60,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade100,
                              Colors.grey.shade300,
                              Colors.grey.shade100,
                            ],
                          ),
                        ),
                      ),

                      // Team Lead Section
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Chef d'équipe",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.verified_user_rounded,
                                    size: 12,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.chefNom ?? 'Non assigné',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                e.description?.isNotEmpty == true
                                    ? e.description!
                                    : 'Aucune description',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Vertical Divider
                      Container(
                        width: 1,
                        height: 60,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade100,
                              Colors.grey.shade300,
                              Colors.grey.shade100,
                            ],
                          ),
                        ),
                      ),

                      // Members Section
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Membres",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${members.length}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  ...members
                                      .take(4)
                                      .map(
                                        (m) => Padding(
                                          padding: EdgeInsets.only(right: 6),
                                          child: _CompactAvatarInitials(
                                            name: m.nom,
                                          ),
                                        ),
                                      ),
                                  if (members.length > 4)
                                    _CompactMoreBadge(
                                      count: members.length - 4,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactAvatarInitials extends StatelessWidget {
  final String name;
  const _CompactAvatarInitials({required this.name});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1)
      return parts.first.characters.take(2).toString().toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CompactMoreBadge extends StatelessWidget {
  final int count;
  const _CompactMoreBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Color _getRespectColor(int percentage) {
  if (percentage >= 80) return Color(0xFF10B981);
  if (percentage >= 60) return Color(0xFFF59E0B);
  return Color(0xFFEF4444);
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Chargement des équipes...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.danger,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Erreur de chargement",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Get.find<EquipeController>().fetch(),
            icon: Icon(Icons.refresh_rounded),
            label: Text("Réessayer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;

  const _EmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_work_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 16),
          Text(
            hasSearch ? "Aucune équipe trouvée" : "Aucune équipe",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            hasSearch
                ? "Aucun résultat ne correspond à votre recherche"
                : "Commencez par créer votre première équipe",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
