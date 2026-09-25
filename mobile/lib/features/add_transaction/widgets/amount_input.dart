import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';

/// Formatter for thousands separator in Indonesian Rupiah
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final number = int.tryParse(cleanText) ?? 0;
    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Focused, Large Numeric Amount Input with quick addition chips
class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<num>? onAmountChanged;
  final FocusNode? focusNode;

  const AmountInput({
    super.key,
    required this.controller,
    this.onAmountChanged,
    this.focusNode,
  });

  void _addAmount(int addition) {
    final current = CurrencyFormatter.parseDigits(controller.text);
    final updated = current + addition;
    final formatted = NumberFormat('#,###', 'id_ID').format(updated);
    controller.text = formatted;
    onAmountChanged?.call(updated);
  }

  void _clear() {
    controller.clear();
    onAmountChanged?.call(0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'NOMINAL (IDR)',
          style: AppTypography.sectionEyebrow(context),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Large Editorial Input Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Rp',
                style: AppTypography.balance(context).copyWith(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  style: AppTypography.balance(context).copyWith(
                    fontSize: 30.0,
                    letterSpacing: -0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTypography.balance(context).copyWith(
                      fontSize: 30.0,
                      color: (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                          .withValues(alpha: 0.4),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  onChanged: (val) {
                    final amount = CurrencyFormatter.parseDigits(val);
                    onAmountChanged?.call(amount);
                  },
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: _clear,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // Quick Addition Chips (+10k, +20k, +50k, +100k)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickChip(context, '+10rb', 10000),
              _buildQuickChip(context, '+25rb', 25000),
              _buildQuickChip(context, '+50rb', 50000),
              _buildQuickChip(context, '+100rb', 100000),
              _buildQuickChip(context, '+500rb', 500000),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChip(BuildContext context, String label, int amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: InkWell(
        onTap: () => _addAmount(amount),
        borderRadius: AppRadius.roundedSm,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadius.roundedSm,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.caption(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
