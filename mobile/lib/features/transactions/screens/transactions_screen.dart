import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_state.dart';
import '../../../shared_widgets/skeleton_loader.dart';
import '../../add_transaction/screens/add_transaction_sheet.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_sheet.dart';

/// Transactions Screen with Search, Category Filter, and Date Grouping
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(transactionsProvider);
    final activeFilter = ref.watch(categoryFilterProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Transaksi',
          style: AppTypography.h1(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Tambah Transaksi',
            onPressed: () => AddTransactionSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Box
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: AppRadius.roundedSm,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.body(context).copyWith(fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Cari transaksi atau nominal...',
                        hintStyle: AppTypography.bodyMuted(context).copyWith(fontSize: 13.5),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        ref.read(searchQueryProvider.notifier).setQuery(val);
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).setQuery('');
                      },
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ),
            ),
          ),

          // 2. Category Filter Pills
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6.0),
              children: [
                _buildFilterChip(context, 'Semua', activeFilter == 'Semua'),
                ...AppCategories.all.map((cat) {
                  return _buildFilterChip(context, cat, activeFilter == cat);
                }),
              ],
            ),
          ),

          const Divider(),

          // 3. Transactions List / Content
          Expanded(
            child: transactionsAsync.when(
              data: (_) {
                if (filteredTransactions.isEmpty) {
                  return EmptyState(
                    title: 'Tidak Ada Transaksi',
                    message: activeFilter != 'Semua' || _searchController.text.isNotEmpty
                        ? 'Tidak ada transaksi yang cocok dengan kriteria filter.'
                        : 'Belum ada data transaksi yang tercatat di Google Sheets.',
                    actionLabel: '+ Catat Transaksi',
                    onAction: () => AddTransactionSheet.show(context),
                  );
                }

                // Group transactions by date
                final grouped = _groupByDate(filteredTransactions);

                return RefreshIndicator(
                  onRefresh: () => ref.read(transactionsProvider.notifier).fetchTransactions(),
                  color: isDark ? AppColors.accentDark : AppColors.accentLight,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final group = grouped[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Section Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              AppSpacing.md,
                              AppSpacing.md,
                              AppSpacing.xs,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  group.dateLabel,
                                  style: AppTypography.sectionEyebrow(context),
                                ),
                                Text(
                                  CurrencyFormatter.format(group.subtotal),
                                  style: AppTypography.caption(context).copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.5,
                                    fontFeatures: AppTypography.tabularFigures,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Transaction Items in this date group
                          ...group.items.map((item) {
                            return Column(
                              children: [
                                TransactionTile(
                                  transaction: item,
                                  onTap: () => TransactionDetailSheet.show(context, item),
                                ),
                                const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                              ],
                            );
                          }),
                        ],
                      );
                    },
                  ),
                );
              },
              loading: () => _buildLoadingList(context),
              error: (err, _) => ErrorState(
                message: err.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
                onRetry: () => ref.read(transactionsProvider.notifier).fetchTransactions(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String category, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = category == 'Semua'
        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
        : AppColors.getCategoryColor(category, isDark: isDark);

    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: InkWell(
        onTap: () {
          ref.read(categoryFilterProvider.notifier).setFilter(category);
        },
        borderRadius: AppRadius.roundedSm,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: isSelected
                ? (category == 'Semua'
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : catColor.withValues(alpha: isDark ? 0.25 : 0.12))
                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            borderRadius: AppRadius.roundedSm,
            border: Border.all(
              color: isSelected
                  ? catColor
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            category,
            style: AppTypography.caption(context).copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
              color: isSelected
                  ? (category == 'Semua'
                      ? (isDark ? AppColors.darkBackground : AppColors.lightSurface)
                      : catColor)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 8,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SkeletonLoader(width: 40, height: 40),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 140, height: 14),
                    SizedBox(height: 6),
                    SkeletonLoader(width: 80, height: 10),
                  ],
                ),
              ),
              SkeletonLoader(width: 70, height: 14),
            ],
          ),
        );
      },
    );
  }

  List<_DateGroup> _groupByDate(List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> map = {};
    for (final item in transactions) {
      map.putIfAbsent(item.tanggal, () => []).add(item);
    }

    final List<_DateGroup> groups = [];
    for (final entry in map.entries) {
      num subtotal = 0;
      for (final item in entry.value) {
        subtotal += item.nominal;
      }
      groups.add(_DateGroup(
        dateLabel: DateFormatter.relativeLabel(entry.key),
        subtotal: subtotal,
        items: entry.value,
      ));
    }
    return groups;
  }
}

class _DateGroup {
  final String dateLabel;
  final num subtotal;
  final List<TransactionModel> items;

  const _DateGroup({
    required this.dateLabel,
    required this.subtotal,
    required this.items,
  });
}
