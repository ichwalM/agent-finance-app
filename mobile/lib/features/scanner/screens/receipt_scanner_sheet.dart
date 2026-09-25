import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/global_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../add_transaction/screens/add_transaction_sheet.dart';

/// Editorial Bottom Sheet for AI Receipt Scanning
class ReceiptScannerSheet extends ConsumerStatefulWidget {
  const ReceiptScannerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ReceiptScannerSheet(),
    );
  }

  @override
  ConsumerState<ReceiptScannerSheet> createState() => _ReceiptScannerSheetState();
}

class _ReceiptScannerSheetState extends ConsumerState<ReceiptScannerSheet> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _pickAndScan(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isProcessing = true;
        _errorMessage = null;
      });

      final bytes = await pickedFile.readAsBytes();
      final filename = pickedFile.name.isEmpty ? 'receipt.jpg' : pickedFile.name;

      final apiService = ref.read(apiServiceProvider);
      final scanResult = await apiService.scanReceipt(bytes, filename);

      if (mounted) {
        // Pop scanner sheet first
        Navigator.pop(context);

        // Open AddTransactionSheet with extracted data
        AddTransactionSheet.show(
          context,
          scannedReceipt: scanResult,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
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
          // Drag handle
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI RECEIPT SCANNER',
                    style: AppTypography.sectionEyebrow(context).copyWith(
                      color: isDark ? AppColors.accentDark : AppColors.accentLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pindai Struk Belanja',
                    style: AppTypography.h2(context),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          if (_isProcessing) ...[
            // Processing state
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.accentDark : AppColors.accentLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Menganalisis struk dengan Vision AI...',
                      style: AppTypography.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Menyimpan gambar ke MinIO & mengekstrak rincian',
                      style: AppTypography.caption(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 20,
                      color: isDark ? AppColors.negativeDark : AppColors.negative,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.caption(context).copyWith(
                          color: isDark ? AppColors.negativeDark : AppColors.negative,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Text(
              'Pilih metode pengambilan struk:',
              style: AppTypography.bodyMuted(context),
            ),
            const SizedBox(height: AppSpacing.md),

            // Camera Option
            InkWell(
              onTap: () => _pickAndScan(ImageSource.camera),
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
                        Icons.camera_alt_outlined,
                        size: 22,
                        color: isDark ? AppColors.accentDark : AppColors.accentLight,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kamera Foto',
                            style: AppTypography.body(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Foto struk fisik langsung dengan kamera',
                            style: AppTypography.caption(context),
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

            // Gallery Option
            InkWell(
              onTap: () => _pickAndScan(ImageSource.gallery),
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
                        Icons.photo_library_outlined,
                        size: 22,
                        color: isDark ? AppColors.accentDark : AppColors.accentLight,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih dari Galeri',
                            style: AppTypography.body(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Unggah gambar atau screenshot bukti transfer',
                            style: AppTypography.caption(context),
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

            const SizedBox(height: AppSpacing.lg),

            Text(
              'Catatan: Gambar disimpan ke MinIO cloud storage server Anda dan diproses secara aman oleh Gemini Vision.',
              style: AppTypography.caption(context).copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
