import 'package:flutter/material.dart';
import '../../../core/constants/categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';

/// Scannable, Compact Transaction Item (No heavy card wrapping)
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = AppColors.getCategoryColor(transaction.kategori, isDark: isDark);
    final catBg = AppColors.getCategoryBg(transaction.kategori, isDark: isDark);
    final icon = AppCategories.getCategoryIcon(transaction.kategori);

    final isSavingsOrInvestment =
        transaction.kategori == 'Simpanan' || transaction.kategori == 'Investasi';

    return InkWell(
      onTap: onTap,
      splashColor: catColor.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 11.0),
        child: Row(
          children: [
            // Minimal Category Geometric Icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: catBg,
                borderRadius: AppRadius.roundedSm,
              ),
              child: Icon(icon, size: 18, color: catColor),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Description & Subcategory
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.deskripsi.isEmpty ? transaction.subKategori : transaction.deskripsi,
                    style: AppTypography.body(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        transaction.subKategori,
                        style: AppTypography.caption(context).copyWith(
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        transaction.kategori,
                        style: AppTypography.caption(context).copyWith(
                          color: catColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount Display with Tabular Figures
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isSavingsOrInvestment ? '+' : '-'} ${CurrencyFormatter.format(transaction.nominal)}',
                  style: AppTypography.amount(
                    context,
                    fontSize: 14.5,
                    color: isSavingsOrInvestment
                        ? (isDark ? AppColors.positiveDark : AppColors.positive)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
                if (transaction.row != null)
                  Text(
                    'Baris ${transaction.row}',
                    style: AppTypography.caption(context).copyWith(fontSize: 10),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
