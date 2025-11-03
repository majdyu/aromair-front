import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';
import 'package:front_erp_aromair/viewmodel/admin/equipe/recette_detail_controller.dart';

class RecetteDetailScreen extends StatelessWidget {
  const RecetteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<RecetteDetailController>()
        ? Get.find<RecetteDetailController>()
        : Get.put(RecetteDetailController());
    return Obx(() {
      final d = c.detail.value;
      return AromaScaffold(
        title: 'Détail Recette',
        onRefresh: c.refreshFromServer,
        body: c.isLoading.value && d == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Elegant Period Selector
                  _PeriodSelector(controller: c),
                  const SizedBox(height: 24),

                  // Financial Overview Cards
                  if (d != null) _FinancialOverview(d: d),
                  if (c.isLoading.value) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(minHeight: 2),
                  ],

                  const SizedBox(height: 24),

                  // Lines Section
                  Expanded(
                    child: _LinesSection(
                      lines: d?.lignes ?? [],
                      isLoading: c.isLoading.value,
                    ),
                  ),
                ],
              ),
      );
    });
  }
}

class _PeriodSelector extends StatelessWidget {
  final RecetteDetailController controller;

  const _PeriodSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PÉRIODE DE RAPPORT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.periodeLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => controller.pickPeriode(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'MODIFIER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialOverview extends StatelessWidget {
  final dynamic d;

  const _FinancialOverview({required this.d});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FinancialCard(
                  title: 'Actuelle',
                  amount: d.actuelle,
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.primary,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.divider.withOpacity(0.6),
                      AppColors.divider.withOpacity(1),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinancialCard(
                  title: 'Supposée',
                  amount: d.recetteSuppose,
                  icon: Icons.analytics_rounded,
                  color: AppColors.info,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.info.withOpacity(0.1),
                      AppColors.info.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinancialCard(
                  title: 'Cultivée',
                  amount: d.recetteCultive,
                  icon: Icons.agriculture_rounded,
                  color: AppColors.success,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.08),
                      AppColors.success.withOpacity(0.02),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinancialCard(
                  title: 'Reçue',
                  amount: d.recetteRecu,
                  icon: Icons.download_done_rounded,
                  color: AppColors.success,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.08),
                      AppColors.success.withOpacity(0.02),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- NEW: Show top-level `nature` / `numeroPiece` as chips (no design change) ---
          const SizedBox(height: 12),
          if ((d.nature?.toString().trim().isNotEmpty ?? false) ||
              (d.numeroPiece?.toString().trim().isNotEmpty ?? false))
            _InfoChipsRow(
              nature: d.nature?.toString(),
              numeroPiece: d.numeroPiece?.toString(),
            ),
          // --- END NEW ---
        ],
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final Gradient gradient;

  const _FinancialCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Text(
                  '${amount.toStringAsFixed(3)} TND',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinesSection extends StatelessWidget {
  final List<Map<String, dynamic>> lines;
  final bool isLoading;

  const _LinesSection({required this.lines, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AromaCard(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'DÉTAIL DES RECETTES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (lines.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${lines.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: lines.isEmpty
                  ? _ElegantEmptyState()
                  : _LinesList(items: lines),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinesList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _LinesList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      padding: const EdgeInsets.all(0),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Colors.grey.shade100,
        indent: 20,
        endIndent: 20,
      ),
      itemBuilder: (_, index) {
        final line = items[index];
        return _LineTile(line: line);
      },
    );
  }
}

class _LineTile extends StatelessWidget {
  final Map<String, dynamic> line;

  const _LineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final date = line['date']?.toString() ?? '';
    final client = line['client']?.toString() ?? 'Non spécifié';
    final montantSuppose = (line['montantSuppose'] as num?)?.toDouble() ?? 0.0;
    final montantCultive = (line['montantCultive'] as num?)?.toDouble() ?? 0.0;
    final estRecu = line['estRecu'] as bool? ?? false;
    final transactionId = line['payementTransactionId']?.toString();
    final txId = transactionId == null ? null : int.tryParse(transactionId);

    // --- NEW: extract optional per-line fields (no design change) ---
    final nature = line['nature']?.toString();
    final numeroPiece = line['numeroPiece']?.toString();
    // --- END NEW ---

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and receipt status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (date.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

              // Interactive receipt checkbox
              _ReceiptCheckbox(
                isReceived: estRecu,
                transactionId: transactionId,
                onChanged: (newValue) {
                  Get.find<RecetteDetailController>().updateReceiptStatus(
                    txId!,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Client name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 14,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  client,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // --- NEW: show per-line nature / numeroPiece as chips (no design change) ---
          const SizedBox(height: 8),
          _InfoChipsRow(nature: nature, numeroPiece: numeroPiece),

          // --- END NEW ---
          const SizedBox(height: 16),

          // Amount cards in a row
          Row(
            children: [
              Expanded(
                child: _AmountCard(
                  title: 'Montant Supposé',
                  amount: montantSuppose,
                  icon: Icons.analytics_rounded,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AmountCard(
                  title: 'Montant Cultivé',
                  amount: montantCultive,
                  icon: Icons.agriculture_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Difference indicator
          if (montantCultive > 0 && montantSuppose > 0)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getDifferenceColor(
                  montantCultive,
                  montantSuppose,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getDifferenceColor(
                    montantCultive,
                    montantSuppose,
                  ).withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getDifferenceIcon(montantCultive, montantSuppose),
                    size: 14,
                    color: _getDifferenceColor(montantCultive, montantSuppose),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_calculateDifferencePercentage(montantCultive, montantSuppose)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getDifferenceColor(
                        montantCultive,
                        montantSuppose,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getDifferenceText(montantCultive, montantSuppose),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDifferenceColor(
                        montantCultive,
                        montantSuppose,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (transactionId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_rounded,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ID: $transactionId',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
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

  Color _getDifferenceColor(double cultive, double suppose) {
    if (suppose == 0) return AppColors.info;
    final percentage = (cultive / suppose) * 100;
    if (percentage >= 100) return AppColors.success;
    if (percentage >= 80) return AppColors.warning;
    return AppColors.danger;
  }

  IconData _getDifferenceIcon(double cultive, double suppose) {
    if (suppose == 0) return Icons.info_rounded;
    final percentage = (cultive / suppose) * 100;
    if (percentage >= 100) return Icons.trending_up_rounded;
    if (percentage >= 80) return Icons.trending_flat_rounded;
    return Icons.trending_down_rounded;
  }

  String _getDifferenceText(double cultive, double suppose) {
    if (suppose == 0) return 'vs prévision';
    final percentage = (cultive / suppose) * 100;
    if (percentage >= 100) return 'objectif atteint';
    if (percentage >= 80) return 'proche de l\'objectif';
    return 'en dessous de l\'objectif';
  }

  String _calculateDifferencePercentage(double cultive, double suppose) {
    if (suppose == 0) return '100';
    final percentage = (cultive / suppose) * 100;
    return percentage.toStringAsFixed(1);
  }
}

class _ReceiptCheckbox extends StatefulWidget {
  final bool isReceived;
  final String? transactionId;
  final Function(bool) onChanged;

  const _ReceiptCheckbox({
    required this.isReceived,
    required this.transactionId,
    required this.onChanged,
  });

  @override
  State<_ReceiptCheckbox> createState() => _ReceiptCheckboxState();
}

class _ReceiptCheckboxState extends State<_ReceiptCheckbox> {
  late bool _isReceived;

  @override
  void initState() {
    super.initState();
    _isReceived = widget.isReceived;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isReceived = !_isReceived;
        });
        widget.onChanged(_isReceived);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isReceived
              ? AppColors.success.withOpacity(0.1)
              : AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isReceived ? AppColors.success : AppColors.warning,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom checkbox
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: _isReceived ? AppColors.success : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _isReceived ? AppColors.success : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: _isReceived
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              _isReceived ? 'Reçue' : 'En attente',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isReceived ? AppColors.success : AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _AmountCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${amount.toStringAsFixed(3)} TND',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElegantEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune Recette',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune recette trouvée pour la période sélectionnée',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =================== NEW: tiny reusable chips (no design change) ===================

class _InfoChipsRow extends StatelessWidget {
  final String? nature;
  final String? numeroPiece;

  const _InfoChipsRow({this.nature, this.numeroPiece});

  bool _has(String? s) =>
      s != null && s.trim().isNotEmpty && s.trim().toLowerCase() != 'null';

  @override
  Widget build(BuildContext context) {
    final showNature = _has(nature);
    final showNumero = _has(numeroPiece);

    if (!showNature && !showNumero) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (showNature)
          _InfoChip(
            label: 'Nature',
            value: nature!.trim(),
            icon: Icons.category_rounded,
            color: AppColors.primary,
          ),
        if (showNumero)
          _InfoChip(
            label: 'N° Pièce',
            value: numeroPiece!.trim(),
            icon: Icons.confirmation_number_rounded,
            color: AppColors.info,
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color.withOpacity(0.9),
            ),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
