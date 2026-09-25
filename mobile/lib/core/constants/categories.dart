import 'package:flutter/material.dart';

/// Categories and strict sub-category definitions matching backend validation
class AppCategories {
  AppCategories._();

  static const String needs = 'Needs';
  static const String wants = 'Wants';
  static const String simpanan = 'Simpanan';
  static const String investasi = 'Investasi';

  static const List<String> allCategories = [
    needs,
    wants,
    simpanan,
    investasi,
  ];

  static List<String> get all => allCategories;

  static const Map<String, List<String>> categorySubcategories = {
    needs: [
      'Makan & Minum',
      'Transport & Bensin',
      'Sewa Kost',
      'Internet & Kuota',
    ],
    wants: [
      'Kopi & Jajan',
      'Kopi & Nongkrong',
      'Jajan & Hiburan',
    ],
    simpanan: [
      'Dana Darurat',
    ],
    investasi: [
      'Portofolio Investasi',
      'RDPU / Saham / Emas',
    ],
  };

  /// Returns valid sub-categories for a category
  static List<String> getSubcategories(String category) {
    return categorySubcategories[category] ?? [];
  }

  /// Alias for getSubcategories
  static List<String> subCategoriesFor(String category) => getSubcategories(category);

  /// Get icon representation for category
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case needs:
        return Icons.shopping_basket_outlined;
      case wants:
        return Icons.coffee_outlined;
      case simpanan:
        return Icons.savings_outlined;
      case investasi:
        return Icons.trending_up_rounded;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  /// Validate if category & sub-category pair matches backend rules
  static bool isValidPair(String category, String subCategory) {
    final allowed = categorySubcategories[category];
    if (allowed == null) return false;
    return allowed.contains(subCategory);
  }
}
