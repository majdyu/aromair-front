import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_erp_aromair/data/models/equipe.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:front_erp_aromair/viewmodel/admin/interventions/intervention_detail_controller.dart';
import 'package:front_erp_aromair/view/screens/admin/interventions/work_todo_dialog.dart';

class InterventionDetailScreen extends StatelessWidget {
  final int interventionId;
  const InterventionDetailScreen({super.key, required this.interventionId});

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
  String _fmtMoney(num? v) =>
      v == null ? '-' : NumberFormat("#,##0.###", "fr_FR").format(v);

  @override
  Widget build(BuildContext context) {
    final tag = 'inter_$interventionId';

    return GetX<InterventionDetailController>(
      init: Get.put(InterventionDetailController(interventionId), tag: tag),
      tag: tag,
      builder: (c) {
        final d = c.detail.value;

        if (d != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!c.isEditingRemark.value) {
              final incoming = (d.remarque ?? '').trim();
              if (c.remarkCtrl.text != incoming) c.remarkCtrl.text = incoming;
            }
            if (!c.isEditingPay.value) {
              final payStr = d.payement == null ? '' : d.payement!.toString();
              if (c.payCtrl.text != payStr) c.payCtrl.text = payStr;
            }
            c.hydrateBasicFormIfIdle();
          });
        }

