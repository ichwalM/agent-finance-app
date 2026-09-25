import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, text }

/// Editorial Button with intentional tactile feedback and zero AI-gradient gimmicks
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        fg = isDark ? AppColors.darkBackground : AppColors.lightSurface;
        break;
      case AppButtonVariant.secondary:
        bg = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        border = BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder);
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        border = BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder);
        break;
      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = isDark ? AppColors.accentDark : AppColors.accentLight;
        break;
    }

    final buttonChild = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: AppTypography.body(context).copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: 48,
      child: Material(
        color: onPressed == null ? bg.withValues(alpha: 0.4) : bg,
        borderRadius: AppRadius.roundedMd,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedMd,
          side: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          splashColor: fg.withValues(alpha: 0.08),
          highlightColor: fg.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Center(child: buttonChild),
          ),
        ),
      ),
    );
  }
}
