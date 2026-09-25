import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/biometric_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared_widgets/app_button.dart';

/// Full-screen Biometric Lock Screen protecting sensitive financial data
class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerBiometricAuth();
    });
  }

  Future<void> _triggerBiometricAuth() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final success = await ref.read(appLockProvider.notifier).authenticateAndUnlock();

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
        if (!success) {
          _errorMessage = 'Verifikasi sidik jari dibatalkan atau gagal.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Biometric Emblem
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.fingerprint_rounded,
                      size: 48,
                      color: isDark ? AppColors.accentDark : AppColors.accentLight,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Eyebrow
                Text(
                  'KEAMANAN FINANSIAL',
                  style: AppTypography.sectionEyebrow(context).copyWith(
                    color: isDark ? AppColors.accentDark : AppColors.accentLight,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // Title
                Text(
                  'Aplikasi Terkunci',
                  style: AppTypography.h1(context),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Description
                Text(
                  'Pindai sidik jari Anda untuk memverifikasi identitas dan membuka data keuangan.',
                  style: AppTypography.bodyMuted(context),
                  textAlign: TextAlign.center,
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.negativeDark : AppColors.negative)
                          .withValues(alpha: 0.1),
                      borderRadius: AppRadius.roundedSm,
                      border: Border.all(
                        color: (isDark ? AppColors.negativeDark : AppColors.negative)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: isDark ? AppColors.negativeDark : AppColors.negative,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.caption(context).copyWith(
                              color: isDark ? AppColors.negativeDark : AppColors.negative,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(flex: 3),

                // Action Button
                AppButton(
                  label: 'Buka dengan Sidik Jari',
                  icon: Icons.fingerprint_rounded,
                  variant: AppButtonVariant.primary,
                  isLoading: _isAuthenticating,
                  onPressed: _triggerBiometricAuth,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
