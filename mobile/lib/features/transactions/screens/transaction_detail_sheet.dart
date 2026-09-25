import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared_widgets/app_button.dart';
import '../../add_transaction/screens/add_transaction_sheet.dart';
import '../providers/transaction_provider.dart';

/// Editorial Transaction Detail Sheet with Edit and Delete capabilities
class TransactionDetailSheet extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
  });

  static Future<void> show(BuildContext context, TransactionModel transaction) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransactionDetailSheet(transaction: transaction),
    );
  }

  @override
  ConsumerState<TransactionDetailSheet> createState() => _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends ConsumerState<TransactionDetailSheet> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedMd,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
          title: Text(
            'Hapus Transaksi?',
            style: AppTypography.h2(ctx),
          ),
          content: Text(
            'Transaksi "${widget.transaction.deskripsi.isEmpty ? widget.transaction.subKategori : widget.transaction.deskripsi}" senilai ${CurrencyFormatter.format(widget.transaction.nominal)} akan dihapus dari Google Sheets.',
            style: AppTypography.body(ctx).copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Batal',
                style: AppTypography.body(ctx).copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Hapus',
                style: AppTypography.body(ctx).copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.negativeDark : AppColors.negative,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        final row = widget.transaction.row;
        if (row != null) {
          await ref.read(transactionsProvider.notifier).deleteTransaction(row);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Transaksi berhasil dihapus',
                  style: AppTypography.body(context).copyWith(color: Colors.white),
                ),
                backgroundColor: AppColors.lightTextPrimary,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isDeleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: AppColors.negative,
            ),
          );
        }
      }
    }
  }

  void _handleEdit() {
    Navigator.pop(context);
    AddTransactionSheet.show(context, initialTransaction: widget.transaction);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = AppColors.getCategoryColor(widget.transaction.kategori, isDark: isDark);
    final catBg = AppColors.getCategoryBg(widget.transaction.kategori, isDark: isDark);
    final isSavingsOrInvestment = widget.transaction.kategori == 'Simpanan' ||
        widget.transaction.kategori == 'Investasi';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.0,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Category Pill & Row Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: catBg,
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppCategories.getCategoryIcon(widget.transaction.kategori),
                      size: 14,
                      color: catColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.transaction.kategori.toUpperCase(),
                      style: AppTypography.caption(context).copyWith(
                        color: catColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.transaction.row != null)
                Text(
                  'Row #${widget.transaction.row}',
                  style: AppTypography.caption(context).copyWith(
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Prominent Amount
          Text(
            '${isSavingsOrInvestment ? '+' : '-'} ${CurrencyFormatter.format(widget.transaction.nominal)}',
            style: AppTypography.balance(
              context,
              color: isSavingsOrInvestment
                  ? (isDark ? AppColors.positiveDark : AppColors.positive)
                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Description or Sub-Category Title
          Text(
            widget.transaction.deskripsi.isNotEmpty
                ? widget.transaction.deskripsi
                : widget.transaction.subKategori,
            style: AppTypography.h2(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Key Value Metadata Section (Minimalist hairline layout)
          _buildMetaRow(
            context,
            label: 'SUB-KATEGORI',
            value: widget.transaction.subKategori,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildMetaRow(
            context,
            label: 'TANGGAL TRANSAKSI',
            value: DateFormatter.formatFullFromApi(widget.transaction.tanggal),
          ),
          if (widget.transaction.deskripsi.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildMetaRow(
              context,
              label: 'CATATAN',
              value: widget.transaction.deskripsi,
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // Actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: _isDeleting ? null : _handleEdit,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Hapus',
                  icon: Icons.delete_outline_rounded,
                  variant: AppButtonVariant.outline,
                  isLoading: _isDeleting,
                  onPressed: _isDeleting ? null : _handleDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, {required String label, required String value}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: AppTypography.caption(context).copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.body(context).copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
