import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared_widgets/error_state.dart';
import '../../../shared_widgets/skeleton_loader.dart';
import '../../add_transaction/screens/add_transaction_sheet.dart';
import '../../scanner/screens/receipt_scanner_sheet.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/screens/transaction_detail_sheet.dart';
import '../../transactions/widgets/transaction_tile.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/category_allocation_bar.dart';

/// Personal Finance Cockpit (Modern Editorial Dashboard)
class DashboardScreen extends ConsumerWidget {
  final VoidCallback onSeeAllTransactions;

  const DashboardScreen({
    super.key,
    required this.onSeeAllTransactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(transactionsProvider);
    final summary = ref.watch(dashboardSummaryProvider);

    final currentMonthYear = DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COCKPIT FINANSIAL',
              style: AppTypography.sectionEyebrow(context).copyWith(
                color: isDark ? AppColors.accentDark : AppColors.accentLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Ringkasan Arus Kas',
              style: AppTypography.h1(context),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: AppRadius.roundedSm,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.0,
              ),
            ),
            child: Text(
              currentMonthYear,
              style: AppTypography.caption(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(transactionsProvider.notifier).fetchTransactions(),
        color: isDark ? AppColors.accentDark : AppColors.accentLight,
        child: transactionsAsync.when(
          data: (transactions) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // 1. Cockpit Balance Card
                BalanceCard(
                  totalSpent: summary.totalSpent,
                  insight: summary.primaryInsight,
                  onScanReceipt: () => ReceiptScannerSheet.show(context),
                  onAddManual: () => AddTransactionSheet.show(context),
                ),

                const SizedBox(height: AppSpacing.md),

                // 2. Proportional Allocation Bar
                CategoryAllocationBar(summary: summary),

                const SizedBox(height: AppSpacing.lg),

                // 3. Recent Transactions Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AKTIVITAS TERBARU',
                      style: AppTypography.sectionEyebrow(context),
                    ),
                    if (transactions.isNotEmpty)
                      InkWell(
                        onTap: onSeeAllTransactions,
                        borderRadius: AppRadius.roundedSm,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                'Lihat Semua (${transactions.length})',
                                style: AppTypography.caption(context).copyWith(
                                  color: isDark ? AppColors.accentDark : AppColors.accentLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: isDark ? AppColors.accentDark : AppColors.accentLight,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xs),

                // 4. Recent Transactions List
                if (summary.recentTransactions.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 36,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Belum Ada Catatan Transaksi',
                            style: AppTypography.h2(context),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Mulai mencatat pengeluaran atau scan struk belanja Anda.',
                            style: AppTypography.bodyMuted(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: AppRadius.roundedMd,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (int i = 0; i < summary.recentTransactions.length; i++) ...[
                          TransactionTile(
                            transaction: summary.recentTransactions[i],
                            onTap: () => TransactionDetailSheet.show(
                              context,
                              summary.recentTransactions[i],
                            ),
                          ),
                          if (i < summary.recentTransactions.length - 1)
                            const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
              ],
            );
          },
          loading: () => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: const [
              SkeletonLoader(width: double.infinity, height: 190),
              SizedBox(height: AppSpacing.md),
              SkeletonLoader(width: double.infinity, height: 110),
              SizedBox(height: AppSpacing.lg),
              SkeletonLoader(width: 160, height: 18),
              SizedBox(height: AppSpacing.sm),
              SkeletonLoader(width: double.infinity, height: 260),
            ],
          ),
          error: (err, _) => ErrorState(
            message: err.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
            onRetry: () => ref.read(transactionsProvider.notifier).fetchTransactions(),
          ),
        ),
      ),
    );
  }
}
