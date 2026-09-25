import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_state.dart';
import '../../../shared_widgets/skeleton_loader.dart';
import '../../add_transaction/screens/add_transaction_sheet.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

/// Editorial Financial Analytics & 50/30/20 Rule Benchmark
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(transactionsProvider);
    final summary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ANALISIS KEUANGAN',
              style: AppTypography.sectionEyebrow(context).copyWith(
                color: isDark ? AppColors.accentDark : AppColors.accentLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Distribusi & Evaluasi',
              style: AppTypography.h1(context),
            ),
          ],
        ),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return EmptyState(
              title: 'Belum Ada Data Finansial',
              message: 'Tambahkan transaksi untuk melihat analisis rasio 50/30/20 dan rincian sub-kategori.',
              actionLabel: '+ Catat Transaksi',
              onAction: () => AddTransactionSheet.show(context),
            );
          }

          final subCatRankings = _calculateSubCategoryRankings(transactions, summary.totalSpent);
          final avgPerTransaction =
              transactions.isEmpty ? 0 : (summary.totalSpent / transactions.length);

          return RefreshIndicator(
            onRefresh: () => ref.read(transactionsProvider.notifier).fetchTransactions(),
            color: isDark ? AppColors.accentDark : AppColors.accentLight,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // 1. Overall Summary Metric Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        title: 'TOTAL PENGELUARAN',
                        value: CurrencyFormatter.formatCompact(summary.totalSpent),
                        subtitle: '${transactions.length} transaksi tercatat',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        title: 'RATA-RATA TRANSAKSI',
                        value: CurrencyFormatter.formatCompact(avgPerTransaction),
                        subtitle: 'Per entri pengeluaran',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // 2. 50/30/20 Rule Benchmark Audit
                Text(
                  'EVALUASI METODE 50/30/20',
                  style: AppTypography.sectionEyebrow(context),
                ),
                const SizedBox(height: AppSpacing.xs),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildBenchmarkBar(
                        context,
                        label: 'Needs (Kebutuhan)',
                        actualPct: summary.needsPercentage,
                        targetPct: 50.0,
                        amount: summary.needsTotal,
                        category: 'Needs',
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(),
                      const SizedBox(height: AppSpacing.md),
                      _buildBenchmarkBar(
                        context,
                        label: 'Wants (Keinginan)',
                        actualPct: summary.wantsPercentage,
                        targetPct: 30.0,
                        amount: summary.wantsTotal,
                        category: 'Wants',
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(),
                      const SizedBox(height: AppSpacing.md),
                      _buildBenchmarkBar(
                        context,
                        label: 'Simpanan & Investasi',
                        actualPct: summary.simpananPercentage + summary.investasiPercentage,
                        targetPct: 20.0,
                        amount: summary.simpananTotal + summary.investasiTotal,
                        category: 'Simpanan',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 3. Sub-Category Breakdown Ranking
                Text(
                  'RANKING PENGELUARAN SUB-KATEGORI',
                  style: AppTypography.sectionEyebrow(context),
                ),
                const SizedBox(height: AppSpacing.xs),

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
                      for (int i = 0; i < subCatRankings.length; i++) ...[
                        _buildSubCategoryRow(context, subCatRankings[i], i + 1, isDark),
                        if (i < subCatRankings.length - 1)
                          const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const [
            SkeletonLoader(width: double.infinity, height: 90),
            SizedBox(height: AppSpacing.md),
            SkeletonLoader(width: double.infinity, height: 220),
            SizedBox(height: AppSpacing.md),
            SkeletonLoader(width: double.infinity, height: 250),
          ],
        ),
        error: (err, _) => ErrorState(
          message: err.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
          onRetry: () => ref.read(transactionsProvider.notifier).fetchTransactions(),
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption(context).copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.amount(context, fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption(context).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkBar(
    BuildContext context, {
    required String label,
    required double actualPct,
    required double targetPct,
    required num amount,
    required String category,
    required bool isDark,
  }) {
    final catColor = AppColors.getCategoryColor(category, isDark: isDark);
    final isOverLimit = actualPct > targetPct + 5;
    final isUnderTarget = actualPct < targetPct - 5 && category == 'Simpanan';

    final statusText = isOverLimit
        ? 'Melebihi Target'
        : isUnderTarget
            ? 'Perlu Ditingkatkan'
            : 'Sesuai Benchmark';

    final statusColor = isOverLimit
        ? (isDark ? AppColors.warningDark : AppColors.warning)
        : (isDark ? AppColors.positiveDark : AppColors.positive);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.body(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
            Text(
              CurrencyFormatter.format(amount),
              style: AppTypography.amount(context, fontSize: 13.5),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Progress Bar vs Target Marker
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                borderRadius: AppRadius.roundedPill,
              ),
            ),
            FractionallySizedBox(
              widthFactor: (actualPct / 100.0).clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: catColor,
                  borderRadius: AppRadius.roundedPill,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktual: ${actualPct.toStringAsFixed(1)}% (Target: ${targetPct.toStringAsFixed(0)}%)',
              style: AppTypography.caption(context).copyWith(fontSize: 11),
            ),
            Text(
              statusText,
              style: AppTypography.caption(context).copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubCategoryRow(
    BuildContext context,
    _SubCatRanking item,
    int rank,
    bool isDark,
  ) {
    final catColor = AppColors.getCategoryColor(item.kategori, isDark: isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '#$rank',
                style: AppTypography.caption(context).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subKategori,
                      style: AppTypography.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      item.kategori,
                      style: AppTypography.caption(context).copyWith(
                        color: catColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(item.total),
                    style: AppTypography.amount(context, fontSize: 13.5),
                  ),
                  Text(
                    '${item.percentage.toStringAsFixed(1)}%',
                    style: AppTypography.caption(context).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Subtle progress bar
          ClipRRect(
            borderRadius: AppRadius.roundedPill,
            child: LinearProgressIndicator(
              value: (item.percentage / 100.0).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(catColor),
            ),
          ),
        ],
      ),
    );
  }

  List<_SubCatRanking> _calculateSubCategoryRankings(
    List<TransactionModel> transactions,
    num totalSpent,
  ) {
    final Map<String, _SubCatRanking> map = {};

    for (final t in transactions) {
      final key = '${t.kategori}::${t.subKategori}';
      if (!map.containsKey(key)) {
        map[key] = _SubCatRanking(
          kategori: t.kategori,
          subKategori: t.subKategori,
          total: t.nominal,
          percentage: 0,
        );
      } else {
        final existing = map[key]!;
        map[key] = _SubCatRanking(
          kategori: existing.kategori,
          subKategori: existing.subKategori,
          total: existing.total + t.nominal,
          percentage: 0,
        );
      }
    }

    final list = map.values.map((item) {
      final pct = totalSpent > 0 ? (item.total / totalSpent) * 100 : 0.0;
      return _SubCatRanking(
        kategori: item.kategori,
        subKategori: item.subKategori,
        total: item.total,
        percentage: pct,
      );
    }).toList();

    list.sort((a, b) => b.total.compareTo(a.total));
    return list;
  }
}

class _SubCatRanking {
  final String kategori;
  final String subKategori;
  final num total;
  final double percentage;

  const _SubCatRanking({
    required this.kategori,
    required this.subKategori,
    required this.total,
    required this.percentage,
  });
}
