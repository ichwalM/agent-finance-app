import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/providers/global_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared_widgets/app_button.dart';

/// Settings & Configuration Screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isCheckingHealth = false;
  bool? _isServerOnline;
  String? _healthStatusMessage;

  @override
  void initState() {
    super.initState();
    _checkServerHealth();
  }

  Future<void> _checkServerHealth() async {
    setState(() {
      _isCheckingHealth = true;
      _healthStatusMessage = null;
    });

    final apiService = ref.read(apiServiceProvider);
    final isOnline = await apiService.checkHealth();

    if (mounted) {
      setState(() {
        _isCheckingHealth = false;
        _isServerOnline = isOnline;
        _healthStatusMessage = isOnline ? 'Terhubung normal (200 OK)' : 'Tidak dapat terhubung';
      });
    }
  }

  Future<void> _editBaseUrl() async {
    final storage = ref.read(localStorageServiceProvider);
    final controller = TextEditingController(text: storage.getBaseUrl());

    final updated = await showDialog<String>(
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
            'Ubah Alamat Server API',
            style: AppTypography.h2(ctx),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan URL endpoint REST API server Anda:',
                style: AppTypography.bodyMuted(ctx),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller,
                style: AppTypography.body(ctx),
                decoration: InputDecoration(
                  hintText: 'https://finance.walldev.my.id',
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.roundedSm,
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: AppTypography.body(ctx).copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(
                'Simpan',
                style: AppTypography.body(ctx).copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.accentDark : AppColors.accentLight,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (updated != null && updated.isNotEmpty && mounted) {
      await storage.setBaseUrl(updated);
      ref.read(apiServiceProvider).updateBaseUrl(updated);
      await _checkServerHealth();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alamat server berhasil diperbarui'),
            backgroundColor: AppColors.positive,
          ),
        );
      }
    }
  }

  Future<void> _resetDefaultUrl() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setBaseUrl(ApiEndpoints.defaultBaseUrl);
    ref.read(apiServiceProvider).updateBaseUrl(ApiEndpoints.defaultBaseUrl);
    await _checkServerHealth();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat server direset ke default'),
          backgroundColor: AppColors.positive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeModeProvider);
    final storage = ref.watch(localStorageServiceProvider);
    final currentBaseUrl = storage.getBaseUrl();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KONFIGURASI SISTEM',
              style: AppTypography.sectionEyebrow(context).copyWith(
                color: isDark ? AppColors.accentDark : AppColors.accentLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Pengaturan',
              style: AppTypography.h1(context),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // 1. Server Connection Status Card
          Text(
            'KONEKSI BACKEND & CLOUD',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'API GATEWAY STATUS',
                      style: AppTypography.caption(context).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    if (_isCheckingHealth)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.accentDark : AppColors.accentLight,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (_isServerOnline == true
                                  ? (isDark ? AppColors.positiveDark : AppColors.positive)
                                  : (isDark ? AppColors.negativeDark : AppColors.negative))
                              .withValues(alpha: 0.12),
                          borderRadius: AppRadius.roundedPill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _isServerOnline == true
                                    ? (isDark ? AppColors.positiveDark : AppColors.positive)
                                    : (isDark ? AppColors.negativeDark : AppColors.negative),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isServerOnline == true ? 'Online' : 'Offline',
                              style: AppTypography.caption(context).copyWith(
                                color: _isServerOnline == true
                                    ? (isDark ? AppColors.positiveDark : AppColors.positive)
                                    : (isDark ? AppColors.negativeDark : AppColors.negative),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  currentBaseUrl,
                  style: AppTypography.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                if (_healthStatusMessage != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _healthStatusMessage!,
                    style: AppTypography.caption(context).copyWith(
                      color: _isServerOnline == true
                          ? (isDark ? AppColors.positiveDark : AppColors.positive)
                          : (isDark ? AppColors.negativeDark : AppColors.negative),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Ubah URL',
                        icon: Icons.edit_outlined,
                        variant: AppButtonVariant.secondary,
                        onPressed: _editBaseUrl,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: 'Tes Ping',
                        icon: Icons.refresh_rounded,
                        variant: AppButtonVariant.outline,
                        isLoading: _isCheckingHealth,
                        onPressed: _checkServerHealth,
                      ),
                    ),
                  ],
                ),
                if (currentBaseUrl != ApiEndpoints.defaultBaseUrl) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetDefaultUrl,
                      child: Text(
                        'Reset ke Default URL',
                        style: AppTypography.caption(context).copyWith(
                          color: isDark ? AppColors.accentDark : AppColors.accentLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 2. Appearance Theme Selector
          Text(
            'TAMPILAN & TEMA',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Tema Antarmuka',
                  style: AppTypography.body(context).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _buildThemeOption(
                      context,
                      label: 'Sistem',
                      mode: ThemeMode.system,
                      selected: currentThemeMode == ThemeMode.system,
                      icon: Icons.brightness_auto_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildThemeOption(
                      context,
                      label: 'Terang',
                      mode: ThemeMode.light,
                      selected: currentThemeMode == ThemeMode.light,
                      icon: Icons.light_mode_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildThemeOption(
                      context,
                      label: 'Gelap',
                      mode: ThemeMode.dark,
                      selected: currentThemeMode == ThemeMode.dark,
                      icon: Icons.dark_mode_outlined,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 3. Architecture & Infrastructure
          Text(
            'ARSITEKTUR & INTEGRASI',
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
                _buildInfoTile(
                  context,
                  title: 'Database & Spreadsheet',
                  value: 'Google Sheets API v4',
                  subtitle: 'Ledger transaksi terintegrasi langsung',
                  icon: Icons.table_chart_outlined,
                  isDark: isDark,
                ),
                const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                _buildInfoTile(
                  context,
                  title: 'Cloud Object Storage',
                  value: 'MinIO (S3 Compatible)',
                  subtitle: 'Penyimpanan bukti struk belanja',
                  icon: Icons.cloud_done_outlined,
                  isDark: isDark,
                ),
                const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                _buildInfoTile(
                  context,
                  title: 'AI Vision Engine',
                  value: 'Gemini 2.5 Flash',
                  subtitle: 'OCR struk dan kategorisasi otomatis',
                  icon: Icons.auto_awesome_outlined,
                  isDark: isDark,
                ),
                const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                _buildInfoTile(
                  context,
                  title: 'Backend Gateway',
                  value: 'Node.js Express + Docker Compose',
                  subtitle: 'Deploy pada port 3400 (Cloudflare Tunnel)',
                  icon: Icons.dns_outlined,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // App Version & Signature
          Center(
            child: Column(
              children: [
                Text(
                  'FINANCE MOBILE v1.0.0',
                  style: AppTypography.sectionEyebrow(context).copyWith(fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dirancang dengan Modern Editorial Finance UI',
                  style: AppTypography.caption(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required ThemeMode mode,
    required bool selected,
    required IconData icon,
    required bool isDark,
  }) {
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(themeModeProvider.notifier).setTheme(mode);
        },
        borderRadius: AppRadius.roundedSm,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: isDark ? 0.2 : 0.1)
                : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
            borderRadius: AppRadius.roundedSm,
            border: Border.all(
              color: selected
                  ? accent
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? accent
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.caption(context).copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? accent
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
              borderRadius: AppRadius.roundedSm,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption(context),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: AppTypography.caption(context).copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
