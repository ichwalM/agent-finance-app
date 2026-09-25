import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:finance_mobile/core/constants/categories.dart';
import 'package:finance_mobile/core/utils/currency_formatter.dart';
import 'package:finance_mobile/core/utils/date_formatter.dart';
import 'package:finance_mobile/data/models/transaction_model.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('CurrencyFormatter Tests', () {
    test('formats Indonesian Rupiah properly', () {
      expect(CurrencyFormatter.format(1250000), 'Rp 1.250.000');
      expect(CurrencyFormatter.format(50000), 'Rp 50.000');
      expect(CurrencyFormatter.format(0), 'Rp 0');
    });

    test('formats compact amounts correctly', () {
      expect(CurrencyFormatter.formatCompact(1500000), 'Rp 1,5 Jt');
      expect(CurrencyFormatter.formatCompact(85000), 'Rp 85 Rb');
    });

    test('parses digits correctly', () {
      expect(CurrencyFormatter.parseDigits('Rp 1.250.000'), 1250000);
      expect(CurrencyFormatter.parseDigits('50.000'), 50000);
      expect(CurrencyFormatter.parseDigits(''), 0);
    });
  });

  group('DateFormatter Tests', () {
    test('formats API date format correctly', () {
      final date = DateTime(2026, 9, 25);
      expect(DateFormatter.toApiDate(date), '2026-09-25');
    });

    test('parses API date string correctly', () {
      final parsed = DateFormatter.parseApiDate('2026-09-25');
      expect(parsed, isNotNull);
      expect(parsed!.year, 2026);
      expect(parsed.month, 9);
      expect(parsed.day, 25);
    });

    test('returns relative labels for today', () {
      final today = DateTime.now();
      final dateStr = DateFormatter.toApiDate(today);
      expect(DateFormatter.relativeLabel(dateStr), 'HARI INI');
    });
  });

  group('Category System Tests', () {
    test('validates category and sub-category pairs strictly', () {
      expect(AppCategories.isValidPair('Needs', 'Makan & Minum'), isTrue);
      expect(AppCategories.isValidPair('Needs', 'Sewa Kost'), isTrue);
      expect(AppCategories.isValidPair('Wants', 'Kopi & Nongkrong'), isTrue);
      expect(AppCategories.isValidPair('Simpanan', 'Dana Darurat'), isTrue);
      expect(AppCategories.isValidPair('Investasi', 'Portofolio Investasi'), isTrue);

      // Invalid pairs
      expect(AppCategories.isValidPair('Needs', 'Kopi & Nongkrong'), isFalse);
      expect(AppCategories.isValidPair('Wants', 'Dana Darurat'), isFalse);
    });
  });

  group('TransactionModel Serialization Tests', () {
    test('serializes and deserializes transaction JSON correctly', () {
      final json = {
        'row': 2,
        'tanggal': '2026-09-25',
        'kategori': 'Needs',
        'sub_kategori': 'Makan & Minum',
        'deskripsi': 'Makan Siang Soto',
        'nominal': 35000,
      };

      final model = TransactionModel.fromJson(json);
      expect(model.row, 2);
      expect(model.tanggal, '2026-09-25');
      expect(model.kategori, 'Needs');
      expect(model.subKategori, 'Makan & Minum');
      expect(model.deskripsi, 'Makan Siang Soto');
      expect(model.nominal, 35000);

      final outputJson = model.toJson();
      expect(outputJson['tanggal'], '2026-09-25');
      expect(outputJson['kategori'], 'Needs');
      expect(outputJson['sub_kategori'], 'Makan & Minum');
      expect(outputJson['deskripsi'], 'Makan Siang Soto');
      expect(outputJson['nominal'], 35000);
    });
  });
}
