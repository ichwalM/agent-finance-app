/// Transaction Data Model matching backend schema
class TransactionModel {
  final int? row;
  final String tanggal;
  final String kategori;
  final String subKategori;
  final String deskripsi;
  final num nominal;

  const TransactionModel({
    this.row,
    required this.tanggal,
    required this.kategori,
    required this.subKategori,
    required this.deskripsi,
    required this.nominal,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      row: json['row'] is int ? json['row'] as int : int.tryParse('${json['row']}'),
      tanggal: json['tanggal'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      subKategori: json['sub_kategori'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      nominal: json['nominal'] is num
          ? json['nominal'] as num
          : num.tryParse('${json['nominal']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson({bool includeRow = false}) {
    final map = <String, dynamic>{
      'tanggal': tanggal,
      'kategori': kategori,
      'sub_kategori': subKategori,
      'deskripsi': deskripsi,
      'nominal': nominal,
    };
    if (includeRow && row != null) {
      map['row'] = row;
    }
    return map;
  }

  TransactionModel copyWith({
    int? row,
    String? tanggal,
    String? kategori,
    String? subKategori,
    String? deskripsi,
    num? nominal,
  }) {
    return TransactionModel(
      row: row ?? this.row,
      tanggal: tanggal ?? this.tanggal,
      kategori: kategori ?? this.kategori,
      subKategori: subKategori ?? this.subKategori,
      deskripsi: deskripsi ?? this.deskripsi,
      nominal: nominal ?? this.nominal,
    );
  }
}
