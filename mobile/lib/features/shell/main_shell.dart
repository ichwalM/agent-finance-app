import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../add_transaction/screens/add_transaction_sheet.dart';
import '../analytics/screens/analytics_screen.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../scanner/screens/receipt_scanner_sheet.dart';
import '../settings/screens/settings_screen.dart';
import '../transactions/screens/transactions_screen.dart';

/// Editorial Main Shell with Minimalist Navigation & Contextual Speed Dial
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  void _showAddOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.sm,
            bottom: MediaQuery.of(ctx).padding.bottom + AppSpacing.lg,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                'TAMBAH TRANSAKSI',
                style: AppTypography.sectionEyebrow(ctx).copyWith(
                  color: isDark ? AppColors.accentDark : AppColors.accentLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pilih Metode Pencatatan',
                style: AppTypography.h2(ctx),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),

              // Option 1: AI Scan Struk
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  ReceiptScannerSheet.show(context);
                },
                borderRadius: AppRadius.roundedMd,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.accentDark : AppColors.accentLight)
                              .withValues(alpha: 0.12),
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Icon(
                          Icons.document_scanner_outlined,
                          size: 22,
                          color: isDark ? AppColors.accentDark : AppColors.accentLight,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Pindai Struk dengan AI',
                                  style: AppTypography.body(ctx).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isDark ? AppColors.accentDark : AppColors.accentLight)
                                        .withValues(alpha: 0.15),
                                    borderRadius: AppRadius.roundedPill,
                                  ),
                                  child: Text(
                                    'VISION',
                                    style: AppTypography.caption(ctx).copyWith(
                                      color: isDark ? AppColors.accentDark : AppColors.accentLight,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Foto struk fisik, OCR otomatis oleh Gemini Vision',
                              style: AppTypography.caption(ctx),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Option 2: Input Manual Cepat
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  AddTransactionSheet.show(context);
                },
                borderRadius: AppRadius.roundedMd,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                              .withValues(alpha: 0.08),
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          size: 22,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catat Manual Cepat',
                              style: AppTypography.body(ctx).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Input nominal, kategori, dan deskripsi secara langsung',
                              style: AppTypography.caption(ctx),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      DashboardScreen(
        onSeeAllTransactions: () => _onTabSelected(1),
      ),
      const TransactionsScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  label: 'Ringkasan',
                  icon: Icons.space_dashboard_outlined,
                  activeIcon: Icons.space_dashboard_rounded,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  label: 'Transaksi',
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  isDark: isDark,
                ),

                // Center Action Trigger
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () => _showAddOptions(context),
                    borderRadius: AppRadius.roundedMd,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 26,
                        color: isDark ? AppColors.darkBackground : AppColors.lightSurface,
                      ),
                    ),
                  ),
                ),

                _buildNavItem(
                  context,
                  index: 2,
                  label: 'Analisis',
                  icon: Icons.pie_chart_outline_rounded,
                  activeIcon: Icons.pie_chart_rounded,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  label: 'Pengaturan',
                  icon: Icons.tune_outlined,
                  activeIcon: Icons.tune_rounded,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final inactiveColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.caption(context).copyWith(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
