import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/dashboard_provider.dart';

/// Minimal Proportional Category Allocation Bar
class CategoryAllocationBar extends StatelessWidget {
  final DashboardSummary summary;

  const CategoryAllocationBar({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = summary.totalSpent;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DISTRIBUSI ALOKASI FINANSIAL',
                style: AppTypography.sectionEyebrow(context),
              ),
              Text(
                '50/30/20 Target',
                style: AppTypography.caption(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Proportional Stacked Segment Bar
          ClipRRect(
            borderRadius: AppRadius.roundedPill,
            child: SizedBox(
              height: 10,
              child: total == 0
                  ? Container(
                      color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                    )
                  : Row(
                      children: [
                        if (summary.needsTotal > 0)
                          Expanded(
                            flex: (summary.needsPercentage * 10).round().clamp(1, 1000),
                            child: Container(color: AppColors.getCategoryColor('Needs', isDark: isDark)),
                          ),
                        if (summary.wantsTotal > 0)
                          Expanded(
                            flex: (summary.wantsPercentage * 10).round().clamp(1, 1000),
                            child: Container(color: AppColors.getCategoryColor('Wants', isDark: isDark)),
                          ),
                        if (summary.simpananTotal > 0)
                          Expanded(
                            flex: (summary.simpananPercentage * 10).round().clamp(1, 1000),
                            child: Container(color: AppColors.getCategoryColor('Simpanan', isDark: isDark)),
                          ),
                        if (summary.investasiTotal > 0)
                          Expanded(
                            flex: (summary.investasiPercentage * 10).round().clamp(1, 1000),
                            child: Container(color: AppColors.getCategoryColor('Investasi', isDark: isDark)),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 4-Column Category Grid
          Row(
            children: [
              _buildCategoryMetric(context, 'Needs', summary.needsTotal, summary.needsPercentage, isDark),
              _buildCategoryMetric(context, 'Wants', summary.wantsTotal, summary.wantsPercentage, isDark),
              _buildCategoryMetric(context, 'Simpanan', summary.simpananTotal, summary.simpananPercentage, isDark),
              _buildCategoryMetric(context, 'Investasi', summary.investasiTotal, summary.investasiPercentage, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryMetric(
    BuildContext context,
    String category,
    num amount,
    double percentage,
    bool isDark,
  ) {
    final color = AppColors.getCategoryColor(category, isDark: isDark);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                category,
                style: AppTypography.caption(context).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: AppTypography.amount(context, fontSize: 13),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: AppTypography.caption(context).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
