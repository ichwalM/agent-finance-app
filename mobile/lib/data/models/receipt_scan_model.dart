import 'transaction_model.dart';

/// Scanned Receipt Model from AI Vision extraction
class ReceiptScanModel {
  final String tanggal;
  final num nominal;
  final String kategori;
  final String subKategori;
  final String deskripsi;
  final String? imageUrl;
  final String? imageKey;

  const ReceiptScanModel({
    required this.tanggal,
    required this.nominal,
    required this.kategori,
    required this.subKategori,
    required this.deskripsi,
    this.imageUrl,
    this.imageKey,
  });

  factory ReceiptScanModel.fromJson(Map<String, dynamic> json) {
    return ReceiptScanModel(
      tanggal: json['tanggal'] as String? ?? '',
      nominal: json['nominal'] is num
          ? json['nominal'] as num
          : num.tryParse('${json['nominal']}') ?? 0,
      kategori: json['kategori'] as String? ?? 'Needs',
      subKategori: json['sub_kategori'] as String? ?? 'Makan & Minum',
      deskripsi: json['deskripsi'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      imageKey: json['image_key'] as String?,
    );
  }

  /// Converts scanned result to transaction model for saving
  TransactionModel toTransaction() {
    return TransactionModel(
      tanggal: tanggal,
      kategori: kategori,
      subKategori: subKategori,
      deskripsi: deskripsi,
      nominal: nominal,
    );
  }
}