        return AromaScaffold(
          title: "Détails de l'Intervention",
          body: Container(
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: c.isLoading.value
                  ? _buildLoadingState()
                  : c.error.value != null
                  ? _buildErrorState(c)
                  : d == null
                  ? _buildEmptyState()
                  : SingleChildScrollView(child: _buildContent(context, d, c)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            "Chargement des détails...",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(InterventionDetailController c) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "Erreur de chargement",
              style: TextStyle(
                fontSize: 26,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                c.error.value!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: c.fetch,
                icon: const Icon(Icons.refresh, size: 22),
                label: const Text(
                  "Réessayer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
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
        padding: const EdgeInsets.all(40),
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.construction_outlined,
                color: Colors.grey.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Aucune donnée disponible",
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Vérifiez l'ID de l'intervention ou contactez le support.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic d,
    InterventionDetailController c,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        _buildHeader(d),
        const SizedBox(height: 36),

        // Main content - two columns layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Basic info and remarks
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildInfoCard(
                    "Informations de base",
                    Icons.info_outline_rounded,
                    Obx(
                      () => c.isEditingBasicInfo.value
                          ? _basicInfoForm(c)
                          : _basicInfoView(d),
                    ),
                    trailing: _buildEditButton(c),
                  ),
                  const SizedBox(height: 24),
                  _remarqueWidget(c),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right column - Actions and payment
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildActionCard("Actions", Icons.settings_rounded, [
                    _buildActionButton(
                      Icons.list_alt_rounded,
                      "Travail à faire",
                      () async {
                        final ok = await showWorkToDoDialog(context, d);
                        if (ok == true) await c.fetch();
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      Icons.photo_library_outlined,
                      "Médias (bientôt)",
                      () {},
                      isSecondary: true,
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      Icons.picture_as_pdf_rounded,
                      d.titreFicheMaintenance ?? "Fiche maintenance",
                      () {},
                      isSecondary: true,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _paymentWidget(c),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 36),

        // Diffuseurs section
        _buildSectionTitle("Diffuseurs"),
        const SizedBox(height: 20),
        _buildDataTableCard(
          columns: const [
            DataColumn(label: _TableHeader("CAB")),
            DataColumn(label: _TableHeader("Modèle")),
            DataColumn(label: _TableHeader("Type carte")),
            DataColumn(label: _TableHeader("Emplacement")),
          ],
          rows: d.diffuseurs.map<DataRow>((r) {
            return DataRow(
              onSelectChanged: (_) {
                Get.toNamed(
                  AppRoutes.interventionClientDiffuseur,
                  arguments: {
                    'interventionId': d.id,
                    'clientDiffuseurId': r.id,
                  },
                );
              },
              cells: [
                DataCell(Text(r.cab, style: _tableCellStyle)),
                DataCell(Text(r.modeleDiffuseur, style: _tableCellStyle)),
                DataCell(Text(r.typeDiffuseur, style: _tableCellStyle)),
                DataCell(Text(r.emplacement, style: _tableCellStyle)),
              ],
            );
          }).toList(),
        ),

        const SizedBox(height: 36),

        // Alertes section
        _buildSectionTitle("Alertes"),
        const SizedBox(height: 20),
        d.alertes.isEmpty
            ? _buildEmptyStateCard(
                Icons.notifications_off_rounded,
                "Aucune alerte enregistrée",
                "Les alertes liées à cette intervention apparaîtront ici",
              )
            : _buildDataTableCard(
                columns: const [
                  DataColumn(label: _TableHeader("Date")),
                  DataColumn(label: _TableHeader("Problème")),
                  DataColumn(label: _TableHeader("Cause")),
                  DataColumn(label: _TableHeader("État résolution")),
                ],
                rows: d.alertes.map<DataRow>((a) {
                  return DataRow(
                    onSelectChanged: (_) {
                      Get.toNamed(
                        AppRoutes.alerteDetail,
                        arguments: {'alerteId': a.id},
                      );
                    },
                    cells: [
                      DataCell(Text(a.date, style: _tableCellStyle)),
                      DataCell(Text(a.probleme ?? '-', style: _tableCellStyle)),
                      DataCell(Text(a.cause ?? '-', style: _tableCellStyle)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getResolutionColor(
                              a.etatResolution,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getResolutionColor(
                                a.etatResolution,
                              ).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            a.etatResolution,
                            style: TextStyle(
                              color: _getResolutionColor(a.etatResolution),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildHeader(dynamic d) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.construction_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Intervention #${d.id}",
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        "Client: ${d.clientNom}",
                        style: const TextStyle(
                          fontSize: 16,
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
                        color: _statusColor(d.statut).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _statusColor(d.statut).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: _statusColor(d.statut),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _prettyStatut(d.statut),
                            style: TextStyle(
                              color: _statusColor(d.statut),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    IconData icon,
    Widget child, {
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(icon: icon, title: title, trailing: trailing),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(icon: icon, title: title),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDataTableCard({
    required List<DataColumn> columns,
    required List<DataRow> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: const BoxConstraints(minWidth: 800),
            child: DataTable(
              showCheckboxColumn: false,
              columnSpacing: 32,
              headingRowHeight: 64,
              dataRowHeight: 64,
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              dataRowColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.hovered)) {
                  return AppColors.primary.withOpacity(0.03);
                }
                return null;
              }),
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard(IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 40, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 17),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed, {
    bool isSecondary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: isSecondary
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 22),
              label: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 22),
              label: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
    );
  }

  Widget _buildEditButton(InterventionDetailController c) {
    return Obx(() {
      if (c.isEditingBasicInfo.value) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: c.isSavingBasicInfo.value
                  ? null
                  : c.cancelEditBasicInfo,
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Annuler',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: c.isSavingBasicInfo.value ? null : c.submitBasicInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: c.isSavingBasicInfo.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        );
      } else {
        return IconButton(
          tooltip: "Modifier les informations",
          icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 24),
          onPressed: c.startEditBasicInfo,
        );
      }
    });
  }

  Widget _remarqueWidget(InterventionDetailController c) {
    return _buildInfoCard(
      "Remarques",
      Icons.note_alt_rounded,
      _buildEditableField(
        controller: c.remarkCtrl,
        isEditing: c.isEditingRemark.value,
        isSaving: c.isSavingRemark.value,
        onStartEdit: c.startEditRemark,
        onSubmit: c.submitRemark,
        onCancel: () {
          c.remarkCtrl.text = (c.detail.value?.remarque ?? '').trim();
          c.isEditingRemark.value = false;
        },
        hintText: 'Ajouter une remarque...',
        isMultiline: true,
      ),
    );
  }

  Widget _paymentWidget(InterventionDetailController c) {
    return _buildInfoCard(
      "Paiement",
      Icons.payments_rounded,
      _buildEditableField(
        controller: c.payCtrl,
        isEditing: c.isEditingPay.value,
        isSaving: c.isSavingPay.value,
        onStartEdit: c.startEditPay,
        onSubmit: c.submitPay,
        onCancel: () {
          final v = c.detail.value?.payement;
          c.payCtrl.text = v == null ? '' : v.toString();
          c.isEditingPay.value = false;
        },
        hintText: '0.000',
        isMoney: true,
        prefix: 'TND',
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required bool isEditing,
    required bool isSaving,
    required VoidCallback onStartEdit,
    required VoidCallback onSubmit,
    required VoidCallback onCancel,
    required String hintText,
    bool isMultiline = false,
    bool isMoney = false,
    String? prefix,
  }) {
    if (isEditing) {
      return Focus(
        onKey: (node, event) {
          if (event.logicalKey.keyLabel == 'Escape') {
            onCancel();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          autofocus: true,
          minLines: isMultiline ? 4 : 1,
          maxLines: isMultiline ? 6 : 1,
          keyboardType: isMoney
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: isMoney
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]'))]
              : null,
          onSubmitted: (_) => onSubmit(),
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary, width: 2.5),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixText: isMoney ? '$prefix ' : null,
            prefixStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: isSaving ? null : onCancel,
                ),
                isSaving
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.check, size: 22),
                        onPressed: onSubmit,
                      ),
              ],
            ),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: onStartEdit,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.text.trim().isEmpty ? hintText : controller.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.text.trim().isEmpty
                        ? Colors.grey.shade500
                        : Colors.grey.shade800,
                    fontWeight: controller.text.trim().isEmpty
                        ? FontWeight.normal
                        : FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.edit_outlined, size: 22, color: AppColors.primary),
            ],
          ),
        ),
      );
    }
  }

  // Basic Info View
  Widget _basicInfoView(dynamic d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow("Date", _fmtDate(d.date)),
        _infoRow(
          "Dernière intervention",
          d.derniereIntervention != null
              ? _fmtDate(d.derniereIntervention!)
              : "-",
        ),
        _infoRow("Équipe", d.equipeNom),
        _infoRowWidget("Techniciens", _techniciensChips(d.techniciens)),
        _infoRow("Client", d.clientNom),
        _infoRow(
          "Paiement obligatoire",
          d.estPayementObligatoire ? "Oui" : "Non",
        ),
        _infoRow("Montant", "${_fmtMoney(d.payement)} TND"),
      ],
    );
  }

  // Basic Info Form
  Widget _basicInfoForm(InterventionDetailController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledField(
          "Date",
          TextField(
            controller: c.dateBasicCtrl,
            readOnly: true,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'jj/MM/aaaa',
              hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.all(18),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onTap: () async {
              DateTime init = DateTime.now();
              try {
                init = DateFormat(
                  'dd/MM/yyyy',
                ).parseStrict(c.dateBasicCtrl.text);
              } catch (_) {}
              final picked = await showDatePicker(
                context: Get.context!,
                initialDate: init,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                c.dateBasicCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        _labeledField(
          "Équipe",
          Obx(() {
            final items = c.equipes;
            if (items.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Chargement des équipes...",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            return DropdownButtonFormField<Equipe>(
              value: c.selectedEquipe.value,
              items: items
                  .map(
                    (e) => DropdownMenuItem<Equipe>(
                      value: e,
                      child: Text(e.nom, style: const TextStyle(fontSize: 16)),
                    ),
                  )
                  .toList(),
              onChanged: c.onEquipeSelected,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        _labeledField(
          "Techniciens",
          Obx(() {
            final techs =
                c.selectedEquipe.value?.techniciens ??
                (c.techniciensBasicCtrl.text.isNotEmpty
                    ? c.techniciensBasicCtrl.text
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList()
                    : (c.detail.value?.techniciens ?? const <String>[]));
            return _techniciensChips(techs);
          }),
        ),
        const SizedBox(height: 20),
        _labeledField(
          "Client",
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              c.detail.value?.clientNom ?? '-',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _labeledField(
          "Paiement obligatoire",
          Obx(
            () => Switch(
              value: c.payObligatoire.value,
              onChanged: (v) => c.payObligatoire.value = v,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  Widget _labeledField(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: field),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowWidget(String label, Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: widget),
        ],
      ),
    );
  }

  Widget _techniciensChips(List<String> names) {
    if (names.isEmpty) {
      return Text(
        '-',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
      );
    }

    final displayNames = names.length > 5 ? names.take(5).toList() : names;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...displayNames.map((n) {
          final initials = _initials(n);
          return Container(
            constraints: const BoxConstraints(maxWidth: 140),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      n,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        if (names.length > 5)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                '+${names.length - 5}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    var out = '';
    for (final p in parts) {
      out += p[0].toUpperCase();
      if (out.length >= 2) break;
    }
    return out.isEmpty ? '?' : out;
  }

  static Color _statusColor(String s) {
    switch (s) {
      case "TRAITE":
        return const Color(0xFF10B981);
      case "EN_RETARD":
        return const Color(0xFFEF4444);
      case "NON_ACCOMPLIES":
        return const Color(0xFFF59E0B);
      case "EN_COURS":
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color _getResolutionColor(String status) {
    switch (status.toLowerCase()) {
      case "résolu":
        return const Color(0xFF10B981);
      case "en cours":
        return const Color(0xFFF59E0B);
      case "nouveau":
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  static String _prettyStatut(String s) {
    switch (s) {
      case "EN_COURS":
        return "En cours";
      case "TRAITE":
        return "Traité";
      case "EN_RETARD":
        return "En retard";
      case "NON_ACCOMPLIES":
        return "Non accomplies";
      default:
        return s;
    }
  }

  final TextStyle _tableCellStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
  );
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
