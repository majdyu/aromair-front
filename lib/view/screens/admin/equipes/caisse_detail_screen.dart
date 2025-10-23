import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/screens/admin/equipes/add_transaction_dialog.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_card.dart';
import 'package:front_erp_aromair/viewmodel/admin/equipe/caisse_detail_controller.dart';

class CaisseDetailScreen extends StatelessWidget {
  const CaisseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CaisseDetailController());

    return Obx(() {
      final d = c.detail.value;
      return AromaScaffold(
        title: 'Détail Caisse',
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final saved = await Get.dialog<bool>(
              AddTransactionDialog(userId: c.technicienId!),
              barrierDismissible: false,
            );
            if (saved == true) {
              c.refreshFromServer();
            }
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Transaction',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
        onRefresh: c.refreshFromServer,
        body: c.isLoading.value && d == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _PeriodSelector(controller: c),
                  const SizedBox(height: 24),

                  if (d != null) _FinancialOverview(d: d),
                  if (c.isLoading.value) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(minHeight: 2),
                  ],

                  const SizedBox(height: 24),

                  // Transactions Section
                  Expanded(
                    child: _TransactionsSection(
                      transactions: d?.transactions ?? [],
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
  final CaisseDetailController controller;

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
      child: Row(
        children: [
          Expanded(
            child: _FinancialCard(
              title: 'Solde Actuel',
              amount: d.actuelle,
              icon: Icons.account_balance_wallet_rounded,
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
              title: 'Entrées',
              amount: d.totalEntree,
              icon: Icons.arrow_circle_up_rounded,
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
              title: 'Dépenses',
              amount: d.totalDepense,
              icon: Icons.arrow_circle_down_rounded,
              color: AppColors.danger,
              gradient: LinearGradient(
                colors: [
                  AppColors.danger.withOpacity(0.08),
                  AppColors.danger.withOpacity(0.02),
                ],
              ),
            ),
          ),
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

class _TransactionsSection extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final bool isLoading;

  const _TransactionsSection({
    required this.transactions,
    required this.isLoading,
  });

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
                    'HISTORIQUE DES TRANSACTIONS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (transactions.isNotEmpty)
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
                        '${transactions.length}',
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
              child: transactions.isEmpty
                  ? _ElegantEmptyState()
                  : _TransactionList(items: transactions),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _TransactionList({required this.items});

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
        final transaction = items[index];
        return _TransactionTile(transaction: transaction);
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final date = transaction['date']?.toString() ?? '';
    final type = _getTransactionType(transaction);
    final amount = _getTransactionAmount(transaction);
    final description = _getTransactionDescription(transaction);
    final isPositive = _isPositiveTransaction(transaction, type, amount);

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
          // Header row with date and amount
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
              if (amount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isPositive ? '+' : '-'}${amount.abs().toStringAsFixed(3)} TND',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isPositive ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Transaction details
          if (type != null || description != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getTypeColor(type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTypeIcon(type),
                    size: 16,
                    color: _getTypeColor(type),
                  ),
                ),
                const SizedBox(width: 12),

                // Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (type != null)
                        Text(
                          _formatType(type),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      if (description != null)
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Additional fields (if any)
          if (_hasAdditionalFields(transaction)) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _buildAdditionalFields(transaction),
            ),
          ],
        ],
      ),
    );
  }

  String? _getTransactionType(Map<String, dynamic> t) {
    return t['typeTransaction']?.toString() ?? // <-- NEW (your field)
        t['type']?.toString() ??
        t['categorie']?.toString() ??
        t['category']?.toString();
  }

  String? _getTransactionDescription(Map<String, dynamic> t) {
    return t['designation']?.toString() ??
        t['description']?.toString() ??
        t['libelle']?.toString() ??
        t['label']?.toString() ??
        t['note']?.toString();
  }

  double? _getTransactionAmount(Map<String, dynamic> transaction) {
    // Extract amount from common field names
    final amount =
        transaction['montant'] ??
        transaction['amount'] ??
        transaction['valeur'] ??
        transaction['value'];
    return amount is num ? amount.toDouble() : null;
  }

  bool _isPositiveTransaction(
    Map<String, dynamic> transaction,
    String? type,
    double? amount,
  ) {
    if (amount == null) return true;

    // Check if the amount is already negative (from database)
    if (amount < 0) {
      return false;
    }

    // Check transaction type
    final typeStr = type?.toLowerCase() ?? '';

    // Negative transaction types
    final negativeTypes = [
      'depense',
      'dépense',
      'expense',
      'sortie',
      'debit',
      'withdrawal',
    ];

    // Positive transaction types
    final positiveTypes = [
      'entree',
      'entrée',
      'income',
      'revenue',
      'deposit',
      'credit',
    ];

    // If type explicitly indicates negative, return false
    if (negativeTypes.contains(typeStr)) {
      return false;
    }

    // If type explicitly indicates positive, return true
    if (positiveTypes.contains(typeStr)) {
      return true;
    }

    // Default: positive if amount is positive
    return amount >= 0;
  }

  Color _getTypeColor(String? type) {
    if (type == null) return AppColors.primary;

    final lowerType = type.toLowerCase();
    if (lowerType.contains('entree') ||
        lowerType.contains('income') ||
        lowerType.contains('revenue') ||
        lowerType.contains('credit')) {
      return AppColors.success;
    } else if (lowerType.contains('depense') ||
        lowerType.contains('expense') ||
        lowerType.contains('sortie') ||
        lowerType.contains('debit')) {
      return AppColors.danger;
    } else if (lowerType.contains('transfert') ||
        lowerType.contains('transfer')) {
      return AppColors.info;
    }
    return AppColors.primary;
  }

  IconData _getTypeIcon(String? type) {
    if (type == null) return Icons.receipt_rounded;

    final lowerType = type.toLowerCase();
    if (lowerType.contains('entree') ||
        lowerType.contains('income') ||
        lowerType.contains('credit')) {
      return Icons.arrow_circle_down_rounded;
    } else if (lowerType.contains('depense') ||
        lowerType.contains('expense') ||
        lowerType.contains('debit')) {
      return Icons.arrow_circle_up_rounded;
    } else if (lowerType.contains('transfert')) {
      return Icons.swap_horiz_rounded;
    } else if (lowerType.contains('salaire') || lowerType.contains('salary')) {
      return Icons.work_rounded;
    } else if (lowerType.contains('achat') || lowerType.contains('purchase')) {
      return Icons.shopping_cart_rounded;
    }
    return Icons.receipt_rounded;
  }

  String _formatType(String type) {
    // Convert to title case and remove underscores
    return type
        .replaceAll('_', ' ')
        .replaceAllMapped(
          RegExp(r'\b\w'),
          (match) => match.group(0)!.toUpperCase(),
        );
  }

  bool _hasAdditionalFields(Map<String, dynamic> transaction) {
    final excludedKeys = {
      'date',
      'type',
      'categorie',
      'category',
      'montant',
      'amount',
      'valeur',
      'value',
      'description',
      'libelle',
      'label',
      'note',
    };
    return transaction.keys.any((key) => !excludedKeys.contains(key));
  }

  List<Widget> _buildAdditionalFields(Map<String, dynamic> transaction) {
    final excludedKeys = {
      'date',
      'type',
      'categorie',
      'category',
      'montant',
      'amount',
      'valeur',
      'value',
      'description',
      'libelle',
      'label',
      'note',
    };

    return transaction.entries
        .where(
          (entry) => !excludedKeys.contains(entry.key) && entry.value != null,
        )
        .map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_formatKey(entry.key)}: ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        })
        .toList();
  }

  String _formatKey(String key) {
    final words = key.replaceAllMapped(
      RegExp(r'^[a-z]|[A-Z]'),
      (Match m) =>
          m[0] == m[0]!.toLowerCase() ? m[0]!.toUpperCase() : ' ${m[0]}',
    );
    return words.trim();
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
                Icons.inventory_2_rounded,
                size: 48,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune Transaction',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune transaction trouvée pour la période sélectionnée',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
