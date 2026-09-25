import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/receipt_scan_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared_widgets/app_button.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../widgets/amount_input.dart';

/// Editorial Sheet for Fast Adding, Editing, or Confirming Scanned Receipts
class AddTransactionSheet extends ConsumerStatefulWidget {
  final TransactionModel? initialTransaction;
  final ReceiptScanModel? scannedReceipt;

  const AddTransactionSheet({
    super.key,
    this.initialTransaction,
    this.scannedReceipt,
  });

  static Future<void> show(
    BuildContext context, {
    TransactionModel? initialTransaction,
    ReceiptScanModel? scannedReceipt,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: AddTransactionSheet(
          initialTransaction: initialTransaction,
          scannedReceipt: scannedReceipt,
        ),
      ),
    );
  }

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _descController;
  late String _selectedCategory;
  late String _selectedSubCategory;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialTransaction != null) {
      final t = widget.initialTransaction!;
      _amountController = TextEditingController(
        text: NumberFormat('#,###', 'id_ID').format(t.nominal),
      );
      _descController = TextEditingController(text: t.deskripsi);
      _selectedCategory = t.kategori;
      _selectedSubCategory = t.subKategori;
      _selectedDate = DateFormatter.parseApiDate(t.tanggal) ?? DateTime.now();
    } else if (widget.scannedReceipt != null) {
      final scan = widget.scannedReceipt!;
      _amountController = TextEditingController(
        text: scan.nominal > 0
            ? NumberFormat('#,###', 'id_ID').format(scan.nominal)
            : '',
      );
      _descController = TextEditingController(text: scan.deskripsi);
      _selectedCategory = AppCategories.all.contains(scan.kategori)
          ? scan.kategori
          : 'Needs';
      final validSubs = AppCategories.subCategoriesFor(_selectedCategory);
      _selectedSubCategory = validSubs.contains(scan.subKategori)
          ? scan.subKategori
          : validSubs.first;
      _selectedDate = DateFormatter.parseApiDate(scan.tanggal) ?? DateTime.now();
    } else {
      _amountController = TextEditingController();
      _descController = TextEditingController();
      _selectedCategory = 'Needs';
      _selectedSubCategory = AppCategories.subCategoriesFor('Needs').first;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      final subs = AppCategories.subCategoriesFor(category);
      if (!subs.contains(_selectedSubCategory)) {
        _selectedSubCategory = subs.first;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.accentDark,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : ColorScheme.light(
                    primary: AppColors.accentLight,
                    surface: AppColors.lightSurface,
                    onSurface: AppColors.lightTextPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    final nominal = CurrencyFormatter.parseDigits(_amountController.text);
    if (nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal harus lebih dari 0'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final transaction = TransactionModel(
        row: widget.initialTransaction?.row,
        tanggal: DateFormatter.toApiDate(_selectedDate),
        kategori: _selectedCategory,
        subKategori: _selectedSubCategory,
        deskripsi: _descController.text.trim(),
        nominal: nominal,
      );

      final notifier = ref.read(transactionsProvider.notifier);
      if (widget.initialTransaction != null && widget.initialTransaction!.row != null) {
        await notifier.updateTransaction(widget.initialTransaction!.row!, transaction);
      } else {
        await notifier.addTransaction(transaction);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initialTransaction != null
                  ? 'Transaksi berhasil diperbarui'
                  : 'Transaksi berhasil disimpan ke Google Sheets',
              style: AppTypography.body(context).copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.positive,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan transaksi: $e'),
            backgroundColor: AppColors.negative,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.initialTransaction != null;
    final isFromScan = widget.scannedReceipt != null;
    final subCategories = AppCategories.subCategoriesFor(_selectedCategory);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing
                      ? 'Edit Transaksi'
                      : isFromScan
                          ? 'Konfirmasi Struk AI'
                          : 'Catat Transaksi',
                  style: AppTypography.h2(context),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ],
            ),
          ),
          const Divider(),

          // Scrollable Form Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Receipt Banner if from scan
                  if (isFromScan) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight.withValues(alpha: 0.08),
                        borderRadius: AppRadius.roundedSm,
                        border: Border.all(
                          color: (isDark ? AppColors.accentDark : AppColors.accentLight)
                              .withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: isDark ? AppColors.accentDark : AppColors.accentLight,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'Hasil scan struk berhasil diisi otomatis. Periksa dan simpan ke Google Sheets.',
                              style: AppTypography.caption(context).copyWith(
                                color: isDark ? AppColors.accentDark : AppColors.accentLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 1. Amount Input (Visual focal point)
                  AmountInput(
                    controller: _amountController,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 2. Category Selector (4 Pillars)
                  Text(
                    'KATEGORI UTAMA',
                    style: AppTypography.sectionEyebrow(context),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: AppCategories.all.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      final catColor = AppColors.getCategoryColor(cat, isDark: isDark);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: InkWell(
                            onTap: () => _onCategoryChanged(cat),
                            borderRadius: AppRadius.roundedSm,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 9.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? catColor.withValues(alpha: isDark ? 0.2 : 0.12)
                                    : (isDark
                                        ? AppColors.darkSurfaceSubtle
                                        : AppColors.lightSurfaceSubtle),
                                borderRadius: AppRadius.roundedSm,
                                border: Border.all(
                                  color: isSelected
                                      ? catColor
                                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    AppCategories.getCategoryIcon(cat),
                                    size: 16,
                                    color: isSelected
                                        ? catColor
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat,
                                    style: AppTypography.caption(context).copyWith(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? catColor
                                          : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 3. Sub-Category Chips
                  Text(
                    'SUB-KATEGORI ($_selectedCategory)',
                    style: AppTypography.sectionEyebrow(context),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: subCategories.map((sub) {
                      final isSelected = _selectedSubCategory == sub;
                      final catColor =
                          AppColors.getCategoryColor(_selectedCategory, isDark: isDark);
                      return ChoiceChip(
                        label: Text(
                          sub,
                          style: AppTypography.caption(context).copyWith(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedSubCategory = sub);
                        },
                        selectedColor: catColor.withValues(alpha: isDark ? 0.3 : 0.15),
                        backgroundColor:
                            isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                        side: BorderSide(
                          color: isSelected
                              ? catColor
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedSm,
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 4. Date Picker
                  Text(
                    'TANGGAL TRANSAKSI',
                    style: AppTypography.sectionEyebrow(context),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: AppRadius.roundedSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                        borderRadius: AppRadius.roundedSm,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            DateFormatter.formatFull(_selectedDate),
                            style: AppTypography.body(context).copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormatter.relativeLabel(DateFormatter.toApiDate(_selectedDate)),
                            style: AppTypography.caption(context).copyWith(
                              color: isDark ? AppColors.accentDark : AppColors.accentLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 5. Description / Merchant Note
                  Text(
                    'DESKRIPSI / MERCHANT',
                    style: AppTypography.sectionEyebrow(context),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _descController,
                    style: AppTypography.body(context),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Kopi Tuku, Grab, Makan Siang...',
                      hintStyle: AppTypography.bodyMuted(context),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 12.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.roundedSm,
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.roundedSm,
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.roundedSm,
                        borderSide: BorderSide(
                          color: isDark ? AppColors.accentDark : AppColors.accentLight,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Save Button
                  AppButton(
                    label: isEditing
                        ? 'Simpan Perubahan'
                        : isFromScan
                            ? 'Konfirmasi & Simpan Transaksi'
                            : 'Simpan Transaksi',
                    icon: Icons.check_rounded,
                    isLoading: _isSaving,
                    width: double.infinity,
                    onPressed: _isSaving ? null : _saveTransaction,
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
